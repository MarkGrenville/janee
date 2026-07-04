import { Router } from "express";
import * as admin from "firebase-admin";
import { v4 as uuidv4 } from "uuid";
import { AuthenticatedRequest, hashApiKey } from "../utils/auth";
import { CreateApiKeyRequest, ApiKeyDoc, AppDoc, ApiResponse } from "../types";

const router = Router();
const getDb = () => admin.firestore();

function param(val: string | string[] | undefined): string {
  return Array.isArray(val) ? val[0] : val || "";
}

router.post("/", async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId!;
    const body = req.body as CreateApiKeyRequest;

    if (!body.appId) {
      res.status(400).json({ success: false, error: "appId is required" } as ApiResponse);
      return;
    }

    const appDoc = await getDb().collection("apps").doc(body.appId).get();
    if (!appDoc.exists) {
      res.status(404).json({ success: false, error: "App not found" } as ApiResponse);
      return;
    }
    if ((appDoc.data() as AppDoc).ownerId !== userId) {
      res.status(403).json({ success: false, error: "Only the app owner can create API keys" } as ApiResponse);
      return;
    }

    const rawKey = `jn_${uuidv4().replace(/-/g, "")}`;
    const keyHash = hashApiKey(rawKey);
    const keyPrefix = rawKey.substring(0, 10);

    const keyData: ApiKeyDoc = {
      userId,
      appId: body.appId,
      label: body.label || "Default",
      keyPrefix,
      permissions: body.permissions || ["read", "write"],
      createdAt: admin.firestore.Timestamp.now(),
      lastUsedAt: null,
    };

    await getDb().collection("apiKeys").doc(keyHash).set(keyData);
    console.log(`[keys] Created API key for app ${body.appId} by user ${userId}`);

    res.status(201).json({
      success: true,
      data: {
        key: rawKey,
        keyPrefix,
        label: keyData.label,
        appId: keyData.appId,
        permissions: keyData.permissions,
        note: "Store this key securely — it cannot be retrieved again.",
      },
    } as ApiResponse);
  } catch (err) {
    console.log("[keys] Error creating key:", err);
    res.status(500).json({ success: false, error: "Failed to create API key" } as ApiResponse);
  }
});

router.get("/", async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId!;
    const snapshot = await getDb().collection("apiKeys").where("userId", "==", userId).get();

    const keys = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        keyPrefix: data.keyPrefix,
        label: data.label,
        appId: data.appId,
        permissions: data.permissions,
        createdAt: data.createdAt,
        lastUsedAt: data.lastUsedAt,
      };
    });

    res.json({ success: true, data: keys } as ApiResponse);
  } catch (err) {
    console.log("[keys] Error listing keys:", err);
    res.status(500).json({ success: false, error: "Failed to list keys" } as ApiResponse);
  }
});

router.delete("/:keyId", async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId!;
    const keyId = param(req.params.keyId);

    const keyDoc = await getDb().collection("apiKeys").doc(keyId).get();
    if (!keyDoc.exists || keyDoc.data()?.userId !== userId) {
      res.status(404).json({ success: false, error: "Key not found" } as ApiResponse);
      return;
    }

    await getDb().collection("apiKeys").doc(keyId).delete();
    console.log(`[keys] Deleted API key ${keyId} by user ${userId}`);

    res.json({ success: true } as ApiResponse);
  } catch (err) {
    console.log("[keys] Error deleting key:", err);
    res.status(500).json({ success: false, error: "Failed to delete key" } as ApiResponse);
  }
});

export default router;
