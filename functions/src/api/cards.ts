import { Router } from "express";
import * as admin from "firebase-admin";
import { AuthenticatedRequest } from "../utils/auth";
import { CreateCardRequest, CardDoc, AppDoc, ApiResponse } from "../types";

const router = Router({ mergeParams: true });
const getDb = () => admin.firestore();

function param(val: string | string[] | undefined): string {
  return Array.isArray(val) ? val[0] : val || "";
}

router.post("/", async (req: AuthenticatedRequest, res) => {
  try {
    const appId = param(req.params.appId);
    const userId = req.userId!;

    const appDoc = await getDb().collection("apps").doc(appId).get();
    if (!appDoc.exists) {
      res.status(404).json({ success: false, error: "App not found" } as ApiResponse);
      return;
    }

    if ((appDoc.data() as AppDoc).ownerId !== userId) {
      res.status(403).json({ success: false, error: "Only the app owner can add cards" } as ApiResponse);
      return;
    }

    const cards: CreateCardRequest[] = Array.isArray(req.body) ? req.body : [req.body];

    if (cards.length === 0 || !cards[0].title?.trim()) {
      res.status(400).json({ success: false, error: "At least one card with a title is required" } as ApiResponse);
      return;
    }

    const now = admin.firestore.Timestamp.now();
    const batch = getDb().batch();
    const created: { id: string; title: string }[] = [];

    for (const card of cards) {
      const ref = getDb().collection("apps").doc(appId).collection("cards").doc();
      const cardData: CardDoc = {
        title: card.title.trim(),
        subtitle: card.subtitle?.trim() || "",
        description: card.description?.trim() || "",
        imageUrl: card.imageUrl || "",
        linkUrl: card.linkUrl || "",
        icon: card.icon || "",
        status: "active",
        webhookUrl: card.webhookUrl || "",
        metadata: card.metadata || {},
        createdAt: now,
        availableSince: now,
        createdBy: userId,
      };
      batch.set(ref, cardData);
      created.push({ id: ref.id, title: cardData.title });
    }

    await batch.commit();
    console.log(`[cards] Added ${created.length} card(s) to app ${appId} by user ${userId}`);

    res.status(201).json({ success: true, data: created } as ApiResponse);
  } catch (err) {
    console.log("[cards] Error adding cards:", err);
    res.status(500).json({ success: false, error: "Failed to add cards" } as ApiResponse);
  }
});

router.get("/", async (req: AuthenticatedRequest, res) => {
  try {
    const appId = param(req.params.appId);
    const userId = req.userId!;
    const status = (req.query.status as string) || "active";

    const appDoc = await getDb().collection("apps").doc(appId).get();
    if (!appDoc.exists) {
      res.status(404).json({ success: false, error: "App not found" } as ApiResponse);
      return;
    }

    const appData = appDoc.data() as AppDoc;
    if (!appData.isPublic && appData.ownerId !== userId) {
      const sub = await getDb().collection("users").doc(userId).collection("subscriptions").doc(appId).get();
      if (!sub.exists) {
        res.status(403).json({ success: false, error: "Access denied" } as ApiResponse);
        return;
      }
    }

    const snapshot = await getDb()
      .collection("apps").doc(appId).collection("cards")
      .where("status", "==", status)
      .orderBy("createdAt", "desc")
      .limit(100)
      .get();

    const cards = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));

    console.log(`[cards] Listed ${cards.length} cards from app ${appId}`);
    res.json({ success: true, data: cards } as ApiResponse);
  } catch (err) {
    console.log("[cards] Error listing cards:", err);
    res.status(500).json({ success: false, error: "Failed to list cards" } as ApiResponse);
  }
});

router.get("/undecided", async (req: AuthenticatedRequest, res) => {
  try {
    const appId = param(req.params.appId);
    const userId = req.userId!;

    const cardsSnapshot = await getDb()
      .collection("apps").doc(appId).collection("cards")
      .where("status", "==", "active")
      .orderBy("createdAt", "asc")
      .limit(100)
      .get();

    const decisionsSnapshot = await getDb()
      .collection("users").doc(userId).collection("decisions")
      .where("appId", "==", appId)
      .get();

    const decidedCardIds = new Set(decisionsSnapshot.docs.map((d) => d.data().cardId));

    const undecided = cardsSnapshot.docs
      .filter((doc) => !decidedCardIds.has(doc.id))
      .map((doc) => ({ id: doc.id, ...doc.data() }));

    console.log(`[cards] ${undecided.length} undecided cards for user ${userId} in app ${appId}`);
    res.json({ success: true, data: undecided } as ApiResponse);
  } catch (err) {
    console.log("[cards] Error listing undecided cards:", err);
    res.status(500).json({ success: false, error: "Failed to list undecided cards" } as ApiResponse);
  }
});

router.put("/:cardId", async (req: AuthenticatedRequest, res) => {
  try {
    const appId = param(req.params.appId);
    const cardId = param(req.params.cardId);
    const userId = req.userId!;

    const appDoc = await getDb().collection("apps").doc(appId).get();
    if (!appDoc.exists || (appDoc.data() as AppDoc).ownerId !== userId) {
      res.status(403).json({ success: false, error: "Only the app owner can update cards" } as ApiResponse);
      return;
    }

    const updates: Partial<CardDoc> = {};
    const body = req.body;
    if (body.title !== undefined) updates.title = body.title.trim();
    if (body.subtitle !== undefined) updates.subtitle = body.subtitle.trim();
    if (body.description !== undefined) updates.description = body.description.trim();
    if (body.imageUrl !== undefined) updates.imageUrl = body.imageUrl;
    if (body.linkUrl !== undefined) updates.linkUrl = body.linkUrl;
    if (body.icon !== undefined) updates.icon = body.icon;
    if (body.status !== undefined) updates.status = body.status;
    if (body.webhookUrl !== undefined) updates.webhookUrl = body.webhookUrl;
    if (body.metadata !== undefined) updates.metadata = body.metadata;

    await getDb().collection("apps").doc(appId).collection("cards").doc(cardId).update(updates);
    console.log(`[cards] Updated card ${cardId} in app ${appId}`);

    res.json({ success: true, data: { id: cardId, ...updates } } as ApiResponse);
  } catch (err) {
    console.log("[cards] Error updating card:", err);
    res.status(500).json({ success: false, error: "Failed to update card" } as ApiResponse);
  }
});

export default router;
