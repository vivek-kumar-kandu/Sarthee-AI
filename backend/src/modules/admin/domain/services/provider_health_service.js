import { providerMonitorFramework } from '../../../../infrastructure/monitoring/provider_monitor_framework.js';

/**
 * ProviderHealthService
 *
 * Aggregates provider health telemetry records from ProviderMonitorFramework
 * and computes overall system health status and health summary grids.
 */
export class ProviderHealthService {
  constructor(framework = providerMonitorFramework) {
    this.framework = framework;
  }

  /**
   * Returns complete provider health snapshot.
   */
  getHealthReport() {
    const statuses = this.framework.getAllStatuses();

    const healthyCount = statuses.filter((s) => s.status === 'healthy').length;
    const degradedCount = statuses.filter((s) => s.status === 'degraded').length;
    const downCount = statuses.filter((s) => s.status === 'down').length;

    let overallStatus = 'healthy';
    if (downCount > 0) overallStatus = 'degraded';
    if (downCount > 2) overallStatus = 'down';

    return {
      overallStatus,
      totalProviders: statuses.length,
      healthyCount,
      degradedCount,
      downCount,
      providers: statuses,
      timestamp: new Date().toISOString(),
    };
  }
}

export const providerHealthService = new ProviderHealthService();
