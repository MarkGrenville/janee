import { DecisionDoc } from "../types";

interface WebhookPayload {
  event: "decision.created";
  appId: string;
  cardId: string;
  cardTitle: string;
  decision: string;
  decidedAt: string;
  timeToDecisionMs: number;
  userId: string;
}

export async function fireWebhook(
  webhookUrl: string,
  decision: DecisionDoc,
  userId: string
): Promise<{ status: number; body: unknown } | null> {
  if (!webhookUrl) return null;

  const payload: WebhookPayload = {
    event: "decision.created",
    appId: decision.appId,
    cardId: decision.cardId,
    cardTitle: decision.cardTitle,
    decision: decision.decision,
    decidedAt: decision.decidedAt?.toDate?.()?.toISOString() ?? new Date().toISOString(),
    timeToDecisionMs: decision.timeToDecisionMs,
    userId,
  };

  console.log(`[webhook] Firing webhook to ${webhookUrl} for card ${decision.cardId}`);

  try {
    const response = await fetch(webhookUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
      signal: AbortSignal.timeout(10000),
    });

    const body = await response.text();
    let parsed: unknown;
    try {
      parsed = JSON.parse(body);
    } catch {
      parsed = body;
    }

    console.log(`[webhook] Response: ${response.status}`);
    return { status: response.status, body: parsed };
  } catch (err) {
    console.log(`[webhook] Failed to fire webhook:`, err);
    return null;
  }
}
