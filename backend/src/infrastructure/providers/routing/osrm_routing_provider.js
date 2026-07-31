import { IRoutingProvider } from './i_routing_provider.js';

export class OsrmRoutingProvider extends IRoutingProvider {
  constructor(baseUrl = 'https://router.project-osrm.org') {
    super();
    this.baseUrl = baseUrl;
  }

  async calculateRoute(originLat, originLng, destLat, destLng, mode = 'driving') {
    const profile = mode === 'walk' ? 'foot' : 'driving';
    // OSRM coordinates format: {longitude},{latitude}
    const url = `${this.baseUrl}/route/v1/${profile}/${originLng},${originLat};${destLng},${destLat}?overview=full&geometries=polyline`;

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 5000); // 5.0s timeout guardrail

      const response = await fetch(url, {
        signal: controller.signal,
        headers: { 'Accept': 'application/json' },
      });
      clearTimeout(timeoutId);

      if (response.ok) {
        const data = await response.json();
        if (data.code === 'Ok' && Array.isArray(data.routes) && data.routes.length > 0) {
          const mainRoute = data.routes[0];
          const distMeters = Math.round(mainRoute.distance || 0);
          const durMins = Math.max(1, Math.round((mainRoute.duration || 0) / 60));
          const polyline = mainRoute.geometry || `osrm_polyline_${originLat},${originLng}_to_${destLat},${destLng}`;

          return {
            distanceMeters: distMeters,
            durationMinutes: durMins,
            polyline,
            provider: 'OSRM (Live Public Server)',
          };
        }
      }
    } catch (error) {
      // Fall back to offline Euclidean distance heuristic if network/timeout occurs
    }

    // Heuristic Fallback
    const latDiff = Math.abs(destLat - originLat);
    const lngDiff = Math.abs(destLng - originLng);
    const distMeters = Math.round(Math.sqrt(latDiff * latDiff + lngDiff * lngDiff) * 111000);
    const durMins = Math.max(1, Math.round(distMeters / (mode === 'walk' ? 80 : 500)));

    return {
      distanceMeters: distMeters,
      durationMinutes: durMins,
      polyline: `osrm_polyline_${originLat},${originLng}_to_${destLat},${destLng}`,
      provider: 'OSRM (Heuristic Fallback)',
    };
  }
}
