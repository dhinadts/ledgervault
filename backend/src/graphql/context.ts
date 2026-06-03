import { Request } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { prisma } from '../prisma';

export interface GraphQLContext {
    prisma: typeof prisma;
    user?: {
        userId: string;
        role: string;
    };
}

export function createContext({ req }: { req: Request }): GraphQLContext {
    const authHeader = req.headers.authorization || '';
    if (authHeader.startsWith('Bearer ')) {
        const token = authHeader.slice(7);
        try {
            const payload = jwt.verify(token, config.jwtSecret) as { userId: string; role: string };
            return { prisma, user: { userId: payload.userId, role: payload.role } };
        } catch (error) {
            return { prisma };
        }
    }

    return { prisma };
}
