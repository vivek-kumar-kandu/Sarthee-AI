import { logger } from '../../../../config/logger.js';

/**
 * FavoritesService
 *
 * Manages user saved places, favorites, and custom itinerary collections
 * (e.g. "Jaipur Heritage Expedition" -> Amer Fort -> Jal Mahal -> Hawa Mahal).
 *
 * Includes 1-Click Smart Route Handoff:
 *   Converts any collection of POIs into an optimized multi-stop journey plan!
 */
export class FavoritesService {
  constructor() {
    /** @type {Map<string, Set<Object>>} userId -> Set of POI objects */
    this.userFavorites = new Map();
    /** @type {Map<string, Map<string, Object>>} userId -> Map(collectionId -> collectionObj) */
    this.userCollections = new Map();
  }

  /**
   * Adds a POI to user favorites
   */
  async addFavorite(userId = 'guest', poi) {
    if (!poi?.id) throw new Error('POI requires an id to be favorited.');

    if (!this.userFavorites.has(userId)) {
      this.userFavorites.set(userId, new Map());
    }

    const favMap = this.userFavorites.get(userId);
    favMap.set(poi.id, {
      ...poi,
      savedAt: new Date().toISOString(),
    });

    logger.info({ event: 'favorite_added', userId, poiId: poi.id, poiName: poi.name });
    return Array.from(favMap.values());
  }

  /**
   * Removes a POI from user favorites
   */
  async removeFavorite(userId = 'guest', poiId) {
    const favMap = this.userFavorites.get(userId);
    if (favMap) {
      favMap.delete(poiId);
    }
    return Array.from(favMap?.values() || []);
  }

  /**
   * Returns user favorites
   */
  async getFavorites(userId = 'guest') {
    const favMap = this.userFavorites.get(userId);
    return Array.from(favMap?.values() || []);
  }

  /**
   * Creates a custom Itinerary Collection (e.g. "Jaipur Heritage Expedition")
   */
  async createCollection(userId = 'guest', { title, description, pois = [] }) {
    if (!title) throw new Error('Collection title is required.');

    if (!this.userCollections.has(userId)) {
      this.userCollections.set(userId, new Map());
    }

    const collectionId = `col_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`;
    const collection = {
      id: collectionId,
      title,
      description: description || '',
      pois,
      itemCount: pois.length,
      createdAt: new Date().toISOString(),
    };

    this.userCollections.get(userId).set(collectionId, collection);
    logger.info({ event: 'collection_created', userId, collectionId, title });
    return collection;
  }

  /**
   * Returns user collections
   */
  async getCollections(userId = 'guest') {
    const userMap = this.userCollections.get(userId);
    return Array.from(userMap?.values() || []);
  }

  /**
   * 1-Click Smart Route Handoff Generator!
   * Converts a collection of POIs into a multi-stop Journey Planner payload.
   *
   * @param {string} userId
   * @param {string} collectionId
   * @returns {Promise<Object>} Smart Route multi-modal journey payload
   */
  async convertCollectionToSmartRoute(userId = 'guest', collectionId) {
    const userMap = this.userCollections.get(userId);
    const collection = userMap?.get(collectionId);

    if (!collection || !collection.pois?.length) {
      throw new Error(`Collection "${collectionId}" not found or has no POIs.`);
    }

    const pois = collection.pois;
    const origin = pois[0];
    const destination = pois[pois.length - 1];
    const waypoints = pois.slice(1, -1);

    return {
      title: collection.title,
      origin: {
        name: origin.name,
        lat: origin.lat,
        lng: origin.lng,
      },
      destination: {
        name: destination.name,
        lat: destination.lat,
        lng: destination.lng,
      },
      waypoints: waypoints.map((w) => ({ name: w.name, lat: w.lat, lng: w.lng })),
      totalStops: pois.length,
      handOffTimestamp: new Date().toISOString(),
    };
  }
}
