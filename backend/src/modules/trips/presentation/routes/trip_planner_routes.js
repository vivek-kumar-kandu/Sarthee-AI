import { Router } from 'express';
import {
  planTrip,
  saveTrip,
  getTrips,
  getTripById,
  updateTrip,
  deleteTrip,
  startTrip,
  shareTrip,
  recalculateTrip,
  completeStop,
  exportTrip,
  exportPdf,
  exportCalendar,
} from '../controllers/trip_planner_controller.js';

const router = Router();

/**
 * Phase 4B REST Gateway Routes
 */
router.post('/plan', planTrip);
router.post('/save', saveTrip);
router.get('/', getTrips);

router.get('/:id', getTripById);
router.patch('/:id', updateTrip);
router.delete('/:id', deleteTrip);

router.post('/:id/start', startTrip);
router.post('/:id/share', shareTrip);
router.post('/:id/recalculate', recalculateTrip);
router.post('/:id/completeStop', completeStop);

router.post('/:id/export', exportTrip);
router.post('/:id/pdf', exportPdf);
router.post('/:id/calendar', exportCalendar);

export { router as tripPlannerRouter };
export default router;
