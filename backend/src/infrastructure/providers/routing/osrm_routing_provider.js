import { IRoutingProvider } from './i_routing_provider.js';

export class OsrmRoutingProvider extends IRoutingProvider {
  constructor(baseUrl = 'https://router.project-osrm.org') {
    super();
    this.baseUrl = baseUrl;
  }

  async calculateRoute(originLat, originLng, destLat, destLng, mode = 'driving') {
    const profile = mode === 'walk' ? 'foot' : 'driving';
    // OSRM coordinates format: {longitude},{latitude}
    const url = `${this.baseUrl}/route/v1/${profile}/${originLng},${originLat};${destLng},${destLat}?overview=full&geometries=geojson`;

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 6000); // 6.0s timeout guardrail

      const response = await fetch(url, {
        signal: controller.signal,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Sarthee-AI-App/1.0',
        },
      });
      clearTimeout(timeoutId);

      if (response.ok) {
        const data = await response.json();
        if (data.code === 'Ok' && Array.isArray(data.routes) && data.routes.length > 0) {
          const mainRoute = data.routes[0];
          const distMeters = Math.round(mainRoute.distance || 0);
          const durMins = Math.max(1, Math.round((mainRoute.duration || 0) / 60));

          let routeCoordinates = [];
          if (mainRoute.geometry && Array.isArray(mainRoute.geometry.coordinates)) {
            // Convert OSRM [lng, lat] GeoJSON coordinates to [lat, lng]
            routeCoordinates = mainRoute.geometry.coordinates.map(([lng, lat]) => [lat, lng]);
          }

          return {
            distanceMeters: distMeters,
            durationMinutes: durMins,
            polyline: `geojson:${JSON.stringify(routeCoordinates)}`,
            routeCoordinates,
            provider: 'OSRM (Live Public Server)',
          };
        }
      }
    } catch (_) {
      // Fall back to interpolated road heuristic if network/timeout occurs
    }

    // Heuristic Fallback with smooth 10-point road curve interpolation
    const latDiff = destLat - originLat;
    const lngDiff = destLng - originLng;
    const distMeters = Math.round(Math.sqrt(latDiff * latDiff + lngDiff * lngDiff) * 111000);
    const durMins = Math.max(1, Math.round(distMeters / (mode === 'walk' ? 80 : 500)));

    const routeCoordinates = [];
    const numPoints = 12;
    for (let i = 0; i <= numPoints; i++) {
      const t = i / numPoints;
      // Add slight sin/cos curve perturbation to simulate real road curvature
      const curveOffset = Math.sin(t * Math.PI) * 0.003;
      const pointLat = originLat + latDiff * t + curveOffset;
      const pointLng = originLng + lngDiff * t - curveOffset * 0.5;
      routeCoordinates.push([pointLat, pointLng]);
    }

    return {
      distanceMeters: distMeters,
      durationMinutes: durMins,
      polyline: `geojson:${JSON.stringify(routeCoordinates)}`,
      routeCoordinates,
      provider: 'OSRM (Heuristic Fallback)',
    };
  }
}

