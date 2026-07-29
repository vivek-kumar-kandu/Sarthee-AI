import pinoHttp from "pino-http";

import { logger } from "../config/logger.js";

/**
 * ============================================================================
 * SARTHEE AI — HTTP REQUEST LOGGER
 * ============================================================================
 *
 * Production HTTP logging middleware.
 *
 * Features:
 *
 * • Structured Pino logging
 * • Request correlation IDs
 * • Response timing
 * • Error-aware levels
 * • Health-check noise filtering
 * • Safe serializers
 * • Production-safe metadata
 *
 * ============================================================================
 */

export const requestLoggerMiddleware = pinoHttp({
  logger,

  // ===========================================================================
  // REQUEST ID MANAGEMENT
  // ===========================================================================

  genReqId(req) {
    if (req.id) {
      return req.id;
    }

    const headerId = req.headers["x-request-id"];

    if (typeof headerId === "string" && headerId.trim()) {
      return headerId.trim();
    }

    return undefined;
  },

  // ===========================================================================
  // AUTOMATIC REQUEST LOGGING
  // ===========================================================================

  autoLogging: {
    ignore(req) {
      const url = req.url ?? "";

      return url === "/health" || url.endsWith("/health");
    },
  },

  // ===========================================================================
  // LOG LEVEL MANAGEMENT
  // ===========================================================================

  customLogLevel(_req, res, error) {
    if (error || res.statusCode >= 500) {
      return "error";
    }

    if (res.statusCode >= 400) {
      return "warn";
    }

    return "info";
  },

  // ===========================================================================
  // SUCCESS MESSAGE
  // ===========================================================================

  customSuccessMessage(req, res) {
    return `${req.method} ${req.url} completed ` + `with ${res.statusCode}`;
  },

  // ===========================================================================
  // ERROR MESSAGE
  // ===========================================================================

  customErrorMessage(req, res, error) {
    return (
      `${req.method} ${req.url} failed ` +
      `with ${res.statusCode}: ` +
      `${error?.message ?? "Unknown error"}`
    );
  },

  // ===========================================================================
  // SAFE SERIALIZERS
  // ===========================================================================

  serializers: {
    req(req) {
      return {
        id: req.id,

        method: req.method,

        url: req.url,

        userAgent: req.headers["user-agent"],

        remoteAddress: req.remoteAddress,
      };
    },

    res(res) {
      return {
        statusCode: res.statusCode,
      };
    },

    err: pinoHttp.stdSerializers.err,
  },

  // ===========================================================================
  // EXTRA REQUEST CONTEXT
  // ===========================================================================

  customProps(req) {
    return {
      requestId: req.id,

      service: "sarthee-ai-backend",
    };
  },
});
