export class MemoryFeedbackRepository {
  constructor() {
    this.store = new Map();
  }

  async save(feedbackEntry) {
    if (!feedbackEntry || !feedbackEntry.feedbackId) {
      throw new Error('MemoryFeedbackRepository.save requires valid feedbackEntry with feedbackId.');
    }
    this.store.set(feedbackEntry.feedbackId, { ...feedbackEntry });
    return this.store.get(feedbackEntry.feedbackId);
  }

  async findAll() {
    return Array.from(this.store.values());
  }

  async findByUserId(userId) {
    const list = [];
    for (const item of this.store.values()) {
      if (item.userId === userId) {
        list.push(item);
      }
    }
    return list;
  }

  async findByRating(rating) {
    const list = [];
    for (const item of this.store.values()) {
      if (item.rating === rating) {
        list.push(item);
      }
    }
    return list;
  }

  async findByCategory(category) {
    const list = [];
    for (const item of this.store.values()) {
      if (item.category.toLowerCase() === category.toLowerCase()) {
        list.push(item);
      }
    }
    return list;
  }

  async averageRatings() {
    const list = Array.from(this.store.values());
    if (list.length === 0) {
      return { overall: 5.0, journeyAccuracy: 5.0, nearbyAccuracy: 5.0, performance: 5.0 };
    }
    const sumOverall = list.reduce((acc, f) => acc + (f.rating || 5), 0);
    const sumJourney = list.reduce((acc, f) => acc + (f.journeyAccuracyRating || 5), 0);
    const sumNearby = list.reduce((acc, f) => acc + (f.nearbyAccuracyRating || 5), 0);
    const sumPerf = list.reduce((acc, f) => acc + (f.performanceRating || 5), 0);

    return {
      overall: Math.round((sumOverall / list.length) * 10) / 10,
      journeyAccuracy: Math.round((sumJourney / list.length) * 10) / 10,
      nearbyAccuracy: Math.round((sumNearby / list.length) * 10) / 10,
      performance: Math.round((sumPerf / list.length) * 10) / 10,
    };
  }

  async getStatistics() {
    const list = Array.from(this.store.values());
    const averages = await this.averageRatings();
    const categoryCounts = {};
    const ratingDistribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };

    for (const item of list) {
      const cat = item.category || 'general';
      categoryCounts[cat] = (categoryCounts[cat] || 0) + 1;

      const r = Math.min(Math.max(item.rating || 5, 1), 5);
      ratingDistribution[r] = (ratingDistribution[r] || 0) + 1;
    }

    return {
      totalEntries: list.length,
      averages,
      categoryCounts,
      ratingDistribution,
    };
  }
}

export const memoryFeedbackRepository = new MemoryFeedbackRepository();
