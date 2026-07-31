import { ApiResponse } from "../core/response/api-response.js";

/**
 * ============================================================================
 * SARTHEE AI — NOT FOUND MIDDLEWARE
 * ============================================================================
 *
 * Final fallback middleware for requests that did not match any registered
 * application route.
 *
 * Middleware order:
 *
 * Routes
 *   ↓
 * notFoundMiddleware
 *   ↓
 * errorMiddleware
 *
 * Responsibilities:
 *
 * • Return consistent Sarthee AI API response format
 * • Preserve request ID
 * • Return HTTP 404
 * • Avoid exposing unnecessary internal details
 * • Support API debugging through method/path information
 */

// =============================================================================
// CONSTANTS
// =============================================================================

const HTTP_NOT_FOUND = 404;

const NOT_FOUND_CODE = "ROUTE_NOT_FOUND";

// =============================================================================
// MIDDLEWARE
// =============================================================================

export function notFoundMiddleware(req, res) {
  const method = req.method;

  const path = req.originalUrl ?? req.url ?? "/";

  const response = ApiResponse.error({
    code: NOT_FOUND_CODE,

    message: "The requested API endpoint was not found.",

    details: {
      method,
      path,
    },

    requestId: req.id,
  });

  return res.status(HTTP_NOT_FOUND).json(response);
}

export default notFoundMiddleware;

