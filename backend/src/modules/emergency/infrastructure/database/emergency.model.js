import mongoose from 'mongoose';

const emergencySchema = new mongoose.Schema(
  {
    sosId: { type: String, required: true, unique: true, index: true },
    userId: { type: String, required: true, index: true, default: 'user_guest' },
    timestamp: { type: String, required: true },
    userLocation: {
      lat: { type: Number, required: true },
      lng: { type: Number, required: true },
      liveLocationLink: { type: String, required: true },
    },
    emergencyHelplines: { type: mongoose.Schema.Types.Mixed, default: {} },
    nearestServices: { type: mongoose.Schema.Types.Mixed, default: {} },
    emergencyContacts: { type: [mongoose.Schema.Types.Mixed], default: [] },
    actionableSms: { type: String, default: '' },
    status: { type: String, default: 'DISPATCHED', index: true }, // DISPATCHED | ACKNOWLEDGED | RESOLVED | CANCELLED
  },
  {
    timestamps: true,
  },
);

export const EmergencyModel = mongoose.models.Emergency || mongoose.model('Emergency', emergencySchema);
