import { HEADER } from "../config/constants.js";
import { verifyFirebaseIdToken } from "../config/firebase-auth.js";
import { AuthenticationError } from "../core/errors/authentication-error.js";
import { logger } from "../config/logger.js";

const AUTH_SCHEME = "Bearer ";

export const firebaseAuthMiddleware = async (req, res, next) => {
  try {
    const authorizationHeader =
      req?.get?.(HEADER.AUTHORIZATION) ?? req?.headers?.authorization;

    if (
      typeof authorizationHeader !== "string" ||
      !authorizationHeader.startsWith(AUTH_SCHEME)
    ) {
      throw AuthenticationError.invalidToken({
        reason: "Authorization header must contain a Bearer token.",
      });
    }

    const token = authorizationHeader.slice(AUTH_SCHEME.length).trim();

    if (!token) {
      throw AuthenticationError.invalidToken({
        reason: "Bearer token is missing.",
      });
    }

    let decodedToken;

    try {
      decodedToken = await verifyFirebaseIdToken(token);
    } catch (error) {
      logger.debug(
        {
          err: error,
          event: "firebase_token_verify_failed",
          code: error?.code,
        },
        "Firebase ID token verification failed",
      );

      throw error;
    }

    req.firebaseUser = {
      uid: decodedToken.uid,
      email:
        typeof decodedToken.email === "string"
          ? decodedToken.email
          : null,
      name:
        typeof decodedToken.name === "string"
          ? decodedToken.name
          : null,
      picture:
        typeof decodedToken.picture === "string"
          ? decodedToken.picture
          : null,
      provider: getAuthProvider(decodedToken),
    };

    return next();
  } catch (error) {
    const normalizedError = normalizeAuthError(error);

    logger.warn(
      {
        err: normalizedError,
        event: "firebase_auth_failed",
        path: req?.originalUrl,
        method: req?.method,
      },
      "Firebase authentication failed",
    );

    return res.status(normalizedError.statusCode).json({
      success: false,
      error: {
        code: normalizedError.code,
        message: normalizedError.message,
        ...(normalizedError.details && {
          details: normalizedError.details,
        }),
      },
      requestId: req?.id,
      timestamp: new Date().toISOString(),
    });
  }
};

function getAuthProvider(decodedToken) {
  const provider =
    decodedToken?.firebase?.sign_in_provider ??
    decodedToken?.provider_id ??
    null;

  if (typeof provider !== "string") {
    return "firebase";
  }

  const normalized = provider.toLowerCase();

  if (normalized.endsWith("google.com")) {
    return "google";
  }

  if (normalized.endsWith("apple.com")) {
    return "apple";
  }

  if (normalized === "password") {
    return "password";
  }

  return "firebase";
}

function normalizeAuthError(error) {
  if (error instanceof AuthenticationError) {
    return error;
  }

  const code = error?.code;

  if (
    code === "auth/id-token-expired" ||
    code === "auth/user-token-expired"
  ) {
    return AuthenticationError.tokenExpired({
      reason: "Firebase ID token has expired.",
    });
  }

  if (
    code === "auth/invalid-id-token" ||
    code === "auth/argument-error" ||
    code === "auth/invalid-user-token" ||
    code === "auth/app-deleted" ||
    code === "auth/user-disabled"
  ) {
    return AuthenticationError.invalidToken({
      reason: "Firebase ID token is invalid or user is not authorized.",
    });
  }

  return AuthenticationError.invalidToken({
    reason: "Unable to verify Firebase authentication token.",
  });
}
