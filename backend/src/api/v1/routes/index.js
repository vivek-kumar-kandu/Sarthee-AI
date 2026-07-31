import { Router } from "express";

import healthRoutes from "./health.routes.js";
import homeRoutes from "./home.routes.js";
import authRoutes from "../../../modules/auth/auth.routes.js";

/**
 * ============================================================================
 * SARTHEE AI — API V1 ROUTER REGISTRY
 * ============================================================================
 *
 * Central API gateway for version 1 routes.
 *
 * Architecture:
 *
 * app.js
 *   |
 *   └── /api/v1
 *          |
 *          ├── /health
 *          |
 *          └── /home
 *
 *
 * Responsibilities:
 *
 * ✅ Register feature routers
 * ✅ Maintain API version boundary
 * ✅ Keep modules isolated
 * ✅ Prepare scalable route expansion
 *
 *
 * This layer contains:
 *
 * ❌ No business logic
 * ❌ No validation
 * ❌ No database calls
 * ❌ No service logic
 *
 * Flow:
 *
 * Route
 *   ↓
 * Controller
 *   ↓
 * Validator
 *   ↓
 * Service
 *   ↓
 * Repository
 *   ↓
 * Data Source
 *
 * ============================================================================
 */

const router = Router();

// ============================================================================
// SYSTEM ROUTES
// ============================================================================

/**
 * Health Monitoring
 *
 * GET /api/v1/health
 *
 * Used by:
 *
 * - Load balancers
 * - Monitoring services
 * - Deployment platforms
 */
router.use("/health", healthRoutes);

// ============================================================================
// CORE FEATURE MODULES
// ============================================================================

/**
 * Home Experience
 *
 * GET  /api/v1/home
 * GET  /api/v1/home/ready
 * POST /api/v1/home/refresh
 *
 * Provides:
 *
 * - Location based experience
 * - Personalized sections
 * - Quick actions
 * - Future AI recommendations
 */
router.use("/home", homeRoutes);

/**
 * Authentication & User Profile
 *
 * POST /api/v1/auth/sync
 * GET  /api/v1/auth/profile
 * PUT  /api/v1/auth/profile
 */
router.use("/auth", authRoutes);

/**
 * Smart Journey Engine
 *
 * POST /api/v1/journey/plan
 */
router.use("/journey", createJourneyRouter());

// ============================================================================
// FUTURE MODULE REGISTRY
// ============================================================================
//
// Enable only after completing:
//
// Route
// ↓
// Controller
// ↓
// Validator
// ↓
// Service
// ↓
// Repository
//
// ============================================================================

// Authentication
//
// router.use("/auth", authRoutes);

// Destination Discovery
//
// router.use("/destinations", destinationRoutes);

// Culture & Heritage
//
// router.use("/culture", cultureRoutes);

// Food Discovery
//
// router.use("/food", foodRoutes);

// Hotels
//
// router.use("/hotels", hotelRoutes);

// Favorites
//
// router.use("/favorites", favoriteRoutes);

// Trip Planner
//
// router.use("/trips", tripRoutes);

// Budget Planner
//
// router.use("/budget", budgetRoutes);

// Weather
//
// router.use("/weather", weatherRoutes);

// Navigation
//
// router.use("/navigation", navigationRoutes);

// AI Assistant
//
// router.use("/ai", aiRoutes);

// ============================================================================
// EXPORTS
// ============================================================================

export { router as apiV1Router };

export default router;
