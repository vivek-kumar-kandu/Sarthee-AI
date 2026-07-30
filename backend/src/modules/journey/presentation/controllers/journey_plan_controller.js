import { JourneyPlanRequestDTO } from '../../application/dto/journey_plan_request_dto.js';
import { formatSuccessResponse, formatErrorResponse } from '../../../../common/middleware/api_envelope_middleware.js';

export class JourneyPlanController {
  constructor(planJourneyUseCase) {
    this.planJourneyUseCase = planJourneyUseCase;
  }

  async handlePlanRequest(req, res) {
    const requestId = req.headers?.['x-request-id'] || 'req_default';

    try {
      const dto = new JourneyPlanRequestDTO(req.body || {});
      const keyedPlans = await this.planJourneyUseCase.execute(dto);

      const envelope = formatSuccessResponse({ plans: keyedPlans }, {}, requestId);
      if (res && typeof res.status === 'function') {
        return res.status(200).json(envelope);
      }
      return envelope;
    } catch (error) {
      const errorEnvelope = formatErrorResponse(
        'VALIDATION_ERROR',
        error.message || 'Journey plan request failed validation.',
        {},
        requestId
      );
      if (res && typeof res.status === 'function') {
        return res.status(400).json(errorEnvelope);
      }
      return errorEnvelope;
    }
  }
}
