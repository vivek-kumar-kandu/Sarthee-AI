import helmet from "helmet";

import { env } from "../config/env.js";

/**
 * ============================================================================
 * SARTHEE AI — SECURITY MIDDLEWARE
 * ============================================================================
 *
 * Central HTTP security headers.
 *
 * Helmet protects against several common browser-based attack classes by
 * configuring defensive HTTP response headers.
 *
 * API-specific notes:
 *
 * • CSP remains enabled.
 * • HSTS is enabled only in production.
 * • crossOriginResourcePolicy is configured for API/mobile compatibility.
 */

export const securityMiddleware = helmet({
  // ===========================================================================
  // CONTENT SECURITY POLICY
  // ===========================================================================

  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],

      baseUri: ["'self'"],

      fontSrc: ["'self'", "https:", "data:"],

      formAction: ["'self'"],

      frameAncestors: ["'none'"],

      imgSrc: ["'self'", "data:", "https:"],

      objectSrc: ["'none'"],

      scriptSrc: ["'self'"],

      scriptSrcAttr: ["'none'"],

      styleSrc: ["'self'", "'unsafe-inline'", "https:"],

      upgradeInsecureRequests: env.isProduction ? [] : null,
    },
  },

  // ===========================================================================
  // HSTS
  // ===========================================================================

  strictTransportSecurity: env.isProduction
    ? {
        maxAge: 31_536_000,
        includeSubDomains: true,
        preload: true,
      }
    : false,

  // ===========================================================================
  // CROSS ORIGIN
  // ===========================================================================

  crossOriginResourcePolicy: {
    policy: "cross-origin",
  },

  crossOriginOpenerPolicy: {
    policy: "same-origin",
  },

  // ===========================================================================
  // REFERRER
  // ===========================================================================

  referrerPolicy: {
    policy: "no-referrer",
  },

  // ===========================================================================
  // MIME SNIFFING
  // ===========================================================================

  noSniff: true,

  // ===========================================================================
  // DNS PREFETCH
  // ===========================================================================

  dnsPrefetchControl: {
    allow: false,
  },

  // ===========================================================================
  // FRAME PROTECTION
  // ===========================================================================

  frameguard: {
    action: "deny",
  },

  // ===========================================================================
  // LEGACY XSS HEADER
  // ===========================================================================

  xssFilter: false,
});

