import { test, describe } from 'node:test';
import assert from 'node:assert';
import { CoordinatesVO } from '../../src/modules/journey/domain/value_objects/coordinates_vo.js';
import { FareSummaryVO } from '../../src/modules/journey/domain/value_objects/fare_summary_vo.js';
import { MultiModalGraphSearchService } from '../../src/modules/journey/domain/services/multi_modal_graph_search_service.js';

describe('Layer 3: Backend Clean Architecture Domain Layer', () => {
  test('CoordinatesVO should throw error on invalid coordinates', () => {
    assert.throws(() => new CoordinatesVO(100, 77.4121), /Invalid latitude/);
    assert.throws(() => new CoordinatesVO(28.6715, 200), /Invalid longitude/);
  });

  test('CoordinatesVO should accept valid coordinates', () => {
    const coords = new CoordinatesVO(28.6715, 77.4121);
    assert.strictEqual(coords.latitude, 28.6715);
    assert.strictEqual(coords.longitude, 77.4121);
  });

  test('FareSummaryVO should enforce non-negative total amount', () => {
    assert.throws(() => new FareSummaryVO(-10.0), /Cannot be negative/);
  });

  test('MultiModalGraphSearchService should return 8 keyed journey plan options', () => {
    const service = new MultiModalGraphSearchService();
    const plans = service.generateKeyedPlans('Ghaziabad', 28.6715, 77.4121, 'Delhi', 28.6328, 77.2197);

    assert.ok(plans.recommended);
    assert.ok(plans.balanced);
    assert.ok(plans.fastest);
    assert.ok(plans.cheapest);
    assert.ok(plans.safest);
    assert.ok(plans.accessible);
    assert.ok(plans.eco);
    assert.ok(plans.comfort);
    assert.strictEqual(plans.balanced.mode, 'balanced');
  });
});
