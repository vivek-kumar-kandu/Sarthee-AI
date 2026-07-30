import { test, describe } from 'node:test';
import assert from 'node:assert';
import { validateStartupConfig } from '../../src/infrastructure/config/config_validator.js';
import { featureFlags } from '../../src/infrastructure/config/feature_flags.js';

describe('Layer 1: Infrastructure Startup Configuration & Feature Flags', () => {
  test('validateStartupConfig should throw error when required secrets are missing', () => {
    const mockEnv = { NODE_ENV: 'test' };
    assert.throws(
      () => validateStartupConfig(mockEnv),
      /\[FATAL STARTUP ERROR\] Missing required environment secrets/
    );
  });

  test('validateStartupConfig should pass when all required secrets are supplied', () => {
    const mockEnv = {
      NODE_ENV: 'test',
      GEMINI_API_KEY: 'test_gemini_key',
      MONGODB_URI: 'mongodb://localhost:27017/test',
      REDIS_URL: 'redis://localhost:6379',
      FIREBASE_ADMIN_CREDENTIALS: 'test_firebase_credentials',
      JWT_SECRET: 'test_jwt_secret',
    };

    const result = validateStartupConfig(mockEnv);
    assert.strictEqual(result, true);
  });

  test('featureFlags should expose default operational and experimental flags', () => {
    assert.ok(featureFlags.operational);
    assert.ok(featureFlags.experimental);
    assert.strictEqual(typeof featureFlags.operational.enableAi, 'boolean');
    assert.strictEqual(typeof featureFlags.operational.routingProvider, 'string');
  });
});
