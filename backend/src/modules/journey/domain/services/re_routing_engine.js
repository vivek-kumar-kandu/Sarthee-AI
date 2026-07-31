/**
 * ReRoutingEngine
 * Domain service for detecting GPS location deviation and triggering route recalculation
 */
export class ReRoutingEngine {
  /**
   * Checks if user's current GPS location has strayed beyond deviation threshold
   * @param {number} currentLat User GPS Latitude
   * @param {number} currentLng User GPS Longitude
   * @param {number} expectedLat Target Route Step Latitude
   * @param {number} expectedLng Target Route Step Longitude
   * @param {number} maxThresholdMeters Allowed deviation in meters (default: 200m)
   * @returns {Object} Deviation check result ({ isDeviated, distanceMeters })
   */
  static checkDeviation(currentLat, currentLng, expectedLat, expectedLng, maxThresholdMeters = 200) {
    const distMeters = ReRoutingEngine.calculateHaversineDistance(
      currentLat,
      currentLng,
      expectedLat,
      expectedLng
    );

    const isDeviated = distMeters > maxThresholdMeters;

    return {
      isDeviated,
      distanceMeters: Math.round(distMeters),
      maxThresholdMeters,
      action: isDeviated ? 'recalculate_journey' : 'continue_on_route',
    };
  }

  static calculateHaversineDistance(lat1, lon1, lat2, lon2) {
    const R = 6371e3; // Earth radius in meters
    const rad = Math.PI / 180;
    const dLat = (lat2 - lat1) * rad;
    const dLon = (lon2 - lon1) * rad;

    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(lat1 * rad) * Math.cos(lat2 * rad) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
  }
}

