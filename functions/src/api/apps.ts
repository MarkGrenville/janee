import { Router } from "express";
import * as admin from "firebase-admin";
import { AuthenticatedRequest } from "../utils/auth";
import { CreateAppRequest, AppDoc, ApiResponse } from "../types";

const router = Router();
const getDb = () => admin.firestore();

function param(val: string | string[] | undefined): string {
  return Array.isArray(val) ? val[0] : val || "";
}

router.post("/", async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId!;
    const body = req.body as CreateAppRequest;

    if (!body.name?.trim()) {
      res.status(400).json({ success: false, error: "name is required" } as ApiResponse);
      return;
    }

    const now = admin.firestore.Timestamp.now();
    const appData: AppDoc = {
      name: body.name.trim(),
      description: body.description?.trim() || "",
      icon: body.icon || "",
      imageUrl: body.imageUrl || "",
      coverColor: body.coverColor || "#D4A853",
      ownerId: userId,
      isPublic: body.isPublic ?? false,
      responseType: body.responseType || "yes_no",
      webhookUrl: body.webhookUrl || "",
      subscriberCount: 0,
      createdAt: now,
      updatedAt: now,
    };

    const docRef = await getDb().collection("apps").add(appData);
    console.log(`[apps] Created app ${docRef.id} by user ${userId}`);

    await getDb().collection("users").doc(userId).collection("subscriptions").doc(docRef.id).set({
      subscribedAt: now,
      notifications: true,
    });

    res.status(201).json({ success: true, data: { id: docRef.id, ...appData } } as ApiResponse);
  } catch (err) {
    console.log("[apps] Error creating app:", err);
    res.status(500).json({ success: false, error: "Failed to create app" } as ApiResponse);
  }
});

router.get("/", async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId!;
    const publicOnly = req.query.public === "true";

    let query: admin.firestore.Query = getDb().collection("apps");

    if (publicOnly) {
      query = query.where("isPublic", "==", true);
    }

    const snapshot = await query.orderBy("createdAt", "desc").limit(50).get();
    const apps = snapshot.docs
      .filter((doc) => {
        const data = doc.data();
        return data.isPublic || data.ownerId === userId;
      })
      .map((doc) => ({ id: doc.id, ...doc.data() }));

    console.log(`[apps] Listed ${apps.length} apps for user ${userId}`);
    res.json({ success: true, data: apps } as ApiResponse);
  } catch (err) {
    console.log("[apps] Error listing apps:", err);
    res.status(500).json({ success: false, error: "Failed to list apps" } as ApiResponse);
  }
});

router.get("/:appId", async (req: AuthenticatedRequest, res) => {
  try {
    const appId = param(req.params.appId);
    const doc = await getDb().collection("apps").doc(appId).get();

    if (!doc.exists) {
      res.status(404).json({ success: false, error: "App not found" } as ApiResponse);
      return;
    }

    const data = doc.data() as AppDoc;
    const userId = req.userId!;
    if (!data.isPublic && data.ownerId !== userId) {
      const sub = await getDb().collection("users").doc(userId).collection("subscriptions").doc(appId).get();
      if (!sub.exists) {
        res.status(403).json({ success: false, error: "Access denied" } as ApiResponse);
        return;
      }
    }

    res.json({ success: true, data: { id: doc.id, ...data } } as ApiResponse);
  } catch (err) {
    console.log("[apps] Error getting app:", err);
    res.status(500).json({ success: false, error: "Failed to get app" } as ApiResponse);
  }
});

router.put("/:appId", async (req: AuthenticatedRequest, res) => {
  try {
    const appId = param(req.params.appId);
    const userId = req.userId!;
    const doc = await getDb().collection("apps").doc(appId).get();

    if (!doc.exists) {
      res.status(404).json({ success: false, error: "App not found" } as ApiResponse);
      return;
    }

    if ((doc.data() as AppDoc).ownerId !== userId) {
      res.status(403).json({ success: false, error: "Only the owner can update this app" } as ApiResponse);
      return;
    }

    const updates: Partial<AppDoc> = {};
    const body = req.body;
    if (body.name !== undefined) updates.name = body.name.trim();
    if (body.description !== undefined) updates.description = body.description.trim();
    if (body.icon !== undefined) updates.icon = body.icon;
    if (body.imageUrl !== undefined) updates.imageUrl = body.imageUrl;
    if (body.coverColor !== undefined) updates.coverColor = body.coverColor;
    if (body.isPublic !== undefined) updates.isPublic = body.isPublic;
    if (body.webhookUrl !== undefined) updates.webhookUrl = body.webhookUrl;
    updates.updatedAt = admin.firestore.Timestamp.now();

    await getDb().collection("apps").doc(appId).update(updates);
    console.log(`[apps] Updated app ${appId} by user ${userId}`);

    res.json({ success: true, data: { id: appId, ...updates } } as ApiResponse);
  } catch (err) {
    console.log("[apps] Error updating app:", err);
    res.status(500).json({ success: false, error: "Failed to update app" } as ApiResponse);
  }
});

router.delete("/:appId", async (req: AuthenticatedRequest, res) => {
  try {
    const appId = param(req.params.appId);
    const userId = req.userId!;
    const doc = await getDb().collection("apps").doc(appId).get();

    if (!doc.exists) {
      res.status(404).json({ success: false, error: "App not found" } as ApiResponse);
      return;
    }

    if ((doc.data() as AppDoc).ownerId !== userId) {
      res.status(403).json({ success: false, error: "Only the owner can delete this app" } as ApiResponse);
      return;
    }

    await getDb().collection("apps").doc(appId).delete();
    console.log(`[apps] Deleted app ${appId} by user ${userId}`);

    res.json({ success: true } as ApiResponse);
  } catch (err) {
    console.log("[apps] Error deleting app:", err);
    res.status(500).json({ success: false, error: "Failed to delete app" } as ApiResponse);
  }
});

router.post("/:appId/subscribe", async (req: AuthenticatedRequest, res) => {
  try {
    const appId = param(req.params.appId);
    const userId = req.userId!;

    const appDoc = await getDb().collection("apps").doc(appId).get();
    if (!appDoc.exists) {
      res.status(404).json({ success: false, error: "App not found" } as ApiResponse);
      return;
    }

    await getDb().collection("users").doc(userId).collection("subscriptions").doc(appId).set({
      subscribedAt: admin.firestore.Timestamp.now(),
      notifications: true,
    });

    await getDb().collection("apps").doc(appId).update({
      subscriberCount: admin.firestore.FieldValue.increment(1),
    });

    console.log(`[apps] User ${userId} subscribed to app ${appId}`);
    res.json({ success: true } as ApiResponse);
  } catch (err) {
    console.log("[apps] Error subscribing:", err);
    res.status(500).json({ success: false, error: "Failed to subscribe" } as ApiResponse);
  }
});

router.delete("/:appId/subscribe", async (req: AuthenticatedRequest, res) => {
  try {
    const appId = param(req.params.appId);
    const userId = req.userId!;

    await getDb().collection("users").doc(userId).collection("subscriptions").doc(appId).delete();

    await getDb().collection("apps").doc(appId).update({
      subscriberCount: admin.firestore.FieldValue.increment(-1),
    });

    console.log(`[apps] User ${userId} unsubscribed from app ${appId}`);
    res.json({ success: true } as ApiResponse);
  } catch (err) {
    console.log("[apps] Error unsubscribing:", err);
    res.status(500).json({ success: false, error: "Failed to unsubscribe" } as ApiResponse);
  }
});

export default router;
