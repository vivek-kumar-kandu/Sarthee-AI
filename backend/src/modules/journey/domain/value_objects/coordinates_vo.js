/**
 * Coordinates Value Object with coordinate validation
 */
export class CoordinatesVO {
  constructor(latitude, longitude) {
    if (typeof latitude !== 'number' || latitude < -90 || latitude > 90) {
      throw new Error(`Invalid latitude: ${latitude}. Must be between -90 and 90.`);
    }
    if (typeof longitude !== 'number' || longitude < -180 || longitude > 180) {
      throw new Error(`Invalid longitude: ${longitude}. Must be between -180 and 180.`);
    }
    this.latitude = latitude;
    this.longitude = longitude;
  }
}
