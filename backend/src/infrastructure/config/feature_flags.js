import process from 'node:process';

/**
 * Operational vs Experimental Feature Flags Strategy
 */
export const featureFlags = {
  // Operational Flags
  operational: {
    enableAi: process.env.ENABLE_AI !== 'false',
    enableCache: process.env.ENABLE_CACHE !== 'false',
    enableHistory: process.env.ENABLE_HISTORY !== 'false',
    enableEventBus: process.env.ENABLE_EVENT_BUS !== 'false',
    routingProvider: process.env.USE_ROUTING_PROVIDER || 'osrm',
    weatherProvider: process.env.USE_WEATHER_PROVIDER || 'openweather',
    aiProvider: process.env.USE_AI_PROVIDER || 'gemini',
  },

  // Experimental Flags
  experimental: {
    experimentNewRouter: process.env.EXPERIMENT_NEW_ROUTER === 'true',
    experimentDynamicSurge: process.env.EXPERIMENT_DYNAMIC_SURGE === 'true',
  },
};
