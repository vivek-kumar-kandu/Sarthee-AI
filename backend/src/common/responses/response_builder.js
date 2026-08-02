/**
 * ResponseBuilder — Production Centralized API Envelope Builder
 *
 * Ensures every REST API endpoint in Sarthee AI returns a standardized JSON envelope
 * featuring status, data/error details, and metadata with DataProvenance, Request ID, and Trace ID.
 */
export class ResponseBuilder {
  /**
   * Constructs a standard success response (200 / 201)
   *
   * @param {import('express').Response} res Express response object
   * @param {{
   *   data?: any,
   *   provenance?: Object,
   *   message?: string,
   *   statusCode?: number,
   *   requestId?: string,
   *   traceId?: string
   * }} options Response options
   */
  static success(res, options = {}) {
    const {
      data = null,
      provenance = null,
      message = null,
      statusCode = 200,
      requestId = res.req?.id || null,
      traceId = res.req?.traceId || null,
    } = options;

    const payload = {
      status: 'success',
      ...(message ? { message } : {}),
      ...(data !== null ? { data } : {}),
      meta: {
        timestamp: new Date().toISOString(),
        ...(requestId ? { requestId } : {}),
        ...(traceId ? { traceId } : {}),
        ...(provenance ? { provenance } : {}),
      },
    };

    return res.status(statusCode).json(payload);
  }

  /**
   * Constructs a standard error response (400, 401, 404, 500, etc.)
   *
   * @param {import('express').Response} res Express response object
   * @param {{
   *   code?: string,
   *   message?: string,
   *   details?: any,
   *   statusCode?: number,
   *   requestId?: string,
   *   traceId?: string
   * }} options Error options
   */
  static error(res, options = {}) {
    const {
      code = 'INTERNAL_SERVER_ERROR',
      message = 'An unexpected error occurred.',
      details = null,
      statusCode = 500,
      requestId = res.req?.id || null,
      traceId = res.req?.traceId || null,
    } = options;

    const payload = {
      status: 'error',
      error: {
        code,
        message,
        ...(details ? { details } : {}),
      },
      meta: {
        timestamp: new Date().toISOString(),
        ...(requestId ? { requestId } : {}),
        ...(traceId ? { traceId } : {}),
      },
    };

    return res.status(statusCode).json(payload);
  }
}
