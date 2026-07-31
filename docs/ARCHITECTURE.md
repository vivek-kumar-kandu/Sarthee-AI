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
    REG --> JC
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
    PlanJourneyUseCase --> OpenWeatherProvider
    MultiModalGraphSearchService --> OsrmRoutingProvider
```
