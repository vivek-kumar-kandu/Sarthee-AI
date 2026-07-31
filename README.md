# 🚀 Sarthee AI — Intelligent Multi-Modal Mobility Assistant

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/vivek-kumar-kandu/Sarthee-AI)
[![Node.js Version](https://img.shields.io/badge/node-%3E%3D20.0.0-blue.svg)](https://nodejs.org)
[![Flutter Version](https://img.shields.io/badge/flutter-3.x-blue.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Deployment](https://img.shields.io/badge/render-live-success.svg)](https://sarthee-ai.onrender.com)

**Sarthee AI** is an intelligent, multi-modal travel, navigation, and urban mobility assistant engineered specifically for urban India (Delhi NCR, Ghaziabad, Noida, Gurgaon, and major Indian metro hubs).

The system orchestrates seamless door-to-door journey recommendations combining E-Rickshaws, Auto-Rickshaws, DTC Feeder Buses, Delhi Metro Rail (DMRC), Taxi Cabs, and Walking legs into a single cohesive experience.

---

## 📌 Features & Highlights

- **Multi-Modal Journey Planner**: Computes end-to-end journey recommendations across 8 profiles (`recommended`, `fastest`, `cheapest`, `balanced`, `safest`, `accessible`, `eco`, `comfort`).
- **Deterministic Calculation Engine**: Dynamic Fare Engine (`metro.json` slabs + `auto.json` rates) and Dynamic Safety Engine (`weights.json` score matrix) — **100% math without generative AI guessing**.
- **Grounded Gemini 2.0 Flash AI Advisor**: Explains transit choices in natural language strictly grounded in pre-computed backend metrics.
- **Zero-Latency Redis Cache**: Caches computed itineraries in Redis (10-min TTL) for instant **0ms** responses on repeated queries.
- **Debounced Location Autocomplete**: 350ms debounced place search across Indian landmarks via OpenStreetMap Nominatim.
- **Firebase Auth & User Sync**: Authenticates JWT identity tokens and synchronizes user profiles with MongoDB Atlas.

---

## 🌐 Production URL & Live API

- **Production API Base**: `https://sarthee-ai.onrender.com/api/v1`
- **Health Check Probe**: `GET https://sarthee-ai.onrender.com/` (`HTTP 200 OK`)
- **Live Smart Journey Planning**: `POST https://sarthee-ai.onrender.com/api/v1/journey/plan`

---

## 📚 Technical Documentation Directory (`docs/`)

For in-depth architectural blueprints, schemas, and developer manuals, explore our modular documentation suite:

| Document | Description |
| :--- | :--- |
| 🏗️ **[Architecture Guide](docs/ARCHITECTURE.md)** | System architecture diagrams, Clean Architecture layers, request lifecycles, and class diagrams. |
| 📡 **[API Reference](docs/API_REFERENCE.md)** | Endpoint specifications, HTTP headers, envelope schemas, and request/response JSON examples. |
| 🗄️ **[Database & Cache Guide](docs/DATABASE.md)** | MongoDB Atlas `users` Mongoose schema, indexing, and Redis 10-min TTL caching strategy. |
| 🔒 **[Security Policy](docs/SECURITY.md)** | Secret management, Firebase JWT authentication verification, rate limiting, and push protection. |
| ☁️ **[Deployment Guide](docs/DEPLOYMENT.md)** | Production hosting setup on Render Cloud Platform, environment variables, and health probes. |
| 📖 **[Developer Onboarding Guide](docs/DEVELOPER_GUIDE.md)** | Folder-by-folder breakdown, file explanations, and a 4-Week Developer Onboarding Roadmap. |
| 🐞 **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)** | Breakpoint setup, Pino JSON log filtering, common startup errors, and debugging recipes. |

---

## ⚡ Developer Quickstart

### Backend Setup (Node.js REST API)
```bash
cd backend
npm install
npm test
npm run dev
```

### Mobile App Setup (Flutter Frontend)
```bash
cd Sarthe_AI
flutter pub get
flutter analyze
flutter run
```

---

## 📄 Repository License & Governance

- 📜 **[CHANGELOG.md](CHANGELOG.md)** — Project release history and version notes.
- 🤝 **[CONTRIBUTING.md](CONTRIBUTING.md)** — Guidelines for submitting issues and pull requests.
- ⚖️ **[LICENSE](LICENSE)** — MIT License terms and conditions.

---
*Copyright © 2026 Sarthee AI. Developed with ❤️ for Urban India Mobility.*
