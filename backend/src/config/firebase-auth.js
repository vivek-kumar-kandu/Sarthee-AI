import { getAuth } from "firebase-admin/auth";

import firebaseApp from "./firebase.js";

/**
 * Returns Firebase Auth for the initialized Admin app.
 * Firebase Admin SDK v14+ requires modular `getAuth()` — not `admin.auth()`.
 */
export function getFirebaseAuth() {
  if (!firebaseApp) {
    return null;
  }

  return getAuth(firebaseApp);
}

async function verifyIdTokenImpl(idToken) {
  const auth = getFirebaseAuth();

  if (!auth) {
    const error = new Error("Firebase Admin is not initialized.");
    error.code = "auth/app-deleted";
    throw error;
  }

  return auth.verifyIdToken(idToken);
}

/** Mutable hook for unit tests. */
export const firebaseAuthVerifier = {
  verifyIdToken: verifyIdTokenImpl,
};

export async function verifyFirebaseIdToken(idToken) {
  return firebaseAuthVerifier.verifyIdToken(idToken);
}

