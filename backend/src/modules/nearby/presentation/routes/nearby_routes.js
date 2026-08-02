import { Router } from "express";
import { getNearbyPlaces } from "../controllers/nearby_controller.js";

/**
 * ============================================================================
 * SARTHEE AI — NEARBY MODULE ROUTER
 * ============================================================================
 *
 * GET /api/v1/nearby?lat=&lng=&category=&radius=&limit=&query=
 */

const router = Router();

router.get("/", getNearbyPlaces);

export { router as nearbyRouter };
export default router;
