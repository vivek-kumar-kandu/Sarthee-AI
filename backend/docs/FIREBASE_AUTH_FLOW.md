# Firebase Authentication Flow

## Overview

The backend uses Firebase Authentication as the trusted identity provider for the mobile app. Flutter signs in with Firebase, obtains an ID token, and sends it to the Express backend through the Authorization header.

## Login Flow

```text
Flutter App
  -> Firebase Authentication
  -> getIdToken()
  -> Authorization: Bearer <firebase_id_token>
  -> Express Middleware
  -> Firebase Admin SDK verification
  -> MongoDB user sync/profile operations
```

## Backend Requirements

- Firebase Admin SDK must be initialized.
- Every protected auth route requires a valid Bearer token.
- The backend never trusts a client-supplied UID.
- The backend only uses the UID from the verified Firebase token.

## API Endpoints

### Sync Firebase user with MongoDB

POST /api/v1/auth/sync

Headers:

```http
Authorization: Bearer <firebase_id_token>
Content-Type: application/json
```

Body:

```json
{
  "email": "user@example.com",
  "name": "Example User",
  "photoURL": "https://example.com/photo.png"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user-id",
      "firebaseUid": "firebase-uid",
      "email": "user@example.com",
      "name": "Example User"
    },
    "created": true
  }
}
```

### Get authenticated profile

GET /api/v1/auth/profile

Headers:

```http
Authorization: Bearer <firebase_id_token>
```

### Update authenticated profile

PUT /api/v1/auth/profile

Headers:

```http
Authorization: Bearer <firebase_id_token>
Content-Type: application/json
```

Body:

```json
{
  "profile": {
    "language": "en",
    "country": "US"
  },
  "preferences": {
    "travelStyle": "balanced"
  }
}
```

## Security Notes

- Do not store Firebase passwords.
- Do not store Firebase ID tokens.
- Do not trust client-supplied UIDs.
- Always verify tokens with Firebase Admin SDK before using the user identity.
