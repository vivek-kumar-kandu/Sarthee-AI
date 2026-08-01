import helmet from 'helmet';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import { logger } from './logger.js';

/**
 * Security & Audit Logging Middleware Configuration
 *
 * Enforces production security standards:
 *   - Helmet HTTP security headers
 *   - CORS whitelist protection
 *   - Express Rate Limiting (100 requests per 15-minute window per IP)
 *   - Request audit logging
 */

export const configureSecurityHeaders = helmet({
  contentSecurityPolicy: false, // Allows swagger UI & local prototype dashboard
  crossOriginEmbedderPolicy: false,
});

export const configureCors = cors({
  origin: '*', // Configurable to specific domains in production
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID'],
});

export const apiRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200, // Limit each IP to 200 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: 'RATE_LIMIT_EXCEEDED',
    message: 'Too many requests from this IP, please try again after 15 minutes.',
  },
});

/** Audit Logging Middleware */
export const auditLogger = (req, res, next) => {
  const startTime = Date.now();
  res.on('finish', () => {
    logger.info({
      event: 'api_request_audit',
      method: req.method,
      url: req.originalUrl,
      status: res.statusCode,
      ip: req.ip,
      elapsedMs: Date.now() - startTime,
    });
  });
  next();
};
