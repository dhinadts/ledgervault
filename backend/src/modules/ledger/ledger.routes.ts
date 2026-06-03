import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../../config';
import { LedgerService } from './ledger.service';

export const ledgerRouter = Router();
const service = new LedgerService();

ledgerRouter.get('/', async (req, res, next) => {
    try {
        const userId = requireUserId(req.headers.authorization);
        const entries = await service.listEntries(req.query.search?.toString(), userId);
        res.json({ success: true, data: entries });
    } catch (err) {
        next(err);
    }
});

ledgerRouter.post('/entry', async (req, res, next) => {
    try {
        const userId = requireUserId(req.headers.authorization);
        const entry = await service.createEntry({
            ...req.body,
            createdBy: userId,
        });
        res.status(201).json({ success: true, data: entry });
    } catch (err) {
        next(err);
    }
});

ledgerRouter.post('/sync', async (req, res, next) => {
    try {
        const userId = requireUserId(req.headers.authorization);
        const entries = Array.isArray(req.body.entries) ? req.body.entries : [];
        const result = await service.syncEntries(entries, userId);
        res.json({ success: true, data: result });
    } catch (err) {
        next(err);
    }
});

ledgerRouter.post('/test-data/reset', async (req, res, next) => {
    try {
        requireUserId(req.headers.authorization);
        const entries = await service.resetTestData();
        res.json({ success: true, data: entries });
    } catch (err) {
        next(err);
    }
});

ledgerRouter.put('/entry/:id', async (req, res, next) => {
    try {
        const userId = requireUserId(req.headers.authorization);
        const entry = await service.updateEntry(req.params.id, req.body, userId);
        res.json({ success: true, data: entry });
    } catch (err) {
        next(err);
    }
});

ledgerRouter.delete('/entry/:id', async (req, res, next) => {
    try {
        const userId = requireUserId(req.headers.authorization);
        const result = await service.deleteEntry(req.params.id, userId);
        res.json({ success: true, data: result });
    } catch (err) {
        next(err);
    }
});

function getUserId(authHeader?: string) {
    if (!authHeader?.startsWith('Bearer ')) {
        return undefined;
    }

    try {
        const token = authHeader.slice(7);
        const payload = jwt.verify(token, config.jwtSecret) as { userId: string };
        return payload.userId;
    } catch (error) {
        return undefined;
    }
}

function requireUserId(authHeader?: string) {
    const userId = getUserId(authHeader);
    if (!userId) {
        throw new Error('Authentication required. Please provide a valid JWT token.');
    }
    return userId;
}
