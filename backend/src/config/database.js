import dns from "node:dns";

import mongoose from "mongoose";

import { logger } from "./logger.js";

/**
 * ============================================================================
 * SARTHEE AI — DATABASE CONFIGURATION
 * ============================================================================
 *
 * MongoDB connection manager.
 *
 * Responsibilities:
 *
 * • Establish MongoDB connection
 * • Validate database configuration
 * • Handle connection errors
 * • Graceful disconnect
 *
 * Flow:
 *
 * Server Bootstrap
 *        |
 *        ↓
 * connectDatabase()
 *        |
 *        ↓
 * MongoDB Atlas
 *
 * ============================================================================
 */

let databaseConnected = false;

// =============================================================================
// DNS (Windows / corporate resolvers often refuse Node SRV queries)
// =============================================================================

function configureDnsForMongoSrv(uri) {
  if (!uri.startsWith("mongodb+srv://")) {
    return;
  }

  const customServers = process.env.MONGODB_DNS_SERVERS?.split(",")
    .map((server) => server.trim())
    .filter(Boolean);

  dns.setServers(
    customServers?.length ? customServers : ["8.8.8.8", "8.8.4.4", "1.1.1.1"],
  );
}

// =============================================================================
// CONNECT DATABASE
// =============================================================================

export async function connectDatabase() {
  try {
    const databaseUrl = process.env.DATABASE_URL || process.env.MONGODB_URI;

    if (!databaseUrl) {
      throw new Error(
        "DATABASE_URL or MONGODB_URI is missing from environment variables",
      );
    }

    configureDnsForMongoSrv(databaseUrl);

    logger.info(
      {
        database: "mongodb",
        status: "connecting",
      },

      "Connecting to MongoDB...",
    );

    await mongoose.connect(databaseUrl, {
      serverSelectionTimeoutMS: 10000,

      maxPoolSize: 10,

      minPoolSize: 2,
    });

    databaseConnected = true;

    logger.info(
      {
        database: "mongodb",
        status: "connected",

        host: mongoose.connection.host,

        name: mongoose.connection.name,
      },

      "MongoDB connected successfully",
    );
  } catch (error) {
    logger.error(
      {
        database: "mongodb",

        error: error.message,

        name: error.name,
      },

      "MongoDB connection failed",
    );

    throw error;
  }
}

// =============================================================================
// DISCONNECT DATABASE
// =============================================================================

export async function disconnectDatabase() {
  try {
    if (!databaseConnected) {
      return;
    }

    await mongoose.disconnect();

    databaseConnected = false;

    logger.info(
      {
        database: "mongodb",
        status: "disconnected",
      },

      "MongoDB disconnected successfully",
    );
  } catch (error) {
    logger.error(
      {
        error: error.message,
      },

      "MongoDB disconnect failed",
    );

    throw error;
  }
}

// =============================================================================
// DATABASE STATUS
// =============================================================================

export function isDatabaseConnected() {
  return databaseConnected;
}

