# 🏗️ Sarthee AI — System & Software Architecture

> Detailed architectural design, Clean Architecture layers, system interactions, and class relationships for Sarthee AI.

---

## 📌 1. High-Level System Architecture

```mermaid
graph TD
    subgraph Client Layer [Flutter 3.x Cross-Platform Mobile App]
        UI[Flutter UI / Responsive Widgets]
        RP[Riverpod 2.6 StateNotifier]
        MAP[Sarthee Leaflet Map Widget]
    end

    subgraph Gateway Layer [Node.js Express v5 API]
        GW[Express Gateway Router /api/v1]
        CTRL[JourneyPlanController]
    end

    subgraph Orchestration & Intelligence Layer [Clean Architecture Core]
        UC[PlanJourneyUseCase]
        JIO[JourneyIntelligenceOrchestrator]
        REG[JourneyProviderRegistry]
        DFE[DynamicFareEngine - Peak/Rain/Night Multipliers]
        RRE[RouteRankingEngine - Weighted Score Re-Ranker]
        JAS[JourneyAdvisorService]
        JC[Immutable JourneyContext]
    end

    subgraph Infrastructure & External Services
        REDIS[(Redis Cache / Memory Fallback)]
        OSRM[OSRM GeoJSON Routing Engine]
        OVERPASS[OpenStreetMap Overpass POI API]
        OWM[OpenWeatherMap API]
        GEMINI[Google Gemini 2.0 Flash AI]
    end

    UI --> RP --> MAP
    UI -->|POST /api/v1/journey/plan| GW --> CTRL --> UC
    UC -->|Check Cache| REDIS
    UC --> JIO --> REG
    REG -->|Core Engine| OSRM
    REG -->|Optional POI| OVERPASS
    REG -->|Optional Weather| OWM
    OSRM & OWM --> DFE
    DFE & OWM --> RRE
    RRE --> JC
    JC --> JAS --> GEMINI
    JC & JAS --> CTRL
```

---

## 📌 2. Clean Architecture Layer Breakdown

Sarthee AI adheres strictly to Clean Architecture principles:

```mermaid
graph LR
    subgraph Layer4 [Outer: External Frameworks & Drivers]
        Express[Express.js Engine]
        Flutter[Flutter Mobile UI]
        MongoDB[MongoDB Atlas]
        Redis[Redis Server]
    end

    subgraph Layer3 [Interface Adapters]
        Controller[JourneyPlanController]
        Providers[OsrmRoutingProvider / GeminiAiProvider]
    end

    subgraph Layer2 [Application Business Rules]
        UseCase[PlanJourneyUseCase]
        DTO[JourneyPlanRequestDTO]
    end

    subgraph Layer1 [Core: Enterprise Business Rules]
        Domain[MultiModalGraphSearchService]
        Entities[CoordinatesVO / FareSummaryVO]
    end

    Express --> Controller
    Flutter --> Controller
    Controller --> UseCase
    UseCase --> Domain
    Domain --> Entities
    Providers --> UseCase
    MongoDB --> Providers
    Redis --> Providers
```

---

## 📌 3. Request Lifecycle & Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Page as SmartJourneyPlannerPage
    participant Notifier as SmartJourneyNotifier (Riverpod)
    participant DS as RemoteJourneyDatasource (Dio)
    participant API as Express Gateway (/api/v1/journey/plan)
    participant UC as PlanJourneyUseCase
    participant Cache as Redis Cache Service
    participant OSRM as OSRM Routing Provider
    participant Engine as Dynamic Fare & Safety Engine
    participant Weather as OpenWeather Provider
    participant Gemini as Gemini AI Provider

    User->>Page: Select Origin & Destination
    Page->>Notifier: searchJourney(origin, dest, profile)
    Notifier->>DS: planJourney(dto)
    DS->>API: HTTP POST /api/v1/journey/plan
    API->>UC: execute(dto)
    UC->>Cache: checkCache(cacheKey)

    alt Cache Hit (0ms)
        Cache-->>UC: Return Cached Journey Plan JSON
    else Cache Miss (Live Calculation)
        UC->>OSRM: calculateRoute(origin, dest)
        OSRM-->>UC: Distance, Duration & Polylines
        UC->>Engine: calculateFaresAndSafety(legs)
        Engine-->>UC: Fares (₹) & Safety Index (0-100)
        UC->>Weather: getWeatherAdvisory(lat, lng)
        Weather-->>UC: Temperature & Rain Status
        UC->>Gemini: generateRationale(metrics)
        Gemini-->>UC: Grounded Natural Language Advice
        UC->>Cache: setCache(cacheKey, result, TTL=600s)
    end

    UC-->>API: Return Standard Success Envelope JSON
    API-->>DS: HTTP 200 OK
    DS-->>Notifier: JourneyPlan Entity
    Notifier-->>Page: Update UI State (isLoading = false)
    Page-->>User: Render Cards & Polylines
```

---

## 📌 4. Domain Class Relationships

```mermaid
classDiagram
    class PlanJourneyUseCase {
        +execute(dto: JourneyPlanRequestDTO)
    }
    class MultiModalGraphSearchService {
        +calculateMultiModalRoutes(origin, dest)
    }
    class OsrmRoutingProvider {
        +calculateRoute(lat1, lng1, lat2, lng2)
    }
    class GeminiAiProvider {
        +generateRationale(metrics)
    }
    class OpenWeatherProvider {
        +getWeatherAdvisory(lat, lng)
    }

    PlanJourneyUseCase --> MultiModalGraphSearchService
    PlanJourneyUseCase --> GeminiAiProvider
    MultiModalGraphSearchService --> OsrmRoutingProvider
    MultiModalGraphSearchService --> OpenWeatherProvider
```

---

## 📌 5. Phase 1 Dynamic Intelligence Engines & Active Guidance

### 5.1 DynamicFareEngine
Dedicated domain engine calculating time-of-day and weather surge multipliers:
- **Peak Hour Multiplier (`1.15x`)**: Active during morning (8–10 AM) and evening (5–8 PM) rush hours.
- **Rain Surge Multiplier (`1.25x`)**: Applied when monsoon rain/drizzle is reported.
- **Night Fare Multiplier (`1.25x`)**: Applied between 11 PM and 5 AM.

### 5.2 RouteRankingEngine & Weighted Scoring Formula
Calculates a composite recommendation score ($0 - 100$) for every candidate route profile:
$$\text{Score} = (\text{Time} \times 0.40) + (\text{Cost} \times 0.20) + (\text{Weather} \times 0.20) + (\text{Safety} \times 0.15) + (\text{Walking} \times 0.05)$$

- **Rain Re-Ranking**: Penalizes open walking (>250m) and open e-rickshaws, automatically promoting **Covered Metro Rail** as the top recommended route option.
- **Heat Re-Ranking**: Triggers when temperature $\ge 38^\circ\text{C}$, penalizing unshaded walking (>300m) and promoting AC transit.

### 5.3 Active Trip Guidance & Voice Suite
Flutter UI component (`ActiveTripGuidanceWidget.dart`) providing real-time trip execution state:
- Live leg progress bar (`LinearProgressIndicator`).
- Current step milestone details with OpenStreetMap landmark tips.
- Spoken turn-by-turn navigation via `VoiceGuidanceService.dart`.
- Next arrival milestone alerts and completion controls (`▶`).

---

## 📌 6. Phase 2B & 2C Live Transit, Traffic & Incident Intelligence

### 6.1 Generic Transit Abstraction & Trustworthy Fallback (`ITransitProvider`)
- Implements generic provider pattern (`GtfsRealtimeProvider`, `GtfsStaticProvider`) driven by `TRANSIT_PROVIDER` system configuration.
- **Rule — "Never Fake Real-Time"**: When live GTFS feeds are offline or unconfigured (`UNCONFIGURED`), transparently displays scheduled timetable metadata (`status: "SCHEDULED"`, `confidence: 0.7`) instead of faking fake countdown ETAs.

### 6.2 Traffic & Incident Intelligence (`TrafficProvider` & `IncidentProvider`)
- **Traffic Feed Monitor (`TrafficFeedMonitor.js`)**: Tracks feed health states (`UNCONFIGURED`, `HEALTHY`, `OFFLINE`).
- **Verified Congestion Penalties (`RouteRankingEngine.js`)**: Heavy road congestion (`+12 min delay`) or road closures (`ROAD_CLOSED`) automatically apply score penalties to cab/auto routes, promoting **Metro Rail** as the #1 recommended plan.
- **Flutter UI**: Displays `🟢 LIVE` or `🔵 SCHEDULED` badges, `🚦 Traffic` status chips, and `🚧 Incident` warning banners.
