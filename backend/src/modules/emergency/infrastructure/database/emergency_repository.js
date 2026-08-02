import { isDatabaseConnected } from '../../../../config/database.js';
import { logger } from '../../../../config/logger.js';
import { memoryEmergencyRepository } from './memory_emergency_repository.js';
import { mongoEmergencyRepository } from './mongo_emergency_repository.js';

export class EmergencyRepository {
  constructor(mongoRepo = mongoEmergencyRepository, memoryRepo = memoryEmergencyRepository) {
    this.mongoRepo = mongoRepo;
    this.memoryRepo = memoryRepo;
  }

  async _executeWithFallback(actionName, primaryFn, fallbackFn) {
    if (isDatabaseConnected()) {
      try {
        return await primaryFn();
      } catch (err) {
        logger.warn({
          event: 'mongo_emergency_repo_failover',
          action: actionName,
          error: err.message,
        });
        return await fallbackFn();
      }
    }
    return await fallbackFn();
  }

  async save(sosPayload) {
    return this._executeWithFallback(
      'save',
      () => this.mongoRepo.save(sosPayload),
      () => this.memoryRepo.save(sosPayload),
    );
  }

  async findById(sosId) {
    return this._executeWithFallback(
      'findById',
      () => this.mongoRepo.findById(sosId),
      () => this.memoryRepo.findById(sosId),
    );
  }

  async findByUserId(userId) {
    return this._executeWithFallback(
      'findByUserId',
      () => this.mongoRepo.findByUserId(userId),
      () => this.memoryRepo.findByUserId(userId),
    );
  }

  async updateStatus(sosId, status) {
    return this._executeWithFallback(
      'updateStatus',
      () => this.mongoRepo.updateStatus(sosId, status),
      () => this.memoryRepo.updateStatus(sosId, status),
    );
  }

  async findRecent(limit = 10) {
    return this._executeWithFallback(
      'findRecent',
      () => this.mongoRepo.findRecent(limit),
      () => this.memoryRepo.findRecent(limit),
    );
  }

  async findActive() {
    return this._executeWithFallback(
      'findActive',
      () => this.mongoRepo.findActive(),
      () => this.memoryRepo.findActive(),
    );
  }
}

export const emergencyRepository = new EmergencyRepository();
