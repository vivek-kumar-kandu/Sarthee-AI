import { HTTP_STATUS, ERROR_CODE } from "../../config/constants.js";
import { AppError } from "./app-error.js";

export class AuthenticationError extends AppError {
  constructor({
    message = "Authentication is required.",
    code = ERROR_CODE.AUTHENTICATION_REQUIRED,
    details,
    cause,
  } = {}) {
    super({
      message,
      statusCode: HTTP_STATUS.UNAUTHORIZED,
      code,
      details,
      cause,
      isOperational: true,
    });
  }

  static invalidCredentials(details) {
    return new AuthenticationError({
      message: "Invalid credentials.",
      code: ERROR_CODE.INVALID_CREDENTIALS,
      details,
    });
  }

  static invalidToken(details) {
    return new AuthenticationError({
      message: "Invalid authentication token.",
      code: ERROR_CODE.INVALID_TOKEN,
      details,
    });
  }

  static tokenExpired(details) {
    return new AuthenticationError({
      message: "Authentication token has expired.",
      code: ERROR_CODE.TOKEN_EXPIRED,
      details,
    });
  }
}
