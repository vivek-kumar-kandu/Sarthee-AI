# Firebase Authentication Architecture

## Overview

Sarthee AI backend uses Firebase Authentication for all user auth flows. The backend never stores passwords or Firebase secrets. The client authenticates with Firebase, receives an ID token, and sends that token to the backend using the Authorization header.

## Flow

Flutter App

    |
    | Firebase Authentication (Login / Signup / Google / Apple)

Firebase ID Token

    |
    | Authorization: Bearer <firebase_id_token>

Firebase Auth Middleware

    |
    | req.firebaseUser

Auth Controller

    |
    | Auth Service

User Repository

    |
    | MongoDB users collection

## API Endpoints

### POST /api/v1/auth/sync

Synchronizes a verified Firebase user with the MongoDB user collection.

Request headers:

``
Authorization: Bearer <firebase_id_token>
Content-Type: application/json
``

Request body:

``
{}
``

Response:

``json
{
  "success": true,
  "data": {
    "user": { ... },
    "created": true
  },
  "requestId": "...",
  "timestamp": "..."
}
``

### GET /api/v1/auth/profile

Returns the authenticated user's profile.

Request headers:

``bash
Authorization: Bearer <firebase_id_token>
``

Response:

``
{
  "success": true,
  "data": {
    "user": { ... }
  },
  "requestId": "...",
  "timestamp": "..."
}
``

### PUT /api/v1/auth/profile

Updates the authenticated user's profile data.

Request headers:

``
Authorization: Bearer <firebase_id_token>
Content-Type: application/json
``

Request body:

``json
{
  "profile": {
    "dob": "1990-01-01",
    "gender": "female",
    "location": "Paris",
    "bio": "Travel lover"
  },
  "location": {
    "city": "Paris",
    "latitude": 48.8566,
    "longitude": 2.3522
  },
  "preferences": {
    "language": "en",
    "theme": "dark",
    "notifications": true
  }
}
``

Response:

``
{
  "success": true,
  "data": {
    "user": { ... }
  },
  "requestId": "...",
  "timestamp": "..."
}
``

## Headers Example

``
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI...
``

## Security Notes

- Only Firebase Admin SDK verifies tokens.
- No Firebase client secrets or custom token storage are used.
- The backend uses only verified token fields:
  - `uid`
  - `email`
  - `name`
  - `picture`
  - `provider`
- Client-provided UID, email, or custom headers are ignored.
- `lastLoginAt` is updated each time `sync` runs.
