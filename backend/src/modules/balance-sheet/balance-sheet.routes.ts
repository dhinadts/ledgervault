import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../../config';
import { BalanceSheetService } from './balance-sheet.service';

export const balanceSheetRouter = Router();
const service = new BalanceSheetService();

balanceSheetRouter.use((req, _res, next) => {
    requireUserId(req.headers.authorization);
    next();
});

balanceSheetRouter.get('/current', async (_req, res, next) => {
    try {
        const summary = await service.getCurrentBalanceSheet();
        res.json({ success: true, data: summary });
    } catch (err) {
        next(err);
    }
});

balanceSheetRouter.post('/items', async (req, res, next) => {
    try {
        const item = await service.addItem(req.body);
        res.status(201).json({ success: true, data: item });
    } catch (err) {
        next(err);
    }
});

balanceSheetRouter.post('/sync', async (req, res, next) => {
    try {
        const items = Array.isArray(req.body.items) ? req.body.items : [];
        const result = await service.syncItems(items);
        res.json({ success: true, data: result });
    } catch (err) {
        next(err);
    }
});

balanceSheetRouter.put('/items/:id', async (req, res, next) => {
    try {
        const item = await service.updateItem(req.params.id, req.body);
        res.json({ success: true, data: item });
    } catch (err) {
        next(err);
    }
});

balanceSheetRouter.delete('/items/:id', async (req, res, next) => {
    try {
        const result = await service.deleteItem(req.params.id);
        res.json({ success: true, data: result });
    } catch (err) {
        next(err);
    }
});

function requireUserId(authHeader?: string) {
    if (!authHeader?.startsWith('Bearer ')) {
        throw new Error('Authentication required. Please provide a valid JWT token.');
    }

    try {
        const token = authHeader.slice(7);
        const payload = jwt.verify(token, config.jwtSecret) as { userId?: string; sub?: string };
        const userId = payload.userId || payload.sub;
        if (!userId) {
            throw new Error('Authentication required. Please provide a valid JWT token.');
        }
        return userId;
    } catch (error) {
        throw new Error('Authentication required. Please provide a valid JWT token.');
    }
}
