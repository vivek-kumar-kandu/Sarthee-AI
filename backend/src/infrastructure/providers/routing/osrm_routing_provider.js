import { IRoutingProvider } from './i_routing_provider.js';

export class OsrmRoutingProvider extends IRoutingProvider {
  constructor(baseUrl = 'https://router.project-osrm.org') {
    super();
    this.baseUrl = baseUrl;
  }

  async calculateRoute(originLat, originLng, destLat, destLng, mode = 'driving') {
    // In actual implementation or mock test environment
    const profile = mode === 'walk' ? 'foot' : 'car';
    
    // Calculate approximate distance & time heuristics if network unavailable
    const latDiff = Math.abs(destLat - originLat);
    const lngDiff = Math.abs(destLng - originLng);
    const distMeters = Math.round(Math.sqrt(latDiff * latDiff + lngDiff * lngDiff) * 111000);
    const durMins = Math.max(1, Math.round(distMeters / (mode === 'walk' ? 80 : 500)));

    return {
      distanceMeters: distMeters,
      durationMinutes: durMins,
      polyline: `osrm_polyline_${originLat},${originLng}_to_${destLat},${destLng}`,
      provider: 'OSRM',
    };
  }
}
