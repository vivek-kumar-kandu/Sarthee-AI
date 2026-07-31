/**
 * Immutable JourneyContext Value Object
 * Single source of truth containing normalized journey metrics
 */
export class JourneyContext {
  constructor({
    originName,
    originLat,
    originLng,
    destinationName,
    destinationLat,
    destinationLng,
    preferredMode,
    plans = {},
    weather = null,
    transit = null,
    traffic = null,
    incidents = [],
    originLandmark = null,
    destLandmark = null,
    providerMetadata = {},
  }) {
    this.originName = originName;
    this.originLat = originLat;
    this.originLng = originLng;
    this.destinationName = destinationName;
    this.destinationLat = destinationLat;
    this.destinationLng = destinationLng;
    this.preferredMode = preferredMode || 'balanced';
    this.plans = Object.freeze({ ...plans });
    this.weather = weather ? Object.freeze({ ...weather }) : null;
    this.transit = transit ? Object.freeze({ ...transit }) : null;
    this.traffic = traffic ? Object.freeze({ ...traffic }) : null;
    this.incidents = Object.freeze([...incidents]);
    this.originLandmark = originLandmark ? Object.freeze({ ...originLandmark }) : null;
    this.destLandmark = destLandmark ? Object.freeze({ ...destLandmark }) : null;
    this.providerMetadata = Object.freeze({ ...providerMetadata });
    this.timestamp = new Date().toISOString();

    // Freeze object to enforce immutability
    Object.freeze(this);
  }

  /**
   * Helper to extract primary plan based on preferred mode
   */
  getPrimaryPlan() {
    return this.plans[this.preferredMode] || this.plans['balanced'] || Object.values(this.plans)[0] || null;
  }
}

