import { isDatabaseConnected } from '../../../../config/database.js';
import { logger } from '../../../../config/logger.js';
import { memoryFeedbackRepository } from './memory_feedback_repository.js';
import { mongoFeedbackRepository } from './mongo_feedback_repository.js';

export class FeedbackRepository {
  constructor(mongoRepo = mongoFeedbackRepository, memoryRepo = memoryFeedbackRepository) {
    this.mongoRepo = mongoRepo;
    this.memoryRepo = memoryRepo;
  }

  async _executeWithFallback(actionName, primaryFn, fallbackFn) {
    if (isDatabaseConnected()) {
      try {
        return await primaryFn();
      } catch (err) {
        logger.warn({
          event: 'mongo_feedback_repo_failover',
          action: actionName,
          error: err.message,
        });
        return await fallbackFn();
      }
    }
    return await fallbackFn();
  }

  async save(feedbackEntry) {
    return this._executeWithFallback(
      'save',
      () => this.mongoRepo.save(feedbackEntry),
      () => this.memoryRepo.save(feedbackEntry),
    );
  }

  async findAll() {
    return this._executeWithFallback(
      'findAll',
      () => this.mongoRepo.findAll(),
      () => this.memoryRepo.findAll(),
    );
  }

  async findByUserId(userId) {
    return this._executeWithFallback(
      'findByUserId',
      () => this.mongoRepo.findByUserId(userId),
      () => this.memoryRepo.findByUserId(userId),
    );
  }

  async findByRating(rating) {
    return this._executeWithFallback(
      'findByRating',
      () => this.mongoRepo.findByRating(rating),
      () => this.memoryRepo.findByRating(rating),
    );
  }

  async findByCategory(category) {
    return this._executeWithFallback(
      'findByCategory',
      () => this.mongoRepo.findByCategory(category),
      () => this.memoryRepo.findByCategory(category),
    );
  }

  async averageRatings() {
    return this._executeWithFallback(
      'averageRatings',
      () => this.mongoRepo.averageRatings(),
      () => this.memoryRepo.averageRatings(),
    );
  }

  async getStatistics() {
    return this._executeWithFallback(
      'getStatistics',
      () => this.mongoRepo.getStatistics(),
      () => this.memoryRepo.getStatistics(),
    );
  }
}

export const feedbackRepository = new FeedbackRepository();
