import { Router } from "express";
import * as admin from "firebase-admin";
import { AuthenticatedRequest } from "../utils/auth";
import { CreateDecisionRequest, DecisionDoc, CardDoc, ApiResponse } from "../types";

const router = Router({ mergeParams: true });
const db = admin.firestore();

function param(val: string | string[] | undefined): string {
  return Array.isArray(val) ? val[0] : val || "";
}

router.post("/", async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId!;
    const appId = param(req.params.appId);
    const body = req.body as CreateDecisionRequest;

    if (!body.cardId || !body.decision) {
      res.status(400).json({ success: false, error: "cardId and decision are required" } as ApiResponse);
      return;
    }

    if (!["yes", "no", "skip"].includes(body.decision)) {
      res.status(400).json({ success: false, error: "decision must be yes, no, or skip" } as ApiResponse);
      return;
    }

    const cardRef = db.collection("apps").doc(appId).collection("cards").doc(body.cardId);
    const cardDoc = await cardRef.get();

    if (!cardDoc.exists) {
      res.status(404).json({ success: false, error: "Card not found" } as ApiResponse);
      return;
    }

    const cardData = cardDoc.data() as CardDoc;
    const now = admin.firestore.Timestamp.now();

    const timeToDecisionMs = cardData.availableSince
      ? now.toMillis() - cardData.availableSince.toMillis()
      : 0;

    const decisionData: DecisionDoc = {
      appId,
      cardId: body.cardId,
      cardTitle: cardData.title,
      decision: body.decision,
      decidedAt: now,
      availableSince: cardData.availableSince || now,
      timeToDecisionMs,
      webhookFired: false,
      webhookResponse: null,
      webhookFiredAt: null,
    };

    const decisionRef = await db
      .collection("users").doc(userId)
      .collection("decisions")
      .add(decisionData);

    console.log(`[decisions] User ${userId} decided "${body.decision}" on card ${body.cardId} (app: ${appId})`);

    res.status(201).json({
      success: true,
      data: { id: decisionRef.id, ...decisionData },
    } as ApiResponse);
  } catch (err) {
    console.log("[decisions] Error creating decision:", err);
    res.status(500).json({ success: false, error: "Failed to create decision" } as ApiResponse);
  }
});

router.get("/", async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId!;
    const appId = param(req.params.appId);
    const filter = req.query.decision as string | undefined;
    const limitParam = parseInt(req.query.limit as string) || 50;

    let query: admin.firestore.Query = db
      .collection("users").doc(userId)
      .collection("decisions")
      .where("appId", "==", appId);

    if (filter && ["yes", "no", "skip"].includes(filter)) {
      query = query.where("decision", "==", filter);
    }

    const snapshot = await query
      .orderBy("decidedAt", "desc")
      .limit(limitParam)
      .get();

    const decisions = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));

    console.log(`[decisions] Listed ${decisions.length} decisions for user ${userId} in app ${appId}`);
    res.json({ success: true, data: decisions } as ApiResponse);
  } catch (err) {
    console.log("[decisions] Error listing decisions:", err);
    res.status(500).json({ success: false, error: "Failed to list decisions" } as ApiResponse);
  }
});

router.get("/all", async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.userId!;
    const limitParam = parseInt(req.query.limit as string) || 100;

    const snapshot = await db
      .collection("users").doc(userId)
      .collection("decisions")
      .orderBy("decidedAt", "desc")
      .limit(limitParam)
      .get();

    const decisions = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));

    console.log(`[decisions] Listed ${decisions.length} total decisions for user ${userId}`);
    res.json({ success: true, data: decisions } as ApiResponse);
  } catch (err) {
    console.log("[decisions] Error listing all decisions:", err);
    res.status(500).json({ success: false, error: "Failed to list decisions" } as ApiResponse);
  }
});

export default router;
