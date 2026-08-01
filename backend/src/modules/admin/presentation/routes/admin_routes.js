import { Router } from 'express';
import {
  getAdminDashboard,
  getProviderHealth,
  getProvidersStatus,
  getSystemMetrics,
  getSystemAnalytics,
} from '../controllers/admin_controller.js';

const router = Router();

/**
 * Admin Operations & Observability REST Endpoints
 */
router.get('/dashboard', getAdminDashboard);
router.get('/health', getProviderHealth);
router.get('/providers', getProvidersStatus);
router.get('/metrics', getSystemMetrics);
router.get('/analytics', getSystemAnalytics);

export { router as adminRouter };
export default router;
