# ☁️ Sarthee AI — Production Deployment Guide

> Production deployment manual for hosting Sarthee AI backend on Render Cloud Platform with MongoDB Atlas & Redis.

---

## 📌 1. Production Architecture Overview

```mermaid
graph TD
    subgraph Client Tier [User Devices]
        MOB[Flutter Android / iOS Application]
    end

    subgraph Hosting Tier [Render Cloud Platform]
        API_SRV[Node.js Express API Instance]
    end

    subgraph Data Tier [Managed Cloud Databases]
        REDIS[(Redis Cloud Service)]
        MONGO[(MongoDB Atlas Primary Cluster)]
    end

    subgraph External APIs Tier
        OSRM_API[OSRM Public Routing API]
        OWM_API[OpenWeatherMap API]
        GEMINI_API[Google Gemini 2.0 Flash AI]
    end

    MOB -->|HTTPS / REST| API_SRV
    API_SRV -->|0ms Cache Read/Write| REDIS
    API_SRV -->|User Auth & Profiles| MONGO
    API_SRV -->|Distance & Polyline| OSRM_API
    API_SRV -->|Rain & Temp Alerts| OWM_API
    API_SRV -->|Grounded AI Rationale| GEMINI_API
```

---

## 📌 2. Render Deployment Setup

1. **Service Type**: Web Service (Node.js Environment).
2. **Repository**: `https://github.com/vivek-kumar-kandu/Sarthee-AI`.
3. **Branch**: `main`.
4. **Root Directory**: `backend`.
5. **Build Command**: `npm install`.
6. **Start Command**: `npm start` (`node src/server.js`).

---

## 📌 3. Required Environment Variables on Render

In the Render Dashboard under **Environment Variables**, add:

| Key | Value Description |
| :--- | :--- |
| `NODE_ENV` | `production` |
| `PORT` | `10000` (assigned automatically by Render) |
| `MONGODB_URI` | `mongodb+srv://user:pass@cluster.mongodb.net/sarthee_ai` |
| `REDIS_URL` | `redis://default:pass@redis-cloud-host:6379` |
| `FIREBASE_PROJECT_ID` | `sartheeai` |
| `FIREBASE_CLIENT_EMAIL` | `firebase-adminsdk-...@sartheeai.iam.gserviceaccount.com` |
| `FIREBASE_PRIVATE_KEY` | `-----BEGIN PRIVATE KEY-----\n...` |
| `OPENWEATHER_API_KEY` | Live OpenWeatherMap API Key |
| `GEMINI_API_KEY` | Live Google Gemini 2.0 Flash API Key |

---

## 📌 4. Health Check Verification

Render pings `GET /` to verify service readiness:

- **Endpoint**: `GET https://sarthee-ai.onrender.com/`
- **Expected Status**: `HTTP 200 OK`
- **Expected Payload**:
  ```json
  {
    "status": "ok",
    "app": "Sarthee AI",
    "version": "1.0.0",
    "timestamp": "2026-07-31T05:20:17.000Z"
  }
  ```
