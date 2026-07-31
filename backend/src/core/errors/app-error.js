import { ERROR_CODE, HTTP_STATUS } from "../../config/constants.js";

/**
 * ============================================================================
 * SARTHEE AI — BASE APPLICATION ERROR
 * ============================================================================
 *
 * Base class for expected/operational application errors.
 *
 * Examples:
 *
 * • validation failures
 * • authentication failures
 * • authorization failures
 * • missing resources
 * • conflicts
 * • external-service failures
 *
 * Unexpected programming errors do not need to be manually converted into
 * AppError. The global error middleware will handle them separately.
 */
export class AppError extends Error {
  constructor({
    message = "An unexpected application error occurred.",
    statusCode = HTTP_STATUS.INTERNAL_SERVER_ERROR,
    code = ERROR_CODE.INTERNAL_ERROR,
    details,
    cause,
    isOperational = true,
  } = {}) {
    super(message, {
      cause,
    });

    // -------------------------------------------------------------------------
    // IDENTITY
    // -------------------------------------------------------------------------

    this.name = new.target.name;

    // -------------------------------------------------------------------------
    // HTTP / APPLICATION METADATA
    // -------------------------------------------------------------------------

    this.statusCode = normalizeStatusCode(statusCode);

    this.code = normalizeErrorCode(code);

    this.details = details;

    this.isOperational = Boolean(isOperational);

    // -------------------------------------------------------------------------
    // STACK TRACE
    // -------------------------------------------------------------------------

    Error.captureStackTrace?.(this, new.target);
  }

  // ===========================================================================
  // CLASSIFICATION
  // ===========================================================================

  get isServerError() {
    return this.statusCode >= 500;
  }

  get isClientError() {
    return this.statusCode >= 400 && this.statusCode < 500;
  }

  // ===========================================================================
  // SERIALIZATION
  // ===========================================================================

  /**
   * Safe structured representation.
   *
   * Stack traces and causes are intentionally excluded because API responses
   * must not accidentally expose internal implementation details.
   */
  toJSON() {
    return {
      name: this.name,

      message: this.message,

      code: this.code,

      statusCode: this.statusCode,

      ...(this.details !== undefined && {
        details: this.details,
      }),
    };
  }
}

// =============================================================================
// NORMALIZATION
// =============================================================================

function normalizeStatusCode(value) {
  if (Number.isInteger(value) && value >= 400 && value <= 599) {
    return value;
  }

  return HTTP_STATUS.INTERNAL_SERVER_ERROR;
}

function normalizeErrorCode(value) {
  if (typeof value === "string" && value.trim().length > 0) {
    return value.trim();
  }

  return ERROR_CODE.INTERNAL_ERROR;
}

