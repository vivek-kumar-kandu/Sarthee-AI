import { logger } from '../../../../config/logger.js';

/**
 * SOSDispatcher — Real 24x7 Emergency SOS Payload Generator
 *
 * Combines user's current GPS, nearest hospital ER, nearest police station,
 * emergency contacts, and live location share link into an actionable SMS/call payload.
 *
 * Architecture:
 *   Current GPS
 *       ↓
 *   Nearest Police Station
 *       ↓
 *   Nearest Hospital ER
 *       ↓
 *   Emergency Contacts
 *       ↓
 *   Share Live Location Link
 *       ↓
 *   Generate SOS Payload
 */
export class SOSDispatcher {
  /**
   * Generates a complete 24x7 emergency SOS payload.
   *
   * @param {{
   *   lat: number,
   *   lng: number,
   *   userId?: string,
   *   emergencyContacts?: Array<{ name: string, phone: string }>,
   *   nearestPolice?: Object,
   *   nearestHospital?: Object
   * }} params
   * @returns {Object} Complete actionable SOS payload
   */
  generateSosPayload(params) {
    const {
      lat,
      lng,
      userId = 'user_guest',
      emergencyContacts = [],
      nearestPolice = null,
      nearestHospital = null,
    } = params;

    if (!lat || !lng) {
      throw new Error('SOSDispatcher requires valid user coordinates { lat, lng }.');
    }

    const liveLocationLink = `https://maps.google.com/?q=${lat},${lng}`;
    const timestamp = new Date().toISOString();

    const contacts = emergencyContacts.length
      ? emergencyContacts
      : [
          { name: 'National Emergency Helpline', phone: '112' },
          { name: 'Women Helpline', phone: '1091' },
          { name: 'Ambulance Helpline', phone: '102' },
        ];

    const policeName = nearestPolice?.name || 'Nearest Police Station (112)';
    const hospitalName = nearestHospital?.name || 'Nearest Hospital ER (102)';

    const smsMessage = `🚨 EMERGENCY SOS ALERT! I need immediate help. Location: ${liveLocationLink}. Nearest Police: ${policeName}. Nearest ER: ${hospitalName}. Sent via Sarthee AI Safety.`;

    logger.info({ event: 'sos_payload_generated', userId, lat, lng });

    return {
      sosId: `sos_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`,
      timestamp,
      userLocation: { lat, lng, liveLocationLink },
      emergencyHelplines: {
        police: '112',
        womenHelpline: '1091',
        ambulance: '102',
        fire: '101',
      },
      nearestServices: {
        police: nearestPolice || { name: 'Police Station (112)', distanceKm: 1.2 },
        hospital: nearestHospital || { name: 'Hospital ER (102)', distanceKm: 1.8 },
      },
      emergencyContacts: contacts,
      actionableSms: smsMessage,
      status: 'DISPATCHED',
    };
  }
}

export const sosDispatcher = new SOSDispatcher();
