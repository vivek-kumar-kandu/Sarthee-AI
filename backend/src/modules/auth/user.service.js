import { ERROR_CODE, HTTP_STATUS } from "../../config/constants.js";
import { AppError } from "../../core/errors/app-error.js";
import { AuthenticationError } from "../../core/errors/authentication-error.js";
import { NotFoundError } from "../../core/errors/not-found-error.js";
import { logger } from "../../config/logger.js";

import { userRepository } from "./user.repository.js";

/**
 * ============================================================================
 * SARTHEE AI — USER SERVICE
 * ============================================================================
 *
 * Business logic for user management and Firebase sync preparation.
 *
 * Responsibilities:
 *
 * • createOrUpdateUser — sync Firebase identity into MongoDB
 * • Profile retrieval and updates
 * • Duplicate prevention for email and firebaseUid
 * • No HTTP or database driver code beyond repository calls
 */

export class UserService {
  constructor({ repository = userRepository } = {}) {
    validateRepository(repository);

    this._repository = repository;
  }

  async createOrUpdateUser(firebaseUserData) {
    const payload = normalizeSyncPayload(firebaseUserData);

    const existingByUid = await this._repository.findByFirebaseUid(
      payload.firebaseUid,
    );

    if (existingByUid) {
      const updatePayload = {
        ...(payload.email ? { email: payload.email } : {}),
        ...(payload.name ? { name: payload.name } : {}),
        ...(payload.picture !== undefined ? { picture: payload.picture } : {}),
        ...(payload.authProvider !== undefined
          ? { authProvider: payload.authProvider }
          : {}),
        lastLoginAt: new Date(),
      };

      const updated = await this._repository.updateUser(
        existingByUid._id,
        updatePayload,
      );

      logger.info(
        {
          module: "auth",
          action: "user_sync_update",
          userId: String(updated._id),
          firebaseUid: updated.firebaseUid,
        },
        "Existing user synced from Firebase context",
      );

      return Object.freeze({
        user: toPublicUser(updated),
        created: false,
      });
    }

    if (!payload.email) {
      throw new AppError({
        message: "Firebase user email is required for account synchronization.",
        statusCode: HTTP_STATUS.BAD_REQUEST,
        code: ERROR_CODE.VALIDATION_ERROR,
      });
    }

    await assertEmailAvailable(
      payload.email,
      payload.firebaseUid,
      this._repository,
    );

    try {
      const created = await this._repository.createUser({
        ...payload,
        lastLoginAt: new Date(),
      });

      logger.info(
        {
          module: "auth",
          action: "user_sync_create",
          userId: String(created._id),
          firebaseUid: created.firebaseUid,
        },
        "New user created from Firebase context",
      );

      return Object.freeze({
        user: toPublicUser(created),
        created: true,
      });
    } catch (error) {
      throw translateDuplicateKeyError(error);
    }
  }

  async getProfileByFirebaseUid(firebaseUid) {
    const normalizedUid = normalizeFirebaseUid(firebaseUid);

    if (!normalizedUid) {
      throw AuthenticationError.invalidToken({
        reason: "Missing Firebase user context.",
      });
    }

    const user = await this._repository.findByFirebaseUid(normalizedUid);

    if (!user) {
      throw NotFoundError.resource("User", normalizedUid);
    }

    if (!user.isActive) {
      throw new AppError({
        message: "User account is inactive.",
        statusCode: HTTP_STATUS.FORBIDDEN,
        code: ERROR_CODE.FORBIDDEN,
      });
    }

    return toPublicUser(user);
  }

  async updateProfileByFirebaseUid(firebaseUid, updateData) {
    const normalizedUid = normalizeFirebaseUid(firebaseUid);

    if (!normalizedUid) {
      throw AuthenticationError.invalidToken({
        reason: "Missing Firebase user context.",
      });
    }

    const user = await this._repository.findByFirebaseUid(normalizedUid);

    if (!user) {
      throw NotFoundError.resource("User", normalizedUid);
    }

    if (!user.isActive) {
      throw new AppError({
        message: "User account is inactive.",
        statusCode: HTTP_STATUS.FORBIDDEN,
        code: ERROR_CODE.FORBIDDEN,
      });
    }

    const updatePayload = buildProfileUpdatePayload(updateData, user);

    const updated = await this._repository.updateUser(user._id, {
      ...updatePayload,
      updatedAt: new Date(),
    });

    if (!updated) {
      throw NotFoundError.resource("User", normalizedUid);
    }

    logger.info(
      {
        module: "auth",
        action: "profile_update",
        userId: String(updated._id),
        firebaseUid: updated.firebaseUid,
      },
      "User profile updated",
    );

    return toPublicUser(updated);
  }
}

async function assertEmailAvailable(email, firebaseUid, repository) {
  const existingByEmail = await repository.findByEmail(email);

  if (existingByEmail && existingByEmail.firebaseUid !== firebaseUid) {
    throw new AppError({
      message: "A user with this email already exists.",
      statusCode: HTTP_STATUS.CONFLICT,
      code: ERROR_CODE.CONFLICT,
      details: {
        field: "email",
      },
    });
  }
}

function buildProfileUpdatePayload(updateData, existingUser) {
  const payload = {};

  if (updateData.profile !== undefined) {
    payload.profile = mergeNestedObject(
      existingUser.profile ?? {},
      updateData.profile,
    );
  }

  if (updateData.location !== undefined) {
    payload.location = mergeNestedObject(
      existingUser.location ?? {},
      updateData.location,
    );
  }

  if (updateData.preferences !== undefined) {
    payload.preferences = mergeNestedObject(
      existingUser.preferences ?? {},
      updateData.preferences,
    );
  }

  return payload;
}

function mergeNestedObject(target, source) {
  const result = { ...target };

  for (const [key, value] of Object.entries(source)) {
    if (value === undefined) {
      continue;
    }

    result[key] = value;
  }

  return result;
}

function normalizeSyncPayload(data) {
  return Object.freeze({
    firebaseUid: data.firebaseUid,
    email: data.email,
    name: data.name,
    ...(data.picture !== undefined && { picture: data.picture }),
    authProvider: data.authProvider ?? "firebase",
  });
}

function normalizeFirebaseUid(value) {
  if (typeof value !== "string") {
    return undefined;
  }

  const normalized = value.trim();

  return normalized.length > 0 ? normalized : undefined;
}

function toPublicUser(document) {
  if (!document) {
    return null;
  }

  return Object.freeze({
    id: String(document._id),
    firebaseUid: document.firebaseUid,
    email: document.email,
    name: document.name,
    picture: document.picture ?? null,
    authProvider: document.authProvider,
    role: document.role,
    profile: Object.freeze({
      dob: document.profile?.dob ?? null,
      gender: document.profile?.gender ?? null,
      location: document.profile?.location ?? null,
      bio: document.profile?.bio ?? null,
    }),
    location: Object.freeze({
      city: document.location?.city ?? null,
      latitude: document.location?.latitude ?? null,
      longitude: document.location?.longitude ?? null,
    }),
    preferences: Object.freeze({
      language: document.preferences?.language ?? null,
      theme: document.preferences?.theme ?? null,
      notifications:
        typeof document.preferences?.notifications === "boolean"
          ? document.preferences.notifications
          : null,
    }),
    isActive: document.isActive,
    createdAt: document.createdAt,
    updatedAt: document.updatedAt,
    lastLoginAt: document.lastLoginAt ?? null,
  });
}

function translateDuplicateKeyError(error) {
  if (!isDuplicateKeyError(error)) {
    throw error;
  }

  const field = extractDuplicateField(error);

  return new AppError({
    message:
      field === "email"
        ? "A user with this email already exists."
        : "A user with this Firebase UID already exists.",
    statusCode: HTTP_STATUS.CONFLICT,
    code: ERROR_CODE.CONFLICT,
    details: {
      field,
    },
    cause: error,
  });
}

function isDuplicateKeyError(error) {
  return error?.code === 11000 || error?.name === "MongoServerError";
}

function extractDuplicateField(error) {
  const keyPattern = error?.keyPattern ?? error?.errorResponse?.keyPattern;

  if (keyPattern?.email) {
    return "email";
  }

  if (keyPattern?.firebaseUid) {
    return "firebaseUid";
  }

  const keyValue = error?.keyValue ?? error?.errorResponse?.keyValue;

  if (keyValue?.email) {
    return "email";
  }

  if (keyValue?.firebaseUid) {
    return "firebaseUid";
  }

  return "unknown";
}

function validateRepository(repository) {
  const requiredMethods = [
    "findByFirebaseUid",
    "findByEmail",
    "findById",
    "createUser",
    "updateUser",
    "deleteUser",
  ];

  for (const method of requiredMethods) {
    if (typeof repository?.[method] !== "function") {
      throw new TypeError(`UserService repository must implement ${method}().`);
    }
  }
}

export function createUserService(options) {
  return new UserService(options);
}

export const userService = new UserService();

export default userService;
