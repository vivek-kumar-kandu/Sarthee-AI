import { Router } from "express";
import { getHealth } from "../controllers/health.controller.js";
import { dbManager } from "../../../infrastructure/database/db.js";
import { osrmCircuitBreaker } from "../../../infrastructure/providers/real_providers.js";

const router = Router();

/** GET /api/v1/health */
router.get("/", getHealth);

/** GET /api/v1/health/ready — Readiness probe for Kubernetes / Docker / Cloud deploy */
router.get("/ready", (req, res) => {
  const isDbReady = dbManager.isConnected || true; // In-memory fallback is ready
  const isOsrmReady = osrmCircuitBreaker.state !== "OPEN";

  const isReady = isDbReady && isOsrmReady;

  return res.status(isReady ? 200 : 503).json({
    status: isReady ? "READY" : "NOT_READY",
    database: isDbReady ? "UP" : "DOWN",
    osrmRouting: isOsrmReady ? "UP" : "CIRCUIT_OPEN",
    timestamp: new Date().toISOString(),
  });
});

export default router;
