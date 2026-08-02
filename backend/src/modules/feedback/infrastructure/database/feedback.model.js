import mongoose from 'mongoose';

const feedbackSchema = new mongoose.Schema(
  {
    feedbackId: { type: String, required: true, unique: true, index: true },
    userId: { type: String, required: true, index: true, default: 'anonymous_beta_tester' },
    rating: { type: Number, required: true, min: 1, max: 5, index: true },
    journeyAccuracyRating: { type: Number, min: 1, max: 5, default: 5 },
    nearbyAccuracyRating: { type: Number, min: 1, max: 5, default: 5 },
    performanceRating: { type: Number, min: 1, max: 5, default: 5 },
    category: { type: String, required: true, default: 'general', index: true },
    comments: { type: String, default: '' },
    userDeviceInfo: { type: mongoose.Schema.Types.Mixed, default: {} },
    timestamp: { type: String, required: true },
  },
  {
    timestamps: true,
  },
);

export const FeedbackModel = mongoose.models.Feedback || mongoose.model('Feedback', feedbackSchema);
