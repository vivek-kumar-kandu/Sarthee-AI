import { describe, test } from 'node:test';
import assert from 'node:assert';
import { DynamicFareEngine } from '../../src/modules/journey/domain/services/dynamic_fare_engine.js';
import { RouteRankingEngine } from '../../src/modules/journey/domain/services/route_ranking_engine.js';

describe('Layer 3: Dynamic Engines Unit Tests', () => {
  describe('DynamicFareEngine', () => {
    test('should return 1.0x surge multiplier during normal off-peak daytime hours without rain', () => {
      const fareEngine = new DynamicFareEngine();
      const surge = fareEngine.calculateSurgeMultiplier(14, false);
      assert.strictEqual(surge, 1.0);

      const baseFare = 100;
      const finalFare = fareEngine.calculateFinalFare(baseFare, 14, false);
      assert.strictEqual(finalFare, 100);
    });

    test('should apply 1.15x Peak-hour surge multiplier during morning rush hour (8-10 AM)', () => {
      const fareEngine = new DynamicFareEngine();
      const surge = fareEngine.calculateSurgeMultiplier(9, false);
      assert.strictEqual(surge, 1.15);

      const finalFare = fareEngine.calculateFinalFare(100, 9, false);
      assert.strictEqual(finalFare, 115);
    });

    test('should apply 1.25x Rain surge multiplier when rain condition is active', () => {
      const fareEngine = new DynamicFareEngine();
      const surge = fareEngine.calculateSurgeMultiplier(14, true);
      assert.strictEqual(surge, 1.25);

      const finalFare = fareEngine.calculateFinalFare(100, 14, true);
      assert.strictEqual(finalFare, 125);
    });

    test('should apply 1.25x Late Night surge multiplier after 11 PM', () => {
      const fareEngine = new DynamicFareEngine();
      const surge = fareEngine.calculateSurgeMultiplier(23, false);
      assert.strictEqual(surge, 1.25);

      const finalFare = fareEngine.calculateFinalFare(100, 23, false);
      assert.strictEqual(finalFare, 125);
    });

    test('should combine Peak and Rain multipliers during rain in rush hour (1.15 * 1.25 = 1.44x)', () => {
      const fareEngine = new DynamicFareEngine();
      const surge = fareEngine.calculateSurgeMultiplier(9, true);
      assert.strictEqual(surge, 1.44);

      const finalFare = fareEngine.calculateFinalFare(100, 9, true);
      assert.strictEqual(finalFare, 144);
    });
  });

  describe('RouteRankingEngine', () => {
    const mockPlans = {
      balanced: {
        id: 'plan_bal',
        mode: 'balanced',
        totalDurationMinutes: 30,
        totalCost: 80,
        totalWalkingDistanceMeters: 200,
        compositeSafetyScore: 90,
        steps: [{ type: 'metro' }],
        aiRationale: 'Standard metro route',
      },
      eco: {
        id: 'plan_eco',
        mode: 'eco',
        totalDurationMinutes: 45,
        totalCost: 50,
        totalWalkingDistanceMeters: 1200,
        compositeSafetyScore: 80,
        steps: [{ type: 'walk' }, { type: 'eRickshaw' }],
        aiRationale: 'Long walk eco route',
      },
    };

    test('should calculate weighted recommendation score correctly', () => {
      const rankingEngine = new RouteRankingEngine();
      const score = rankingEngine.calculateRouteScore(mockPlans.balanced, null, 12);
      assert.ok(score > 50 && score <= 100);
    });

    test('should penalize long walking and open rickshaw during rain and re-rank metro plan to top', () => {
      const rankingEngine = new RouteRankingEngine();
      const rainWeather = { isRainExpected: true, condition: 'Heavy Rain', tempCelsius: 24 };

      const reRanked = rankingEngine.reRankPlans(mockPlans, rainWeather, 14);
      assert.ok(reRanked.recommended);
      assert.ok(reRanked.recommended.aiRationale.includes('Weather Advisory'));
    });

    test('should trigger extreme heat warning and score penalty when temperature exceeds 38°C', () => {
      const rankingEngine = new RouteRankingEngine();
      const heatWeather = { isRainExpected: false, condition: 'Sunny', tempCelsius: 42 };

      const reRanked = rankingEngine.reRankPlans(mockPlans, heatWeather, 14);
      assert.ok(reRanked.recommended);
      assert.ok(reRanked.recommended.aiRationale.includes('Heat Warning'));
    });

    test('should apply visibility penalty when fog/mist is detected', () => {
      const rankingEngine = new RouteRankingEngine();
      const fogWeather = { isRainExpected: false, condition: 'Dense Fog', tempCelsius: 12 };

      const fogScore = rankingEngine.calculateRouteScore(mockPlans.eco, fogWeather, 7);
      const clearScore = rankingEngine.calculateRouteScore(mockPlans.eco, null, 7);

      assert.ok(fogScore < clearScore);
    });
  });
});
