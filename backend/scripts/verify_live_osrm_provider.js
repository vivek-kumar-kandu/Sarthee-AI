import { OsrmRoutingProvider } from '../src/infrastructure/providers/routing/osrm_routing_provider.js';

async function verifyOsrmProvider() {
  const provider = new OsrmRoutingProvider();

  console.log('==================================================');
  console.log('🌐 EXECUTING LIVE OSRM ROUTING PROVIDER TEST');
  console.log('==================================================');
  console.log('Origin      : Ghaziabad (28.6715, 77.4121)');
  console.log('Destination : Connaught Place, Delhi (28.6328, 77.2197)');
  console.log('Mode        : driving');

  const startTime = Date.now();
  const result = await provider.calculateRoute(28.6715, 77.4121, 28.6328, 77.2197, 'driving');
  const elapsedMs = Date.now() - startTime;

  console.log('\n==================================================');
  console.log('✅ LIVE OSRM RESULT RETURNED');
  console.log('==================================================');
  console.log(`Provider          : ${result.provider}`);
  console.log(`Response Time     : ${elapsedMs} ms`);
  console.log(`Real Distance     : ${result.distanceMeters} meters (${(result.distanceMeters / 1000).toFixed(2)} km)`);
  console.log(`Real Duration     : ${result.durationMinutes} minutes`);
  console.log(`Real Polyline Enc : ${result.polyline.substring(0, 50)}... (Length: ${result.polyline.length} chars)`);
}

verifyOsrmProvider();
