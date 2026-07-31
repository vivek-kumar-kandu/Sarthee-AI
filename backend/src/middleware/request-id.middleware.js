import { randomUUID } from "node:crypto";

/**
 * ============================================================================
 * SARTHEE AI — REQUEST ID MIDDLEWARE
 * ============================================================================
 *
 * Assigns a unique correlation identifier to every incoming HTTP request.
 *
 * Request lifecycle:
 *
 * Client Request
 *      ↓
 * Existing X-Request-Id?
 *      ↓
 * Validate / normalize
 *      ↓
 * Otherwise generate UUID
 *      ↓
 * req.id
 *      ↓
 * X-Request-Id response header
 *      ↓
 * Logger / errors / API responses
 *
 * Benefits:
 *
 * • Distributed request tracing
 * • Production debugging
 * • Log correlation
 * • Error investigation
 * • Client/server support diagnostics
 */

// =============================================================================
// CONSTANTS
// =============================================================================

const REQUEST_ID_HEADER = "x-request-id";

const RESPONSE_REQUEST_ID_HEADER = "X-Request-Id";

const MAX_REQUEST_ID_LENGTH = 128;

// Safe characters for externally supplied correlation IDs.
//
// Supports:
//
// UUID
// ULID
// custom trace IDs
// common gateway-generated IDs
const REQUEST_ID_PATTERN = /^[A-Za-z0-9._:-]+$/;

// =============================================================================
// MIDDLEWARE
// =============================================================================

export function requestIdMiddleware(req, res, next) {
  const requestId = resolveRequestId(req);

  // ---------------------------------------------------------------------------
  // REQUEST CONTEXT
  // ---------------------------------------------------------------------------

  req.id = requestId;

  // ---------------------------------------------------------------------------
  // RESPONSE CORRELATION
  // ---------------------------------------------------------------------------

  res.setHeader(RESPONSE_REQUEST_ID_HEADER, requestId);

  next();
}

// =============================================================================
// REQUEST ID RESOLUTION
// =============================================================================

function resolveRequestId(req) {
  const incomingRequestId = getIncomingRequestId(req);

  if (isValidRequestId(incomingRequestId)) {
    return incomingRequestId;
  }

  return randomUUID();
}

// =============================================================================
// HEADER EXTRACTION
// =============================================================================

function getIncomingRequestId(req) {
  const headerValue = req.headers?.[REQUEST_ID_HEADER];

  if (typeof headerValue === "string") {
    return normalizeRequestId(headerValue);
  }

  if (
    Array.isArray(headerValue) &&
    headerValue.length > 0 &&
    typeof headerValue[0] === "string"
  ) {
    return normalizeRequestId(headerValue[0]);
  }

  return null;
}

// =============================================================================
// NORMALIZATION
// =============================================================================

function normalizeRequestId(value) {
  const normalized = value.trim();

  if (!normalized) {
    return null;
  }

  return normalized;
}

// =============================================================================
// VALIDATION
// =============================================================================

function isValidRequestId(value) {
  if (typeof value !== "string") {
    return false;
  }

  if (value.length === 0 || value.length > MAX_REQUEST_ID_LENGTH) {
    return false;
  }

  return REQUEST_ID_PATTERN.test(value);
}

// =============================================================================
// DEFAULT EXPORT
// =============================================================================

export default requestIdMiddleware;

