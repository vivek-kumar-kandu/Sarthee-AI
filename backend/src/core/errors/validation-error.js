import { ERROR_CODE, HTTP_STATUS } from "../../config/constants.js";

import { AppError } from "./app-error.js";

/**
 * ============================================================================
 * SARTHEE AI — VALIDATION ERROR
 * ============================================================================
 *
 * Standard operational error representing invalid client/application input.
 *
 * Designed for:
 *
 * • Zod validation
 * • Query parameter validation
 * • Request body validation
 * • Route parameter validation
 * • Service/domain validation
 * • Field-level validation
 *
 * Architecture:
 *
 * Request
 *    ↓
 * Validator
 *    ↓
 * ValidationError
 *    ↓
 * Global Error Middleware
 *    ↓
 * Standard API Error Response
 */
export class ValidationError extends AppError {
  constructor({ message = "Validation failed.", details, cause } = {}) {
    super({
      message,

      statusCode: HTTP_STATUS.UNPROCESSABLE_ENTITY ?? 422,

      code: ERROR_CODE.VALIDATION_ERROR ?? "VALIDATION_ERROR",

      details,

      cause,

      isOperational: true,
    });
  }

  // ==========================================================================
  // FACTORIES
  // ==========================================================================

  /**
   * Creates a validation error from normalized validation issues.
   *
   * Example:
   *
   * ValidationError.fromIssues([
   *   {
   *     field: 'latitude',
   *     message: 'latitude is invalid.',
   *     code: 'invalid_value',
   *   },
   * ]);
   */
  static fromIssues(
    issues = [],
    { message = "Validation failed.", details, cause } = {},
  ) {
    const normalizedIssues = normalizeIssues(issues);

    const normalizedDetails = {
      ...normalizeDetails(details),

      issues: normalizedIssues,
    };

    return new ValidationError({
      message,

      details: Object.freeze(normalizedDetails),

      cause,
    });
  }

  /**
   * Converts a Zod validation error into the application's standardized
   * validation format.
   */
  static fromZodError(
    error,
    { message = "Validation failed.", details, cause } = {},
  ) {
    const issues = Array.isArray(error?.issues)
      ? error.issues.map((issue) => ({
          field:
            Array.isArray(issue.path) && issue.path.length > 0
              ? issue.path.join(".")
              : null,

          message:
            typeof issue.message === "string" && issue.message.trim()
              ? issue.message.trim()
              : "Invalid value.",

          code:
            typeof issue.code === "string" && issue.code.trim()
              ? issue.code.trim()
              : "validation_error",
        }))
      : [];

    return ValidationError.fromIssues(issues, {
      message,

      details,

      cause: cause ?? error,
    });
  }

  /**
   * Creates a validation error for one field.
   */
  static field(field, message, code = "invalid_value") {
    return ValidationError.fromIssues([
      {
        field,
        message,
        code,
      },
    ]);
  }

  /**
   * Creates a standard required-field validation error.
   */
  static required(field) {
    const normalizedField = normalizeFieldName(field);

    return ValidationError.field(
      normalizedField,
      `${normalizedField} is required.`,
      "required",
    );
  }

  /**
   * Creates a validation error for multiple required fields.
   */
  static requiredFields(fields = []) {
    const normalizedFields = Array.isArray(fields)
      ? fields.map(normalizeFieldName).filter(Boolean)
      : [];

    return ValidationError.fromIssues(
      normalizedFields.map((field) => ({
        field,
        message: `${field} is required.`,
        code: "required",
      })),
    );
  }

  // ==========================================================================
  // DERIVED STATE
  // ==========================================================================

  /**
   * Normalized validation issues.
   */
  get issues() {
    return Array.isArray(this.details?.issues) ? this.details.issues : [];
  }

  /**
   * Whether this error contains field-level issues.
   */
  get hasIssues() {
    return this.issues.length > 0;
  }

  /**
   * Unique fields involved in validation failures.
   */
  get fields() {
    return Object.freeze([
      ...new Set(this.issues.map((issue) => issue.field).filter(Boolean)),
    ]);
  }

  /**
   * Whether a particular field contains a validation error.
   */
  hasField(field) {
    const normalizedField = normalizeFieldName(field);

    if (!normalizedField) {
      return false;
    }

    return this.issues.some((issue) => issue.field === normalizedField);
  }

  /**
   * Returns validation issues associated with a particular field.
   */
  issuesFor(field) {
    const normalizedField = normalizeFieldName(field);

    if (!normalizedField) {
      return Object.freeze([]);
    }

    return Object.freeze(
      this.issues.filter((issue) => issue.field === normalizedField),
    );
  }
}

// =============================================================================
// ISSUE NORMALIZATION
// =============================================================================

function normalizeIssues(issues) {
  if (!Array.isArray(issues)) {
    return Object.freeze([]);
  }

  const normalized = issues.map((issue) => {
    const field = normalizeFieldName(issue?.field);

    const message = normalizeMessage(issue?.message);

    const code = normalizeIssueCode(issue?.code);

    return Object.freeze({
      field,
      message,
      code,
    });
  });

  return Object.freeze(normalized);
}

// =============================================================================
// DETAILS NORMALIZATION
// =============================================================================

function normalizeDetails(details) {
  if (
    details === null ||
    details === undefined ||
    typeof details !== "object" ||
    Array.isArray(details)
  ) {
    return {};
  }

  return {
    ...details,
  };
}

// =============================================================================
// FIELD NORMALIZATION
// =============================================================================

function normalizeFieldName(field) {
  if (typeof field !== "string") {
    return null;
  }

  const normalized = field.trim();

  return normalized.length > 0 ? normalized : null;
}

// =============================================================================
// MESSAGE NORMALIZATION
// =============================================================================

function normalizeMessage(message) {
  if (typeof message !== "string") {
    return "Invalid value.";
  }

  const normalized = message.trim();

  return normalized.length > 0 ? normalized : "Invalid value.";
}

// =============================================================================
// CODE NORMALIZATION
// =============================================================================

function normalizeIssueCode(code) {
  if (typeof code !== "string") {
    return "validation_error";
  }

  const normalized = code.trim();

  return normalized.length > 0 ? normalized : "validation_error";
}

// =============================================================================
// DEFAULT EXPORT
// =============================================================================

export default ValidationError;

