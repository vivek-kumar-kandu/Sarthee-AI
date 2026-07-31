# 📖 Sarthee AI — Developer Onboarding Guide & Directory Explanation

> Complete folder-by-folder structure breakdown, key file explanations, and a 4-week onboarding learning roadmap.

---

## 📌 1. Complete Directory Breakdown

### 📱 Flutter Mobile Application (`Sarthe_AI/lib/`)

```text
Sarthe_AI/lib/
├── app/                        # MaterialApp bootstrap, Riverpod scope, GoRouter navigation
│   ├── app.dart                # SartheeApp root widget
│   └── router/                 # AppRouter, RouteGuards, Named route constants
├── config/                     # Firebase & environment configuration stubs
├── core/                       # Core system infrastructure
│   ├── api/                    # Core API interfaces
│   ├── auth/                   # Token storage & auth state wrappers
│   ├── error/                  # Domain exceptions (NetworkException, AuthException)
│   ├── network/                # Dio HTTP client with global interceptors (api_client.dart)
│   ├── storage/                # FlutterSecureStorage & Hive local cache
│   └── theme/                  # Sarthee Design System (colors, typography, light/dark themes)
├── features/                   # Feature-first Clean Architecture packages
│   ├── smart_journey/          # Core Multi-Modal Journey Engine (UI, Notifier, Datasource)
│   ├── auth/                   # Firebase Auth UI, Google Sign-In, login state
│   ├── profile/                # Profile view, edit dialog, preferences
│   ├── location/               # GPS location service & permissions
│   ├── home/                   # Home dashboard UI & quick actions
│   └── weather/                # Weather forecast cards & rain advisories
└── shared/                     # Reusable UI components & adaptive shell navigation
```

### 🖥️ Node.js Express Backend (`backend/src/`)

```text
backend/src/
├── api/v1/routes/              # Central versioned API gateway router registry (index.js)
├── common/middleware/          # Rate limiting, security headers, CORS, response envelope
├── config/                     # Environment schema validation (env.js) & feature flags
├── core/                       # AppError definitions & Pino structured logger
├── database/                   # MongoDB connection lifecycle (mongoose.js)
├── infrastructure/             # Cache services & concrete API providers
│   ├── cache/                  # RedisCacheService with in-memory Map fallback
│   ├── config/                 # Dynamic fare rules (metro.json, auto.json) & safety weights
│   └── providers/              # External API adapters (OSRM, OpenWeather, Gemini 2.0 Flash)
└── modules/                    # Domain Modules (auth, journey, home, ai)
    └── journey/                # Core Journey Module (Controller, DTO, UseCase, Domain Graph)
```

---

## 📌 2. Explanation of 10 Critical Core Files

1. **`plan_journey_use_case.js`**: Application use case orchestrating Redis cache check, domain graph search, weather provider, and Gemini AI.
2. **`multi_modal_graph_search_service.js`**: Core pure domain service executing deterministic fare and safety calculations.
3. **`osrm_routing_provider.js`**: OSRM HTTP routing API adapter with 5.0s timeout fallback.
4. **`openweather_provider.js`**: OpenWeatherMap API provider with 3.5s timeout guardrail.
5. **`gemini_ai_provider.js`**: Google Gemini 2.0 Flash AI explanation engine adapter.
6. **`journey_plan_controller.js`**: Express controller processing request DTOs & response envelopes.
7. **`user.model.js`**: Mongoose model for MongoDB `users` collection.
8. **`firebase-auth.middleware.js`**: Express middleware verifying Firebase JWT tokens.
9. **`smart_journey_planner_page.dart`**: Flutter UI screen for journey planning.
10. **`smart_journey_provider.dart`**: Riverpod StateNotifier managing journey planning UI state.

---

## 📌 3. 4-Week Developer Onboarding Roadmap

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
