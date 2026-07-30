import process from 'node:process';

/**
 * Fail-Fast Startup Configuration Validator
 * Validates required environment secrets and database connection requirements on startup.
 */
export function validateStartupConfig(env = process.env) {
  const requiredVariables = [
    'GEMINI_API_KEY',
    'MONGODB_URI',
    'REDIS_URL',
    'FIREBASE_ADMIN_CREDENTIALS',
    'JWT_SECRET',
  ];

  const missing = requiredVariables.filter((key) => !env[key] || env[key].trim() === '');

  if (missing.length > 0) {
    const errorMessage = `[FATAL STARTUP ERROR] Missing required environment secrets: ${missing.join(', ')}. Server initialization halted.`;
    if (env.NODE_ENV === 'test') {
      throw new Error(errorMessage);
    } else {
      console.error(errorMessage);
      process.exit(1);
    }
  }

  return true;
}
