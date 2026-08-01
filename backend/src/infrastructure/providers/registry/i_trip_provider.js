/**
 * ITripProvider — Base Interface for Self-Describing Trip Data Providers
 *
 * Enforces a uniform contract for all providers contributing data to the
 * Trip Planning Orchestrator (Nearby POIs, OSRM Routing, OpenWeather, Traffic,
 * Tourism Intelligence, Live Events).
 *
 * Provider Contract:
 * {
 *   id: string,
 *   name: string,
 *   priority: number, // 1 (highest) to 10
 *   isCritical: boolean, // If true, failure triggers retry; if false, skip & log
 *   timeoutMs: number,
 *   version: string,
 *   execute(context): Promise<any>,
 *   health(): Promise<{ status: 'healthy'|'degraded'|'down', latencyMs: number }>
 * }
 */
export class ITripProvider {
  constructor({
    id,
    name,
    priority = 5,
    isCritical = false,
    timeoutMs = 4000,
    version = '1.0.0',
  }) {
    if (!id || typeof id !== 'string') {
      throw new Error('ITripProvider requires a valid string id');
    }

    this.id = id;
    this.name = name || id;
    this.priority = priority;
    this.isCritical = isCritical;
    this.timeoutMs = timeoutMs;
    this.version = version;
  }

  async execute(_context) {
    throw new Error(`ITripProvider.execute() must be implemented by "${this.id}".`);
  }

  async health() {
    return {
      status: 'healthy',
      latencyMs: 10,
      version: this.version,
    };
  }
}
