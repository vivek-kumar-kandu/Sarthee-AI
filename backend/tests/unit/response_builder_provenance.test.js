import { describe, test } from 'node:test';
import assert from 'node:assert/strict';

import { ResponseBuilder } from '../../src/common/responses/response_builder.js';
import { DataProvenance, CONFIDENCE_TIERS } from '../../src/infrastructure/providers/data_provenance.js';

describe('ResponseBuilder & DataProvenance Suite', () => {
  describe('DataProvenance Class & Confidence Tiers', () => {
    test('should construct live single provider provenance with options', () => {
      const provenance = DataProvenance.live('OpenWeather', {
        confidence: CONFIDENCE_TIERS.DIRECT_LIVE,
        latencyMs: 142,
        cache: false,
        verified: true,
        providerVersion: 'v2.5',
      });

      assert.equal(provenance.provider, 'OpenWeather');
      assert.equal(provenance.providerVersion, 'v2.5');
      assert.equal(provenance.live, true);
      assert.equal(provenance.fallback, false);
      assert.equal(provenance.confidence, 1.0);
      assert.equal(provenance.latencyMs, 142);
      assert.equal(provenance.cache, false);
      assert.equal(provenance.verified, true);
      assert.ok(provenance.lastUpdated);
    });

    test('should construct multi-provider provenance for trip/journey engines', () => {
      const provenance = DataProvenance.multiProvider({
        engine: 'Sarthee 12-Factor Optimizer',
        providers: ['OSRM', 'OpenWeather', 'Overpass OSM'],
        confidence: CONFIDENCE_TIERS.MULTI_PROVIDER,
        latencyMs: 310,
        cache: true,
      });

      assert.equal(provenance.engine, 'Sarthee 12-Factor Optimizer');
      assert.deepEqual(provenance.providers, ['OSRM', 'OpenWeather', 'Overpass OSM']);
      assert.equal(provenance.live, true);
      assert.equal(provenance.fallback, false);
      assert.equal(provenance.confidence, 0.90);
      assert.equal(provenance.latencyMs, 310);
      assert.equal(provenance.cache, true);
    });

    test('should construct fallback provenance when live provider fails', () => {
      const provenance = DataProvenance.fallback('Seasonal Monthly Climate Defaults', 'API Key Missing', {
        confidence: CONFIDENCE_TIERS.SEASONAL_MODEL,
      });

      assert.equal(provenance.provider, 'Seasonal Monthly Climate Defaults');
      assert.equal(provenance.live, false);
      assert.equal(provenance.fallback, true);
      assert.equal(provenance.reason, 'API Key Missing');
      assert.equal(provenance.confidence, 0.40);
    });
  });

  describe('ResponseBuilder Class', () => {
    test('should format standard success response envelope with requestId & traceId', () => {
      const mockRes = {
        statusCode: 0,
        payload: null,
        status(code) {
          this.statusCode = code;
          return this;
        },
        json(data) {
          this.payload = data;
          return this;
        },
      };

      const data = { temp: 32, condition: 'Sunny' };
      const provenance = DataProvenance.live('OpenWeather', { confidence: 1.0 });

      ResponseBuilder.success(mockRes, {
        data,
        provenance,
        statusCode: 200,
        requestId: 'req_test_123',
        traceId: 'trace_test_456',
      });

      assert.equal(mockRes.statusCode, 200);
      assert.equal(mockRes.payload.status, 'success');
      assert.deepEqual(mockRes.payload.data, data);
      assert.equal(mockRes.payload.meta.requestId, 'req_test_123');
      assert.equal(mockRes.payload.meta.traceId, 'trace_test_456');
      assert.equal(mockRes.payload.meta.provenance.provider, 'OpenWeather');
    });

    test('should format standard error response envelope', () => {
      const mockRes = {
        statusCode: 0,
        payload: null,
        status(code) {
          this.statusCode = code;
          return this;
        },
        json(data) {
          this.payload = data;
          return this;
        },
      };

      ResponseBuilder.error(mockRes, {
        code: 'INVALID_PARAMS',
        message: 'lat and lng are required.',
        statusCode: 400,
        requestId: 'req_err_99',
        traceId: 'trace_err_88',
      });

      assert.equal(mockRes.statusCode, 400);
      assert.equal(mockRes.payload.status, 'error');
      assert.equal(mockRes.payload.error.code, 'INVALID_PARAMS');
      assert.equal(mockRes.payload.error.message, 'lat and lng are required.');
      assert.equal(mockRes.payload.meta.requestId, 'req_err_99');
      assert.equal(mockRes.payload.meta.traceId, 'trace_err_88');
    });
  });
});
