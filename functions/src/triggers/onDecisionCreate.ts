import * as functionsV1 from "firebase-functions/v1";
import * as admin from "firebase-admin";
import { DecisionDoc, AppDoc, CardDoc } from "../types";
import { fireWebhook } from "../utils/webhook";

export const onDecisionCreate = functionsV1.firestore
  .document("users/{userId}/decisions/{decisionId}")
  .onCreate(async (snap, context) => {
    const { userId, decisionId } = context.params;
    const decision = snap.data() as DecisionDoc;

    console.log(`[trigger:onDecisionCreate] User ${userId} decided "${decision.decision}" on card ${decision.cardId} (decision: ${decisionId})`);

    try {
      const appDoc = await admin.firestore().collection("apps").doc(decision.appId).get();
      if (!appDoc.exists) {
        console.log(`[trigger:onDecisionCreate] App ${decision.appId} not found, skipping webhook`);
        return;
      }

      const appData = appDoc.data() as AppDoc;

      const cardDoc = await admin.firestore()
        .collection("apps").doc(decision.appId)
        .collection("cards").doc(decision.cardId)
        .get();

      const cardData = cardDoc.exists ? (cardDoc.data() as CardDoc) : null;

      const webhookUrl = cardData?.webhookUrl || appData.webhookUrl;

      if (!webhookUrl) {
        console.log(`[trigger:onDecisionCreate] No webhook configured for app ${decision.appId}`);
        return;
      }

      const result = await fireWebhook(webhookUrl, decision, userId);

      await snap.ref.update({
        webhookFired: true,
        webhookResponse: result ? { status: result.status, body: result.body } : { error: "No response" },
        webhookFiredAt: admin.firestore.Timestamp.now(),
      });

      console.log(`[trigger:onDecisionCreate] Webhook fired for decision ${decisionId}`);
    } catch (err) {
      console.log(`[trigger:onDecisionCreate] Error processing decision ${decisionId}:`, err);
      await snap.ref.update({
        webhookFired: false,
        webhookResponse: { error: String(err) },
      });
    }
  });
