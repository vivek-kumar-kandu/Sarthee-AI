# 📜 Changelog

All notable changes to **Sarthee AI** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-07-31

### 🚀 Added
- **Smart Journey Engine**: Clean Architecture backend endpoint (`POST /api/v1/journey/plan`) supporting 8 journey optimization profiles (`recommended`, `fastest`, `cheapest`, `balanced`, `safest`, `accessible`, `eco`, `comfort`).
- **Grounded Gemini 2.0 Flash AI Advisor**: `GeminiAiProvider` generating natural language rationale strictly grounded in backend pre-computed metrics.
- **Dynamic Fare Engine**: Multi-tier fare calculation using `metro.json` (DMRC distance slabs) and `auto.json` (base + per km rates).
- **Dynamic Safety Engine**: 0–100 composite safety scoring using `weights.json` and time-of-day matrices.
- **Zero-Latency Redis Cache**: `RedisCacheService` storing 10-min TTL pre-computed plans with automatic in-memory Map fallback.
- **Firebase Auth & User Sync**: `firebaseAuthMiddleware` and `UserService` syncing user profiles with MongoDB Atlas `users` collection.
- **Location Autocomplete**: 350ms debounced place search across India landmarks via OpenStreetMap Nominatim API.
- **Flutter UI**: Cross-platform mobile application with Riverpod 2.6 state management, GoRouter 14 navigation, and Dio HTTP client.
- **Enterprise Documentation**: Modular documentation layout inside `docs/` (`ARCHITECTURE.md`, `API_REFERENCE.md`, `DATABASE.md`, `SECURITY.md`, `DEPLOYMENT.md`, `DEVELOPER_GUIDE.md`, `TROUBLESHOOTING.md`).

### 🛡️ Fixed
- **Router Registry**: Fixed missing import of `createJourneyRouter` in `backend/src/api/v1/routes/index.js`.
- **Push Protection Security**: Removed hardcoded OpenWeather and Gemini test keys from codebase and squashed commit history.
- **Riverpod State Mutation**: Resolved `state = AsyncValue.data(cached)` mutation inside `build()` in `home_provider.dart`.
- **Favicon 404 Log**: Added HTTP 204 No Content handler for `/favicon.ico` in `backend/src/app.js` to silence browser warning logs.
