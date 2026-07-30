import { CoordinatesVO } from '../../domain/value_objects/coordinates_vo.js';

export class JourneyPlanRequestDTO {
  constructor(payload) {
    if (!payload.originName || !payload.destinationName) {
      throw new Error('originName and destinationName are required fields.');
    }
    if (payload.originName.trim() === payload.destinationName.trim()) {
      throw new Error('Destination cannot be identical to Origin.');
    }

    this.originName = payload.originName.trim();
    this.destinationName = payload.destinationName.trim();
    this.originCoords = new CoordinatesVO(payload.originLat, payload.originLng);
    this.destinationCoords = new CoordinatesVO(payload.destinationLat, payload.destinationLng);
    this.preferredMode = payload.preferredMode || 'balanced';
    this.preferences = payload.preferences || {};
  }
}
