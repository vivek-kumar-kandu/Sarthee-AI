/**
 * NearbyDTO — Data Transfer Object
 *
 * Maps internal ranked POI objects to a stable Flutter contract.
 * Provider-specific internal fields are never exposed to the client.
 *
 * Contract (guaranteed stable across provider changes):
 * {
 *   id, name, category, subcategory,
 *   lat, lng, distanceKm, distanceDisplay,
 *   score, confidence, reasons,
 *   imageUrl, imageSource,
 *   aiAdvice: { summary, whyRecommended, bestTime, estimatedVisit, weatherAdvice, familyFriendly, accessibility, confidence },
 *   tags: { isIndoor, isOpen24h, phone, website, cuisine, stars, ... },
 *   navigateTo: { lat, lng, name, category }
 * }
 */
export class NearbyDTO {
  /**
   * Maps a single ranked POI to a Flutter-safe DTO.
   * @param {Object} poi Scored & image-resolved POI from NearbyOrchestrator
   * @returns {Object} DTO safe for JSON serialization
   */
  static fromPoi(poi) {
    return {
      id: poi.id || `poi_${poi.lat}_${poi.lng}`,
      name: poi.name,
      category: poi.category,
      subcategory: poi.subcategory || poi.category,

      // Location
      lat: poi.lat,
      lng: poi.lng,
      distanceKm: poi.distanceKm,
      distanceDisplay: poi.distanceKm < 1
        ? `${Math.round(poi.distanceKm * 1000)} m`
        : `${poi.distanceKm} km`,

      // Image Intelligence (3B.2)
      imageUrl: poi.imageUrl || 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=800&q=80',
      imageSource: poi.imageSource || 'fallback',

      // Ranking signals (Flutter renders, not computes)
      score: poi.score,
      confidence: poi.confidence,
      reasons: Array.isArray(poi.reasons) ? poi.reasons : [],

      // AI Advisor Intelligence (3B.3)
      aiAdvice: poi.aiAdvice ? {
        summary: poi.aiAdvice.summary,
        whyRecommended: poi.aiAdvice.whyRecommended,
        bestTime: poi.aiAdvice.bestTime,
        estimatedVisit: poi.aiAdvice.estimatedVisit,
        weatherAdvice: poi.aiAdvice.weatherAdvice,
        familyFriendly: poi.aiAdvice.familyFriendly,
        accessibility: poi.aiAdvice.accessibility,
        confidence: poi.aiAdvice.confidence,
      } : null,

      // Formatted metadata for UI display
      tags: {
        isIndoor: poi.isIndoor || false,
        isOpen24h: poi.isOpen24h || false,
        phone: poi.phone || poi.tags?.phone || null,
        website: poi.website || poi.tags?.website || null,
        cuisine: poi.cuisine || poi.tags?.cuisine || null,
        stars: poi.stars || null,
        estimatedVisitHours: poi.estimatedVisitHours || null,
        urgencyLevel: poi.urgencyLevel || null,
        openHours: poi.tags?.opening_hours || null,
      },

      // Pre-populated navigation payload — tapping "Navigate Here"
      // populates JourneyPlanner with these coordinates.
      navigateTo: {
        lat: poi.lat,
        lng: poi.lng,
        name: poi.name,
        category: poi.category,
        subcategory: poi.subcategory || poi.category,
      },
    };
  }

  /**
   * Maps a full ranked POI list and wraps in a standard API envelope.
   * @param {Object[]} rankedPois
   * @param {import('../../domain/value_objects/nearby_context.js').NearbyContext} context
   * @param {Object} [searchIntent] Parsed search query intent
   * @returns {Object} Full API response envelope
   */
  static toApiResponse(rankedPois, context, searchIntent = null) {
    return {
      requestId: context.requestId,
      category: context.category,
      userLocation: context.userLocation,
      radius: context.radius,
      timestamp: context.timestamp,
      searchIntent,
      results: rankedPois.map(NearbyDTO.fromPoi),
      metadata: {
        total: rankedPois.length,
        providersUsed: context.providersUsed,
        elapsedMs: context.metadata?.elapsedMs,
        cacheHit: context.metadata?.cacheHit || false,
      },
    };
  }
}
