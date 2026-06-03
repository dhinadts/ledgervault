import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../.env') });

function requireMongoUri() {
    const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/ledger';

    try {
        const url = new URL(mongoUri);
        const databaseName = url.pathname.replace('/', '').trim();

        if (!databaseName) {
            throw new Error('MONGO_URI must include a database name, for example /ledger');
        }
    } catch (error) {
        if (error instanceof Error && error.message.includes('database name')) {
            throw error;
        }
        throw new Error('MONGO_URI is not a valid MongoDB connection string');
    }

    return mongoUri;
}

export const config = {
    port: process.env.PORT || '4000',
    jwtSecret: process.env.JWT_SECRET || 'replace-with-secure-secret',
    jwtRefreshSecret: process.env.JWT_REFRESH_SECRET || 'replace-with-secure-refresh-secret',
    mongoUri: requireMongoUri(),
    gmailUser: process.env.GMAIL_USER || '',
    gmailAppPassword: process.env.GMAIL_APP_PASSWORD || '',
};
