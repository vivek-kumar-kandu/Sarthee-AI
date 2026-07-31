import { env } from "../config/env.js";
import { logger } from "../config/logger.js";

import { AppError } from "../core/errors/app-error.js";
import { ApiResponse } from "../core/response/api-response.js";

/**
 * ============================================================================
 * SARTHEE AI — GLOBAL ERROR MIDDLEWARE
 * ============================================================================
 *
 * Final Express error boundary.
 *
 * Responsibilities:
 *
 * • Handle trusted operational errors
 * • Normalize unexpected errors
 * • Preserve request IDs
 * • Produce consistent API responses
 * • Avoid leaking stack traces in production
 * • Log server-side failures
 * • Handle malformed JSON
 * • Handle CORS failures
 * • Handle payload-too-large failures
 *
 * IMPORTANT:
 *
 * This middleware MUST be registered after all routes and the 404 middleware.
 */

// =============================================================================
// ERROR MIDDLEWARE
// =============================================================================

export function errorMiddleware(error, req, res, next) {
  // Express requires four arguments for an error middleware.
  // `next` is intentionally retained even though this is the final boundary.
  void next;

  // ---------------------------------------------------------------------------
  // RESPONSE ALREADY STARTED
  // ---------------------------------------------------------------------------

  if (res.headersSent) {
    logger.error(
      {
        err: error,
        requestId: req.id,
        method: req.method,
        url: req.originalUrl,
      },
      "Error occurred after response headers were sent",
    );

    return;
  }

  // ---------------------------------------------------------------------------
  // NORMALIZE ERROR
  // ---------------------------------------------------------------------------

  const normalizedError = normalizeError(error);

  const statusCode = normalizeStatusCode(normalizedError.statusCode);

  // ---------------------------------------------------------------------------
  // LOGGING
  // ---------------------------------------------------------------------------

  logError({
    error: normalizedError,
    originalError: error,
    requestId: req.id,
    method: req.method,
    url: req.originalUrl,
    statusCode,
  });

  // ---------------------------------------------------------------------------
  // RESPONSE DETAILS
  // ---------------------------------------------------------------------------

  const details = resolvePublicDetails(normalizedError);

  const response = ApiResponse.error({
    code: normalizedError.code ?? "INTERNAL_SERVER_ERROR",

    message: resolvePublicMessage(normalizedError, statusCode),

    ...(details !== undefined && {
      details,
    }),

    requestId: req.id,
  });

  // ---------------------------------------------------------------------------
  // DEVELOPMENT DEBUG INFORMATION
  // ---------------------------------------------------------------------------

  if (!env.isProduction && statusCode >= 500) {
    response.debug = {
      name: normalizedError.name,

      stack: normalizedError.stack,
    };
  }

  return res.status(statusCode).json(response);
}

// =============================================================================
// NORMALIZATION
// =============================================================================

function normalizeError(error) {
  if (error instanceof AppError) {
    return error;
  }

  // ---------------------------------------------------------------------------
  // MALFORMED JSON
  // ---------------------------------------------------------------------------

  if (isMalformedJsonError(error)) {
    return createOperationalError({
      name: "MalformedJsonError",
      message: "The request body contains invalid JSON.",
      code: "INVALID_JSON",
      statusCode: 400,
      details: undefined,
      cause: error,
    });
  }

  // ---------------------------------------------------------------------------
  // PAYLOAD TOO LARGE
  // ---------------------------------------------------------------------------

  if (
    error?.type === "entity.too.large" ||
    error?.status === 413 ||
    error?.statusCode === 413
  ) {
    return createOperationalError({
      name: "PayloadTooLargeError",
      message: "The request payload is too large.",
      code: "PAYLOAD_TOO_LARGE",
      statusCode: 413,
      details: undefined,
      cause: error,
    });
  }

  // ---------------------------------------------------------------------------
  // CORS
  // ---------------------------------------------------------------------------

  if (error?.code === "CORS_ORIGIN_DENIED") {
    return createOperationalError({
      name: "CorsError",
      message: "The request origin is not allowed.",
      code: "CORS_ORIGIN_DENIED",
      statusCode: 403,
      details: undefined,
      cause: error,
    });
  }

  // ---------------------------------------------------------------------------
  // GENERIC HTTP ERROR
  // ---------------------------------------------------------------------------

  if (
    Number.isInteger(error?.statusCode) &&
    error.statusCode >= 400 &&
    error.statusCode <= 499
  ) {
    return createOperationalError({
      name: error.name ?? "HttpError",

      message: error.message ?? "The request could not be processed.",

      code: error.code ?? "REQUEST_ERROR",

      statusCode: error.statusCode,

      details: error.details,

      cause: error,
    });
  }

  // ---------------------------------------------------------------------------
  // UNKNOWN ERROR
  // ---------------------------------------------------------------------------

  return createUnexpectedError(error);
}

// =============================================================================
// OPERATIONAL ERROR
// =============================================================================

function createOperationalError({
  name,
  message,
  code,
  statusCode,
  details,
  cause,
}) {
  const operationalError = new Error(message, {
    cause,
  });

  operationalError.name = name;

  operationalError.code = code;

  operationalError.statusCode = statusCode;

  operationalError.details = details;

  operationalError.isOperational = true;

  return operationalError;
}

// =============================================================================
// UNEXPECTED ERROR
// =============================================================================

function createUnexpectedError(originalError) {
  const unexpectedError = new Error(
    originalError?.message ?? "Unexpected server error.",
    {
      cause: originalError instanceof Error ? originalError : undefined,
    },
  );

  unexpectedError.name = originalError?.name ?? "InternalServerError";

  unexpectedError.code = "INTERNAL_SERVER_ERROR";

  unexpectedError.statusCode = 500;

  unexpectedError.isOperational = false;

  if (originalError?.stack) {
    unexpectedError.stack = originalError.stack;
  }

  return unexpectedError;
}

// =============================================================================
// STATUS
// =============================================================================

function normalizeStatusCode(statusCode) {
  if (Number.isInteger(statusCode) && statusCode >= 400 && statusCode <= 599) {
    return statusCode;
  }

  return 500;
}

// =============================================================================
// PUBLIC MESSAGE
// =============================================================================

function resolvePublicMessage(error, statusCode) {
  if (statusCode < 500 || error.isOperational === true) {
    return error.message ?? "The request could not be processed.";
  }

  return "An unexpected server error occurred.";
}

// =============================================================================
// PUBLIC DETAILS
// =============================================================================

function resolvePublicDetails(error) {
  if (error.isOperational === true || error instanceof AppError) {
    return error.details;
  }

  return undefined;
}

// =============================================================================
// MALFORMED JSON
// =============================================================================

function isMalformedJsonError(error) {
  return (
    error instanceof SyntaxError &&
    error?.status === 400 &&
    Object.prototype.hasOwnProperty.call(error, "body")
  );
}

// =============================================================================
// LOGGING
// =============================================================================

function logError({
  error,
  originalError,
  requestId,
  method,
  url,
  statusCode,
}) {
  const context = {
    err: originalError instanceof Error ? originalError : error,

    requestId,

    method,

    url,

    statusCode,

    errorCode: error.code,

    operational: error.isOperational === true,
  };

  if (statusCode >= 500) {
    logger.error(context, "Request failed with server error");

    return;
  }

  logger.warn(context, "Request failed");
}

export default errorMiddleware;

