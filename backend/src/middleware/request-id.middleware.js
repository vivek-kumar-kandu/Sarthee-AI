import { randomUUID } from "node:crypto";

/**
 * ============================================================================
 * SARTHEE AI — REQUEST ID & TRACE ID MIDDLEWARE
 * ============================================================================
 *
 * Assigns unique request and correlation trace identifiers to every incoming HTTP request.
 */

const REQUEST_ID_HEADER = "x-request-id";
const TRACE_ID_HEADER = "x-trace-id";

const RESPONSE_REQUEST_ID_HEADER = "X-Request-Id";
const RESPONSE_TRACE_ID_HEADER = "X-Trace-Id";

const MAX_REQUEST_ID_LENGTH = 128;
const REQUEST_ID_PATTERN = /^[A-Za-z0-9._:-]+$/;

export function requestIdMiddleware(req, res, next) {
  const requestId = resolveHeaderId(req, REQUEST_ID_HEADER) || randomUUID();
  const traceId = resolveHeaderId(req, TRACE_ID_HEADER) || `trace_${requestId.replace(/-/g, "").substr(0, 16)}`;

  req.id = requestId;
  req.traceId = traceId;

  res.setHeader(RESPONSE_REQUEST_ID_HEADER, requestId);
  res.setHeader(RESPONSE_TRACE_ID_HEADER, traceId);

  next();
}

function resolveHeaderId(req, headerName) {
  const headerValue = req.headers?.[headerName];
  let normalized = null;

  if (typeof headerValue === "string") {
    normalized = headerValue.trim();
  } else if (Array.isArray(headerValue) && headerValue.length > 0 && typeof headerValue[0] === "string") {
    normalized = headerValue[0].trim();
  }

  if (normalized && normalized.length > 0 && normalized.length <= MAX_REQUEST_ID_LENGTH && REQUEST_ID_PATTERN.test(normalized)) {
    return normalized;
  }

  return null;
}

export default requestIdMiddleware;
