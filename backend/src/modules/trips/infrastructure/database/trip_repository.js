import { isDatabaseConnected } from '../../../../config/database.js';
import { logger } from '../../../../config/logger.js';
import { memoryTripRepository } from './memory_trip_repository.js';
import { mongoTripRepository } from './mongo_trip_repository.js';

export class TripRepository {
  constructor(mongoRepo = mongoTripRepository, memoryRepo = memoryTripRepository) {
    this.mongoRepo = mongoRepo;
    this.memoryRepo = memoryRepo;
  }

  _selectRepo() {
    return isDatabaseConnected() ? this.mongoRepo : this.memoryRepo;
  }

  async _executeWithFallback(actionName, primaryFn, fallbackFn) {
    if (isDatabaseConnected()) {
      try {
        return await primaryFn();
      } catch (err) {
        logger.warn({
          event: 'mongo_trip_repo_failover',
          action: actionName,
          error: err.message,
        });
        return await fallbackFn();
      }
    }
    return await fallbackFn();
  }

  async save(tripEntity) {
    return this._executeWithFallback(
      'save',
      () => this.mongoRepo.save(tripEntity),
      () => this.memoryRepo.save(tripEntity),
    );
  }

  async findById(id) {
    return this._executeWithFallback(
      'findById',
      () => this.mongoRepo.findById(id),
      () => this.memoryRepo.findById(id),
    );
  }

  async findByUserId(userId) {
    return this._executeWithFallback(
      'findByUserId',
      () => this.mongoRepo.findByUserId(userId),
      () => this.memoryRepo.findByUserId(userId),
    );
  }

  async updateState(id, newState) {
    return this._executeWithFallback(
      'updateState',
      () => this.mongoRepo.updateState(id, newState),
      () => this.memoryRepo.updateState(id, newState),
    );
  }

  async delete(id) {
    return this._executeWithFallback(
      'delete',
      () => this.mongoRepo.delete(id),
      () => this.memoryRepo.delete(id),
    );
  }

  async exists(id) {
    return this._executeWithFallback(
      'exists',
      () => this.mongoRepo.exists(id),
      () => this.memoryRepo.exists(id),
    );
  }

  async list(filter = {}) {
    return this._executeWithFallback(
      'list',
      () => this.mongoRepo.list(filter),
      () => this.memoryRepo.list(filter),
    );
  }

  async archive(id) {
    return this._executeWithFallback(
      'archive',
      () => this.mongoRepo.archive(id),
      () => this.memoryRepo.archive(id),
    );
  }

  async restore(id) {
    return this._executeWithFallback(
      'restore',
      () => this.mongoRepo.restore(id),
      () => this.memoryRepo.restore(id),
    );
  }
}

export const tripRepository = new TripRepository();
