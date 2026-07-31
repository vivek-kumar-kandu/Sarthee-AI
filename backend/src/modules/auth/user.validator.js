import { z } from "zod";

import { ValidationError } from "../../core/errors/validation-error.js";

/**
 * ============================================================================
 * SARTHEE AI — USER VALIDATION
 * ============================================================================
 *
 * Zod validation for Auth/User API input.
 *
 * Responsibilities:
 *
 * • Sanitize and normalize request input
 * • Validate create/sync payloads
 * • Validate profile update payloads
 * • Return immutable normalized objects
 */

const USER_VALIDATION_LIMITS = Object.freeze({
  firebaseUidMaxLength: 128,
  nameMaxLength: 160,
  languageMaxLength: 35,
  countryMaxLength: 120,
  cityMaxLength: 160,
  travelStyleMaxLength: 80,
  budgetRangeMaxLength: 80,
  stringListItemMaxLength: 80,
  stringListMaxItems: 50,
});

const trimmedString = ({ fieldName, maxLength, required = false }) => {
  const schema = z.preprocess(
    (value) => sanitizeString(value),
    z
      .string({
        error: `${fieldName} must be a string.`,
      })
      .max(maxLength, `${fieldName} must not exceed ${maxLength} characters.`),
  );

  return required ? schema : schema.optional();
};

const _stringListField = ({ fieldName }) =>
  z
    .array(
      z
        .string({
          error: `${fieldName} items must be strings.`,
        })
        .trim()
        .min(1, `${fieldName} items must not be empty.`)
        .max(
          USER_VALIDATION_LIMITS.stringListItemMaxLength,
          `${fieldName} items must not exceed ${USER_VALIDATION_LIMITS.stringListItemMaxLength} characters.`,
        ),
    )
    .max(
      USER_VALIDATION_LIMITS.stringListMaxItems,
      `${fieldName} must not exceed ${USER_VALIDATION_LIMITS.stringListMaxItems} items.`,
    )
    .optional();

const profileSchema = z
  .object({
    dob: trimmedString({
      fieldName: "profile.dob",
      maxLength: 100,
    }),

    gender: trimmedString({
      fieldName: "profile.gender",
      maxLength: 40,
    }),

    location: trimmedString({
      fieldName: "profile.location",
      maxLength: 200,
    }),

    bio: trimmedString({
      fieldName: "profile.bio",
      maxLength: 500,
    }),

    // Removed unsupported profile fields to match the database schema.
  })
  .strict()
  .optional();

const locationSchema = z
  .object({
    city: trimmedString({
      fieldName: "location.city",
      maxLength: USER_VALIDATION_LIMITS.cityMaxLength,
    }),

    latitude: z
      .number({
        error: "location.latitude must be a valid number.",
      })
      .finite("location.latitude must be finite.")
      .min(-90, "location.latitude must be greater than or equal to -90.")
      .max(90, "location.latitude must be less than or equal to 90.")
      .optional(),

    longitude: z
      .number({
        error: "location.longitude must be a valid number.",
      })
      .finite("location.longitude must be finite.")
      .min(-180, "location.longitude must be greater than or equal to -180.")
      .max(180, "location.longitude must be less than or equal to 180.")
      .optional(),
  })
  .strict()
  .superRefine((value, context) => {
    const hasLatitude = value.latitude !== undefined;
    const hasLongitude = value.longitude !== undefined;

    if (hasLatitude !== hasLongitude) {
      context.addIssue({
        code: "custom",
        path: hasLatitude ? ["longitude"] : ["latitude"],
        message:
          "location.latitude and location.longitude must be provided together.",
      });
    }
  })
  .optional();

const preferencesSchema = z
  .object({
    language: trimmedString({
      fieldName: "preferences.language",
      maxLength: USER_VALIDATION_LIMITS.languageMaxLength,
    }),

    theme: trimmedString({
      fieldName: "preferences.theme",
      maxLength: 50,
    }),

    notifications: z
      .boolean({
        invalid_type_error: "preferences.notifications must be a boolean.",
      })
      .optional(),
  })
  .strict()
  .optional();

export const syncUserSchema = z
  .object({})
  .strict()
  .transform(() => Object.freeze({}));

export const updateUserProfileSchema = z
  .object({
    profile: profileSchema,
    location: locationSchema,
    preferences: preferencesSchema,
  })
  .strict()
  .superRefine((value, context) => {
    const hasUpdate =
      value.profile !== undefined ||
      value.location !== undefined ||
      value.preferences !== undefined;

    if (!hasUpdate) {
      context.addIssue({
        code: "custom",
        path: [],
        message:
          "At least one of profile, location, or preferences must be provided.",
      });
    }
  })
  .transform((value) =>
    Object.freeze({
      ...(value.profile !== undefined && { profile: value.profile }),
      ...(value.location !== undefined && { location: value.location }),
      ...(value.preferences !== undefined && {
        preferences: value.preferences,
      }),
    }),
  );

export const firebaseUidHeaderSchema = z
  .object({
    firebaseUid: trimmedString({
      fieldName: "firebaseUid",
      maxLength: USER_VALIDATION_LIMITS.firebaseUidMaxLength,
      required: true,
    }),
  })
  .strict()
  .transform((value) =>
    Object.freeze({
      firebaseUid: value.firebaseUid,
    }),
  );

export function validateSyncUser(body = {}) {
  return parseSchema(syncUserSchema, body, "Invalid auth sync request.");
}

export function validateUpdateUserProfile(body = {}) {
  return parseSchema(
    updateUserProfileSchema,
    body,
    "Invalid profile update request.",
  );
}

export function validateFirebaseUidHeader(firebaseUid) {
  return parseSchema(
    firebaseUidHeaderSchema,
    { firebaseUid },
    "Invalid Firebase user context.",
  );
}

function parseSchema(schema, value, message) {
  const result = schema.safeParse(value);

  if (!result.success) {
    throw createUserValidationError(result.error, message);
  }

  return result.data;
}

function createUserValidationError(zodError, message) {
  if (typeof ValidationError.fromZodError === "function") {
    return ValidationError.fromZodError(zodError, { message });
  }

  return ValidationError.fromIssues(
    zodError.issues.map((issue) => ({
      field: issue.path.length > 0 ? issue.path.join(".") : null,
      message: issue.message,
      code: issue.code,
    })),
    { message },
  );
}

function sanitizeString(value) {
  if (value === undefined || value === null) {
    return undefined;
  }

  if (typeof value !== "string") {
    return value;
  }

  const normalized = value.trim();

  return normalized.length > 0 ? normalized : undefined;
}

export const userValidationLimits = USER_VALIDATION_LIMITS;

export default validateSyncUser;

