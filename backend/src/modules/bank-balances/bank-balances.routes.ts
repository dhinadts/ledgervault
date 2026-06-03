import { Router } from "express";
import jwt from "jsonwebtoken";
import { config } from "../../config";
import { BankBalancesService } from "./bank-balances.service";

export const bankBalancesRouter = Router();
const service = new BankBalancesService();

bankBalancesRouter.get("/", async (req, res, next) => {
  try {
    const userId = requireUserId(req.headers.authorization);
    const accounts = await service.listBalances(userId);
    res.json({ success: true, data: accounts });
  } catch (err) {
    next(err);
  }
});

bankBalancesRouter.post("/", async (req, res, next) => {
  try {
    const userId = requireUserId(req.headers.authorization);
    const account = await service.createAccount(req.body, userId);
    res.status(201).json({ success: true, data: account });
  } catch (err) {
    next(err);
  }
});

bankBalancesRouter.post("/sync", async (req, res, next) => {
  try {
    const userId = requireUserId(req.headers.authorization);
    const accounts = Array.isArray(req.body.accounts) ? req.body.accounts : [];
    const result = await service.syncAccounts(accounts, userId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

bankBalancesRouter.put("/:id", async (req, res, next) => {
  try {
    const userId = requireUserId(req.headers.authorization);
    const account = await service.updateAccount(req.params.id, req.body, userId);
    res.json({ success: true, data: account });
  } catch (err) {
    next(err);
  }
});

bankBalancesRouter.delete("/:id", async (req, res, next) => {
  try {
    const userId = requireUserId(req.headers.authorization);
    const result = await service.deleteAccount(req.params.id, userId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

function getUserId(authHeader?: string) {
  if (!authHeader?.startsWith("Bearer ")) {
    return undefined;
  }

  try {
    const token = authHeader.slice(7);
    const payload = jwt.verify(token, config.jwtSecret) as {
      userId?: string;
      sub?: string;
    };
    return payload.userId || payload.sub;
  } catch (error) {
    return undefined;
  }
}

function requireUserId(authHeader?: string) {
  const userId = getUserId(authHeader);
  if (!userId) {
    throw new Error("Authentication required. Please provide a valid JWT token.");
  }
  return userId;
}
