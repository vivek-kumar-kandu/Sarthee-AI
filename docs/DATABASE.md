# 🗄️ Sarthee AI — Database & Cache Architecture

> Data modeling, MongoDB Atlas Mongoose schemas, indexing strategies, and Redis caching design.

---

## 📌 1. Primary Database: MongoDB Atlas

Sarthee AI uses MongoDB Atlas as its primary document store for user identities, profiles, and preferences.

### Collection: `users`
- **File**: `backend/src/modules/auth/user.model.js`

```javascript
const userSchema = new mongoose.Schema({
  firebaseUid: { type: String, required: true, unique: true, index: true },
  email: { type: String, required: true, unique: true, lowercase: true, index: true },
  name: { type: String, required: true },
  picture: { type: String, default: null },
  authProvider: { type: String, enum: ['google', 'password'], default: 'google' },
  role: { type: String, enum: ['user', 'admin'], default: 'user' },
  profile: {
    dob: Date,
    gender: String,
    location: String,
    bio: String
  },
  location: {
    city: String,
    latitude: Number,
    longitude: Number
  },
  preferences: {
    language: { type: String, default: 'en' },
    theme: { type: String, default: 'system' },
    notifications: { type: Boolean, default: true }
  },
  isActive: { type: Boolean, default: true },
  lastLoginAt: Date
}, { timestamps: true });
```

#### Indexing Strategy:
1. `firebaseUid` (Unique Index): Instant 0ms lookups during Firebase JWT token sync.
2. `email` (Unique Lowercase Index): Prevents duplicate account registration.

---

## 📌 2. Planned Collection: `journey_logs` (Q4 Roadmap)

Stores historical user search queries and calculated carbon savings:

```javascript
const journeyLogSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', index: true },
  origin: { name: String, latitude: Number, longitude: Number },
  destination: { name: String, latitude: Number, longitude: Number },
  selectedProfile: String,
  totalCost: Number,
  totalDurationMinutes: Number,
  co2SavedKg: Number,
  createdAt: { type: Date, default: Date.now, expires: '90d' }
});
```

---

## 📌 3. Redis Caching Engine

### Strategy & Keys
- **Key Hashing Formula**: `journey:plan:{originLat},{originLng}:{destLat},{destLng}:{profile}`
- **TTL Strategy**: 600 seconds (10 minutes).
- **Eviction Policy**: `volatile-lru` (Least Recently Used with TTL).
- **Performance**:
  - **Cache Miss**: ~1.2s – 2.0s (computes OSRM, OpenWeather, Gemini AI).
  - **Cache Hit**: **0ms** (retrieves pre-computed JSON instantly).

### In-Memory Fallback Mechanism
If the Redis container disconnects or drops, `RedisCacheService` automatically switches to an internal JavaScript `Map` instance:

```javascript
if (!redisClient.isReady) {
  memoryFallbackMap.set(key, { value, expiresAt: Date.now() + ttlSeconds * 1000 });
}
```
This guarantees zero runtime crashes even if Redis is unavailable.
