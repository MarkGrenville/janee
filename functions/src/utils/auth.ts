import { Request, Response, NextFunction } from "express";
import * as admin from "firebase-admin";
import { createHash } from "crypto";

export interface AuthenticatedRequest extends Request {
  userId?: string;
  authMethod?: "token" | "apikey";
}

export function hashApiKey(key: string): string {
  return createHash("sha256").update(key).digest("hex");
}

export async function authMiddleware(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  const apiKey = req.headers["x-api-key"] as string | undefined;
  const authHeader = req.headers.authorization;

  if (apiKey) {
    try {
      const keyHash = hashApiKey(apiKey);
      const keyDoc = await admin.firestore().collection("apiKeys").doc(keyHash).get();

      if (!keyDoc.exists) {
        res.status(401).json({ success: false, error: "Invalid API key" });
        return;
      }

      const keyData = keyDoc.data()!;
      req.userId = keyData.userId;
      req.authMethod = "apikey";

      admin.firestore().collection("apiKeys").doc(keyHash).update({
        lastUsedAt: admin.firestore.FieldValue.serverTimestamp(),
      }).catch((err) => console.log("[auth] Failed to update lastUsedAt:", err));

      console.log(`[auth] API key auth for user ${req.userId} (key: ${keyData.keyPrefix}...)`);
      next();
      return;
    } catch (err) {
      console.log("[auth] API key validation error:", err);
      res.status(500).json({ success: false, error: "Auth error" });
      return;
    }
  }

  if (authHeader?.startsWith("Bearer ")) {
    const token = authHeader.split("Bearer ")[1];
    try {
      const decoded = await admin.auth().verifyIdToken(token);
      req.userId = decoded.uid;
      req.authMethod = "token";
      console.log(`[auth] Token auth for user ${req.userId}`);
      next();
      return;
    } catch (err) {
      console.log("[auth] Token verification failed:", err);
      res.status(401).json({ success: false, error: "Invalid token" });
      return;
    }
  }

  res.status(401).json({ success: false, error: "No authentication provided. Use x-api-key header or Bearer token." });
}
