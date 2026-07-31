# 📘 Sarthee AI — Developer Handbook & Onboarding Manual

> Complete developer onboarding manual, file-by-file explanations, 4-week learning roadmap, and debugging guide.

---

## 📌 1. 4-Week Developer Onboarding Roadmap

```mermaid
timeline
    title Sarthee AI 4-Week Developer Onboarding Roadmap
    section Week 1 : Core Setup & Flutter UI
        Day 1-3 : Clone repo, setup Flutter 3.x, run app
        Day 4-7 : Study Riverpod state management & GoRouter navigation
    section Week 2 : Smart Journey UI & Repositories
        Day 8-10 : Trace smart_journey_planner_page.dart & Nominatim debouncing
        Day 11-14 : Understand RemoteJourneyDatasource & Dio HTTP client
    section Week 3 : Node.js Backend & Clean Architecture
        Day 15-18 : Run npm test, trace JourneyPlanController & PlanJourneyUseCase
        Day 19-21 : Study MultiModalGraphSearchService, fare_rules & safety weights
    section Week 4 : Cache, DB & Production Readiness
        Day 22-25 : Inspect RedisCacheService, MongoDB user.model.js & Pino logs
        Day 26-28 : Deploy sample route, study security guidelines & write unit tests
```

---

## 📌 2. Detailed Explanation of 10 Critical Core Files

1. **`plan_journey_use_case.js`**: Application use case orchestrating Redis cache check, domain graph search, weather provider, and Gemini AI.
2. **`multi_modal_graph_search_service.js`**: Pure domain service executing deterministic fare and safety algorithms.
3. **`osrm_routing_provider.js`**: OSRM HTTP routing API adapter with 5.0s timeout fallback.
4. **`openweather_provider.js`**: OpenWeatherMap API provider with 3.5s timeout guardrail.
5. **`gemini_ai_provider.js`**: Google Gemini 2.0 Flash AI explanation engine adapter.
6. **`journey_plan_controller.js`**: Express controller processing request DTOs & response envelopes.
7. **`user.model.js`**: Mongoose model for MongoDB `users` collection.
8. **`firebase-auth.middleware.js`**: Express middleware verifying Firebase JWT tokens.
9. **`smart_journey_planner_page.dart`**: Flutter UI screen for journey planning.
10. **`smart_journey_provider.dart`**: Riverpod StateNotifier managing journey planning UI state.

---

## 📌 3. Developer Debugging & Breakpoints Guide

### Key Breakpoints:
- **Flutter**: Place breakpoint inside `searchJourney()` in `smart_journey_provider.dart`.
- **Backend Controller**: Place breakpoint inside `handlePlanRequest()` in `journey_plan_controller.js`.
- **Domain Search**: Place breakpoint inside `calculateMultiModalRoutes()` in `multi_modal_graph_search_service.js`.

### Log Inspection:
Filter backend Pino JSON logs during local development:
```bash
cd backend
npm run dev | npx pino-pretty -m message -l error
```

---

## 📌 4. Common Startup Errors & Troubleshooting

| Symptom / Error | Root Cause | Fix Procedure |
| :--- | :--- | :--- |
| `ReferenceError: createJourneyRouter is not defined` | Missing import in `backend/src/api/v1/routes/index.js`. | Add `import { createJourneyRouter }` in `index.js`. |
| `AuthenticationError: Invalid authentication token` | Expired/invalid Firebase JWT token header. | Re-authenticate on mobile client to refresh token. |
| `GET /favicon.ico completed with 404` | Browser requesting tab icon from API server. | HTTP 204 No Content handler added in `app.js` to silence log. |
| `GitHub Push Protection Error (GH013)` | Hardcoded API key committed in Git history. | Replace key with `process.env.*` and squash/rebase commit history. |
| `ECONNREFUSED 127.0.0.1:6379` | Local Redis server not running. | Start Redis container or rely on automatic in-memory Map fallback. |

