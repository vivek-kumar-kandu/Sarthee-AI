import { ApiResponse } from "../../../core/response/api-response.js";

import { validateHomeQuery } from "../../../modules/home/home.validator.js";

import { homeService } from "../../../modules/home/home.service.js";

/**
 * ============================================================================
 * SARTHEE AI — HOME CONTROLLER
 * ============================================================================
 *
 * HTTP controller for the Home module.
 *
 * Architecture:
 *
 * HTTP Request
 *      ↓
 * Home Routes
 *      ↓
 * Home Controller
 *      ├── Validate request
 *      ├── Extract request context
 *      ├── Call HomeService
 *      └── Build ApiResponse
 *      ↓
 * Home Service
 *      ↓
 * Repository / Mapper / Cache
 *
 * Controller responsibilities:
 *
 * • Read HTTP input
 * • Validate query parameters
 * • Forward normalized context to HomeService
 * • Propagate request IDs
 * • Return standardized API responses
 * • Forward unexpected failures to global error middleware
 *
 * Controller intentionally contains no:
 *
 * • repository queries
 * • database logic
 * • cache implementation
 * • response mapping logic
 * • business orchestration
 */

// =============================================================================
// HOME CONTROLLER
// =============================================================================

export class HomeController {
  constructor({
    service = homeService,
    queryValidator = validateHomeQuery,
  } = {}) {
    validateService(service);
    validateQueryValidator(queryValidator);

    this._service = service;
    this._queryValidator = queryValidator;

    /*
     * Bind methods once so they can safely be passed directly to Express:
     *
     * router.get('/', controller.getHomeContent)
     */
    this.getHomeContent = this.getHomeContent.bind(this);

    this.refreshHomeContent = this.refreshHomeContent.bind(this);

    this.getReadiness = this.getReadiness.bind(this);
  }

  // ==========================================================================
  // GET HOME CONTENT
  // ==========================================================================

  /**
   * GET /api/v1/home
   *
   * Supported query parameters:
   *
   * location
   * latitude
   * longitude
   * locale
   * userId
   * personalized
   */
  async getHomeContent(req, res, next) {
    try {
      const context = this._queryValidator(req?.query ?? {});

      const data = await this._service.getHomeContent(context);

      return sendSuccess(res, {
        data,

        requestId: extractRequestId(req, res),
      });
    } catch (error) {
      return forwardError(error, next);
    }
  }

  // ==========================================================================
  // REFRESH HOME CONTENT
  // ==========================================================================

  /**
   * Refreshes Home content while bypassing normal cache lookup.
   *
   * Intended for:
   *
   * • pull-to-refresh
   * • explicit user refresh
   * • administrative refresh workflows
   *
   * Route recommendation:
   *
   * POST /api/v1/home/refresh
   */
  async refreshHomeContent(req, res, next) {
    try {
      /*
       * Support query parameters today while allowing body-based context in
       * future clients.
       *
       * Query values intentionally win when both sources provide the same
       * field.
       */
      const input = mergeRequestInput(req?.body, req?.query);

      const context = this._queryValidator(input);

      const data = await this._service.refreshHomeContent(context);

      return sendSuccess(res, {
        data,

        requestId: extractRequestId(req, res),
      });
    } catch (error) {
      return forwardError(error, next);
    }
  }

  // ==========================================================================
  // READINESS
  // ==========================================================================

  /**
   * Optional Home-module readiness endpoint.
   *
   * Useful independently from the global health endpoint when debugging
   * module-specific dependencies.
   *
   * Route recommendation:
   *
   * GET /api/v1/home/ready
   */
  async getReadiness(req, res, next) {
    try {
      const ready = await this._service.isReady();

      const data = Object.freeze({
        module: "home",

        ready,

        status: ready ? "ready" : "not_ready",
      });

      return sendSuccess(res, {
        data,

        requestId: extractRequestId(req, res),

        statusCode: ready ? 200 : 503,
      });
    } catch (error) {
      return forwardError(error, next);
    }
  }
}

// =============================================================================
// SUCCESS RESPONSE
// =============================================================================

function sendSuccess(res, { data, requestId, statusCode = 200 }) {
  if (
    !res ||
    typeof res.status !== "function" ||
    typeof res.json !== "function"
  ) {
    throw new TypeError("A valid Express response object is required.");
  }

  const payload = ApiResponse.success({
    data,
    requestId,
  });

  return res.status(statusCode).json(payload);
}

// =============================================================================
// REQUEST ID
// =============================================================================

/**
 * Extracts the request ID assigned by request-id.middleware.js.
 *
 * Multiple locations are supported deliberately so the controller remains
 * compatible if the middleware implementation evolves.
 */
function extractRequestId(req, res) {
  const candidates = [
    req?.requestId,
    req?.id,
    res?.locals?.requestId,
    readHeader(res, "X-Request-Id"),
    readHeader(req, "X-Request-Id"),
  ];

  for (const candidate of candidates) {
    if (typeof candidate === "string" && candidate.trim().length > 0) {
      return candidate.trim();
    }
  }

  return undefined;
}

// =============================================================================
// HEADER ACCESS
// =============================================================================

function readHeader(target, name) {
  if (!target) {
    return undefined;
  }

  if (typeof target.getHeader === "function") {
    const value = target.getHeader(name);

    if (typeof value === "string") {
      return value;
    }

    if (Array.isArray(value)) {
      return value[0];
    }
  }

  if (typeof target.get === "function") {
    return target.get(name);
  }

  return undefined;
}

// =============================================================================
// REQUEST INPUT
// =============================================================================

function mergeRequestInput(body, query) {
  const safeBody = isPlainObject(body) ? body : {};

  const safeQuery = isPlainObject(query) ? query : {};

  return {
    ...safeBody,
    ...safeQuery,
  };
}

function isPlainObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

// =============================================================================
// ERROR FORWARDING
// =============================================================================

function forwardError(error, next) {
  /*
   * In normal Express usage `next` will always exist.
   *
   * Throwing when it does not exist also makes controller unit tests fail
   * loudly instead of silently swallowing application errors.
   */
  if (typeof next === "function") {
    return next(error);
  }

  throw error;
}

// =============================================================================
// DEPENDENCY VALIDATION
// =============================================================================

function validateService(service) {
  if (
    !service ||
    typeof service.getHomeContent !== "function" ||
    typeof service.refreshHomeContent !== "function" ||
    typeof service.isReady !== "function"
  ) {
    throw new TypeError(
      "HomeController service must implement getHomeContent(), " +
        "refreshHomeContent(), and isReady().",
    );
  }
}

function validateQueryValidator(validator) {
  if (typeof validator !== "function") {
    throw new TypeError("HomeController queryValidator must be a function.");
  }
}

// =============================================================================
// FACTORY
// =============================================================================

export function createHomeController(options) {
  return new HomeController(options);
}

// =============================================================================
// DEFAULT INSTANCE
// =============================================================================

export const homeController = new HomeController();

export default homeController;
