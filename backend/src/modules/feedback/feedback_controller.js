import { logger } from '../../config/logger.js';

/** In-memory storage for Beta User Feedback */
export const memoryFeedbackStore = [];

/**
 * POST /api/v1/feedback
 * Collects 5-star ratings, Journey/Nearby accuracy feedback, and bug reports
 */
export const submitFeedback = async (req, res) => {
  try {
    const {
      rating = 5,
      journeyAccuracyRating = 5,
      nearbyAccuracyRating = 5,
      performanceRating = 5,
      category = 'general', // 'general' | 'bug_report' | 'feature_request'
      comments = '',
      userDeviceInfo = {},
    } = req.body || {};

    const feedbackEntry = {
      feedbackId: `fb_${Date.now()}_${Math.random().toString(36).substr(2, 4)}`,
      userId: req.user?.userId || 'anonymous_beta_tester',
      rating: Math.min(Math.max(parseInt(rating) || 5, 1), 5),
      journeyAccuracyRating: Math.min(Math.max(parseInt(journeyAccuracyRating) || 5, 1), 5),
      nearbyAccuracyRating: Math.min(Math.max(parseInt(nearbyAccuracyRating) || 5, 1), 5),
      performanceRating: Math.min(Math.max(parseInt(performanceRating) || 5, 1), 5),
      category,
      comments: comments.trim(),
      userDeviceInfo,
      timestamp: new Date().toISOString(),
    };

    memoryFeedbackStore.push(feedbackEntry);

    logger.info({
      event: 'beta_feedback_submitted',
      feedbackId: feedbackEntry.feedbackId,
      rating: feedbackEntry.rating,
      category,
    });

    return res.status(201).json({
      success: true,
      message: 'Thank you for your feedback! Your insights help improve Sarthee AI.',
      data: feedbackEntry,
    });
  } catch (err) {
    logger.error({ event: 'submit_feedback_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to record feedback.' });
  }
};

/**
 * GET /api/v1/feedback
 * Returns summary of beta feedback (Admin access)
 */
export const getFeedbackSummary = async (req, res) => {
  try {
    const total = memoryFeedbackStore.length;
    const avgRating = total > 0 ? memoryFeedbackStore.reduce((acc, f) => acc + f.rating, 0) / total : 5.0;

    return res.status(200).json({
      success: true,
      totalFeedbackEntries: total,
      averageRating: Math.round(avgRating * 10) / 10,
      feedbackList: memoryFeedbackStore,
    });
  } catch (err) {
    logger.error({ event: 'get_feedback_summary_error', error: err.message });
    return res.status(500).json({ error: 'SERVER_ERROR', message: 'Failed to fetch feedback summary.' });
  }
};
