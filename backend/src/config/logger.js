import pino from "pino";

import { env } from "./env.js";

/// ============================================================================
/// SARTHEE AI — STRUCTURED LOGGER
/// ============================================================================
///
/// Central application logger.
///
/// Development:
///
/// readable pretty logs
///
/// Production:
///
/// structured JSON logs
///
/// Features:
///
/// • environment-aware logging
/// • secret redaction
/// • child loggers
/// • structured errors
/// • application metadata
/// • safe request/response serialization
/// • production-friendly timestamps
/// ============================================================================

// =============================================================================
// REDACTION
// =============================================================================

const REDACT_PATHS = Object.freeze([
  // ---------------------------------------------------------------------------
  // HTTP HEADERS
  // ---------------------------------------------------------------------------

  "req.headers.authorization",
  "req.headers.cookie",
  'req.headers["set-cookie"]',

  'res.headers["set-cookie"]',

  // ---------------------------------------------------------------------------
  // AUTHENTICATION
  // ---------------------------------------------------------------------------

  "*.password",
  "*.passwordConfirmation",

  "*.token",
  "*.accessToken",
  "*.refreshToken",

  "*.authorization",

  // ---------------------------------------------------------------------------
  // API KEYS / SECRETS
  // ---------------------------------------------------------------------------

  "*.apiKey",
  "*.api_key",

  "*.secret",
  "*.clientSecret",
  "*.privateKey",

  // ---------------------------------------------------------------------------
  // COMMON NESTED PAYLOADS
  // ---------------------------------------------------------------------------

  "body.password",
  "body.passwordConfirmation",

  "body.token",
  "body.accessToken",
  "body.refreshToken",

  "body.apiKey",
  "body.secret",

  "request.body.password",
  "request.body.token",
  "request.body.accessToken",
  "request.body.refreshToken",
]);

// =============================================================================
// LOGGER OPTIONS
// =============================================================================

const loggerOptions = {
  level: env.logging.level,

  base: {
    service: "sarthee-ai-backend",
    app: env.app.name,
    version: env.app.version,
    environment: env.nodeEnv,
    pid: process.pid,
  },

  timestamp: pino.stdTimeFunctions.isoTime,

  redact: {
    paths: [...REDACT_PATHS],
    censor: "[REDACTED]",
  },

  serializers: {
    err: pino.stdSerializers.err,

    error: pino.stdSerializers.err,

    req(request) {
      if (!request || typeof request !== "object") {
        return request;
      }

      return {
        id: request.id,
        method: request.method,
        url: request.url,
        remoteAddress: request.remoteAddress ?? request.socket?.remoteAddress,
      };
    },

    res(response) {
      if (!response || typeof response !== "object") {
        return response;
      }

      return {
        statusCode: response.statusCode,
      };
    },
  },

  formatters: {
    level(label) {
      return {
        level: label,
      };
    },
  },
};

// =============================================================================
// TRANSPORT
// =============================================================================

function createTransport() {
  if (!env.logging.pretty || !env.isDevelopment) {
    return undefined;
  }

  return pino.transport({
    target: "pino-pretty",

    options: {
      colorize: true,

      translateTime: "SYS:standard",

      singleLine: false,

      ignore: "pid,hostname",

      messageFormat: "{msg}",
    },
  });
}

// =============================================================================
// LOGGER
// =============================================================================

const transport = createTransport();

export const logger = pino(loggerOptions, transport);

// =============================================================================
// CHILD LOGGER
// =============================================================================

/**
 * Creates a contextual child logger.
 *
 * Example:
 *
 * const log = createChildLogger({
 *   module: 'home',
 * });
 *
 * log.info('Loading Home content');
 */
export function createChildLogger(bindings = {}) {
  if (
    bindings === null ||
    typeof bindings !== "object" ||
    Array.isArray(bindings)
  ) {
    throw new TypeError("Logger bindings must be an object.");
  }

  return logger.child(bindings);
}

// =============================================================================
// MODULE LOGGER
// =============================================================================

/**
 * Creates a logger scoped to an application module.
 *
 * Example:
 *
 * const logger = createModuleLogger('home');
 */
export function createModuleLogger(moduleName) {
  const normalizedModuleName =
    typeof moduleName === "string" ? moduleName.trim() : "";

  if (!normalizedModuleName) {
    throw new TypeError("Module logger requires a non-empty module name.");
  }

  return createChildLogger({
    module: normalizedModuleName,
  });
}

// =============================================================================
// ERROR SERIALIZATION
// =============================================================================

/**
 * Converts unknown error-like values into safe structured log metadata.
 */
export function serializeError(error) {
  if (error instanceof Error) {
    return {
      type: error.name,
      message: error.message,
      stack: error.stack,
      cause: serializeCause(error.cause),
    };
  }

  if (error !== null && typeof error === "object") {
    return {
      type: error.constructor?.name ?? "Object",
      value: error,
    };
  }

  return {
    type: typeof error,
    value: error,
  };
}

function serializeCause(cause) {
  if (cause === undefined || cause === null) {
    return undefined;
  }

  if (cause instanceof Error) {
    return {
      type: cause.name,
      message: cause.message,
      stack: cause.stack,
    };
  }

  return cause;
}

// =============================================================================
// STARTUP LOGGING
// =============================================================================

export function logStartup({ host, port, apiPrefix } = {}) {
  logger.info(
    {
      event: "application_started",

      server: {
        host,
        port,
        apiPrefix,
      },

      runtime: {
        node: process.version,
        platform: process.platform,
        architecture: process.arch,
      },
    },
    "Sarthee AI backend started",
  );
}

// =============================================================================
// SHUTDOWN LOGGING
// =============================================================================

export function logShutdown({ signal, reason } = {}) {
  logger.info(
    {
      event: "application_shutdown",
      signal,
      reason,
    },
    "Sarthee AI backend shutting down",
  );
}

