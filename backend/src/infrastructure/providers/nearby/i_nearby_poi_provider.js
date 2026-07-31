export class IPoiNearbyProvider {
  constructor({
    id,
    name,
    category,
    timeoutMs = 4000,
    isEnabled = true,
    version = '1.0.0',
  }) {
    if (!id || typeof id !== 'string') {
      throw new Error('IPoiNearbyProvider requires a valid string id');
    }
    if (!category || typeof category !== 'string') {
      throw new Error(`IPoiNearbyProvider "${id}" requires a valid string category`);
    }

    this.id = id;
    this.name = name || id;
    this.category = category;
    this.timeoutMs = timeoutMs;
    this.isEnabled = isEnabled;
    this.version = version;
  }

  getCategory() {
    return this.category;
  }

  supports(category) {
    return this.category === category || category === 'all';
  }

  async execute(_context) {
    throw new Error(`IPoiNearbyProvider.execute() must be implemented by "${this.id}".`);
  }
}
