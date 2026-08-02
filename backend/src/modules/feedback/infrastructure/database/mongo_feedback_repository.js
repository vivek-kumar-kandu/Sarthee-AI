import { FeedbackModel } from './feedback.model.js';

export class MongoFeedbackRepository {
  async save(feedbackEntry) {
    const doc = await FeedbackModel.findOneAndUpdate(
      { feedbackId: feedbackEntry.feedbackId },
      { $set: feedbackEntry },
      { upsert: true, new: true, lean: true },
    );
    return doc;
  }

  async findAll() {
    return await FeedbackModel.find().sort({ timestamp: -1 }).lean();
  }

  async findByUserId(userId) {
    return await FeedbackModel.find({ userId }).sort({ timestamp: -1 }).lean();
  }

  async findByRating(rating) {
    return await FeedbackModel.find({ rating }).sort({ timestamp: -1 }).lean();
  }

  async findByCategory(category) {
    return await FeedbackModel.find({ category: new RegExp(`^${category}$`, 'i') }).sort({ timestamp: -1 }).lean();
  }

  async averageRatings() {
    const agg = await FeedbackModel.aggregate([
      {
        $group: {
          _id: null,
          overall: { $avg: '$rating' },
          journeyAccuracy: { $avg: '$journeyAccuracyRating' },
          nearbyAccuracy: { $avg: '$nearbyAccuracyRating' },
          performance: { $avg: '$performanceRating' },
        },
      },
    ]);

    if (!agg || agg.length === 0) {
      return { overall: 5.0, journeyAccuracy: 5.0, nearbyAccuracy: 5.0, performance: 5.0 };
    }

    const res = agg[0];
    return {
      overall: Math.round((res.overall || 5.0) * 10) / 10,
      journeyAccuracy: Math.round((res.journeyAccuracy || 5.0) * 10) / 10,
      nearbyAccuracy: Math.round((res.nearbyAccuracy || 5.0) * 10) / 10,
      performance: Math.round((res.performance || 5.0) * 10) / 10,
    };
  }

  async getStatistics() {
    const list = await this.findAll();
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

export const mongoFeedbackRepository = new MongoFeedbackRepository();
