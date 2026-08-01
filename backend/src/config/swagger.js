import swaggerUi from 'swagger-ui-express';

/**
 * OpenAPI 3.0 Specification for Sarthee AI Backend Gateway
 */
export const swaggerSpec = {
  openapi: '3.0.0',
  info: {
    title: 'Sarthee AI — Journey & Travel Intelligence Platform API',
    version: '1.0.0',
    description: 'Production-grade scalable API gateway for Sarthee AI intelligent travel assistant.',
    contact: { name: 'Sarthee AI Deepmind Engineering', email: 'support@sarthee.ai' },
  },
  servers: [
    { url: 'http://localhost:3000/api/v1', description: 'Local Development Server' },
    { url: 'https://api.sarthee.ai/v1', description: 'Production Gateway' },
  ],
  components: {
    securitySchemes: {
      BearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
      },
    },
  },
  paths: {
    '/health': {
      get: {
        summary: 'Liveness Probe',
        responses: { 200: { description: 'Server is healthy and running' } },
      },
    },
    '/health/ready': {
      get: {
        summary: 'Readiness Probe',
        responses: { 200: { description: 'Server and dependencies ready for traffic' } },
      },
    },
    '/journey/plan': {
      post: {
        summary: 'Calculate Multi-Modal Smart Routes',
        description: 'Computes multi-modal journey plans with surge fares, live traffic, weather, and Gemini explanations.',
        responses: { 200: { description: 'Successful journey plan response' } },
      },
    },
    '/nearby': {
      get: {
        summary: 'Discover Nearby Places',
        description: 'Fetches nearby POIs with composite scores, reason chips, and Smart Routes navigation handoff payload.',
        parameters: [
          { name: 'lat', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'lng', in: 'query', required: true, schema: { type: 'number' } },
          { name: 'category', in: 'query', required: false, schema: { type: 'string' } },
        ],
        responses: { 200: { description: 'Nearby places discovery payload' } },
      },
    },
    '/trips/plan': {
      post: {
        summary: 'Plan AI Trip & Multi-Phase Itinerary',
        description: 'Computes optimized multi-stop itineraries with 12-factor scoring, timeline slots, buffers, and AI advice.',
        responses: { 200: { description: 'Generated trip payload' } },
      },
    },
    '/emergency': {
      get: {
        summary: 'Fetch Nearby Emergency Services',
        responses: { 200: { description: 'Emergency services list' } },
      },
    },
    '/emergency/sos': {
      post: {
        summary: 'Trigger 24x7 Emergency SOS Dispatch',
        responses: { 200: { description: 'Actionable SOS dispatch payload' } },
      },
    },
    '/admin/dashboard': {
      get: {
        summary: 'Real-Time Operational Dashboard Snapshot',
        security: [{ BearerAuth: [] }],
        responses: { 200: { description: 'Operational dashboard metrics' } },
      },
    },
  },
};

export const serveSwaggerUi = swaggerUi.serve;
export const setupSwaggerUi = swaggerUi.setup(swaggerSpec);
