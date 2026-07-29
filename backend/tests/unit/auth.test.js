import test from "node:test";
import assert from "node:assert/strict";

import * as firebaseAuth from "../../src/config/firebase-auth.js";
import { firebaseAuthMiddleware } from "../../src/middleware/firebase-auth.middleware.js";
import { UserService } from "../../src/modules/auth/user.service.js";

function createMockResponse() {
  return {
    statusCode: 200,
    body: undefined,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(payload) {
      this.body = payload;
      return this;
    },
  };
}

function createMockRequest(headers = {}) {
  return {
    headers,
    get(name) {
      return this.headers[name.toLowerCase()];
    },
  };
}

test("firebaseAuthMiddleware rejects requests without a bearer token", async () => {
  const req = createMockRequest();
  const res = createMockResponse();
  let nextCalled = false;

  await firebaseAuthMiddleware(req, res, () => {
    nextCalled = true;
  });

  assert.equal(nextCalled, false);
  assert.equal(res.statusCode, 401);
  assert.equal(res.body?.success, false);
});

test("firebaseAuthMiddleware rejects invalid Firebase tokens", async () => {
  const originalVerify = firebaseAuth.firebaseAuthVerifier.verifyIdToken;
  firebaseAuth.firebaseAuthVerifier.verifyIdToken = async () => {
    const error = new Error("Invalid token");
    error.code = "auth/invalid-id-token";
    throw error;
  };

  const req = createMockRequest({ authorization: "Bearer invalid-token" });
  const res = createMockResponse();
  let nextCalled = false;

  try {
    await firebaseAuthMiddleware(req, res, () => {
      nextCalled = true;
    });
  } finally {
    firebaseAuth.firebaseAuthVerifier.verifyIdToken = originalVerify;
  }

  assert.equal(nextCalled, false);
  assert.equal(res.statusCode, 401);
  assert.equal(res.body?.success, false);
});

test("firebaseAuthMiddleware attaches verified Firebase user data", async () => {
  const originalVerify = firebaseAuth.firebaseAuthVerifier.verifyIdToken;
  firebaseAuth.firebaseAuthVerifier.verifyIdToken = async () => ({
    uid: "firebase-uid-1",
    email: "user@example.com",
    name: "Example User",
    picture: "https://example.com/photo.png",
    firebase: { sign_in_provider: "google.com" },
  });

  const req = createMockRequest({ authorization: "Bearer valid-token" });
  const res = createMockResponse();
  let nextCalled = false;

  try {
    await firebaseAuthMiddleware(req, res, () => {
      nextCalled = true;
    });
  } finally {
    firebaseAuth.firebaseAuthVerifier.verifyIdToken = originalVerify;
  }

  assert.equal(nextCalled, true);
  assert.deepEqual(req.firebaseUser, {
    uid: "firebase-uid-1",
    email: "user@example.com",
    name: "Example User",
    picture: "https://example.com/photo.png",
    provider: "google",
  });
});

test("firebaseAuthMiddleware rejects expired Firebase tokens", async () => {
  const originalVerify = firebaseAuth.firebaseAuthVerifier.verifyIdToken;
  firebaseAuth.firebaseAuthVerifier.verifyIdToken = async () => {
    const error = new Error("Expired token");
    error.code = "auth/id-token-expired";
    throw error;
  };

  const req = createMockRequest({ authorization: "Bearer expired-token" });
  const res = createMockResponse();
  let nextCalled = false;

  try {
    await firebaseAuthMiddleware(req, res, () => {
      nextCalled = true;
    });
  } finally {
    firebaseAuth.firebaseAuthVerifier.verifyIdToken = originalVerify;
  }

  assert.equal(nextCalled, false);
  assert.equal(res.statusCode, 401);
  assert.equal(res.body?.success, false);
  assert.equal(res.body?.error?.code, "TOKEN_EXPIRED");
});

test("UserService creates a new user from Firebase context", async () => {
  const repository = {
    findByFirebaseUid: async () => null,
    findByEmail: async () => null,
    findById: async () => null,
    createUser: async (payload) => ({
      _id: "user-1",
      ...payload,
      role: "user",
      isActive: true,
      profile: {},
      location: {},
      preferences: {},
      createdAt: new Date("2024-01-01T00:00:00.000Z"),
      updatedAt: new Date("2024-01-01T00:00:00.000Z"),
    }),
    updateUser: async () => null,
    deleteUser: async () => null,
  };

  const service = new UserService({ repository });
  const result = await service.createOrUpdateUser({
    firebaseUid: "firebase-uid-1",
    email: "user@example.com",
    name: "Example User",
    picture: "https://example.com/photo.png",
  });

  assert.equal(result.created, true);
  assert.equal(result.user.firebaseUid, "firebase-uid-1");
  assert.equal(result.user.email, "user@example.com");
  assert.equal(result.user.picture, "https://example.com/photo.png");
});

test("UserService updates an existing user and refreshes last login", async () => {
  const repository = {
    findByFirebaseUid: async () => ({
      _id: "user-1",
      firebaseUid: "firebase-uid-1",
      email: "user@example.com",
      name: "Example User",
      picture: "https://example.com/photo.png",
      authProvider: "google",
      role: "user",
      isActive: true,
      profile: {},
      location: {},
      preferences: {},
      createdAt: new Date("2024-01-01T00:00:00.000Z"),
      updatedAt: new Date("2024-01-01T00:00:00.000Z"),
    }),
    findByEmail: async () => null,
    findById: async () => null,
    createUser: async () => null,
    updateUser: async (_id, payload) => ({
      _id,
      firebaseUid: "firebase-uid-1",
      email: "user@example.com",
      name: "Example User",
      picture: "https://example.com/photo.png",
      authProvider: "google",
      role: "user",
      isActive: true,
      profile: {},
      location: {},
      preferences: {},
      lastLoginAt: payload.lastLoginAt,
      createdAt: new Date("2024-01-01T00:00:00.000Z"),
      updatedAt: new Date("2024-01-01T00:00:00.000Z"),
    }),
    deleteUser: async () => null,
  };

  const service = new UserService({ repository });
  const result = await service.createOrUpdateUser({
    firebaseUid: "firebase-uid-1",
    email: "user@example.com",
    name: "Example User",
    picture: "https://example.com/photo.png",
  });

  assert.equal(result.created, false);
  assert.ok(result.user.lastLoginAt !== undefined);
});

test("UserService allows profile updates for authenticated user", async () => {
  const repository = {
    findByFirebaseUid: async () => ({
      _id: "user-1",
      firebaseUid: "firebase-uid-1",
      email: "user@example.com",
      name: "Example User",
      picture: "https://example.com/photo.png",
      authProvider: "google",
      role: "user",
      isActive: true,
      profile: { dob: "1990-01-01" },
      location: { city: "Mumbai" },
      preferences: { language: "en", theme: "light", notifications: true },
      createdAt: new Date("2024-01-01T00:00:00.000Z"),
      updatedAt: new Date("2024-01-01T00:00:00.000Z"),
    }),
    findByEmail: async () => null,
    findById: async () => null,
    createUser: async () => null,
    updateUser: async (_id, payload) => ({
      _id,
      firebaseUid: "firebase-uid-1",
      email: "user@example.com",
      name: "Example User",
      picture: "https://example.com/photo.png",
      authProvider: "google",
      role: "user",
      isActive: true,
      profile: { ...{ dob: "1990-01-01" }, ...payload.profile },
      location: { ...{ city: "Mumbai" }, ...payload.location },
      preferences: {
        ...{ language: "en", theme: "light", notifications: true },
        ...payload.preferences,
      },
      createdAt: new Date("2024-01-01T00:00:00.000Z"),
      updatedAt: new Date("2024-01-02T00:00:00.000Z"),
    }),
    deleteUser: async () => null,
  };

  const service = new UserService({ repository });
  const updated = await service.updateProfileByFirebaseUid("firebase-uid-1", {
    profile: { bio: "Travel lover" },
    location: { city: "Paris", latitude: 48.8566, longitude: 2.3522 },
    preferences: { theme: "dark", notifications: false },
  });

  assert.equal(updated.profile.bio, "Travel lover");
  assert.equal(updated.location.city, "Paris");
  assert.equal(updated.preferences.theme, "dark");
  assert.equal(updated.preferences.notifications, false);
});

test("UserService returns a public profile for an authenticated user", async () => {
  const repository = {
    findByFirebaseUid: async () => ({
      _id: "user-1",
      firebaseUid: "firebase-uid-1",
      email: "user@example.com",
      name: "Example User",
      picture: "https://example.com/photo.png",
      authProvider: "google",
      role: "user",
      isActive: true,
      profile: {},
      location: {},
      preferences: {},
      createdAt: new Date("2024-01-01T00:00:00.000Z"),
      updatedAt: new Date("2024-01-01T00:00:00.000Z"),
    }),
    findByEmail: async () => null,
    findById: async () => null,
    createUser: async () => null,
    updateUser: async () => null,
    deleteUser: async () => null,
  };

  const service = new UserService({ repository });
  const user = await service.getProfileByFirebaseUid("firebase-uid-1");

  assert.equal(user.firebaseUid, "firebase-uid-1");
  assert.equal(user.email, "user@example.com");
});
