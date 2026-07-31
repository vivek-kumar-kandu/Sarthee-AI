/**
 * ============================================================================
 * SARTHEE AI — API RESPONSE
 * ============================================================================
 *
 * Standard response contract:
 *
 * {
 *   success: true,
 *   data: {...},
 *   meta: {...},
 *   requestId: "...",
 *   timestamp: "..."
 * }
 *
 * Error:
 *
 * {
 *   success: false,
 *   error: {
 *     code: "...",
 *     message: "...",
 *     details: ...
 *   },
 *   requestId: "...",
 *   timestamp: "..."
 * }
 */

export class ApiResponse {
  static success({ data = null, message, meta, requestId } = {}) {
    return compactObject({
      success: true,

      ...(message !== undefined && {
        message,
      }),

      data,

      ...(meta !== undefined && {
        meta,
      }),

      requestId,

      timestamp: new Date().toISOString(),
    });
  }

  static error({
    code = "INTERNAL_ERROR",
    message = "An unexpected error occurred.",
    details,
    requestId,
  } = {}) {
    return compactObject({
      success: false,

      error: compactObject({
        code,
        message,
        details,
      }),

      requestId,

      timestamp: new Date().toISOString(),
    });
  }

  static paginated({ data = [], page, limit, total, requestId } = {}) {
    const normalizedPage = normalizePositiveInteger(page, 1);
    const normalizedLimit = normalizePositiveInteger(limit, 20);
    const normalizedTotal = normalizeNonNegativeInteger(total, 0);

    const totalPages =
      normalizedLimit > 0 ? Math.ceil(normalizedTotal / normalizedLimit) : 0;

    return ApiResponse.success({
      data,

      meta: {
        pagination: {
          page: normalizedPage,
          limit: normalizedLimit,
          total: normalizedTotal,
          totalPages,

          hasNextPage: normalizedPage < totalPages,

          hasPreviousPage: normalizedPage > 1 && totalPages > 0,
        },
      },

      requestId,
    });
  }
}

// =============================================================================
// HELPERS
// =============================================================================

function compactObject(object) {
  return Object.fromEntries(
    Object.entries(object).filter(([, value]) => value !== undefined),
  );
}

function normalizePositiveInteger(value, fallback) {
  const number = Number(value);

  if (!Number.isInteger(number) || number <= 0) {
    return fallback;
  }

  return number;
}

function normalizeNonNegativeInteger(value, fallback) {
  const number = Number(value);

  if (!Number.isInteger(number) || number < 0) {
    return fallback;
  }

  return number;
}

