import { JourneyPlanRequestDTO } from '../../application/dto/journey_plan_request_dto.js';
import { ResponseBuilder } from '../../../../common/responses/response_builder.js';
import { DataProvenance, CONFIDENCE_TIERS } from '../../../../infrastructure/providers/data_provenance.js';

export class JourneyPlanController {
  constructor(planJourneyUseCase) {
    this.planJourneyUseCase = planJourneyUseCase;
  }

  async handlePlanRequest(req, res) {
    const startTime = Date.now();
    const requestId = req?.id || req?.headers?.['x-request-id'] || 'req_default';
    const traceId = req?.traceId || null;

    try {
      const dto = new JourneyPlanRequestDTO(req?.body || {});
      const keyedPlans = await this.planJourneyUseCase.execute(dto);
      const latencyMs = Date.now() - startTime;

      const dataPayload = keyedPlans.plans ? keyedPlans : { plans: keyedPlans };
      const provenance = DataProvenance.multiProvider({
        engine: 'Smart Journey Multi-Modal Engine',
        providers: ['OSRM', 'GTFS', 'OpenWeather'],
        confidence: CONFIDENCE_TIERS.MULTI_PROVIDER,
        latencyMs,
        cache: false,
        verified: true,
      });

      if (res && typeof res.status === 'function') {
        return ResponseBuilder.success(res, {
          data: dataPayload,
          provenance,
          statusCode: 200,
          requestId,
          traceId,
        });
      }

      // Unit test fallback when res is null
      return {
        status: 'success',
        success: true,
        requestId,
        data: dataPayload,
        meta: { timestamp: new Date().toISOString(), apiVersion: 'v1', requestId, traceId, provenance },
      };
    } catch (error) {
      if (res && typeof res.status === 'function') {
        return ResponseBuilder.error(res, {
          code: 'VALIDATION_ERROR',
          message: error.message || 'Journey plan request failed validation.',
          statusCode: 400,
          requestId,
          traceId,
        });
      }

      // Unit test fallback when res is null
      return {
        status: 'error',
        success: false,
        requestId,
        error: { code: 'VALIDATION_ERROR', message: error.message || 'Journey plan request failed validation.' },
        meta: { timestamp: new Date().toISOString(), apiVersion: 'v1', requestId, traceId },
      };
    }
  }
}
