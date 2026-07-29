import process from "node:process";

import { app } from "./app.js";
import { connectDatabase, disconnectDatabase } from "./config/database.js";
import { env } from "./config/env.js";
import { logger } from "./config/logger.js";
import firebaseApp from "./config/firebase.js";

/**
 * ============================================================================
 * SARTHEE AI — HTTP SERVER
 * ============================================================================
 *
 * Responsibilities:
 *
 * • Initialize database
 * • Start Express server
 * • Handle startup failures
 * • Graceful shutdown
 * • Handle process crashes
 *
 * Architecture:
 *
 * MongoDB
 *    ↓
 * Express API
 *    ↓
 * Routes
 *    ↓
 * Controllers
 *    ↓
 * Services
 *
 * ============================================================================
 */

let server;

let shuttingDown = false;

let databaseConnected = false;

// =============================================================================
// PROCESS SAFETY
// =============================================================================

process.on("uncaughtException", (error) => {
  logger.fatal(
    {
      err: error,
      event: "uncaught_exception",
    },
    "Uncaught exception",
  );

  initiateShutdown("uncaughtException", 1);
});

process.on("unhandledRejection", (reason) => {
  logger.fatal(
    {
      err: reason instanceof Error ? reason : undefined,
      reason: reason instanceof Error ? reason.message : reason,
      event: "unhandled_rejection",
    },
    "Unhandled promise rejection",
  );

  initiateShutdown("unhandledRejection", 1);
});

// =============================================================================
// OPERATING SYSTEM SIGNALS
// =============================================================================

process.on("SIGTERM", () => {
  initiateShutdown("SIGTERM", 0);
});

process.on("SIGINT", () => {
  initiateShutdown("SIGINT", 0);
});

// =============================================================================
// SERVER START
// =============================================================================

async function startServer() {
  const host = env.server.host;
  const port = env.server.port;

  server = app.listen(port, host);

  server.on("listening", () => {
    logger.info(
      {
        event: "server_started",
        environment: env.nodeEnv,
        host,
        port,
        apiPrefix: env.server.apiPrefix,
        database: databaseConnected ? "connected" : "disconnected",
        firebase: getFirebaseInitializationStatus(),
      },
      "Sarthee AI Backend Started",
    );
  });

  server.on("error", (error) => {
    const errorMessage =
      error.code === "EADDRINUSE"
        ? `Port ${port} is already in use. Set PORT to a free port or stop the process using it.`
        : error.message;

    logger.fatal(
      {
        err: error,
        event: "server_error",
        host,
        port,
      },
      errorMessage,
    );

    initiateShutdown("serverError", 1);
  });
}

function getFirebaseInitializationStatus() {
  return firebaseApp ? "initialized" : "not_initialized";
}

// =============================================================================
// GRACEFUL SHUTDOWN
// =============================================================================

async function initiateShutdown(reason, exitCode) {
  if (shuttingDown) {
    return;
  }

  shuttingDown = true;

  logger.info(
    {
      event: "shutdown_started",
      reason,
    },

    "Graceful shutdown started",
  );

  const forceShutdownTimer = setTimeout(
    () => {
      logger.error(
        {
          event: "shutdown_timeout",
        },

        "Forced shutdown",
      );

      process.exit(1);
    },

    10000,
  );

  forceShutdownTimer.unref();

  try {
    if (server) {
      await new Promise((resolve) => {
        server.close(() => {
          resolve();
        });
      });
    }

    if (databaseConnected) {
      await disconnectDatabase();
    }

    clearTimeout(forceShutdownTimer);

    logger.info(
      {
        event: "shutdown_completed",
        reason,
      },

      "Sarthee AI backend stopped",
    );

    process.exit(exitCode);
  } catch (error) {
    logger.error(
      {
        err: error,
        event: "shutdown_error",
      },

      "Shutdown failed",
    );

    process.exit(1);
  }
}

// =============================================================================
// BOOTSTRAP
// =============================================================================

async function bootstrap() {
  try {
    await connectDatabase();

    databaseConnected = true;

    await startServer();
  } catch (error) {
    logger.fatal(
      {
        err: error,
        event: "bootstrap_failed",
      },

      "Sarthee AI startup failed",
    );

    process.exit(1);
  }
}

bootstrap();
