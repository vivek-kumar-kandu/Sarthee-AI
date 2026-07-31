/**
 * Standardized API Response Envelope Middleware
 */
export function formatSuccessResponse(data, meta = {}, requestId = 'req_mock_123') {
  return {
    success: true,
    requestId,
    timestamp: new Date().toISOString(),
    meta: {
      apiVersion: 'v1',
      schemaVersion: '1.0',
      planVersion: '2026.08',
      ...meta,
    },
    data,
  };
}

export function formatErrorResponse(code, message, details = {}, requestId = 'req_mock_123') {
  return {
    success: false,
    requestId,
    timestamp: new Date().toISOString(),
    error: {
      code,
      message,
      details,
    },
  };
}

