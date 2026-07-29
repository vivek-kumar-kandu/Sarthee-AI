import { rateLimit } from "express-rate-limit";

import { ERROR_CODE, HTTP_STATUS } from "../config/constants.js";

import { env } from "../config/env.js";

import { ApiResponse } from "../core/response/api-response.js";

/**
 * ============================================================================
 * SARTHEE AI — GLOBAL RATE LIMITER
 * ============================================================================
 *
 * Protects public API infrastructure from:
 *
 * • accidental request loops
 * • scraping bursts
 * • basic abuse
 * • excessive automated traffic
 *
 * Specialized endpoints such as authentication and AI can receive stricter
 * route-specific limiters later.
 */

export const rateLimitMiddleware = rateLimit({
  windowMs: env.rateLimit.windowMs,

  limit: env.rateLimit.maxRequests,

  // Modern standardized RateLimit headers.
  standardHeaders: "draft-8",

  legacyHeaders: false,

  // Successful and failed requests both count toward the limit.
  skipSuccessfulRequests: false,

  skipFailedRequests: false,

  // ===========================================================================
  // SKIP
  // ===========================================================================

  skip(req) {
    // Infrastructure health checks should not consume normal user quota.
    return req.path === "/health" || req.originalUrl?.endsWith("/health");
  },

  // ===========================================================================
  // RESPONSE
  // ===========================================================================

  handler(req, res) {
    const response = ApiResponse.error({
      code: ERROR_CODE.RATE_LIMIT_EXCEEDED,

      message: "Too many requests. Please try again later.",

      details: {
        retryAfter: resolveRetryAfterSeconds(req.rateLimit?.resetTime),
      },

      requestId: req.id,
    });

    res.status(HTTP_STATUS.TOO_MANY_REQUESTS).json(response);
  },
});

// =============================================================================
// SPECIALIZED LIMITER FACTORY
// =============================================================================

/**
 * Creates stricter route-specific rate limiters.
 *
 * Future examples:
 *
 * authentication:
 *
 * createRateLimiter({
 *   windowMs: 15 * 60 * 1000,
 *   maxRequests: 10,
 * })
 *
 * AI:
 *
 * createRateLimiter({
 *   windowMs: 60 * 1000,
 *   maxRequests: 20,
 * })
 */
export function createRateLimiter({
  windowMs,
  maxRequests,
  message = "Too many requests. Please try again later.",
  skip,
} = {}) {
  validatePositiveInteger(windowMs, "windowMs");

  validatePositiveInteger(maxRequests, "maxRequests");

  return rateLimit({
    windowMs,

    limit: maxRequests,

    standardHeaders: "draft-8",

    legacyHeaders: false,

    skipSuccessfulRequests: false,

    skipFailedRequests: false,

    ...(typeof skip === "function" && {
      skip,
    }),

    handler(req, res) {
      res.status(HTTP_STATUS.TOO_MANY_REQUESTS).json(
        ApiResponse.error({
          code: ERROR_CODE.RATE_LIMIT_EXCEEDED,

          message,

          details: {
            retryAfter: resolveRetryAfterSeconds(req.rateLimit?.resetTime),
          },

          requestId: req.id,
        }),
      );
    },
  });
}

// =============================================================================
// HELPERS
// =============================================================================

function resolveRetryAfterSeconds(resetTime) {
  if (!(resetTime instanceof Date)) {
    return undefined;
  }

  const milliseconds = resetTime.getTime() - Date.now();

  return Math.max(0, Math.ceil(milliseconds / 1000));
}

function validatePositiveInteger(value, name) {
  if (!Number.isInteger(value) || value <= 0) {
    throw new TypeError(`${name} must be a positive integer.`);
  }
}
