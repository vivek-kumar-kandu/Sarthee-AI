import { test, describe } from 'node:test';
import assert from 'node:assert';
import { JourneyPlanController } from '../../src/modules/journey/presentation/controllers/journey_plan_controller.js';
import { PlanJourneyUseCase } from '../../src/modules/journey/application/use_cases/plan_journey_use_case.js';
import { GeminiAiProvider } from '../../src/infrastructure/providers/ai/gemini_ai_provider.js';

describe('Layer 5: Presentation & Journey REST APIs', () => {
  test('JourneyPlanController should return standardized success envelope for valid request', async () => {
    const aiProvider = new GeminiAiProvider('test_key');
    const useCase = new PlanJourneyUseCase(aiProvider);
    const controller = new JourneyPlanController(useCase);

    const mockReq = {
      headers: { 'x-request-id': 'req_test_999' },
      body: {
        originName: 'Ghaziabad',
        destinationName: 'Connaught Place, Delhi',
        originLat: 28.6715,
        originLng: 77.4121,
        destinationLat: 28.6328,
        destinationLng: 77.2197,
      },
    };

    const envelope = await controller.handlePlanRequest(mockReq, null);

    assert.strictEqual(envelope.success, true);
    assert.strictEqual(envelope.requestId, 'req_test_999');
    assert.strictEqual(envelope.meta.apiVersion, 'v1');
    assert.ok(envelope.data.plans.recommended);
    assert.ok(envelope.data.plans.balanced);
    assert.ok(envelope.data.plans.fastest);
  });

  test('JourneyPlanController should return standardized error envelope on validation failure', async () => {
    const aiProvider = new GeminiAiProvider('test_key');
    const useCase = new PlanJourneyUseCase(aiProvider);
    const controller = new JourneyPlanController(useCase);

    const mockReq = {
      headers: { 'x-request-id': 'req_test_888' },
      body: {
        originName: 'Delhi',
        destinationName: 'Delhi', // Same origin and destination
        originLat: 28.6715,
        originLng: 77.4121,
        destinationLat: 28.6715,
        destinationLng: 77.4121,
      },
    };

    const errorEnvelope = await controller.handlePlanRequest(mockReq, null);

    assert.strictEqual(errorEnvelope.success, false);
    assert.strictEqual(errorEnvelope.requestId, 'req_test_888');
    assert.strictEqual(errorEnvelope.error.code, 'VALIDATION_ERROR');
    assert.ok(errorEnvelope.error.message.includes('Destination cannot be identical'));
  });
});
