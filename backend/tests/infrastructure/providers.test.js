import { test, describe } from 'node:test';
import assert from 'node:assert';
import { OsrmRoutingProvider } from '../../src/infrastructure/providers/routing/osrm_routing_provider.js';
import { OpenWeatherProvider } from '../../src/infrastructure/providers/weather/openweather_provider.js';
import { GeminiAiProvider } from '../../src/infrastructure/providers/ai/gemini_ai_provider.js';

describe('Layer 2: Infrastructure Provider Abstractions', () => {
  test('OsrmRoutingProvider should calculate route heuristics and polyline', async () => {
    const provider = new OsrmRoutingProvider();
    const result = await provider.calculateRoute(28.6715, 77.4121, 28.6328, 77.2197, 'driving');

    assert.ok(result.distanceMeters > 0);
    assert.ok(result.durationMinutes > 0);
    assert.ok(result.provider.includes('OSRM'));
  });

  test('OpenWeatherProvider should return weather advisory', async () => {
    const provider = new OpenWeatherProvider(process.env.OPENWEATHER_API_KEY || 'dummy_test_key');
    const result = await provider.getWeatherAdvisory(28.6715, 77.4121);

    assert.ok(result.provider.includes('OpenWeatherMap'));
    assert.strictEqual(typeof result.isRainExpected, 'boolean');
  });

  test('GeminiAiProvider should generate structured rationale', async () => {
    const provider = new GeminiAiProvider('test_key');
    const result = await provider.generateRationale({
      origin: 'Ghaziabad',
      destination: 'Delhi',
      timeMinutes: 52,
      cost: 65,
    });

    assert.ok(result.model.includes('gemini-2.0-flash'));
    assert.ok(result.rationale.includes('Ghaziabad'));
  });
});
