import { dashboardService } from '../domain/services/dashboard_service.js';
import { providerHealthService } from '../domain/services/provider_health_service.js';
import { analyticsService } from '../domain/services/analytics_service.js';
import { osrmCircuitBreaker, weatherCircuitBreaker, openAqCircuitBreaker, evChargingCircuitBreaker } from '../../../../infrastructure/providers/real_providers.js';
import { logger } from '../../../../config/logger.js';

/** GET /api/v1/admin/dashboard */
export const getAdminDashboard = async (req, res) => {
  try {
    const snapshot = dashboardService.getDashboardSnapshot();
    return res.status(200).json(snapshot);
  } catch (err) {
    logger.error({ event: 'admin_dashboard_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to generate admin dashboard.' });
  }
};

/** GET /api/v1/admin/health */
export const getProviderHealth = async (req, res) => {
  try {
    const report = providerHealthService.getHealthReport();
    return res.status(200).json(report);
  } catch (err) {
    logger.error({ event: 'admin_health_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to generate health report.' });
  }
};

/** GET /api/v1/admin/providers */
export const getProvidersStatus = async (req, res) => {
  try {
    const circuitBreakers = [
      osrmCircuitBreaker.getStatus(),
      weatherCircuitBreaker.getStatus(),
      openAqCircuitBreaker.getStatus(),
      evChargingCircuitBreaker.getStatus(),
    ];
    return res.status(200).json({ success: true, circuitBreakers });
  } catch (err) {
    logger.error({ event: 'admin_providers_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to fetch provider circuit breakers.' });
  }
};

/** GET /api/v1/admin/metrics */
export const getSystemMetrics = async (req, res) => {
  try {
    const memory = process.memoryUsage();
    const metrics = {
      process: {
        uptimeSeconds: Math.round(process.uptime()),
        memoryRssMb: Math.round((memory.rss / 1024 / 1024) * 10) / 10,
        heapUsedMb: Math.round((memory.heapUsed / 1024 / 1024) * 10) / 10,
        nodeVersion: process.version,
      },
      analytics: analyticsService.getAnalyticsSummary(),
    };
    return res.status(200).json({ success: true, metrics });
  } catch (err) {
    logger.error({ event: 'admin_metrics_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to fetch system metrics.' });
  }
};

/** GET /api/v1/admin/analytics */
export const getSystemAnalytics = async (req, res) => {
  try {
    const summary = analyticsService.getAnalyticsSummary();
    return res.status(200).json(summary);
  } catch (err) {
    logger.error({ event: 'admin_analytics_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to generate analytics summary.' });
  }
};
