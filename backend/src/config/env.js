import "dotenv/config";

import { z } from "zod";

const booleanFromString = z
  .enum(["true", "false"])
  .transform((value) => value === "true");

const optionalUrl = z
  .string()
  .trim()
  .optional()
  .transform((value) => {
    if (!value) {
      return undefined;
    }

    return value;
  })
  .pipe(z.url().optional());

const optionalString = z
  .string()
  .trim()
  .optional()
  .transform((value) => {
    if (!value) {
      return undefined;
    }

    return value;
  });

const envSchema = z
  .object({
    // =========================================================================
    // APPLICATION
    // =========================================================================

    NODE_ENV: z
      .enum(["development", "test", "production"])
      .default("development"),

    APP_NAME: z.string().trim().min(1).default("Sarthee AI"),

    APP_VERSION: z.string().trim().min(1).default("1.0.0"),

    // =========================================================================
    // SERVER
    // =========================================================================

    HOST: z.string().trim().min(1).default("0.0.0.0"),

    PORT: z.coerce.number().int().min(1).max(65535).default(5000),

    API_PREFIX: z
      .string()
      .trim()
      .min(1)
      .default("/api/v1")
      .transform((value) => normalizeApiPrefix(value)),

    SHUTDOWN_TIMEOUT_MS: z.coerce.number().int().positive().default(10000),

    // =========================================================================
    // REQUEST
    // =========================================================================

    REQUEST_BODY_LIMIT: z.string().trim().min(1).default("1mb"),

    REQUEST_TIMEOUT_MS: z.coerce.number().int().positive().default(30000),

    // =========================================================================
    // CORS
    // =========================================================================

    CORS_ORIGINS: z.string().default(""),

    // =========================================================================
    // RATE LIMIT
    // =========================================================================

    RATE_LIMIT_WINDOW_MS: z.coerce.number().int().positive().default(900000),

    RATE_LIMIT_MAX_REQUESTS: z.coerce.number().int().positive().default(200),

    // =========================================================================
    // LOGGING
    // =========================================================================

    LOG_LEVEL: z
      .enum(["fatal", "error", "warn", "info", "debug", "trace", "silent"])
      .default("info"),

    LOG_PRETTY: booleanFromString.default(false),

    // =========================================================================
    // DATABASE
    // =========================================================================

    DATABASE_URL: optionalUrl,

    // =========================================================================
    // FIREBASE ADMIN
    // =========================================================================

    FIREBASE_PROJECT_ID: optionalString,

    FIREBASE_CLIENT_EMAIL: optionalString,

    FIREBASE_PRIVATE_KEY: optionalString,

    FIREBASE_SERVICE_ACCOUNT_PATH: optionalString,

    // =========================================================================
    // CACHE
    // =========================================================================

    REDIS_URL: optionalUrl,

    // =========================================================================
    // INTELLIGENCE & PROVIDER FLAGS
    // =========================================================================

    OVERPASS_API_URL: z.string().trim().default("https://overpass-api.de/api/interpreter"),

    ENABLE_POI: booleanFromString.default(true),

    ENABLE_WEATHER: booleanFromString.default(true),

    ENABLE_GEMINI: booleanFromString.default(true),

    // =========================================================================
    // AUTHENTICATION
    // =========================================================================

    JWT_ACCESS_SECRET: optionalString,

    JWT_REFRESH_SECRET: optionalString,

    JWT_ACCESS_EXPIRES_IN: z.string().trim().min(1).default("15m"),

    JWT_REFRESH_EXPIRES_IN: z.string().trim().min(1).default("30d"),

    // =========================================================================
    // AI
    // =========================================================================

    GEMINI_API_KEY: optionalString,

    OPENAI_API_KEY: optionalString,

    // =========================================================================
    // MAPS
    // =========================================================================

    GOOGLE_MAPS_API_KEY: optionalString,

    PLACES_API_KEY: optionalString,

    // =========================================================================
    // WEATHER
    // =========================================================================

    WEATHER_API_KEY: optionalString,

    // =========================================================================
    // STORAGE
    // =========================================================================

    STORAGE_PROVIDER: z
      .enum(["local", "s3", "gcs", "firebase"])
      .default("local"),

    STORAGE_BUCKET: optionalString,

    // =========================================================================
    // NOTIFICATIONS
    // =========================================================================

    FCM_PROJECT_ID: optionalString,

    FCM_CLIENT_EMAIL: optionalString,

    FCM_PRIVATE_KEY: optionalString,

    // =========================================================================
    // FEATURE FLAGS
    // =========================================================================

    ENABLE_AI: booleanFromString.default(false),

    ENABLE_WEATHER: booleanFromString.default(false),

    ENABLE_MAPS: booleanFromString.default(false),

    ENABLE_NOTIFICATIONS: booleanFromString.default(false),

    ENABLE_REDIS: booleanFromString.default(false),
  })
  .superRefine((values, context) => {
    validateFeatureDependencies(values, context);
    validateProductionEnvironment(values, context);
  });

// =============================================================================
// PARSE
// =============================================================================

const parsedEnvironment = envSchema.safeParse(process.env);

if (!parsedEnvironment.success) {
  printEnvironmentErrors(parsedEnvironment.error);

  throw new Error(
    "Invalid Sarthee AI environment configuration. " +
      "Check the errors above and update your .env file.",
  );
}

const rawEnv = parsedEnvironment.data;

// =============================================================================
// PUBLIC CONFIGURATION
// =============================================================================

export const env = Object.freeze({
  nodeEnv: rawEnv.NODE_ENV,

  isDevelopment: rawEnv.NODE_ENV === "development",
  isTest: rawEnv.NODE_ENV === "test",
  isProduction: rawEnv.NODE_ENV === "production",

  app: Object.freeze({
    name: rawEnv.APP_NAME,
    version: rawEnv.APP_VERSION,
  }),

  server: Object.freeze({
    host: rawEnv.HOST,
    port: rawEnv.PORT,
    apiPrefix: rawEnv.API_PREFIX,
    shutdownTimeoutMs: rawEnv.SHUTDOWN_TIMEOUT_MS,
    requestTimeoutMs: rawEnv.REQUEST_TIMEOUT_MS,
    bodyLimit: rawEnv.REQUEST_BODY_LIMIT,
  }),

  cors: Object.freeze({
    origins: parseCommaSeparatedList(rawEnv.CORS_ORIGINS),
  }),

  rateLimit: Object.freeze({
    windowMs: rawEnv.RATE_LIMIT_WINDOW_MS,
    maxRequests: rawEnv.RATE_LIMIT_MAX_REQUESTS,
  }),

  logging: Object.freeze({
    level: rawEnv.LOG_LEVEL,
    pretty: rawEnv.LOG_PRETTY,
  }),

  database: Object.freeze({
    url: rawEnv.DATABASE_URL,
  }),

  redis: Object.freeze({
    enabled: rawEnv.ENABLE_REDIS,
    url: rawEnv.REDIS_URL,
  }),

  auth: Object.freeze({
    accessSecret: rawEnv.JWT_ACCESS_SECRET,
    refreshSecret: rawEnv.JWT_REFRESH_SECRET,
    accessExpiresIn: rawEnv.JWT_ACCESS_EXPIRES_IN,
    refreshExpiresIn: rawEnv.JWT_REFRESH_EXPIRES_IN,
  }),

  firebase: Object.freeze({
    projectId: rawEnv.FIREBASE_PROJECT_ID,
    clientEmail: rawEnv.FIREBASE_CLIENT_EMAIL,
    privateKey: normalizePrivateKey(rawEnv.FIREBASE_PRIVATE_KEY),
    serviceAccountPath: rawEnv.FIREBASE_SERVICE_ACCOUNT_PATH,
  }),

  ai: Object.freeze({
    enabled: rawEnv.ENABLE_AI,
    geminiApiKey: rawEnv.GEMINI_API_KEY,
    openAiApiKey: rawEnv.OPENAI_API_KEY,
  }),

  maps: Object.freeze({
    enabled: rawEnv.ENABLE_MAPS,
    googleMapsApiKey: rawEnv.GOOGLE_MAPS_API_KEY,
    placesApiKey: rawEnv.PLACES_API_KEY,
  }),

  weather: Object.freeze({
    enabled: rawEnv.ENABLE_WEATHER,
    apiKey: rawEnv.WEATHER_API_KEY,
  }),

  storage: Object.freeze({
    provider: rawEnv.STORAGE_PROVIDER,
    bucket: rawEnv.STORAGE_BUCKET,
  }),

  notifications: Object.freeze({
    enabled: rawEnv.ENABLE_NOTIFICATIONS,
    projectId: rawEnv.FCM_PROJECT_ID,
    clientEmail: rawEnv.FCM_CLIENT_EMAIL,
    privateKey: normalizePrivateKey(rawEnv.FCM_PRIVATE_KEY),
  }),
});

// =============================================================================
// VALIDATION HELPERS
// =============================================================================

function validateFeatureDependencies(values, context) {
  if (values.ENABLE_AI && !values.GEMINI_API_KEY && !values.OPENAI_API_KEY) {
    addIssue(
      context,
      "ENABLE_AI",
      "AI is enabled but neither GEMINI_API_KEY nor OPENAI_API_KEY is configured.",
    );
  }

  if (values.ENABLE_WEATHER && !values.WEATHER_API_KEY) {
    addIssue(
      context,
      "WEATHER_API_KEY",
      "Weather integration is enabled but WEATHER_API_KEY is missing.",
    );
  }

  if (
    values.ENABLE_MAPS &&
    !values.GOOGLE_MAPS_API_KEY &&
    !values.PLACES_API_KEY
  ) {
    addIssue(
      context,
      "ENABLE_MAPS",
      "Maps integration is enabled but no Maps/Places API key is configured.",
    );
  }

  if (values.ENABLE_REDIS && !values.REDIS_URL) {
    addIssue(
      context,
      "REDIS_URL",
      "Redis is enabled but REDIS_URL is missing.",
    );
  }

  if (
    values.ENABLE_NOTIFICATIONS &&
    (!values.FCM_PROJECT_ID ||
      !values.FCM_CLIENT_EMAIL ||
      !values.FCM_PRIVATE_KEY)
  ) {
    addIssue(
      context,
      "ENABLE_NOTIFICATIONS",
      "Notifications are enabled but Firebase credentials are incomplete.",
    );
  }
}

function validateProductionEnvironment(values, context) {
  if (values.NODE_ENV !== "production") {
    return;
  }

  if (!values.JWT_ACCESS_SECRET) {
    addIssue(
      context,
      "JWT_ACCESS_SECRET",
      "JWT_ACCESS_SECRET is required in production.",
    );
  }

  if (!values.DATABASE_URL) {
    addIssue(
      context,
      "DATABASE_URL",
      "DATABASE_URL is required in production.",
    );
  }

  if (!values.JWT_REFRESH_SECRET) {
    addIssue(
      context,
      "JWT_REFRESH_SECRET",
      "JWT_REFRESH_SECRET is required in production.",
    );
  }

  if (
    !values.FIREBASE_SERVICE_ACCOUNT_PATH &&
    (!values.FIREBASE_PROJECT_ID ||
      !values.FIREBASE_CLIENT_EMAIL ||
      !values.FIREBASE_PRIVATE_KEY)
  ) {
    addIssue(
      context,
      "FIREBASE_SERVICE_ACCOUNT_PATH",
      "Firebase credentials are required in production. Set FIREBASE_SERVICE_ACCOUNT_PATH or FIREBASE_PROJECT_ID/FIREBASE_CLIENT_EMAIL/FIREBASE_PRIVATE_KEY.",
    );
  }

  if (
    values.JWT_ACCESS_SECRET?.includes("development-only") ||
    values.JWT_ACCESS_SECRET?.includes("replace-with")
  ) {
    addIssue(
      context,
      "JWT_ACCESS_SECRET",
      "Development/default JWT secrets cannot be used in production.",
    );
  }

  if (
    values.JWT_REFRESH_SECRET?.includes("development-only") ||
    values.JWT_REFRESH_SECRET?.includes("replace-with")
  ) {
    addIssue(
      context,
      "JWT_REFRESH_SECRET",
      "Development/default JWT secrets cannot be used in production.",
    );
  }
}

function addIssue(context, path, message) {
  context.addIssue({
    code: "custom",
    path: [path],
    message,
  });
}

// =============================================================================
// NORMALIZATION HELPERS
// =============================================================================

function normalizeApiPrefix(value) {
  let normalized = value.trim();

  if (!normalized.startsWith("/")) {
    normalized = `/${normalized}`;
  }

  if (normalized.length > 1 && normalized.endsWith("/")) {
    normalized = normalized.slice(0, -1);
  }

  return normalized;
}

function parseCommaSeparatedList(value) {
  if (!value) {
    return Object.freeze([]);
  }

  return Object.freeze([
    ...new Set(
      value
        .split(",")
        .map((entry) => entry.trim())
        .filter(Boolean),
    ),
  ]);
}

function normalizePrivateKey(value) {
  if (!value) {
    return undefined;
  }

  return value.replace(/\\n/g, "\n");
}

// =============================================================================
// ERROR REPORTING
// =============================================================================

function printEnvironmentErrors(error) {
  console.error("");
  console.error("Sarthee AI environment validation failed:");

  for (const issue of error.issues) {
    const path = issue.path.length > 0 ? issue.path.join(".") : "environment";

    console.error(`  - ${path}: ${issue.message}`);
  }

  console.error("");
}

