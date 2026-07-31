/**
 * DynamicFareEngine
 * Domain service for calculating contextual fare surge multipliers (Peak, Rain, Night)
 */
export class DynamicFareEngine {
  static DEFAULT_CONFIG = {
    peakMultiplier: 1.15,
    rainMultiplier: 1.25,
    nightMultiplier: 1.25,
    peakHours: [
      { start: 8, end: 10 },
      { start: 17, end: 20 },
    ],
    nightHours: { start: 23, end: 5 },
  };

  constructor(config = {}) {
    this.config = { ...DynamicFareEngine.DEFAULT_CONFIG, ...config };
  }

  /**
   * Calculates surge multiplier based on time of day and weather conditions
   * @param {number} hourOfDay Hour (0-23)
   * @param {boolean} isRain Whether rain condition is active
   * @returns {number} Combined fare surge multiplier
   */
  calculateSurgeMultiplier(hourOfDay = new Date().getHours(), isRain = false) {
    let multiplier = 1.0;

    // Check Peak Hours
    const isPeak = this.config.peakHours.some(
      (slot) => hourOfDay >= slot.start && hourOfDay <= slot.end
    );
    if (isSelectedOrTrue(isPeak)) {
      multiplier *= this.config.peakMultiplier;
    }

    // Check Night Hours
    const isNight = hourOfDay >= this.config.nightHours.start || hourOfDay < this.config.nightHours.end;
    if (isSelectedOrTrue(isNight)) {
      multiplier *= this.config.nightMultiplier;
    }

    // Check Rain Condition
    if (isSelectedOrTrue(isRain)) {
      multiplier *= this.config.rainMultiplier;
    }

    return parseFloat(multiplier.toFixed(2));
  }

  /**
   * Applies surge multiplier to base fare amount
   * @param {number} baseFare Base unadjusted fare amount
   * @param {number} hourOfDay Hour (0-23)
   * @param {boolean} isRain Whether rain condition is active
   * @returns {number} Final rounded surge-adjusted fare
   */
  calculateFinalFare(baseFare, hourOfDay, isRain) {
    const surge = this.calculateSurgeMultiplier(hourOfDay, isRain);
    return Math.round(baseFare * surge);
  }
}

function isSelectedOrTrue(val) {
  return val === true;
}

