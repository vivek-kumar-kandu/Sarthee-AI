import cors from "cors";

import { env } from "./env.js";

/**
 * ============================================================================
 * SARTHEE AI — CORS CONFIGURATION
 * ============================================================================
 *
 * Browser-origin access policy.
 *
 * Native Flutter applications do not normally depend on browser CORS.
 * Flutter Web does.
 *
 * Production:
 *
 * Only explicitly configured origins are allowed.
 *
 * Development:
 *
 * Explicit origins plus common localhost development origins are accepted.
 */

// =============================================================================
// DEVELOPMENT ORIGINS
// =============================================================================

const DEVELOPMENT_ORIGINS = Object.freeze([
  "http://localhost:3000",
  "http://localhost:5173",
  "http://127.0.0.1:3000",
  "http://127.0.0.1:5173",
  "http://localhost:5000",
  "http://127.0.0.1:5000",
]);

const LOCAL_NETWORK_ORIGIN_PATTERN =
  /^https?:\/\/((10\.|127\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|169\.254\.).*?):\d+$/;

// =============================================================================
// ALLOWED ORIGINS
// =============================================================================

const allowedOrigins = new Set([
  ...env.cors.origins,

  ...(env.isDevelopment ? DEVELOPMENT_ORIGINS : []),
]);

// =============================================================================
// CORS OPTIONS
// =============================================================================

export const corsOptions = Object.freeze({
  origin(origin, callback) {
    // Requests without an Origin header include:
    //
    // • native mobile applications
    // • curl
    // • Postman
    // • server-to-server requests

    if (!origin) {
      callback(null, true);
      return;
    }

    if (allowedOrigins.has(origin)) {
      callback(null, true);
      return;
    }

    if (env.isDevelopment && LOCAL_NETWORK_ORIGIN_PATTERN.test(origin)) {
      callback(null, true);
      return;
    }

    const error = new Error(
      "Origin is not allowed by the Sarthee AI CORS policy.",
    );

    error.code = "CORS_ORIGIN_DENIED";

    callback(error);
  },

  credentials: true,

  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],

  allowedHeaders: [
    "Accept",
    "Authorization",
    "Content-Type",
    "X-Request-Id",
    "X-Correlation-Id",
  ],

  exposedHeaders: ["X-Request-Id"],

  maxAge: 86_400,

  optionsSuccessStatus: 204,
});

// =============================================================================
// MIDDLEWARE
// =============================================================================

export const corsMiddleware = cors(corsOptions);

// =============================================================================
// INSPECTION
// =============================================================================

export function getAllowedCorsOrigins() {
  return Object.freeze([...allowedOrigins]);
}

