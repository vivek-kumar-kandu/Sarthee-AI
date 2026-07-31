import { IJourneyProvider } from './i_journey_provider.js';

export class JourneyProviderRegistry {
  constructor() {
    this.providers = new Map();
  }

  /**
   * Register a new provider plugin
   * @param {IJourneyProvider} provider 
   */
  register(provider) {
    if (!provider || !provider.id) {
      throw new Error('Cannot register invalid provider instance.');
    }
    this.providers.set(provider.id, provider);
  }

  /**
   * Get provider by ID
   * @param {string} id 
   */
  get(id) {
    return this.providers.get(id);
  }

  /**
   * List all enabled provider plugins
   */
  getEnabledProviders() {
    return Array.from(this.providers.values()).filter((p) => p.isEnabled);
  }

  /**
   * Get independent providers (dependencies: [])
   */
  getIndependentProviders() {
    return this.getEnabledProviders().filter((p) => p.dependencies.length === 0);
  }

  /**
   * Get dependent providers requiring specific dependency (e.g. 'route')
   * @param {string} dependencyKey 
   */
  getDependentProviders(dependencyKey) {
    return this.getEnabledProviders().filter((p) => p.dependencies.includes(dependencyKey));
  }
}
