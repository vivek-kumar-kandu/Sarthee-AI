/**
 * IncidentStatusService
 * Pure domain service formatting incident disruption envelopes
 */
export class IncidentStatusService {
  constructor(incidentProvider = null) {
    this.incidentProvider = incidentProvider;
  }

  async resolveIncidents(context) {
    if (this.incidentProvider) {
      try {
        const res = await this.incidentProvider.getIncidents(context);
        return res?.incidents || [];
      } catch (_) {
        // Fallback
      }
    }

    return [];
  }
}

