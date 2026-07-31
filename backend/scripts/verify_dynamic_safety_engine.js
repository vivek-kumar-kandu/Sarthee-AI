import { MultiModalGraphSearchService } from '../src/modules/journey/domain/services/multi_modal_graph_search_service.js';

async function verifyDynamicSafetyEngine() {
  const service = new MultiModalGraphSearchService();

  console.log('==================================================');
  console.log('🛡️ EXECUTING DYNAMIC SAFETY ENGINE COMPARISON TEST');
  console.log('==================================================');

  // Scenario 1: Daytime (14:00), Clear Weather
  console.log('\n--- Scenario 1: Daytime Travel (14:00), Clear Weather ---');
  const dayPlans = await service.generateKeyedPlans(
    'Ghaziabad', 28.6715, 77.4121,
    'Connaught Place', 28.6328, 77.2197,
    { hourOfDay: 14, isRain: false }
  );

  console.log('🛡️ Safest Profile Score     :', dayPlans.safest.compositeSafetyScore);
  console.log('🛡️ Safest Safety Details    :', dayPlans.safest.safetyDetails);
  console.log('💰 Cheapest Profile Score   :', dayPlans.cheapest.compositeSafetyScore);
  console.log('💰 Cheapest Safety Details  :', dayPlans.cheapest.safetyDetails);

  // Scenario 2: Nighttime (23:00), Heavy Rain
  console.log('\n--- Scenario 2: Nighttime Travel (23:00), Rainy Weather ---');
  const nightPlans = await service.generateKeyedPlans(
    'Ghaziabad', 28.6715, 77.4121,
    'Connaught Place', 28.6328, 77.2197,
    { hourOfDay: 23, isRain: true }
  );

  console.log('🛡️ Safest Profile Score     :', nightPlans.safest.compositeSafetyScore);
  console.log('🛡️ Safest Safety Details    :', nightPlans.safest.safetyDetails);
  console.log('💰 Cheapest Profile Score   :', nightPlans.cheapest.compositeSafetyScore);
  console.log('💰 Cheapest Safety Details  :', nightPlans.cheapest.safetyDetails);

  console.log('\n==================================================');
  console.log('✅ EMPIRICAL PROOF OF DYNAMIC SAFETY SCORE DIFFERENCES');
  console.log('==================================================');
  console.log(`Daytime Safest Score        : ${dayPlans.safest.compositeSafetyScore} (${dayPlans.safest.safetyDetails.ratingLabel})`);
  console.log(`Nighttime Rainy Safest Score: ${nightPlans.safest.compositeSafetyScore} (${nightPlans.safest.safetyDetails.ratingLabel})`);
  console.log(`Daytime Cheapest Score      : ${dayPlans.cheapest.compositeSafetyScore} (${dayPlans.cheapest.safetyDetails.ratingLabel})`);
  console.log(`Nighttime Rainy Cheap Score : ${nightPlans.cheapest.compositeSafetyScore} (${nightPlans.cheapest.safetyDetails.ratingLabel})`);
}

verifyDynamicSafetyEngine();
