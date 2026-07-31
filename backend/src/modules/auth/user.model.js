import mongoose from "mongoose";

/**
 * ============================================================================
 * SARTHEE AI — USER MODEL
 * ============================================================================
 *
 * MongoDB schema for application users.
 *
 * Designed for:
 *
 * • Firebase Authentication sync (firebaseUid lookup)
 * • Profile retrieval by email or id
 * • Future recommendation and personalization features
 *
 * This file contains schema definition only — no business logic.
 */

const AUTH_PROVIDERS = Object.freeze([
  "firebase",
  "password",
  "google",
  "apple",
]);

const USER_ROLES = Object.freeze(["user", "admin"]);

const profileSchema = new mongoose.Schema(
  {
    dob: {
      type: String,
      trim: true,
      maxlength: 100,
    },

    gender: {
      type: String,
      trim: true,
      maxlength: 40,
    },

    location: {
      type: String,
      trim: true,
      maxlength: 200,
    },

    bio: {
      type: String,
      trim: true,
      maxlength: 500,
    },
  },
  {
    _id: false,
  },
);

const locationSchema = new mongoose.Schema(
  {
    city: {
      type: String,
      trim: true,
      maxlength: 160,
    },

    latitude: {
      type: Number,
      min: -90,
      max: 90,
    },

    longitude: {
      type: Number,
      min: -180,
      max: 180,
    },
  },
  {
    _id: false,
  },
);

const preferencesSchema = new mongoose.Schema(
  {
    language: {
      type: String,
      trim: true,
      maxlength: 35,
    },

    theme: {
      type: String,
      trim: true,
      maxlength: 50,
    },

    notifications: {
      type: Boolean,
      default: null,
    },
  },
  {
    _id: false,
  },
);

const userSchema = new mongoose.Schema(
  {
    firebaseUid: {
      type: String,
      required: true,
      trim: true,
      index: true,
      unique: true,
    },

    email: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
      index: true,
      unique: true,
      maxlength: 320,
    },

    name: {
      type: String,
      required: true,
      trim: true,
      maxlength: 160,
    },

    picture: {
      type: String,
      trim: true,
      maxlength: 2048,
    },

    authProvider: {
      type: String,
      enum: AUTH_PROVIDERS,
      default: "firebase",
    },

    role: {
      type: String,
      enum: USER_ROLES,
      default: "user",
    },

    profile: {
      type: profileSchema,
      default: () => ({}),
    },

    location: {
      type: locationSchema,
      default: () => ({}),
    },

    preferences: {
      type: preferencesSchema,
      default: () => ({}),
    },

    lastLoginAt: {
      type: Date,
      default: null,
    },

    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
    collection: "users",
  },
);

// =============================================================================
// INDEXES
// =============================================================================

userSchema.index({ createdAt: -1 });

// =============================================================================
// MODEL
// =============================================================================

export const User = mongoose.model("User", userSchema);

export default User;

