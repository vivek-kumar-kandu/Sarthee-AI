import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { CoordinatesVO } from '../value_objects/coordinates_vo.js';
import { FareSummaryVO } from '../value_objects/fare_summary_vo.js';
import { OsrmRoutingProvider } from '../../../../infrastructure/providers/routing/osrm_routing_provider.js';
import { DynamicFareEngine } from './dynamic_fare_engine.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function loadJsonConfig(filename) {
  try {
    const filePath = path.join(__dirname, '../../../../infrastructure/config', filename);
    const content = fs.readFileSync(filePath, 'utf-8');
    return JSON.parse(content);
  } catch (_) {
    return null;
  }
}

const metroFareRules = loadJsonConfig('fare_rules/metro.json');
const autoFareRules = loadJsonConfig('fare_rules/auto.json');
const busFareRules = loadJsonConfig('fare_rules/bus.json');
const safetyWeights = loadJsonConfig('safety/weights.json');

export class MultiModalGraphSearchService {
  constructor(routingProvider = new OsrmRoutingProvider(), fareEngine = null) {
    this.routingProvider = routingProvider;
    this.fareEngine = fareEngine || new DynamicFareEngine();
  }

  /**
   * Dynamic Fare Engine Calculation for Metro
   */
  calculateMetroFare(distanceKm) {
    if (!metroFareRules || !Array.isArray(metroFareRules.fareSlabs)) {
      if (distanceKm <= 2) return 10;
      if (distanceKm <= 5) return 20;
      if (distanceKm <= 12) return 30;
      if (distanceKm <= 21) return 40;
      if (distanceKm <= 32) return 50;
      return 60;
    }

    for (const slab of metroFareRules.fareSlabs) {
      if (distanceKm >= slab.minKm && distanceKm < slab.maxKm) {
        return slab.fare;
      }
    }
    return 60;
  }

  calculateAutoFare(distanceKm, options = {}) {
    const baseFare = autoFareRules?.privateAuto?.baseFare ?? 30.0;
    const baseDist = autoFareRules?.privateAuto?.baseDistanceKm ?? 1.5;
    const perKm = autoFareRules?.privateAuto?.perKmRate ?? 9.5;

    const rawFare = distanceKm <= baseDist ? baseFare : (baseFare + (distanceKm - baseDist) * perKm);
    return this.fareEngine.calculateFinalFare(rawFare, options.hourOfDay, options.isRain);
  }

  calculateCabFare(distanceKm, options = {}) {
    const baseFare = 50.0;
    const baseDist = 2.0;
    const perKm = 14.0;

    const rawFare = distanceKm <= baseDist ? baseFare : (baseFare + (distanceKm - baseDist) * perKm);
    return this.fareEngine.calculateFinalFare(rawFare, options.hourOfDay, options.isRain);
  }

  calculateBusFare(distanceKm, isAc = false) {
    const slabs = isAc ? busFareRules?.acBus : busFareRules?.nonAcBus;
    if (Array.isArray(slabs)) {
      for (const slab of slabs) {
        if (distanceKm <= slab.maxKm) return slab.fare;
      }
    }
    return isAc ? 25 : 15;
  }

  /**
   * Dynamic Safety Engine Calculation
   */
  calculateSafetyProfile({ mode, hourOfDay = new Date().getHours(), walkingMeters = 600, isRain = false }) {
    const isNight = hourOfDay >= 20 || hourOfDay < 6;

    let baseScore = 88;
    const highlights = [];

    switch (mode) {
      case 'safest':
        baseScore = 96;
        highlights.push('CISF Gated Metro Station Patrol');
        highlights.push('100% Illuminated Footpaths');
        break;
      case 'comfort':
        baseScore = 92;
        highlights.push('Live App GPS Tracking & SOS');
        highlights.push('Verified Commercial Driver');
        break;
      case 'recommended':
      case 'balanced':
      case 'eco':
      case 'accessible':
        baseScore = 90;
        highlights.push('CCTV Covered Transit Hubs');
        highlights.push('High Footfall Public Corridors');
        break;
      case 'fastest':
        baseScore = 85;
        highlights.push('Direct Highway Route');
        break;
      case 'cheapest':
        baseScore = 80;
        highlights.push('Public Bus Stop Transit');
        break;
      default:
        baseScore = 85;
    }

    // Time of day modifier
    if (isNight) {
      baseScore -= (mode === 'safest' ? 4 : 10);
      highlights.push('Nighttime Low Visibility Warning');
    }

    // Walking distance penalty
    if (walkingMeters > 800) {
      baseScore -= 6;
      highlights.push(`Long Walk (${walkingMeters}m) Penalty`);
    } else if (walkingMeters > 500 && isNight) {
      baseScore -= 5;
      highlights.push('Night Walking Penalty');
    }

    // Weather penalty
    if (isRain) {
      baseScore -= 4;
      highlights.push('Rain / Slippery Walkway Advisory');
    }

    const compositeScore = Math.max(40, Math.min(100, baseScore));
    let ratingLabel = 'High Safety';
    if (compositeScore < 70) ratingLabel = 'Moderate Caution';
    if (compositeScore < 55) ratingLabel = 'Higher Risk';

    return {
      compositeSafetyScore: compositeScore,
      ratingLabel,
      highlights,
      reasoning: `${compositeScore}/100 (${ratingLabel}): ${highlights.join(', ')}`,
    };
  }

  /**
   * Generates keyed Journey Plans with Dynamic Fares & Dynamic Safety Engine
   */
  async generateKeyedPlans(originName, originLat, originLng, destName, destLat, destLng, options = {}) {
    const origin = new CoordinatesVO(originLat, originLng);
    const dest = new CoordinatesVO(destLat, destLng);

    // 1. Live OSRM Distance & Duration
    const osrmRoute = await this.routingProvider.calculateRoute(
      origin.latitude,
      origin.longitude,
      dest.latitude,
      dest.longitude,
      'driving'
    );

    const estDistanceMeters = osrmRoute.distanceMeters;
    const distanceKm = Math.max(0.5, estDistanceMeters / 1000.0);
    const drivingMinutes = osrmRoute.durationMinutes;

    // 2. Dynamic Fare Computations
    const metroFare = this.calculateMetroFare(distanceKm);
    const firstLegAutoFare = this.calculateAutoFare(1.2);
    const directCabFare = this.calculateCabFare(distanceKm);
    const busFare = this.calculateBusFare(distanceKm, false);

    const recommendedTotalCost = metroFare + firstLegAutoFare;
    const cheapestTotalCost = metroFare + busFare;
    const comfortTotalCost = metroFare + this.calculateAutoFare(3.0);

    // 3. Dynamic Safety Calculations
    const hour = options.hourOfDay ?? new Date().getHours();
    const isRain = options.isRain ?? false;

    const recSafety = this.calculateSafetyProfile({ mode: 'recommended', hourOfDay: hour, walkingMeters: 600, isRain });
    const safeSafety = this.calculateSafetyProfile({ mode: 'safest', hourOfDay: hour, walkingMeters: 350, isRain });
    const fastSafety = this.calculateSafetyProfile({ mode: 'fastest', hourOfDay: hour, walkingMeters: 50, isRain });
    const cheapSafety = this.calculateSafetyProfile({ mode: 'cheapest', hourOfDay: hour, walkingMeters: 1200, isRain });
    const comfSafety = this.calculateSafetyProfile({ mode: 'comfort', hourOfDay: hour, walkingMeters: 100, isRain });

    // 4. Dynamic Steps Construction
    const metroSteps = [
      { stepIndex: 1, type: 'auto', title: 'Take Auto to Metro Station', distanceMeters: 1200, durationMinutes: 5, estimatedFare: firstLegAutoFare, farePaymentMethod: 'UPI/Cash' },
      { stepIndex: 2, type: 'metro', title: 'Metro Transit Line', distanceMeters: estDistanceMeters, durationMinutes: Math.max(15, drivingMinutes), estimatedFare: metroFare, farePaymentMethod: 'Smart Card' },
      { stepIndex: 3, type: 'walk', title: 'Walk to Destination', distanceMeters: 250, durationMinutes: 4, estimatedFare: 0, farePaymentMethod: 'Free' },
    ];

    const cabSteps = [
      { stepIndex: 1, type: 'cab', title: 'Direct Taxi Service', distanceMeters: estDistanceMeters, durationMinutes: drivingMinutes, estimatedFare: directCabFare, farePaymentMethod: 'App Pay / Cash' },
    ];

    // 5. Dynamic Structured Fare Summaries
    const recommendedFareSummary = new FareSummaryVO(recommendedTotalCost, 'INR', [
      { legTitle: 'Auto to Metro Station', amount: firstLegAutoFare, paymentMethod: 'UPI', confidence: 'verified' },
      { legTitle: 'Metro Rail Ticket', amount: metroFare, paymentMethod: 'Smart Card', confidence: 'verified' },
    ], true);

    const cabFareSummary = new FareSummaryVO(directCabFare, 'INR', [
      { legTitle: 'Direct Taxi Service', amount: directCabFare, paymentMethod: 'App Pay', confidence: 'estimated' },
    ], false);

    const cheapestFareSummary = new FareSummaryVO(cheapestTotalCost, 'INR', [
      { legTitle: 'DTC Feeder Bus', amount: busFare, paymentMethod: 'Cash', confidence: 'verified' },
      { legTitle: 'Metro Rail Ticket', amount: metroFare, paymentMethod: 'Smart Card', confidence: 'verified' },
    ], true);

    const comfortFareSummary = new FareSummaryVO(comfortTotalCost, 'INR', [
      { legTitle: 'Private Doorstep Auto', amount: this.calculateAutoFare(3.0), paymentMethod: 'UPI', confidence: 'verified' },
      { legTitle: 'Metro Rail Ticket', amount: metroFare, paymentMethod: 'Smart Card', confidence: 'verified' },
    ], true);

    return {
      recommended: { id: 'plan_rec_01', mode: 'recommended', originName, destinationName: destName, totalDurationMinutes: Math.max(20, drivingMinutes + 9), totalCost: recommendedTotalCost, compositeSafetyScore: recSafety.compositeSafetyScore, safetyDetails: recSafety, polyline: osrmRoute.polyline, steps: metroSteps, fareSummary: recommendedFareSummary },
      balanced: { id: 'plan_bal_01', mode: 'balanced', originName, destinationName: destName, totalDurationMinutes: Math.max(20, drivingMinutes + 9), totalCost: recommendedTotalCost, compositeSafetyScore: recSafety.compositeSafetyScore, safetyDetails: recSafety, polyline: osrmRoute.polyline, steps: metroSteps, fareSummary: recommendedFareSummary },
      fastest: { id: 'plan_fast_01', mode: 'fastest', originName, destinationName: destName, totalDurationMinutes: drivingMinutes, totalCost: directCabFare, compositeSafetyScore: fastSafety.compositeSafetyScore, safetyDetails: fastSafety, polyline: osrmRoute.polyline, steps: cabSteps, fareSummary: cabFareSummary },
      cheapest: { id: 'plan_cheap_01', mode: 'cheapest', originName, destinationName: destName, totalDurationMinutes: drivingMinutes + 25, totalCost: cheapestTotalCost, compositeSafetyScore: cheapSafety.compositeSafetyScore, safetyDetails: cheapSafety, polyline: osrmRoute.polyline, steps: metroSteps, fareSummary: cheapestFareSummary },
      safest: { id: 'plan_safe_01', mode: 'safest', originName, destinationName: destName, totalDurationMinutes: drivingMinutes + 15, totalCost: recommendedTotalCost, compositeSafetyScore: safeSafety.compositeSafetyScore, safetyDetails: safeSafety, polyline: osrmRoute.polyline, steps: metroSteps, fareSummary: recommendedFareSummary },
      accessible: { id: 'plan_acc_01', mode: 'accessible', originName, destinationName: destName, totalDurationMinutes: drivingMinutes + 10, totalCost: recommendedTotalCost, compositeSafetyScore: recSafety.compositeSafetyScore, safetyDetails: recSafety, polyline: osrmRoute.polyline, steps: metroSteps, fareSummary: recommendedFareSummary },
      eco: { id: 'plan_eco_01', mode: 'eco', originName, destinationName: destName, totalDurationMinutes: drivingMinutes + 9, totalCost: recommendedTotalCost, compositeSafetyScore: recSafety.compositeSafetyScore, safetyDetails: recSafety, polyline: osrmRoute.polyline, steps: metroSteps, fareSummary: recommendedFareSummary },
      comfort: { id: 'plan_com_01', mode: 'comfort', originName, destinationName: destName, totalDurationMinutes: drivingMinutes + 5, totalCost: comfortTotalCost, compositeSafetyScore: comfSafety.compositeSafetyScore, safetyDetails: comfSafety, polyline: osrmRoute.polyline, steps: metroSteps, fareSummary: comfortFareSummary },
    };
  }
}

