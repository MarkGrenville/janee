import { Router } from "express";
import * as admin from "firebase-admin";
import { AuthenticatedRequest } from "../utils/auth";
import { UserDoc, ApiResponse } from "../types";

const router = Router();
const db = admin.firestore();

function param(val: string | string[] | undefined): string {
  return Array.isArray(val) ? val[0] : val || "";
}

router.get("/me", async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId!;
    const doc = await db.collection("users").doc(userId).get();

    if (!doc.exists) {
      res.status(404).json({ success: false, error: "User profile not found" } as ApiResponse);
      return;
    }

    res.json({ success: true, data: { id: doc.id, ...doc.data() } } as ApiResponse);
  } catch (err) {
    console.log("[users] Error getting profile:", err);
    res.status(500).json({ success: false, error: "Failed to get profile" } as ApiResponse);
  }
});

router.put("/me", async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId!;
    const body = req.body;

    const updates: Partial<UserDoc> = {};
    if (body.displayName !== undefined) updates.displayName = body.displayName.trim();
    if (body.bio !== undefined) updates.bio = body.bio.trim();
    if (body.photoURL !== undefined) updates.photoURL = body.photoURL;
    if (body.publicProfile !== undefined) updates.publicProfile = body.publicProfile;
    updates.updatedAt = admin.firestore.Timestamp.now();

    await db.collection("users").doc(userId).update(updates);
    console.log(`[users] Updated profile for user ${userId}`);

    res.json({ success: true, data: updates } as ApiResponse);
  } catch (err) {
    console.log("[users] Error updating profile:", err);
    res.status(500).json({ success: false, error: "Failed to update profile" } as ApiResponse);
  }
});

router.get("/:userId", async (req: AuthenticatedRequest, res) => {
  try {
    const userId = param(req.params.userId);
    const doc = await db.collection("users").doc(userId).get();

    if (!doc.exists) {
      res.status(404).json({ success: false, error: "User not found" } as ApiResponse);
      return;
    }

    const data = doc.data() as UserDoc;

    if (!data.publicProfile && req.userId !== userId) {
      res.json({
        success: true,
        data: { id: doc.id, displayName: data.displayName, photoURL: data.photoURL, publicProfile: false },
      } as ApiResponse);
      return;
    }

    res.json({ success: true, data: { id: doc.id, ...data } } as ApiResponse);
  } catch (err) {
    console.log("[users] Error getting user:", err);
    res.status(500).json({ success: false, error: "Failed to get user" } as ApiResponse);
  }
});

router.post("/friends/:friendId", async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId!;
    const friendId = param(req.params.friendId);

    if (userId === friendId) {
      res.status(400).json({ success: false, error: "Cannot add yourself" } as ApiResponse);
      return;
    }

    const friendDoc = await db.collection("users").doc(friendId).get();
    if (!friendDoc.exists) {
      res.status(404).json({ success: false, error: "User not found" } as ApiResponse);
      return;
    }

    const now = admin.firestore.Timestamp.now();
    const batch = db.batch();

    batch.set(db.collection("users").doc(userId).collection("friends").doc(friendId), {
      status: "pending",
      initiatedBy: userId,
      since: now,
    });

    batch.set(db.collection("users").doc(friendId).collection("friends").doc(userId), {
      status: "pending",
      initiatedBy: userId,
      since: now,
    });

    await batch.commit();
    console.log(`[users] Friend request: ${userId} -> ${friendId}`);

    res.status(201).json({ success: true } as ApiResponse);
  } catch (err) {
    console.log("[users] Error sending friend request:", err);
    res.status(500).json({ success: false, error: "Failed to send friend request" } as ApiResponse);
  }
});

router.put("/friends/:friendId/accept", async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId!;
    const friendId = param(req.params.friendId);
    const now = admin.firestore.Timestamp.now();

    const batch = db.batch();
    batch.update(db.collection("users").doc(userId).collection("friends").doc(friendId), {
      status: "accepted",
      since: now,
    });
    batch.update(db.collection("users").doc(friendId).collection("friends").doc(userId), {
      status: "accepted",
      since: now,
    });
    await batch.commit();

    console.log(`[users] Friend accepted: ${userId} <-> ${friendId}`);
    res.json({ success: true } as ApiResponse);
  } catch (err) {
    console.log("[users] Error accepting friend:", err);
    res.status(500).json({ success: false, error: "Failed to accept friend" } as ApiResponse);
  }
});

export default router;
