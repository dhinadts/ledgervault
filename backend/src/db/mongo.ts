import { MongoClient, Db } from 'mongodb';
import { config } from '../config';

let db: Db;

export async function connectToDatabase(): Promise<Db> {
    if (db) {
        return db;
    }

    const client = new MongoClient(config.mongoUri, {
        tls: true,
        tlsAllowInvalidCertificates: false,
    });

    await client.connect();
    db = client.db();
    return db;
}
