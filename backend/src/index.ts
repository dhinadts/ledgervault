import dotenv from 'dotenv';
import { createApp } from './app';
import { config } from './config';

dotenv.config();

const port = Number(config.port);

createApp()
    .then((app) => {
        app.listen(port, () => {
            console.log(`LedgerVault backend running on port ${port}`);
            console.log('GraphQL endpoint available at /graphql');
            console.log(`Connected to MongoDB at ${config.mongoUri}`);
        });
    })
    .catch((error) => {
        console.error('Failed to start backend', error);
        process.exit(1);
    });
