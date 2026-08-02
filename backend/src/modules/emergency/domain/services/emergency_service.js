import { EmergencyRegistry } from '../../../../infrastructure/providers/registry/emergency_registry.js';
import { sosDispatcher } from './sos_dispatcher.js';
import { emergencyRepository } from '../../infrastructure/database/emergency_repository.js';

/**
 * EmergencyService
 *
 * Orchestrates emergency safety lookups, 24x7 SOS dispatches, and persistence.
 */
export class EmergencyService {
  constructor(registry = new EmergencyRegistry(), dispatcher = sosDispatcher, repository = emergencyRepository) {
    this.registry = registry;
    this.dispatcher = dispatcher;
    this.repository = repository;
  }

  /**
   * Fetches emergency services by subcategory
   */
  async getEmergencyServices(lat, lng, subcategory = 'all') {
    return this.registry.fetchEmergencyServices(lat, lng, subcategory);
  }

  /**
   * Dispatches 24x7 emergency SOS alert and persists dispatch log
   */
  async dispatchSos(params) {
    const { lat, lng, userId, emergencyContacts } = params;

    const hospitals = await this.registry.fetchEmergencyServices(lat, lng, 'hospital');
    const police = await this.registry.fetchEmergencyServices(lat, lng, 'police');

    const sosPayload = this.dispatcher.generateSosPayload({
      lat,
      lng,
      userId,
      emergencyContacts,
      nearestPolice: police[0] || null,
      nearestHospital: hospitals[0] || null,
    });

    await this.repository.save(sosPayload);

    return sosPayload;
  }
}

export const emergencyService = new EmergencyService();
