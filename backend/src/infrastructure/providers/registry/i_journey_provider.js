/**
 * Self-Describing Journey Provider Interface Contract
 */
export class IJourneyProvider {
  constructor({
    id,
    name,
    priority = 'optional', // 'critical' | 'optional'
    dependencies = [],    // e.g. [] for independent, ['route'] for dependent
    timeoutMs = 3000,
    cacheTtlSeconds = 7200,
    version = '1.0.0',
    isEnabled = true,
  }) {
    if (!id || typeof id !== 'string') {
      throw new Error('IJourneyProvider requires a valid string id');
    }

    this.id = id;
    this.name = name || id;
    this.priority = priority;
    this.dependencies = Array.isArray(dependencies) ? dependencies : [];
    this.timeoutMs = timeoutMs;
    this.cacheTtlSeconds = cacheTtlSeconds;
    this.version = version;
    this.isEnabled = isEnabled;
  }

  /**
   * Executes provider lookup asynchronously.
   * @param {Object} context Input request context ({ originLat, originLng, destLat, destLng, route, ... })
   * @returns {Promise<Object|null>} Provider lookup result or null
   */
  async execute(_context) {
    throw new Error(`Method execute() must be implemented by provider plugin "${this.id}".`);
  }
}
