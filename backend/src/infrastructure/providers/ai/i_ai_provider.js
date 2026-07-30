/**
 * Abstract AI Provider Interface
 */
export class IAIProvider {
  /**
   * Generates contextual natural language rationale for a journey plan
   * @param {Object} promptContext
   * @returns {Promise<{rationale: string, model: string}>}
   */
  async generateRationale(promptContext) {
    throw new Error('IAIProvider.generateRationale must be implemented by subclass.');
  }
}
