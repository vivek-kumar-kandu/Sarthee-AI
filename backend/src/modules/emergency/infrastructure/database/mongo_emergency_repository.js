import { EmergencyModel } from './emergency.model.js';

export class MongoEmergencyRepository {
  async save(sosPayload) {
    const doc = await EmergencyModel.findOneAndUpdate(
      { sosId: sosPayload.sosId },
      { $set: sosPayload },
      { upsert: true, new: true, lean: true },
    );
    return doc;
  }

  async findById(sosId) {
    return await EmergencyModel.findOne({ sosId }).lean();
  }

  async findByUserId(userId) {
    return await EmergencyModel.find({ userId }).sort({ timestamp: -1 }).lean();
  }

  async updateStatus(sosId, status) {
    return await EmergencyModel.findOneAndUpdate(
      { sosId },
      { $set: { status, updatedAt: new Date().toISOString() } },
      { new: true, lean: true },
    );
  }

  async findRecent(limit = 10) {
    return await EmergencyModel.find().sort({ timestamp: -1 }).limit(limit).lean();
  }

  async findActive() {
    return await EmergencyModel.find({ status: { $in: ['DISPATCHED', 'ACKNOWLEDGED'] } }).sort({ timestamp: -1 }).lean();
  }
}

export const mongoEmergencyRepository = new MongoEmergencyRepository();
