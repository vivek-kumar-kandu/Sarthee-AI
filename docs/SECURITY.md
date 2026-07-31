# 🔒 Sarthee AI — Security Policy & Secret Management

> Comprehensive security architecture, identity verification policies, and secret protection guidelines for Sarthee AI.

---

## 📌 1. Identity & Token Verification

Sarthee AI delegates primary user identity verification to **Firebase Authentication**:

1. Mobile client authenticates with Google Sign-In or Password credentials via Firebase SDK.
2. Mobile client receives a signed Firebase JWT ID Token.
3. Requests to protected endpoints send `Authorization: Bearer <firebase_jwt>`.
4. Backend `firebaseAuthMiddleware` verifies JWT signature and expiry using `Firebase Admin SDK`.
5. Invalid or expired tokens return `HTTP 401 Unauthorized` (`INVALID_TOKEN` / `TOKEN_EXPIRED`).

---

## 📌 2. Environment Secret Management

All sensitive secrets (API keys, database URIs, service account keys) **MUST** be stored strictly in `.env` files and environment variables — **NEVER hardcoded in source code or test files**.

### Environment Variables Checklist:
- `MONGODB_URI`: MongoDB Atlas connection URI.
- `REDIS_URL`: Redis Cloud server URL.
- `FIREBASE_PROJECT_ID`: Firebase project identifier.
- `FIREBASE_CLIENT_EMAIL`: Firebase service account client email.
- `FIREBASE_PRIVATE_KEY`: Firebase service account RSA private key.
- `OPENWEATHER_API_KEY`: OpenWeatherMap REST API key.
- `GEMINI_API_KEY`: Google Gemini 2.0 Flash API key.

---

## 📌 3. GitHub Push Protection & Secret Scanning

To prevent committing API keys or private credentials to GitHub:

1. **Pre-Commit Hooks (`husky` & `gitleaks`)**:
   ```bash
   npx husky-init && npm install
   npx husky add .husky/pre-commit "npx gitleaks protect --staged"
   ```
2. **Git Ignore Enforcement**: All `.env*` files, `secrets/` folders, `*service-account*.json`, and private keys are ignored by `.gitignore`.

---

## 📌 4. Security Headers & Rate Limiting

- **Helmet Security**: Disables `X-Powered-By`, enables `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, and HTTP Strict Transport Security (HSTS).
- **CORS Policies**: Express restricts allowed HTTP origins to trusted mobile apps and admin domains.
- **Rate Limiting**: Enforces IP-based request limits on `/api/v1` routes to prevent DDoS or API abuse.
