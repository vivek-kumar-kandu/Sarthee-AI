import { TripModel } from './trip.model.js';
import { TRIP_STATES } from '../../domain/entities/trip_entity.js';

export class MongoTripRepository {
  async save(tripEntity) {
    const doc = await TripModel.findOneAndUpdate(
      { id: tripEntity.id },
      { $set: tripEntity },
      { upsert: true, new: true, lean: true },
    );
    return doc;
  }

  async findById(id) {
    return await TripModel.findOne({ id }).lean();
  }

  async findByUserId(userId) {
    return await TripModel.find({ userId, isArchived: { $ne: true } }).sort({ createdAt: -1 }).lean();
  }

  async updateState(id, newState) {
    if (!Object.values(TRIP_STATES).includes(newState)) {
      throw new Error(`Invalid trip state transition to "${newState}".`);
    }
    return await TripModel.findOneAndUpdate(
      { id },
      {
        $set: { status: newState, updatedAt: new Date().toISOString() },
        $push: { history: { state: newState, timestamp: new Date().toISOString() } },
      },
      { new: true, lean: true },
    );
  }

  async delete(id) {
    const res = await TripModel.deleteOne({ id });
    return res.deletedCount > 0;
  }

  async exists(id) {
    const count = await TripModel.countDocuments({ id });
    return count > 0;
  }

  async list(filter = {}) {
    const query = {};
    if (filter.city) query.city = new RegExp(`^${filter.city}$`, 'i');
    if (filter.persona) query.persona = new RegExp(`^${filter.persona}$`, 'i');
    if (filter.status) query.status = filter.status;
    if (typeof filter.isArchived === 'boolean') query.isArchived = filter.isArchived;

    return await TripModel.find(query).sort({ createdAt: -1 }).lean();
  }

  async archive(id) {
    return await TripModel.findOneAndUpdate(
      { id },
      {
        $set: {
          isArchived: true,
          status: TRIP_STATES.ARCHIVED,
          updatedAt: new Date().toISOString(),
        },
      },
      { new: true, lean: true },
    );
  }

  async restore(id) {
    return await TripModel.findOneAndUpdate(
      { id },
      {
        $set: {
          isArchived: false,
          status: TRIP_STATES.PLANNED,
          updatedAt: new Date().toISOString(),
        },
      },
      { new: true, lean: true },
    );
  }
}

export const mongoTripRepository = new MongoTripRepository();
