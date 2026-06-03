import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { GraphQLScalarType, Kind } from 'graphql';
import { AuthenticationError, UserInputError } from 'apollo-server-errors';
import { config } from '../config';
import { prisma } from '../prisma';
import { GraphQLContext } from './context';
import { LedgerService } from '../modules/ledger/ledger.service';

const createToken = (userId: string, role: string) =>
    jwt.sign({ userId, role }, config.jwtSecret, { expiresIn: '15m' });

const createRefreshToken = (userId: string, role: string) =>
    jwt.sign({ userId, role }, config.jwtRefreshSecret, { expiresIn: '30d' });

const ledgerService = new LedgerService();

export const resolvers = {
    DateTime: new GraphQLScalarType({
        name: 'DateTime',
        description: 'ISO 8601 date-time scalar',
        serialize(value: unknown) {
            return value instanceof Date ? value.toISOString() : null;
        },
        parseValue(value: unknown) {
            return typeof value === 'string' ? new Date(value) : null;
        },
        parseLiteral(ast) {
            if (ast.kind === Kind.STRING) {
                return new Date(ast.value);
            }
            return null;
        },
    }),

    Query: {
        me: async (_parent: unknown, _args: unknown, context: GraphQLContext) => {
            if (!context.user) {
                throw new AuthenticationError('Authentication required');
            }
            return prisma.user.findUnique({ where: { id: context.user.userId } });
        },

        ledgerEntries: async (_parent: unknown, _args: unknown, context: GraphQLContext) => {
            if (!context.user) {
                throw new AuthenticationError('Authentication required');
            }
            return prisma.ledgerEntry.findMany({ orderBy: { createdAt: 'desc' } });
        },

        balanceSheet: async (_parent: unknown, _args: unknown, _context: GraphQLContext) => {
            const [assets, liabilities, equity] = await Promise.all([
                prisma.balanceSheetItem.findMany({ where: { type: 'asset' }, orderBy: { name: 'asc' } }),
                prisma.balanceSheetItem.findMany({ where: { type: 'liability' }, orderBy: { name: 'asc' } }),
                prisma.balanceSheetItem.findMany({ where: { type: 'equity' }, orderBy: { name: 'asc' } }),
            ]);
            return { assets, liabilities, equity };
        },

        notifications: async (_parent: unknown, _args: unknown, context: GraphQLContext) => {
            if (!context.user) {
                throw new AuthenticationError('Authentication required');
            }
            return prisma.notification.findMany({ orderBy: { createdAt: 'desc' } });
        },
    },

    Mutation: {
        register: async (_parent: unknown, args: { input: { name: string; email: string; password: string; role: string } }) => {
            const existing = await prisma.user.findUnique({ where: { email: args.input.email } });
            if (existing) {
                throw new UserInputError('Email already registered');
            }
            const passwordHash = await bcrypt.hash(args.input.password, 12);
            const user = await prisma.user.create({
                data: {
                    name: args.input.name,
                    email: args.input.email,
                    passwordHash,
                    role: args.input.role,
                    refreshTokens: [],
                },
            });
            const token = createToken(user.id, user.role);
            const refreshToken = createRefreshToken(user.id, user.role);
            await prisma.user.update({
                where: { id: user.id },
                data: { refreshTokens: { push: refreshToken } },
            });
            return { token, refreshToken, user };
        },

        login: async (_parent: unknown, args: { input: { email: string; password: string } }) => {
            const user = await prisma.user.findUnique({ where: { email: args.input.email } });
            if (!user) {
                throw new AuthenticationError('Invalid credentials');
            }
            const valid = await bcrypt.compare(args.input.password, user.passwordHash);
            if (!valid) {
                throw new AuthenticationError('Invalid credentials');
            }
            const token = createToken(user.id, user.role);
            const refreshToken = createRefreshToken(user.id, user.role);
            await prisma.user.update({ where: { id: user.id }, data: { refreshTokens: { push: refreshToken } } });
            return { token, refreshToken, user };
        },

        refreshToken: async (_parent: unknown, args: { refreshToken: string }) => {
            let decoded;
            try {
                decoded = jwt.verify(args.refreshToken, config.jwtRefreshSecret) as { userId: string; role: string };
            } catch (error) {
                throw new AuthenticationError('Invalid refresh token');
            }
            const user = await prisma.user.findUnique({ where: { id: decoded.userId } });
            if (!user || !user.refreshTokens.includes(args.refreshToken)) {
                throw new AuthenticationError('Invalid refresh token');
            }
            const token = createToken(user.id, user.role);
            return { token, refreshToken: args.refreshToken, user };
        },

        createLedgerEntry: async (_parent: unknown, args: { input: { date: string; particulars: string; ledgerRef: string; debit: number; credit: number; status: string; tags: string[] } }, context: GraphQLContext) => {
            if (!context.user) {
                throw new AuthenticationError('Authentication required');
            }
            return ledgerService.createEntry({
                ...args.input,
                createdBy: context.user.userId,
            });
        },

        addBalanceSheetItem: async (_parent: unknown, args: { input: { name: string; group: string; type: string; value: number } }) => {
            return prisma.balanceSheetItem.create({
                data: {
                    name: args.input.name,
                    group: args.input.group,
                    type: args.input.type,
                    value: args.input.value,
                },
            });
        },

        sendNotification: async (_parent: unknown, args: { input: { title: string; detail: string; time: string; color: string; level: string; isRead?: boolean } }, context: GraphQLContext) => {
            if (!context.user) {
                throw new AuthenticationError('Authentication required');
            }
            return prisma.notification.create({
                data: {
                    title: args.input.title,
                    detail: args.input.detail,
                    time: args.input.time,
                    color: args.input.color,
                    level: args.input.level,
                    isRead: args.input.isRead ?? false,
                },
            });
        },
    },
};
