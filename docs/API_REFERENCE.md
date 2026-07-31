# 📡 Sarthee AI — REST API Reference Manual

> Complete specification for Sarthee AI REST API endpoints, DTO validation, headers, authorization, and error envelope schemas.

---

## 📌 Base URL
- **Production Base URL**: `https://sarthee-ai.onrender.com/api/v1`
- **Local Development URL**: `http://localhost:10000/api/v1`

---

## 📌 Response Envelope Format

All API responses return a standardized JSON envelope structure:

### Success Envelope (HTTP 200 OK)
```json
{
  "success": true,
  "requestId": "req_32a74b4f-228c-4c8c",
  "timestamp": "2026-07-31T05:25:01.000Z",
  "data": { ... }
}
```

### Error Envelope (HTTP 400 / 401 / 404 / 500)
```json
{
  "success": false,
  "requestId": "req_err_9912",
  "timestamp": "2026-07-31T05:25:01.000Z",
  "error": {
    "code": "INVALID_COORDINATES",
    "message": "Origin and destination coordinates cannot be identical."
  }
}
```

---

## 📌 Endpoint Specifications

### 1. Orchestrate Smart Journey
- **URL**: `POST /journey/plan`
- **Method**: `POST`
- **Authentication**: Optional / Bearer Token (`Authorization: Bearer <firebase_jwt>`)
- **Headers**: `Content-Type: application/json`
- **Request Body**:
  ```json
  {
    "originName": "Ghaziabad Junction",
    "originLat": 28.6715,
    "originLng": 77.4121,
    "destinationName": "Connaught Place, Delhi",
    "destinationLat": 28.6328,
    "destinationLng": 77.2197,
    "preferredMode": "balanced"
  }
  ```
- **Validation Rules**:
  - `originLat`/`destinationLat`: Latitude numbers between $-90$ and $90$.
  - `originLng`/`destinationLng`: Longitude numbers between $-180$ and $180$.
  - Origin and destination coordinates must be distinct (distance $> 0$).
  - `preferredMode`: Enum `['recommended', 'fastest', 'cheapest', 'balanced', 'safest', 'accessible', 'eco', 'comfort']`.

- **Success Response (HTTP 200 OK)**:
  ```json
  {
    "success": true,
    "requestId": "req_8f91a2b0-47e1",
    "timestamp": "2026-07-31T05:25:01.000Z",
    "data": {
      "plans": {
        "balanced": {
          "id": "plan_bal_01",
          "mode": "balanced",
          "originName": "Ghaziabad Junction",
          "destinationName": "Connaught Place, Delhi",
          "totalDurationMinutes": 34,
          "totalCost": 80,
          "compositeSafetyScore": 82,
          "safetyDetails": {
            "compositeSafetyScore": 82,
            "ratingLabel": "High Safety",
            "highlights": ["Live App GPS Tracking & SOS", "Verified Commercial Driver"]
          },
          "polyline": "_|~mDspnwMFv@Rn...",
          "steps": [
            { "stepIndex": 1, "type": "auto", "title": "Take Auto to Metro Station", "distanceMeters": 1200, "durationMinutes": 5, "estimatedFare": 30 },
            { "stepIndex": 2, "type": "metro", "title": "Metro Transit Line", "distanceMeters": 24293, "durationMinutes": 25, "estimatedFare": 50 }
          ],
          "fareSummary": { "totalAmount": 80, "currency": "INR" },
          "aiRationale": "Sarthee Suggests: Combining Auto to Metro Rail is the fastest and safest route avoiding GT Road congestion."
        }
      }
    }
  }
  ```

---

### 2. Synchronize User Identity
- **URL**: `POST /auth/sync`
- **Method**: `POST`
- **Authentication**: Required (`Authorization: Bearer <firebase_jwt>`)
- **Headers**: `Content-Type: application/json`
- **Request Body**:
  ```json
  {
    "name": "Vivek Kumar",
    "email": "vivek@example.com",
    "picture": "https://lh3.googleusercontent.com/a/default-user"
  }
  ```
- **Success Response (HTTP 200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "userId": "66a8b1c2e4b0123456789abc",
      "firebaseUid": "FIREBASE_UID_12345",
      "email": "vivek@example.com",
      "role": "user"
    }
  }
  ```

---

### 3. Get User Profile
- **URL**: `GET /auth/profile`
- **Method**: `GET`
- **Authentication**: Required (`Authorization: Bearer <firebase_jwt>`)
- **Success Response (HTTP 200 OK)**: Returns full user profile object.

---

### 4. Health Check Probe
- **URL**: `GET /`
- **Method**: `GET`
- **Authentication**: None
- **Response**: `{"status": "ok", "app": "Sarthee AI", "version": "1.0.0"}`
