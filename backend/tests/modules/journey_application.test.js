import { test, describe } from 'node:test';
import assert from 'node:assert';
import { JourneyPlanRequestDTO } from '../../src/modules/journey/application/dto/journey_plan_request_dto.js';
import { PlanJourneyUseCase } from '../../src/modules/journey/application/use_cases/plan_journey_use_case.js';
import { GeminiAiProvider } from '../../src/infrastructure/providers/ai/gemini_ai_provider.js';

describe('Layer 4: Backend Clean Architecture Application Layer', () => {
  test('JourneyPlanRequestDTO should reject payload when origin equals destination', () => {
    assert.throws(
      () => new JourneyPlanRequestDTO({
        originName: 'Delhi',
        destinationName: 'Delhi',
        originLat: 28.6715,
        originLng: 77.4121,
        destinationLat: 28.6715,
        destinationLng: 77.4121,
      }),
      /Destination cannot be identical to Origin/
    );
  });

  test('PlanJourneyUseCase should orchestrate journey plans with AI rationale', async () => {
    const aiProvider = new GeminiAiProvider('test_key');
    const useCase = new PlanJourneyUseCase(aiProvider);

    const dto = new JourneyPlanRequestDTO({
      originName: 'Ghaziabad',
      destinationName: 'Connaught Place, Delhi',
      originLat: 28.6715,
      originLng: 77.4121,
      destinationLat: 28.6328,
      destinationLng: 77.2197,
    });

    const result = await useCase.execute(dto);
    const plansMap = result.plans || result;

    assert.ok(plansMap.balanced);
    assert.ok(plansMap.balanced.aiRationale.includes('Ghaziabad'));
  });
});
