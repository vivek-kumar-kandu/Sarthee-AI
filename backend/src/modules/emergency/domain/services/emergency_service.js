import { EmergencyRegistry } from '../../../../infrastructure/providers/registry/emergency_registry.js';
import { sosDispatcher } from './sos_dispatcher.js';

/**
 * EmergencyService
 *
 * Orchestrates emergency safety lookups and 24x7 SOS dispatches.
 */
export class EmergencyService {
  constructor(registry = new EmergencyRegistry(), dispatcher = sosDispatcher) {
    this.registry = registry;
    this.dispatcher = dispatcher;
  }

  /**
   * Fetches emergency services by subcategory
   */
  async getEmergencyServices(lat, lng, subcategory = 'all') {
    return this.registry.fetchEmergencyServices(lat, lng, subcategory);
  }

  /**
   * Dispatches 24x7 emergency SOS alert
   */
  async dispatchSos(params) {
    const { lat, lng, userId, emergencyContacts } = params;

    const hospitals = await this.registry.fetchEmergencyServices(lat, lng, 'hospital');
    const police = await this.registry.fetchEmergencyServices(lat, lng, 'police');

    return this.dispatcher.generateSosPayload({
      lat,
      lng,
      userId,
      emergencyContacts,
      nearestPolice: police[0] || null,
      nearestHospital: hospitals[0] || null,
    });
  }
}

export const emergencyService = new EmergencyService();
