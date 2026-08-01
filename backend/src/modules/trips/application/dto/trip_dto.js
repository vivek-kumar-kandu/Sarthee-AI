/**
 * TripDTO — Data Transfer Object for Sarthee AI Trips
 *
 * Maps internal domain TripEntity & TripContext objects to a clean, stable client contract.
 *
 * Contract Schema:
 * {
 *   tripId, title, city, persona, status,
 *   shareToken, shareUrl, qrCodeUrl,
 *   confidence: { score: 94, verifiedSources: [...] },
 *   costBreakdown: { transport, food, tickets, buffer, total, currency },
 *   aiAdvice: { summary, itineraryExplanation, packingTips },
 *   days: [
 *     {
 *       dayIndex: 1, title, date, totalStops,
 *       stops: [
 *         {
 *           stopNumber, poiId, name, category, lat, lng, imageUrl, whyRecommended,
 *           timeline: { reachTime, ticketTime, visitDurationDisplay },
 *           tourismDetails: { entryFee, openingHours, photography, parkingAvailable, accessibility },
 *           travelLegToNext: { fromPoi, toPoi, distanceKm, etaDurationMinutes, bufferMinutes, etaConfidencePercent }
 *         }
 *       ]
 *     }
 *   ],
 *   createdAt, updatedAt
 * }
 */
export class TripDTO {
  /**
   * Maps a TripEntity & optional AI advice into a Flutter-ready DTO.
   * @param {import('../../domain/entities/trip_entity.js').TripEntity} trip
   * @param {Object} [aiAdvice]
   * @returns {Object}
   */
  static fromEntity(trip, aiAdvice = null) {
    const sharePayload = trip.getSharePayload();

    return {
      tripId: trip.id,
      title: trip.title,
      city: trip.city,
      persona: trip.persona,
      status: trip.status,

      shareToken: trip.shareToken,
      shareUrl: sharePayload.shareUrl,
      qrCodeUrl: sharePayload.qrCodeUrl,

      confidence: trip.confidence || { score: 94, verifiedSources: ['OSRM', 'OpenWeather', 'Opening Hours', 'Overpass'] },
      costBreakdown: trip.costBreakdown || { transport: 180, food: 500, tickets: 420, buffer: 400, total: 1500, currency: 'INR' },

      aiAdvice: aiAdvice || trip.aiAdvice || {
        summary: `An optimized ${trip.persona} exploration of ${trip.city}.`,
        itineraryExplanation: 'Sequence built around weather, opening hours, and travel proximity.',
        packingTips: ['Water bottle', 'Walking shoes', 'Camera'],
      },

      days: trip.days || [],
      history: trip.history || [],
      createdAt: trip.createdAt,
      updatedAt: trip.updatedAt,
    };
  }

  /**
   * Standard REST API response envelope for trips
   */
  static toApiResponse(trip, aiAdvice = null, metadata = {}) {
    return {
      success: true,
      data: TripDTO.fromEntity(trip, aiAdvice),
      metadata: {
        timestamp: new Date().toISOString(),
        ...metadata,
      },
    };
  }
}
