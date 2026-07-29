/**
 * ============================================================================
 * SARTHEE AI — APPLICATION CONSTANTS
 * ============================================================================
 *
 * Infrastructure/application-wide constants.
 *
 * Rules:
 *
 * • No environment variables are read here.
 * • No mutable application state is stored here.
 * • No business logic belongs here.
 * • Environment-specific values belong in env.js.
 */

// =============================================================================
// APPLICATION
// =============================================================================

export const APP = Object.freeze({
  NAME: "Sarthee AI",
  DEFAULT_VERSION: "1.0.0",
});

// =============================================================================
// API
// =============================================================================

export const API = Object.freeze({
  DEFAULT_PREFIX: "/api/v1",

  ROUTES: Object.freeze({
    ROOT: "/",
    HEALTH: "/health",
    AUTH: "/auth",
    HOME: "/home",
    DESTINATIONS: "/destinations",
    CULTURE: "/culture",
    FOOD: "/food",
    HOTELS: "/hotels",
    FAVORITES: "/favorites",
    TRIPS: "/trips",
    BUDGET: "/budget",
    WEATHER: "/weather",
    AI: "/ai",
  }),
});

// =============================================================================
// HTTP
// =============================================================================

export const HTTP_STATUS = Object.freeze({
  OK: 200,
  CREATED: 201,
  ACCEPTED: 202,
  NO_CONTENT: 204,

  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  METHOD_NOT_ALLOWED: 405,
  CONFLICT: 409,
  PAYLOAD_TOO_LARGE: 413,
  UNPROCESSABLE_ENTITY: 422,
  TOO_MANY_REQUESTS: 429,

  INTERNAL_SERVER_ERROR: 500,
  BAD_GATEWAY: 502,
  SERVICE_UNAVAILABLE: 503,
  GATEWAY_TIMEOUT: 504,
});

// =============================================================================
// HTTP METHODS
// =============================================================================

export const HTTP_METHOD = Object.freeze({
  GET: "GET",
  POST: "POST",
  PUT: "PUT",
  PATCH: "PATCH",
  DELETE: "DELETE",
  OPTIONS: "OPTIONS",
  HEAD: "HEAD",
});

// =============================================================================
// CONTENT TYPES
// =============================================================================

export const CONTENT_TYPE = Object.freeze({
  JSON: "application/json",
  FORM_URLENCODED: "application/x-www-form-urlencoded",
  MULTIPART: "multipart/form-data",
});

// =============================================================================
// HEADERS
// =============================================================================

export const HEADER = Object.freeze({
  ACCEPT: "accept",
  AUTHORIZATION: "authorization",
  CONTENT_TYPE: "content-type",

  REQUEST_ID: "x-request-id",
  CORRELATION_ID: "x-correlation-id",

  FORWARDED_FOR: "x-forwarded-for",
  REAL_IP: "x-real-ip",
});

// =============================================================================
// ENVIRONMENTS
// =============================================================================

export const ENVIRONMENT = Object.freeze({
  DEVELOPMENT: "development",
  TEST: "test",
  PRODUCTION: "production",
});

// =============================================================================
// LOGGING
// =============================================================================

export const LOG_LEVEL = Object.freeze({
  FATAL: "fatal",
  ERROR: "error",
  WARN: "warn",
  INFO: "info",
  DEBUG: "debug",
  TRACE: "trace",
  SILENT: "silent",
});

// =============================================================================
// ERROR CODES
// =============================================================================

export const ERROR_CODE = Object.freeze({
  INTERNAL_ERROR: "INTERNAL_ERROR",

  VALIDATION_ERROR: "VALIDATION_ERROR",

  AUTHENTICATION_REQUIRED: "AUTHENTICATION_REQUIRED",
  INVALID_CREDENTIALS: "INVALID_CREDENTIALS",
  INVALID_TOKEN: "INVALID_TOKEN",
  TOKEN_EXPIRED: "TOKEN_EXPIRED",

  FORBIDDEN: "FORBIDDEN",

  NOT_FOUND: "NOT_FOUND",

  CONFLICT: "CONFLICT",

  RATE_LIMIT_EXCEEDED: "RATE_LIMIT_EXCEEDED",

  SERVICE_UNAVAILABLE: "SERVICE_UNAVAILABLE",

  REQUEST_TIMEOUT: "REQUEST_TIMEOUT",

  EXTERNAL_SERVICE_ERROR: "EXTERNAL_SERVICE_ERROR",
});

// =============================================================================
// CACHE
// =============================================================================

export const CACHE = Object.freeze({
  DEFAULT_TTL_MS: 15 * 60 * 1000,

  MAXIMUM_STALE_MS: 24 * 60 * 60 * 1000,

  CLEANUP_INTERVAL_MS: 5 * 60 * 1000,
});

// =============================================================================
// PAGINATION
// =============================================================================

export const PAGINATION = Object.freeze({
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 20,
  MAX_LIMIT: 100,
});

// =============================================================================
// REQUEST
// =============================================================================

export const REQUEST = Object.freeze({
  DEFAULT_TIMEOUT_MS: 30_000,
  DEFAULT_BODY_LIMIT: "1mb",
});

// =============================================================================
// SECURITY
// =============================================================================

export const SECURITY = Object.freeze({
  AUTH_SCHEME: "Bearer",

  MIN_PASSWORD_LENGTH: 8,

  MAX_PASSWORD_LENGTH: 128,

  MAX_REQUEST_ID_LENGTH: 128,
});

// =============================================================================
// FEATURE FLAGS
// =============================================================================

export const FEATURE = Object.freeze({
  AI: "ai",
  WEATHER: "weather",
  MAPS: "maps",
  NOTIFICATIONS: "notifications",
  REDIS: "redis",
});
