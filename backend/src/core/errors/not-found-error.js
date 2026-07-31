import { HTTP_STATUS, ERROR_CODE } from "../../config/constants.js";
import { AppError } from "./app-error.js";

export class NotFoundError extends AppError {
  constructor({
    message = "The requested resource was not found.",
    resource,
    resourceId,
    details,
    cause,
  } = {}) {
    const normalizedDetails = {
      ...(details ?? {}),
      ...(resource !== undefined && { resource }),
      ...(resourceId !== undefined && { resourceId }),
    };

    super({
      message,
      statusCode: HTTP_STATUS.NOT_FOUND,
      code: ERROR_CODE.NOT_FOUND,
      details:
        Object.keys(normalizedDetails).length > 0
          ? normalizedDetails
          : undefined,
      cause,
      isOperational: true,
    });
  }

  static resource(resource, resourceId) {
    const resourceName =
      typeof resource === "string" && resource.trim()
        ? resource.trim()
        : "Resource";

    return new NotFoundError({
      message: `${resourceName} was not found.`,
      resource: resourceName,
      resourceId,
    });
  }
}

