import { Router } from "express";

import { userController } from "./user.controller.js";
import { firebaseAuthMiddleware } from "../../middleware/firebase-auth.middleware.js";

/**
 * ============================================================================
 * SARTHEE AI — AUTH ROUTES
 * ============================================================================
 *
 * Authentication Flow:
 *
 * Flutter App
 *      |
 *      | Firebase Authentication
 *      |
 * Firebase ID Token
 *      |
 * Authorization: Bearer <token>
 *      |
 * Firebase Auth Middleware
 *      |
 * req.firebaseUser
 *      |
 * User Controller
 *      |
 * MongoDB
 *
 * Base:
 * /api/v1/auth
 *
 * Protected Routes:
 *
 * POST /sync
 * GET  /profile
 * PUT  /profile
 *
 * ============================================================================
 */

const router = Router();

/**
 * Sync Firebase user with MongoDB
 */
router.post("/sync", firebaseAuthMiddleware, userController.syncUser);

/**
 * Get logged-in user profile
 */
router.get("/profile", firebaseAuthMiddleware, userController.getProfile);

/**
 * Update logged-in user profile
 */
router.put("/profile", firebaseAuthMiddleware, userController.updateProfile);

export { router as authRouter };

export default router;

