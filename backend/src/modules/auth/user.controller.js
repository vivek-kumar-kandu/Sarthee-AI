import { HTTP_STATUS } from "../../config/constants.js";
import { ApiResponse } from "../../core/response/api-response.js";
import { logger } from "../../config/logger.js";

import { userService } from "./user.service.js";
import {
  validateSyncUser,
  validateUpdateUserProfile,
} from "./user.validator.js";

/**
 * ============================================================================
 * SARTHEE AI — USER CONTROLLER
 * ============================================================================
 *
 * HTTP controller for Auth/User endpoints.
 *
 * Flow:
 *
 * HTTP Request
 *      ↓
 * Auth Routes
 *      ↓
 * User Controller
 *      ├── Validate input
 *      ├── Call UserService
 *      └── Build ApiResponse
 */

export class UserController {
  constructor({
    service = userService,
    syncValidator = validateSyncUser,
    profileUpdateValidator = validateUpdateUserProfile,
  } = {}) {
    validateService(service);
    validateFunction(syncValidator, "syncValidator");
    validateFunction(profileUpdateValidator, "profileUpdateValidator");

    this._service = service;
    this._syncValidator = syncValidator;
    this._profileUpdateValidator = profileUpdateValidator;

    this.syncUser = this.syncUser.bind(this);
    this.getProfile = this.getProfile.bind(this);
    this.updateProfile = this.updateProfile.bind(this);
  }

  /**
   * POST /api/v1/auth/sync
   *
   * Syncs Firebase user identity into MongoDB.
   */
  async syncUser(req, res, next) {
    try {
      this._syncValidator(req?.body ?? {});
      const firebaseUser = req?.firebaseUser;

      if (!firebaseUser?.uid) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          success: false,
          message: "Firebase authentication required.",
          code: "AUTHENTICATION_REQUIRED",
        });
      }

      const result = await this._service.createOrUpdateUser({
        firebaseUid: firebaseUser.uid,
        email: firebaseUser.email ?? null,
        name: firebaseUser.name ?? firebaseUser.email ?? "User",
        picture: firebaseUser.picture ?? null,
        authProvider: firebaseUser.provider ?? "firebase",
      });

      logger.debug(
        {
          module: "auth",
          action: "sync_user",
          created: result.created,
          userId: result.user.id,
        },
        "Auth sync completed",
      );

      return sendSuccess(res, {
        data: Object.freeze({
          user: result.user,
          created: result.created,
        }),
        requestId: extractRequestId(req, res),
        statusCode: result.created ? HTTP_STATUS.CREATED : HTTP_STATUS.OK,
      });
    } catch (error) {
      return forwardError(error, next);
    }
  }

  /**
   * GET /api/v1/auth/profile
   *
   * Returns the current user profile.
   */
  async getProfile(req, res, next) {
    try {
      const firebaseUid = req?.firebaseUser?.uid;

      if (!firebaseUid) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          success: false,
          message: "Firebase authentication required.",
          code: "AUTHENTICATION_REQUIRED",
        });
      }

      const user = await this._service.getProfileByFirebaseUid(firebaseUid);

      return sendSuccess(res, {
        data: Object.freeze({ user }),
        requestId: extractRequestId(req, res),
      });
    } catch (error) {
      return forwardError(error, next);
    }
  }

  /**
   * PUT /api/v1/auth/profile
   *
   * Updates profile, location, and preferences for the current user.
   */
  async updateProfile(req, res, next) {
    try {
      const firebaseUid = req?.firebaseUser?.uid;

      if (!firebaseUid) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          success: false,
          message: "Firebase authentication required.",
          code: "AUTHENTICATION_REQUIRED",
        });
      }

      const payload = this._profileUpdateValidator(req?.body ?? {});

      const user = await this._service.updateProfileByFirebaseUid(
        firebaseUid,
        payload,
      );

      return sendSuccess(res, {
        data: Object.freeze({ user }),
        requestId: extractRequestId(req, res),
      });
    } catch (error) {
      return forwardError(error, next);
    }
  }
}

function sendSuccess(res, { data, requestId, statusCode = HTTP_STATUS.OK }) {
  const payload = ApiResponse.success({
    data,
    requestId,
  });

  return res.status(statusCode).json(payload);
}

function readHeader(req, name) {
  if (!req || typeof req.get !== "function") {
    return undefined;
  }

  return req.get(name);
}

function extractRequestId(req, res) {
  const candidates = [
    req?.requestId,
    req?.id,
    res?.locals?.requestId,
    readHeader(req, "x-request-id"),
  ];

  for (const candidate of candidates) {
    if (typeof candidate === "string" && candidate.trim().length > 0) {
      return candidate.trim();
    }
  }

  return undefined;
}

function forwardError(error, next) {
  if (typeof next === "function") {
    return next(error);
  }

  throw error;
}

function validateService(service) {
  const requiredMethods = [
    "createOrUpdateUser",
    "getProfileByFirebaseUid",
    "updateProfileByFirebaseUid",
  ];

  for (const method of requiredMethods) {
    if (typeof service?.[method] !== "function") {
      throw new TypeError(`UserController service must implement ${method}().`);
    }
  }
}

function validateFunction(value, name) {
  if (typeof value !== "function") {
    throw new TypeError(`UserController ${name} must be a function.`);
  }
}

export function createUserController(options) {
  return new UserController(options);
}

export const userController = new UserController();

export default userController;
