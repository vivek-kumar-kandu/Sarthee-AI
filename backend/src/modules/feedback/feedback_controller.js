import { logger } from '../../config/logger.js';
import { feedbackRepository } from './infrastructure/database/feedback_repository.js';
import { memoryFeedbackRepository } from './infrastructure/database/memory_feedback_repository.js';
import { ResponseBuilder } from '../../common/responses/response_builder.js';
import { DataProvenance, CONFIDENCE_TIERS } from '../../infrastructure/providers/data_provenance.js';

/** In-memory storage export for backward compatibility */
export const memoryFeedbackStore = memoryFeedbackRepository.store;

/**
 * POST /api/v1/feedback
 * Collects 5-star ratings, Journey/Nearby accuracy feedback, and bug reports
 */
export const submitFeedback = async (req, res) => {
  const startTime = Date.now();
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

    await feedbackRepository.save(feedbackEntry);

    logger.info({
      event: 'beta_feedback_submitted',
      feedbackId: feedbackEntry.feedbackId,
      rating: feedbackEntry.rating,
      category,
    });

    const provenance = DataProvenance.live('Beta Feedback API', {
      confidence: CONFIDENCE_TIERS.LIVE_PROCESSED,
      latencyMs: Date.now() - startTime,
    });

    return ResponseBuilder.success(res, {
      data: feedbackEntry,
      provenance,
      message: 'Thank you for your feedback! Your insights help improve Sarthee AI.',
      statusCode: 201,
      requestId: req.id,
      traceId: req.traceId,
    });
  } catch (err) {
    logger.error({ event: 'submit_feedback_error', error: err.message });
    return ResponseBuilder.error(res, { code: 'SERVER_ERROR', message: 'Failed to record feedback.', statusCode: 500 });
  }
};

/**
 * GET /api/v1/feedback
 * Returns summary of beta feedback (Admin access)
 */
export const getFeedbackSummary = async (req, res) => {
  const startTime = Date.now();
  try {
    const feedbackList = await feedbackRepository.findAll();
    const stats = await feedbackRepository.getStatistics();

    const provenance = DataProvenance.live('Feedback Analytics Engine', {
      confidence: CONFIDENCE_TIERS.LIVE_PROCESSED,
      latencyMs: Date.now() - startTime,
    });

    return ResponseBuilder.success(res, {
      data: {
        totalFeedbackEntries: stats.totalEntries,
        averageRating: stats.averages.overall,
        averages: stats.averages,
        categoryCounts: stats.categoryCounts,
        ratingDistribution: stats.ratingDistribution,
        feedbackList,
      },
      provenance,
      statusCode: 200,
      requestId: req.id,
      traceId: req.traceId,
    });
  } catch (err) {
    logger.error({ event: 'get_feedback_summary_error', error: err.message });
    return ResponseBuilder.error(res, { code: 'SERVER_ERROR', message: 'Failed to fetch feedback summary.', statusCode: 500 });
  }
};
