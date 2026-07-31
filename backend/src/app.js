import express from "express";

import { env } from "./config/env.js";

import { corsMiddleware } from "./config/cors.js";

import apiV1Router from "./api/v1/routes/index.js";

import { requestIdMiddleware } from "./middleware/request-id.middleware.js";

import { requestLoggerMiddleware } from "./middleware/request-logger.middleware.js";

import { securityMiddleware } from "./middleware/security.middleware.js";

import { rateLimitMiddleware } from "./middleware/rate-limit.middleware.js";

import { notFoundMiddleware } from "./middleware/not-found.middleware.js";

import { errorMiddleware } from "./middleware/error.middleware.js";

/**
 * ============================================================================
 * SARTHEE AI — EXPRESS APPLICATION
 * ============================================================================
 *
 * Middleware pipeline:
 *
 * Request
 *    ↓
 * Request ID
 *    ↓
 * Structured Logging
 *    ↓
 * Security Headers
 *    ↓
 * CORS
 *    ↓
 * Body Parsing
 *    ↓
 * Rate Limiting
 *    ↓
 * API v1
 *    ↓
 * 404 Handler
 *    ↓
 * Global Error Handler
 */

export const app = express();

// =============================================================================
// EXPRESS CONFIGURATION
// =============================================================================

app.disable("x-powered-by");

if (env.isProduction) {
  app.set("trust proxy", 1);
}

// =============================================================================
// REQUEST CONTEXT
// =============================================================================

app.use(requestIdMiddleware);

app.use(requestLoggerMiddleware);

// =============================================================================
// SECURITY
// =============================================================================

app.use(securityMiddleware);

app.use(corsMiddleware);

// =============================================================================
// BODY PARSING
// =============================================================================

app.use(
  express.json({
    limit: "1mb",
    strict: true,
  }),
);

app.use(
  express.urlencoded({
    extended: false,
    limit: "1mb",
  }),
);

// =============================================================================
// RATE LIMITING
// =============================================================================

app.use(env.server.apiPrefix, rateLimitMiddleware);

// =============================================================================
// HEALTH & ROOT CHECK (For Render / K8s probes)
// =============================================================================

app.get("/", (req, res) => {
  res.status(200).json({
    status: "ok",
    app: "Sarthee AI",
    version: "1.0.0",
    timestamp: new Date().toISOString(),
  });
});

app.head("/", (req, res) => {
  res.status(200).end();
});

app.get("/favicon.ico", (req, res) => {
  res.status(204).end();
});

// =============================================================================
// API
// =============================================================================

app.use(env.server.apiPrefix, apiV1Router);

// =============================================================================
// FALLBACK
// =============================================================================

app.use(notFoundMiddleware);

// =============================================================================
// GLOBAL ERROR BOUNDARY
// =============================================================================

// Error middleware MUST remain last.
app.use(errorMiddleware);

export default app;

