import { Router } from 'express';
import { JourneyPlanController } from '../controllers/journey_plan_controller.js';
import { PlanJourneyUseCase } from '../../application/use_cases/plan_journey_use_case.js';
import { GeminiAiProvider } from '../../../../infrastructure/providers/ai/gemini_ai_provider.js';

export function createJourneyRouter() {
  const router = Router();
  const aiProvider = new GeminiAiProvider();
  const planUseCase = new PlanJourneyUseCase(aiProvider);
  const controller = new JourneyPlanController(planUseCase);

  router.post('/plan', (req, res) => controller.handlePlanRequest(req, res));

  return router;
}

