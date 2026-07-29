import { z } from "zod";

import { ValidationError } from "../../core/errors/validation-error.js";

/**
 * ============================================================================
 * SARTHEE AI — HOME VALIDATION
 * ============================================================================
 *
 * Central validation boundary for Home API input.
 *
 * Responsibilities:
 *
 * • Validate Home query parameters
 * • Normalize optional text
 * • Normalize locale values
 * • Validate latitude / longitude
 * • Reject partial coordinate pairs
 * • Parse boolean query values safely
 * • Limit input sizes
 * • Return immutable normalized values
 * • Prevent transport-specific input from leaking into the service layer
 *
 * Request flow:
 *
 * HTTP Request
 *      ↓
 * Home Route
 *      ↓
 * Home Validator
 *      ↓
 * Home Controller
 *      ↓
 * Home Service
 *
 * The service layer should receive trusted, normalized input.
 */

// ============================================================================
// LIMITS
// ============================================================================

const HOME_VALIDATION_LIMITS = Object.freeze({
  locationNameMaxLength: 160,
  localeMaxLength: 35,
  userIdMaxLength: 128,
});

// ============================================================================
// HELPERS
// ============================================================================

const optionalTrimmedString = ({ fieldName, maxLength }) =>
  z.preprocess(
    (value) => {
      if (value === undefined || value === null) {
        return undefined;
      }

      if (typeof value !== "string") {
        return value;
      }

      const normalized = value.trim();

      return normalized.length === 0 ? undefined : normalized;
    },
    z
      .string({
        error: `${fieldName} must be a string.`,
      })
      .max(maxLength, `${fieldName} must not exceed ${maxLength} characters.`)
      .optional(),
  );

const optionalNumber = ({ fieldName, min, max }) =>
  z.preprocess(
    (value) => {
      if (value === undefined || value === null || value === "") {
        return undefined;
      }

      if (typeof value === "number") {
        return value;
      }

      if (typeof value !== "string") {
        return value;
      }

      const normalized = value.trim();

      if (normalized.length === 0) {
        return undefined;
      }

      const parsed = Number(normalized);

      return Number.isNaN(parsed) ? value : parsed;
    },
    z
      .number({
        error: `${fieldName} must be a valid number.`,
      })
      .finite(`${fieldName} must be finite.`)
      .min(min, `${fieldName} must be greater than or equal to ${min}.`)
      .max(max, `${fieldName} must be less than or equal to ${max}.`)
      .optional(),
  );

const optionalBoolean = ({ fieldName }) =>
  z.preprocess(
    (value) => {
      if (value === undefined || value === null || value === "") {
        return undefined;
      }

      if (typeof value === "boolean") {
        return value;
      }

      if (typeof value !== "string") {
        return value;
      }

      switch (value.trim().toLowerCase()) {
        case "true":
        case "1":
        case "yes":
        case "on":
          return true;

        case "false":
        case "0":
        case "no":
        case "off":
          return false;

        default:
          return value;
      }
    },
    z
      .boolean({
        error: `${fieldName} must be a valid boolean.`,
      })
      .optional(),
  );

// ============================================================================
// HOME QUERY SCHEMA
// ============================================================================

export const homeQuerySchema = z
  .object({
    location: optionalTrimmedString({
      fieldName: "location",
      maxLength: HOME_VALIDATION_LIMITS.locationNameMaxLength,
    }),

    locationName: optionalTrimmedString({
      fieldName: "locationName",
      maxLength: HOME_VALIDATION_LIMITS.locationNameMaxLength,
    }),

    latitude: optionalNumber({
      fieldName: "latitude",
      min: -90,
      max: 90,
    }),

    longitude: optionalNumber({
      fieldName: "longitude",
      min: -180,
      max: 180,
    }),

    locale: optionalTrimmedString({
      fieldName: "locale",
      maxLength: HOME_VALIDATION_LIMITS.localeMaxLength,
    }),

    userId: optionalTrimmedString({
      fieldName: "userId",
      maxLength: HOME_VALIDATION_LIMITS.userIdMaxLength,
    }),

    personalized: optionalBoolean({
      fieldName: "personalized",
    }),

    forcePersonalization: optionalBoolean({
      fieldName: "forcePersonalization",
    }),
  })
  .strict()
  .superRefine((value, context) => {
    const hasLatitude = value.latitude !== undefined;
    const hasLongitude = value.longitude !== undefined;

    // Coordinates must always be supplied as a complete pair.
    if (hasLatitude !== hasLongitude) {
      context.addIssue({
        code: "custom",
        path: hasLatitude ? ["longitude"] : ["latitude"],
        message:
          "latitude and longitude must be provided together as a complete coordinate pair.",
      });
    }
  })
  .transform((value) => {
    const locationName = normalizeOptionalText(
      value.locationName ?? value.location,
    );

    const locale = normalizeLocale(value.locale);

    const userId = normalizeOptionalText(value.userId);

    const forcePersonalization =
      value.forcePersonalization ?? value.personalized ?? false;

    return Object.freeze({
      locationName,
      latitude: value.latitude,
      longitude: value.longitude,
      locale,
      userId,
      forcePersonalization,
    });
  });

// ============================================================================
// PUBLIC VALIDATOR
// ============================================================================

/**
 * Validates and normalizes query parameters for:
 *
 * GET /api/v1/home
 *
 * Returns:
 *
 * {
 *   locationName,
 *   latitude,
 *   longitude,
 *   locale,
 *   userId,
 *   forcePersonalization
 * }
 */
export function validateHomeQuery(query = {}) {
  const result = homeQuerySchema.safeParse(query);

  if (!result.success) {
    throw createHomeValidationError(result.error);
  }

  return result.data;
}

/**
 * Alias useful when the controller wants semantic naming around request
 * parsing rather than schema validation.
 */
export const parseHomeQuery = validateHomeQuery;

// ============================================================================
// VALIDATION ERROR MAPPING
// ============================================================================

function createHomeValidationError(zodError) {
  const issues = zodError.issues.map((issue) =>
    Object.freeze({
      field: issue.path.length > 0 ? issue.path.join(".") : null,
      message: issue.message,
      code: issue.code,
    }),
  );

  /*
   * Keep this defensive because different project versions may expose
   * ValidationError through slightly different constructor APIs.
   */
  if (typeof ValidationError.fromIssues === "function") {
    return ValidationError.fromIssues(issues, {
      message: "Invalid Home request.",
    });
  }

  if (typeof ValidationError.fromZodError === "function") {
    return ValidationError.fromZodError(zodError, {
      message: "Invalid Home request.",
    });
  }

  return new ValidationError("Invalid Home request.", {
    issues,
  });
}

// ============================================================================
// NORMALIZATION
// ============================================================================

function normalizeOptionalText(value) {
  if (typeof value !== "string") {
    return undefined;
  }

  const normalized = value.trim();

  return normalized.length > 0 ? normalized : undefined;
}

/**
 * Normalizes common BCP-47 style locale representations.
 *
 * Examples:
 *
 * EN          -> en
 * HI          -> hi
 * en_us       -> en-US
 * hi_in       -> hi-IN
 * zh_hans     -> zh-Hans
 * zh_hans_cn  -> zh-Hans-CN
 */
function normalizeLocale(value) {
  const locale = normalizeOptionalText(value);

  if (!locale) {
    return undefined;
  }

  const parts = locale
    .replaceAll("_", "-")
    .split("-")
    .map((part) => part.trim())
    .filter(Boolean);

  if (parts.length === 0) {
    return undefined;
  }

  const normalized = [parts[0].toLowerCase()];

  for (let index = 1; index < parts.length; index += 1) {
    const part = parts[index];

    if (looksLikeRegion(part)) {
      normalized.push(part.toUpperCase());
      continue;
    }

    if (looksLikeScript(part)) {
      normalized.push(`${part[0].toUpperCase()}${part.slice(1).toLowerCase()}`);
      continue;
    }

    normalized.push(part.toLowerCase());
  }

  return normalized.join("-");
}

function looksLikeRegion(value) {
  return /^[A-Za-z]{2}$/.test(value) || /^[0-9]{3}$/.test(value);
}

function looksLikeScript(value) {
  return /^[A-Za-z]{4}$/.test(value);
}

// ============================================================================
// EXPORTED CONFIGURATION
// ============================================================================

export const homeValidationLimits = HOME_VALIDATION_LIMITS;

export default validateHomeQuery;
