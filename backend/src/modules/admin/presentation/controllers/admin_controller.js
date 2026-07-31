import { dashboardService } from '../domain/services/dashboard_service.js';
import { providerHealthService } from '../domain/services/provider_health_service.js';
import { analyticsService } from '../domain/services/analytics_service.js';
import { logger } from '../../../../config/logger.js';

/**
 * GET /api/v1/admin/dashboard
 * Assembles full real-time operational dashboard payload
 */
export const getAdminDashboard = async (req, res) => {
  try {
    const snapshot = dashboardService.getDashboardSnapshot();
    return res.status(200).json(snapshot);
  } catch (err) {
    logger.error({ event: 'admin_dashboard_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to generate admin dashboard.' });
  }
};

/**
 * GET /api/v1/admin/health
 * Returns provider health report grid
 */
export const getProviderHealth = async (req, res) => {
  try {
    const report = providerHealthService.getHealthReport();
    return res.status(200).json(report);
  } catch (err) {
    logger.error({ event: 'admin_health_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to generate health report.' });
  }
};

/**
 * GET /api/v1/admin/analytics
 * Returns usage analytics and search trends
 */
export const getSystemAnalytics = async (req, res) => {
  try {
    const summary = analyticsService.getAnalyticsSummary();
    return res.status(200).json(summary);
  } catch (err) {
    logger.error({ event: 'admin_analytics_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to generate analytics summary.' });
  }
};
