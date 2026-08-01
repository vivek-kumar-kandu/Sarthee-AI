import { logger } from '../../config/logger.js';

/**
 * DataValidator — Production External Data Validator
 *
 * Validates external provider payloads before serving to users.
 * Rejects corrupted or invalid data to prevent bad external inputs from reaching users.
 */
export class DataValidator {
  /**
   * Validates OSRM Route matrix result
   */
  static validateOsrmRoute(route) {
    if (!route || typeof route !== 'object') return false;
    if (typeof route.distanceKm !== 'number' || route.distanceKm <= 0) return false;
    if (typeof route.durationMinutes !== 'number' || route.durationMinutes <= 0) return false;
    return true;
  }

  /**
   * Validates Weather payload
   */
  static validateWeather(weather) {
    if (!weather || typeof weather !== 'object') return false;
    if (typeof weather.temperature !== 'number' || weather.temperature < -50 || weather.temperature > 60) return false;
    if (!weather.condition || typeof weather.condition !== 'string') return false;
    return true;
  }

  /**
   * Validates Air Quality Index payload
   */
  static validateAirQuality(aqi) {
    if (!aqi || typeof aqi !== 'object') return false;
    if (typeof aqi.aqiValue !== 'number' || aqi.aqiValue < 0 || aqi.aqiValue > 500) return false;
    return true;
  }

  /**
   * Validates Geographic Coordinates
   */
  static validateCoordinates(lat, lng) {
    if (typeof lat !== 'number' || isNaN(lat) || lat < -90 || lat > 90) return false;
    if (typeof lng !== 'number' || isNaN(lng) || lng < -180 || lng > 180) return false;
    return true;
  }
}
