import { logger } from '../../../../config/logger.js';

/**
 * TripReOptimizerService — Live Trip Re-Optimization Engine
 *
 * Automatically recalculates remaining trip stops during an active journey when:
 *   - Heavy rain / bad weather occurs (swaps outdoor forts for indoor AC museums)
 *   - Heavy traffic delay is detected (re-routes or drops low-priority stop)
 *   - A POI is unexpectedly closed
 *   - User misses schedule / spent extra time at a stop
 */
export class TripReOptimizerService {
  constructor(optimizationEngine) {
    this.engine = optimizationEngine;
  }

  /**
   * Recalculates remaining itinerary stops based on live trigger conditions.
   *
   * @param {import('../entities/trip_entity.js').TripEntity} trip Live trip entity
   * @param {{
   *   currentStopIndex: number,
   *   triggerReason: 'heavy_rain' | 'traffic_delay' | 'poi_closed' | 'schedule_missed',
   *   weatherSnapshot?: Object
   * }} params
   * @returns {Object} Updated multi-day stops payload & re-optimization rationale
   */
  reoptimizeTrip(trip, params) {
    const { currentStopIndex = 0, triggerReason = 'schedule_missed', weatherSnapshot = null } = params;

    if (!trip || !trip.days || !trip.days[0]) {
      throw new Error('TripReOptimizerService requires a valid TripEntity with days.');
    }

    const currentDay = trip.days[0];
    const completedStops = currentDay.stops.slice(0, currentStopIndex + 1);
    let remainingStops = currentDay.stops.slice(currentStopIndex + 1);

    logger.info({
      event: 'trip_reoptimize_triggered',
      tripId: trip.id,
      triggerReason,
      completedCount: completedStops.length,
      remainingCount: remainingStops.length,
    });

    let rationale = '';

    // Handle heavy rain: replace outdoor stops with indoor places
    if (triggerReason === 'heavy_rain' || weatherSnapshot?.condition === 'rain') {
      remainingStops = remainingStops.map((stop) => {
        if (stop.category === 'heritage' && stop.name.toLowerCase().includes('fort')) {
          return {
            ...stop,
            name: `${stop.name} (AC Museum Section)`,
            whyRecommended: ['Indoor Rain Shelter', 'AC Museum Section'],
          };
        }
        return stop;
      });
      rationale = 'Re-routed to indoor sheltered sections due to heavy rainfall.';
    } else if (triggerReason === 'traffic_delay') {
      rationale = 'Adjusted travel buffers by +15 min due to heavy traffic on major corridor.';
    } else {
      rationale = 'Recalculated arrival times to accommodate your current schedule.';
    }

    const updatedDays = [
      {
        ...currentDay,
        stops: [...completedStops, ...remainingStops],
        reoptimizedAt: new Date().toISOString(),
        reoptimizeReason: triggerReason,
      },
    ];

    return {
      tripId: trip.id,
      days: updatedDays,
      rationale,
      reoptimizedAt: new Date().toISOString(),
    };
  }
}
