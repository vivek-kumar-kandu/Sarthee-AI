import mongoose from 'mongoose';
import { TRIP_STATES } from '../../domain/entities/trip_entity.js';

const stopSchema = new mongoose.Schema(
  {
    id: { type: String, required: true },
    name: { type: String, required: true },
    category: { type: String, default: 'attraction' },
    arrivalTime: { type: String, default: '' },
    durationMinutes: { type: Number, default: 60 },
    cost: { type: Number, default: 0 },
    location: {
      lat: { type: Number, required: true },
      lng: { type: Number, required: true },
    },
    whyRecommended: { type: [String], default: [] },
  },
  { _id: false },
);

const daySchema = new mongoose.Schema(
  {
    dayIndex: { type: Number, required: true },
    title: { type: String, required: true },
    stops: { type: [stopSchema], default: [] },
    reoptimizedAt: { type: String, default: null },
    reoptimizeReason: { type: String, default: null },
  },
  { _id: false },
);

const tripSchema = new mongoose.Schema(
  {
    id: { type: String, required: true, unique: true, index: true },
    userId: { type: String, required: true, index: true, default: 'guest' },
    title: { type: String, required: true, default: 'Custom Trip' },
    city: { type: String, required: true, default: 'Jaipur' },
    persona: { type: String, required: true, default: 'Family' },
    status: {
      type: String,
      enum: Object.values(TRIP_STATES),
      default: TRIP_STATES.PLANNED,
      index: true,
    },
    days: { type: [daySchema], default: [] },
    costBreakdown: {
      transport: { type: Number, default: 0 },
      food: { type: Number, default: 0 },
      tickets: { type: Number, default: 0 },
      buffer: { type: Number, default: 0 },
      total: { type: Number, default: 0 },
    },
    confidence: {
      score: { type: Number, default: 95 },
      verifiedSources: { type: [String], default: [] },
    },
    shareToken: { type: String, required: true, index: true },
    history: [
      {
        state: { type: String, required: true },
        timestamp: { type: String, required: true },
      },
    ],
    isArchived: { type: Boolean, default: false, index: true },
    metadata: { type: mongoose.Schema.Types.Mixed, default: {} },
  },
  {
    timestamps: true,
  },
);

export const TripModel = mongoose.models.Trip || mongoose.model('Trip', tripSchema);
