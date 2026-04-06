import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import express from "express";
import cors from "cors";
import { authMiddleware } from "./utils/auth";

import appsRouter from "./api/apps";
import cardsRouter from "./api/cards";
import decisionsRouter from "./api/decisions";
import keysRouter from "./api/keys";
import usersRouter from "./api/users";
import seedRouter from "./api/seed";

import { onDecisionCreate } from "./triggers/onDecisionCreate";
import { onUserCreate } from "./triggers/onUserCreate";

admin.initializeApp();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

app.get("/api/health", (_req, res) => {
  console.log("[api] Health check");
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

app.use("/api/seed", seedRouter);

app.use("/api/apps", authMiddleware, appsRouter);
app.use("/api/apps/:appId/cards", authMiddleware, cardsRouter);
app.use("/api/apps/:appId/decisions", authMiddleware, decisionsRouter);
app.use("/api/keys", authMiddleware, keysRouter);
app.use("/api/users", authMiddleware, usersRouter);

app.use("/api/decisions/all", authMiddleware, (req, res) => {
  const decisionsAllRouter = require("./api/decisions").default;
  req.url = "/all";
  decisionsAllRouter(req, res);
});

export const api = functions.https.onRequest(app);

export { onDecisionCreate, onUserCreate };
