import { randomUUID } from 'crypto';
import { logger } from '../config/logger.js';

/**
 * Observability & Correlation Tracing Middleware
 *
 * Attaches request correlation IDs and tracks per-provider execution latency breakdown
 * (e.g. OSRM: 134ms, Weather: 201ms, Nearby: 189ms, Gemini: 612ms).
 */
export const observabilityMiddleware = (req, res, next) => {
  const requestId = req.headers['x-request-id'] || randomUUID().substr(0, 8);
  const correlationId = req.headers['x-correlation-id'] || `corr_${randomUUID().substr(0, 8)}`;

  req.requestId = requestId;
  req.correlationId = correlationId;
  req.providerTraces = [];

  res.setHeader('X-Request-ID', requestId);
  res.setHeader('X-Correlation-ID', correlationId);

  /** Helper method to trace provider latency */
  req.traceProviderLatency = (providerId, latencyMs, success = true) => {
    req.providerTraces.push({ providerId, latencyMs, success, timestamp: Date.now() });
  };

  const startTime = Date.now();

  res.on('finish', () => {
    const totalMs = Date.now() - startTime;

    const logPayload = {
      event: 'request_observability_trace',
      requestId,
      correlationId,
      method: req.method,
      url: req.originalUrl,
      status: res.statusCode,
      totalMs,
      providerBreakdown: req.providerTraces,
    };

    if (totalMs > 500) {
      logger.warn({ ...logPayload, event: 'slow_request_detected' });
    } else {
      logger.info(logPayload);
    }
  });

  next();
};
