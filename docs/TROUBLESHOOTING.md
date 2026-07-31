# 🐞 Sarthee AI — Troubleshooting & Debugging Manual

> Practical developer manual for debugging, log inspection, breakpoints setup, and resolving common errors.

---

## 📌 1. Key Breakpoint Locations

### Flutter Client (VS Code / Android Studio)
1. `searchJourney()` in `Sarthe_AI/lib/features/smart_journey/presentation/providers/smart_journey_provider.dart` — Inspect search input parameters.
2. `planJourney()` in `Sarthe_AI/lib/features/smart_journey/data/datasources/remote_journey_datasource.dart` — Inspect Dio HTTP request headers and payload.

### Node.js Backend (VS Code / Node Inspector)
1. `handlePlanRequest()` in `backend/src/modules/journey/presentation/controllers/journey_plan_controller.js` — Inspect incoming HTTP request body.
2. `execute()` in `backend/src/modules/journey/application/use_cases/plan_journey_use_case.js` — Inspect cache hit/miss status.
3. `calculateMultiModalRoutes()` in `backend/src/modules/journey/domain/services/multi_modal_graph_search_service.js` — Inspect individual leg pricing & polyline generation.

---

## 📌 2. Log Inspection & Formatting

The backend uses `Pino` structured JSON logging.

### View Live Backend Logs:
```bash
cd backend
npm run dev | npx pino-pretty -m message -l error
```

---

## 📌 3. Common Startup & Runtime Errors

| Error Message / Symptom | Root Cause | Fix Procedure |
| :--- | :--- | :--- |
| `ReferenceError: createJourneyRouter is not defined` | Missing import in `backend/src/api/v1/routes/index.js`. | Add `import { createJourneyRouter } from "../../../modules/journey/presentation/routes/journey_routes.js";`. |
| `AuthenticationError: Invalid authentication token` | Missing or expired Firebase JWT token header. | Re-authenticate on mobile client to refresh token. |
| `GET /favicon.ico completed with 404` | Web browser requesting tab icon from API server. | Added HTTP 204 No Content handler in `backend/src/app.js` to silence log. |
| `GitHub Push Protection Error (GH013)` | Exposed API key string committed in Git history. | Replace key with `process.env.*` variable and squash/rebase commit history. |
| `ECONNREFUSED 127.0.0.1:6379` | Local Redis server not running. | Start Redis container (`docker run -p 6379:6379 redis`) or rely on automatic in-memory Map fallback. |
