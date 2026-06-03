const { MongoClient } = require('mongodb');
const bcrypt = require('bcrypt');

async function main() {
    const client = new MongoClient(process.env.MONGO_URI);

    try {
        await client.connect();
        const db = client.db('ledger');
        const usersCollection = db.collection('User');

        const passwordHash = await bcrypt.hash('Qwerty@123', 12);

        const user = {
            name: 'Dhina DTS',
            email: 'dhinadts@gmail.com',
            passwordHash,
            role: 'admin',
            refreshTokens: [],
            createdAt: new Date(),
            updatedAt: new Date(),
        };

        const result = await usersCollection.insertOne(user);

        console.log('User created successfully:');
        console.log('ID:', result.insertedId);
        console.log('User:', user);
    } catch (error) {
        console.error('Error:', error.message);
    } finally {
        await client.close();
    }
}

main();
