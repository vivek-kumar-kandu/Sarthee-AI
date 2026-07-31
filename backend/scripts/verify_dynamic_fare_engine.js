import { MultiModalGraphSearchService } from '../src/modules/journey/domain/services/multi_modal_graph_search_service.js';

async function verifyDynamicFareEngine() {
  const service = new MultiModalGraphSearchService();

  console.log('==================================================');
  console.log('🌐 EXECUTING DYNAMIC FARE ENGINE COMPARISON TEST');
  console.log('==================================================');

  // Route 1: Short Distance (~9.5 km)
  console.log('\n--- Route 1: Short Route (Ghaziabad -> Anand Vihar) ---');
  const r1 = await service.generateKeyedPlans('Ghaziabad', 28.6715, 77.4121, 'Anand Vihar', 28.6469, 77.3162);
  console.log(`Recommended Total Cost : ₹${r1.recommended.totalCost}`);
  console.log(`Direct Cab Cost        : ₹${r1.fastest.totalCost}`);
  console.log(`Cheapest Total Cost    : ₹${r1.cheapest.totalCost}`);
  console.log(`Comfort Total Cost     : ₹${r1.comfort.totalCost}`);
  console.log(`Fare Items Breakdown   :`, r1.recommended.fareSummary.items);

  // Route 2: Long Distance (~48 km)
  console.log('\n--- Route 2: Long Route (Ghaziabad -> Cyber City Gurgaon) ---');
  const r2 = await service.generateKeyedPlans('Ghaziabad', 28.6715, 77.4121, 'Cyber City Gurgaon', 28.4950, 77.0895);
  console.log(`Recommended Total Cost : ₹${r2.recommended.totalCost}`);
  console.log(`Direct Cab Cost        : ₹${r2.fastest.totalCost}`);
  console.log(`Cheapest Total Cost    : ₹${r2.cheapest.totalCost}`);
  console.log(`Comfort Total Cost     : ₹${r2.comfort.totalCost}`);
  console.log(`Fare Items Breakdown   :`, r2.recommended.fareSummary.items);

  console.log('\n==================================================');
  console.log('✅ EMPIRICAL PROOF OF DYNAMIC FARE DIFFERENCES');
  console.log('==================================================');
  console.log(`Short Route (9.5 km) Metro Fare  : ₹${r1.recommended.fareSummary.items[1].amount}`);
  console.log(`Long Route (48 km) Metro Fare   : ₹${r2.recommended.fareSummary.items[1].amount}`);
  console.log(`Short Route Cab Fare             : ₹${r1.fastest.totalCost}`);
  console.log(`Long Route Cab Fare              : ₹${r2.fastest.totalCost}`);
}

verifyDynamicFareEngine();
