import { Router } from "express";
import jwt from "jsonwebtoken";
import { config } from "../../config";
import { AuditDocumentsService } from "./audit-documents.service";

export const auditDocumentsRouter = Router();
const service = new AuditDocumentsService();

auditDocumentsRouter.get("/documents", async (req, res, next) => {
  try {
    const userId = requireUserId(req.headers.authorization);
    const documents = await service.listDocuments(userId);
    res.json({ success: true, data: documents });
  } catch (err) {
    next(err);
  }
});

auditDocumentsRouter.post("/documents", async (req, res, next) => {
  try {
    const userId = requireUserId(req.headers.authorization);
    const document = await service.uploadDocument(req.body, userId);
    res.status(201).json({ success: true, data: document });
  } catch (err) {
    next(err);
  }
});

function requireUserId(authHeader?: string) {
  if (!authHeader?.startsWith("Bearer ")) {
    throw new Error("Authentication required. Please provide a valid JWT token.");
  }

  try {
    const token = authHeader.slice(7);
    const payload = jwt.verify(token, config.jwtSecret) as {
      userId?: string;
      sub?: string;
    };
    const userId = payload.userId || payload.sub;
    if (!userId) {
      throw new Error("Authentication required. Please provide a valid JWT token.");
    }
    return userId;
  } catch {
    throw new Error("Authentication required. Please provide a valid JWT token.");
  }
}
