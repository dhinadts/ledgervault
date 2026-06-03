import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import { ApolloServer } from "apollo-server-express";
import { authRouter } from "./modules/auth/auth.routes";
import { ledgerRouter } from "./modules/ledger/ledger.routes";
import { balanceSheetRouter } from "./modules/balance-sheet/balance-sheet.routes";
import { notificationRouter } from "./modules/notifications/notification.routes";
import { auditDocumentsRouter } from "./modules/audit/audit-documents.routes";
import { errorHandler } from "./middleware/error-handler";
import { createContext } from "./graphql/context";
import { typeDefs } from "./graphql/typeDefs";
import { resolvers } from "./graphql/resolvers";
import { prisma } from "./prisma";

const allowedProductionOrigins = new Set([
  "https://dhinadts.github.io",
  "https://dhinadts.github.io/products",
  "https://dhinadts.github.io/products/",
  "https://ledger-06q7.onrender.com",
  "http://localhost:3000",
  "http://localhost:3001",
  "http://localhost:5173",
  "http://localhost:8080",
  "http://127.0.0.1:3000",
  "http://127.0.0.1:5173",
]);

function isAllowedOrigin(origin?: string) {
  if (!origin) {
    return true;
  }

  // Check production origins
  if (allowedProductionOrigins.has(origin)) {
    return true;
  }

  // Check localhost and 127.0.0.1
  try {
    const { hostname, protocol } = new URL(origin);
    if (protocol === "http:" || protocol === "https:") {
      if (hostname === "localhost" || hostname === "127.0.0.1") {
        return true;
      }
      // Allow any render.com subdomain
      if (hostname.endsWith(".onrender.com")) {
        return true;
      }
      // Allow any github.io subdomain
      if (hostname.endsWith(".github.io")) {
        return true;
      }
    }
  } catch (err) {
    console.error("Error parsing origin:", err);
    return false;
  }
  
  return false;
}

export async function createApp() {
  const app = express();

  try {
    await prisma.$connect();
    console.log("✅ Database connected successfully");
  } catch (error) {
    console.error("❌ Database connection error:", error);
  }

  // Configure CORS with proper options
  const corsOptions = {
    origin: (
      origin: string | undefined,
      callback: (err: Error | null, allow?: boolean) => void,
    ) => {
      const allowed = isAllowedOrigin(origin);
      console.log(`CORS request from origin: ${origin}, allowed: ${allowed}`);
      
      if (allowed) {
        callback(null, true);
      } else {
        callback(new Error(`CORS blocked for origin: ${origin}`));
      }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS', 'HEAD'],
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'X-Requested-With',
      'Accept',
      'Origin',
      'Access-Control-Request-Method',
      'Access-Control-Request-Headers',
    ],
    exposedHeaders: ['Content-Length', 'X-Request-Id'],
    maxAge: 86400, // 24 hours
    preflightContinue: false,
    optionsSuccessStatus: 204,
  };

  // Apply CORS middleware
  app.use(cors(corsOptions));

  // Keep auth preflight simple for Flutter Web and hosted clients.
  app.use((req, res, next) => {
    if (req.method !== "OPTIONS") {
      return next();
    }

    const origin = req.headers.origin;
    if (isAllowedOrigin(origin)) {
      if (origin) {
        res.header("Access-Control-Allow-Origin", origin);
      }
      res.header("Vary", "Origin");
      res.header("Access-Control-Allow-Credentials", "true");
      res.header("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,PATCH,OPTIONS,HEAD");
      res.header(
        "Access-Control-Allow-Headers",
        "Content-Type,Authorization,X-Requested-With,Accept,Origin,Access-Control-Request-Method,Access-Control-Request-Headers",
      );
      res.sendStatus(204);
      return;
    }

    res.status(403).json({ success: false, error: `CORS blocked for origin: ${origin}` });
  });
  
  // Body parsing middleware
  app.use(express.json({ limit: "15mb" }));
  app.use(bodyParser.json({ limit: "15mb" }));
  
  // Request logging middleware
  app.use((req, res, next) => {
    console.log(`${req.method} ${req.path} - Origin: ${req.headers.origin}`);
    next();
  });
  
  // Health check endpoint
  app.get("/api/health", (_req, res) => {
    res.json({ 
      success: true, 
      data: { 
        status: "ok",
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV
      } 
    });
  });
  
  // Test CORS endpoint
  app.options("/api/test-cors", cors(corsOptions));
  app.get("/api/test-cors", (req, res) => {
    res.json({ 
      success: true, 
      message: "CORS is configured correctly!",
      origin: req.headers.origin,
      timestamp: new Date().toISOString()
    });
  });
  
  // API Routes
  app.use("/api/auth", authRouter);
  app.use("/api/ledger", ledgerRouter);
  app.use("/api/balance-sheet", balanceSheetRouter);
  app.use("/api/notifications", notificationRouter);
  app.use("/api/audit", auditDocumentsRouter);
  
  // GraphQL setup
  const server = new ApolloServer({
    typeDefs,
    resolvers,
    context: createContext,
    introspection: process.env.NODE_ENV !== 'production',
    csrfPrevention: true,
  });
  
  await server.start();
  server.applyMiddleware({ 
    app: app as any, 
    path: "/graphql",
    cors: corsOptions,
  });
  
  // 404 handler for undefined routes
  app.use((req, res) => {
    res.status(404).json({ 
      success: false, 
      error: `Route ${req.method} ${req.path} not found` 
    });
  });
  
  // Error handling middleware (should be last)
  app.use(errorHandler);
  
  console.log("✅ App created successfully");
  return app as any;
}
