import { Router } from 'express';
import { submitFeedback, getFeedbackSummary } from './feedback_controller.js';
import { authenticateJwt, requireRole } from '../auth/auth_middleware.js';

const router = Router();

/**
 * Beta In-App Feedback Endpoints
 */
router.post('/', authenticateJwt, submitFeedback);
router.get('/', authenticateJwt, requireRole('admin'), getFeedbackSummary);

export { router as feedbackRouter };
export default router;
