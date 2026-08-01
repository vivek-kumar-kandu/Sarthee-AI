import { CircuitBreaker } from '../resilience/circuit_breaker.js';
import { logger } from '../../config/logger.js';

/** Circuit Breaker Instances per External Provider */
export const osrmCircuitBreaker = new CircuitBreaker('osrm_routing', { timeoutMs: 3000, failureThreshold: 3 });
export const weatherCircuitBreaker = new CircuitBreaker('open_weather', { timeoutMs: 2000, failureThreshold: 3 });
export const openAqCircuitBreaker = new CircuitBreaker('openaq_air_quality', { timeoutMs: 2500, failureThreshold: 3 });
export const evChargingCircuitBreaker = new CircuitBreaker('open_charge_map', { timeoutMs: 2500, failureThreshold: 3 });

/**
 * Real Provider 1: OSRM Live Highway Routing Matrix
 */
export async function fetchOsrmRoute(originLat, originLng, destLat, destLng) {
  const action = async (signal) => {
    const url = `http://router.project-osrm.org/route/v1/driving/${originLng},${originLat};${destLng},${destLat}?overview=false`;
    const resp = await fetch(url, { signal, headers: { 'User-Agent': 'Sarthee-AI-Backend/1.0' } });
    if (!resp.ok) throw new Error(`OSRM HTTP error ${resp.status}`);
    const data = await resp.json();
    const route = data.routes?.[0];
    if (!route) throw new Error('No OSRM route found');

    return {
      distanceKm: Math.round((route.distance / 1000) * 10) / 10,
      durationMinutes: Math.round(route.duration / 60),
      confidencePercent: 94,
      source: 'OSRM Live Routing Engine',
    };
  };

  const fallback = {
    distanceKm: 4.5,
    durationMinutes: 15,
    confidencePercent: 80,
    source: 'OSRM Fallback Estimate',
  };

  return osrmCircuitBreaker.execute(action, fallback);
}

/**
 * Real Provider 2: OpenWeather Live Current Weather API
 */
export async function fetchLiveWeather(lat, lng) {
  const apiKey = process.env.OPENWEATHER_API_KEY;

  const action = async (signal) => {
    if (!apiKey) throw new Error('OPENWEATHER_API_KEY unconfigured');
    const url = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lng}&units=metric&appid=${apiKey}`;
    const resp = await fetch(url, { signal });
    if (!resp.ok) throw new Error(`OpenWeather HTTP error ${resp.status}`);
    const data = await resp.json();

    return {
      temperature: Math.round(data.main?.temp || 28),
      condition: data.weather?.[0]?.main?.toLowerCase() || 'clear',
      humidity: data.main?.humidity || 50,
      source: 'OpenWeather Live API',
    };
  };

  const fallback = {
    temperature: 28,
    condition: 'clear',
    humidity: 45,
    source: 'Climate Fallback Model',
  };

  return weatherCircuitBreaker.execute(action, fallback);
}

/**
 * Real Provider 3: OpenAQ Air Quality Index API (100% Free Public Endpoint)
 */
export async function fetchAirQuality(lat, lng) {
  const action = async (signal) => {
    const url = `https://api.openaq.org/v2/latest?coordinates=${lat},${lng}&radius=25000&limit=1`;
    const resp = await fetch(url, { signal });
    if (!resp.ok) throw new Error(`OpenAQ HTTP error ${resp.status}`);
    const data = await resp.json();
    const result = data.results?.[0];
    const pm25 = result?.measurements?.find((m) => m.parameter === 'pm25')?.value || 42;

    return {
      aqiValue: Math.round(pm25),
      category: pm25 <= 50 ? 'Good' : pm25 <= 100 ? 'Moderate' : 'Unhealthy',
      source: 'OpenAQ Live Public API',
    };
  };

  const fallback = {
    aqiValue: 45,
    category: 'Good',
    source: 'AQI Fallback Estimate',
  };

  return openAqCircuitBreaker.execute(action, fallback);
}

/**
 * Real Provider 4: OpenChargeMap EV Charging Stations (100% Free Endpoint)
 */
export async function fetchEvChargingStations(lat, lng, radiusKm = 10) {
  const action = async (signal) => {
    const url = `https://api.openchargemap.io/v3/poi/?output=json&latitude=${lat}&longitude=${lng}&distance=${radiusKm}&distanceunit=KM&maxresults=10`;
    const resp = await fetch(url, { signal });
    if (!resp.ok) throw new Error(`OpenChargeMap HTTP error ${resp.status}`);
    const data = await resp.json();

    return data.map((station) => ({
      id: `ev_${station.ID}`,
      name: station.AddressInfo?.Title || 'EV Charging Station',
      address: station.AddressInfo?.AddressLine1 || 'Nearby location',
      lat: station.AddressInfo?.Latitude,
      lng: station.AddressInfo?.Longitude,
      operator: station.OperatorInfo?.Title || 'Public EV Charger',
      connectors: station.Connections?.length || 2,
    }));
  };

  const fallback = [
    { id: 'ev_fb_1', name: 'Tata Power EV Charging Station', address: 'Central Mall, Jaipur', lat: 26.9124, lng: 75.7873, operator: 'Tata Power', connectors: 4 },
  ];

  return evChargingCircuitBreaker.execute(action, fallback);
}
