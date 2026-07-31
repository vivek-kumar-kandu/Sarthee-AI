import { Router } from 'express';
import {
  getAdminDashboard,
  getProviderHealth,
  getSystemAnalytics,
} from '../controllers/admin_controller.js';

const router = Router();

/**
 * Admin Operations REST Endpoints
 *
 * GET /api/v1/admin/dashboard — Real-time operational dashboard snapshot
 * GET /api/v1/admin/health    — Provider health monitoring grid
 * GET /api/v1/admin/analytics — System analytics & travel mode distribution
 */
router.get('/dashboard', getAdminDashboard);
router.get('/health', getProviderHealth);
router.get('/analytics', getSystemAnalytics);

export { router as adminRouter };
export default router;
