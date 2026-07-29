import { initializeApp, cert, getApps } from "firebase-admin/app";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

import { env } from "./env.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const serviceAccountPath =
  env.firebase.serviceAccountPath ||
  process.env.FIREBASE_SERVICE_ACCOUNT_PATH ||
  path.join(__dirname, "../../secrets/firebase-service-account.json");

function loadServiceAccount() {
  try {
    if (!fs.existsSync(serviceAccountPath)) {
      return undefined;
    }

    return JSON.parse(fs.readFileSync(serviceAccountPath, "utf8"));
  } catch (err) {
    console.warn(
      "Failed to load Firebase service account:",
      err.message
    );
    return undefined;
  }
}

function loadEnvCredentials() {
  const {
    projectId,
    clientEmail,
    privateKey,
  } = env.firebase;

  if (!projectId || !clientEmail || !privateKey) {
    return undefined;
  }

  return {
    project_id: projectId,
    client_email: clientEmail,
    private_key: privateKey.replace(/\\n/g, "\n"),
  };
}

function initializeFirebase() {
  if (getApps().length) {
    return getApps()[0];
  }

  const credentials =
    loadEnvCredentials() || loadServiceAccount();

  if (!credentials) {
    console.warn(
      "Firebase credentials not found. Firebase Admin disabled."
    );
    return null;
  }

  console.log("Project ID:", credentials.project_id);
  console.log("Client Email:", credentials.client_email);

  const app = initializeApp({
    credential: cert(credentials),
    projectId: credentials.project_id,
  });

  console.log(
    `Firebase Admin initialized: ${credentials.project_id}`
  );

  return app;
}

const firebaseApp = initializeFirebase();

export default firebaseApp;