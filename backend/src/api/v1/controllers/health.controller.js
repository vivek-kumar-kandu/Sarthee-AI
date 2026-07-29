import { ApiResponse } from "../../../core/response/api-response.js";

/**
 * ============================================================================
 * SARTHEE AI — HEALTH CONTROLLER
 * ============================================================================
 *
 * Lightweight health endpoint for:
 *
 * • local development
 * • deployment health probes
 * • Docker / Kubernetes
 * • uptime monitoring
 * • load balancers
 */

export function getHealth(req, res) {
  const response = ApiResponse.success({
    data: {
      status: "ok",
      service: "sarthee-ai-backend",
      database: "connected",
      timestamp: new Date().toISOString(),
    },
    requestId: req.id,
  });

  return res.status(200).json(response);
}
