import { CoordinatesVO } from '../value_objects/coordinates_vo.js';
import { FareSummaryVO } from '../value_objects/fare_summary_vo.js';

export class MultiModalGraphSearchService {
  /**
   * Generates keyed Journey Plans connecting Origin and Destination
   */
  generateKeyedPlans(originName, originLat, originLng, destName, destLat, destLng, fareRules = {}) {
    const origin = new CoordinatesVO(originLat, originLng);
    const dest = new CoordinatesVO(destLat, destLng);

    const latDiff = Math.abs(dest.latitude - origin.latitude);
    const lngDiff = Math.abs(dest.longitude - origin.longitude);
    const estDistanceMeters = Math.round(Math.sqrt(latDiff * latDiff + lngDiff * lngDiff) * 111000);

    const commonSteps = [
      { stepIndex: 1, type: 'walk', title: 'Walk to Transit Station', distanceMeters: 350, durationMinutes: 5, estimatedFare: 0 },
      { stepIndex: 2, type: 'metro', title: 'Metro Transit Line', distanceMeters: estDistanceMeters, durationMinutes: 42, estimatedFare: 50 },
      { stepIndex: 3, type: 'walk', title: 'Walk to Destination', distanceMeters: 250, durationMinutes: 4, estimatedFare: 0 },
    ];

    const standardFare = new FareSummaryVO(50.0, 'INR', [
      { legTitle: 'Metro Transit Ticket', amount: 50.0, paymentMethod: 'Smart Card', confidence: 'verified' }
    ], true);

    return {
      recommended: { id: 'plan_rec_01', mode: 'recommended', originName, destinationName: destName, totalDurationMinutes: 51, totalCost: 50.0, compositeSafetyScore: 90, steps: commonSteps, fareSummary: standardFare },
      balanced: { id: 'plan_bal_01', mode: 'balanced', originName, destinationName: destName, totalDurationMinutes: 51, totalCost: 50.0, compositeSafetyScore: 88, steps: commonSteps, fareSummary: standardFare },
      fastest: { id: 'plan_fast_01', mode: 'fastest', originName, destinationName: destName, totalDurationMinutes: 42, totalCost: 350.0, compositeSafetyScore: 85, steps: [{ stepIndex: 1, type: 'cab', title: 'Direct Taxi', distanceMeters: estDistanceMeters, durationMinutes: 42, estimatedFare: 350 }], fareSummary: new FareSummaryVO(350.0, 'INR', [{ legTitle: 'Direct Taxi', amount: 350.0, paymentMethod: 'App Pay', confidence: 'estimated' }]) },
      cheapest: { id: 'plan_cheap_01', mode: 'cheapest', originName, destinationName: destName, totalDurationMinutes: 68, totalCost: 35.0, compositeSafetyScore: 82, steps: commonSteps, fareSummary: new FareSummaryVO(35.0, 'INR', [{ legTitle: 'Bus + Metro', amount: 35.0, paymentMethod: 'Cash', confidence: 'verified' }]) },
      safest: { id: 'plan_safe_01', mode: 'safest', originName, destinationName: destName, totalDurationMinutes: 55, totalCost: 65.0, compositeSafetyScore: 96, steps: commonSteps, fareSummary: standardFare },
      accessible: { id: 'plan_acc_01', mode: 'accessible', originName, destinationName: destName, totalDurationMinutes: 53, totalCost: 50.0, compositeSafetyScore: 92, steps: commonSteps, fareSummary: standardFare },
      eco: { id: 'plan_eco_01', mode: 'eco', originName, destinationName: destName, totalDurationMinutes: 51, totalCost: 50.0, compositeSafetyScore: 90, steps: commonSteps, fareSummary: standardFare },
      comfort: { id: 'plan_com_01', mode: 'comfort', originName, destinationName: destName, totalDurationMinutes: 48, totalCost: 110.0, compositeSafetyScore: 94, steps: commonSteps, fareSummary: new FareSummaryVO(110.0, 'INR', [{ legTitle: 'Auto + Metro', amount: 110.0, paymentMethod: 'UPI', confidence: 'verified' }]) },
    };
  }
}
