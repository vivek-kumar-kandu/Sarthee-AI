import { Router } from 'express';
import { getEmergencyServices, triggerSos } from '../controllers/emergency_controller.js';

const router = Router();

/**
 * Emergency & Safety Routes
 *
 * GET  /api/v1/emergency?lat=&lng=&subcategory= — Fetch emergency POIs
 * POST /api/v1/emergency/sos                   — Trigger 24x7 Emergency SOS alert dispatch
 */
router.get('/', getEmergencyServices);
router.post('/sos', triggerSos);

export { router as emergencyRouter };
export default router;
