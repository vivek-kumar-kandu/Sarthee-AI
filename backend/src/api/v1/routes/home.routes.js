import { Router } from "express";

import { homeController } from "../controllers/home.controller.js";

/**
 * ============================================================================
 * SARTHEE AI — HOME MODULE ROUTER
 * ============================================================================
 *
 * Responsibility:
 *
 * This file only defines HTTP routes for Home module.
 *
 *
 * Request Flow:
 *
 * Client
 *   ↓
 * Home Router
 *   ↓
 * Home Controller
 *   ↓
 * Home Validator
 *   ↓
 * Home Service
 *   ↓
 * Home Repository
 *   ↓
 * Data Source
 *
 *
 * This file contains:
 *
 * ✅ Route definitions
 * ✅ HTTP methods
 * ✅ Controller binding
 *
 *
 * This file does NOT contain:
 *
 * ❌ Business logic
 * ❌ Database queries
 * ❌ Validation rules
 * ❌ Authentication logic
 *
 * ============================================================================
 */

const router = Router();

// ============================================================================
// ROUTE DEFINITIONS
// ============================================================================

/**
 * ============================================================================
 * MODULE READINESS
 * ============================================================================
 *
 * GET /api/v1/home/ready
 *
 * Purpose:
 *
 * - Verify Home module availability
 * - Used by monitoring systems
 * - Used during deployments
 *
 */
router.get("/ready", homeController.getReadiness);

/**
 * ============================================================================
 * REFRESH HOME CONTENT
 * ============================================================================
 *
 * POST /api/v1/home/refresh
 *
 * Purpose:
 *
 * - Refresh cached home experience
 * - Rebuild dynamic content
 *
 */
router.post("/refresh", homeController.refreshHomeContent);

/**
 * ============================================================================
 * HOME EXPERIENCE
 * ============================================================================
 *
 * GET /api/v1/home
 *
 * Provides:
 *
 * - Location based sections
 * - Quick actions
 * - Personalized recommendations
 * - AI ready experience structure
 *
 */
router.get("/", homeController.getHomeContent);

// ============================================================================
// EXPORTS
// ============================================================================

export { router as homeRouter };

export default router;
