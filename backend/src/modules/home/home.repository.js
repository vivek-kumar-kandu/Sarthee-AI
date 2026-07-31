/**
 * ============================================================================
 * SARTHEE AI — HOME REPOSITORY
 * ============================================================================
 *
 * Data-access boundary for the Home module.
 *
 * Responsibilities:
 *
 * • Provide Home source data to HomeService
 * • Keep storage/provider details outside the service layer
 * • Support location-aware content
 * • Support locale-aware content
 * • Support future personalization
 * • Provide deterministic immutable data
 *
 * Future implementations can replace the in-memory/default source with:
 *
 * • PostgreSQL / MongoDB
 * • Firebase
 * • CMS
 * • Places provider
 * • Recommendation engine
 * • Personalization engine
 *
 * without changing HomeController or HomeService.
 *
 * IMPORTANT:
 *
 * Repository:
 *      data access
 *
 * Service:
 *      business orchestration
 *
 * Mapper:
 *      API/domain response shaping
 */

// =============================================================================
// DEFAULT CONTENT
// =============================================================================

const DEFAULT_HOME_CONTENT = Object.freeze({
  sections: Object.freeze([
    Object.freeze({
      id: "explore-nearby",
      type: "destinations",
      title: "Explore Nearby",
      subtitle: "Discover places worth visiting around you.",
      priority: 10,
      enabled: true,
      items: Object.freeze([]),
    }),

    Object.freeze({
      id: "culture-and-heritage",
      type: "culture",
      title: "Culture & Heritage",
      subtitle: "Experience stories, traditions, and heritage.",
      priority: 20,
      enabled: true,
      items: Object.freeze([]),
    }),

    Object.freeze({
      id: "local-food",
      type: "food",
      title: "Local Food",
      subtitle: "Discover authentic local flavours.",
      priority: 30,
      enabled: true,
      items: Object.freeze([]),
    }),

    Object.freeze({
      id: "recommended-trips",
      type: "trips",
      title: "Recommended Trips",
      subtitle: "Travel ideas selected for your journey.",
      priority: 40,
      enabled: true,
      items: Object.freeze([]),
    }),
  ]),

  quickActions: Object.freeze([
    Object.freeze({
      id: "explore",
      type: "explore",
      title: "Explore",
      priority: 10,
      enabled: true,
    }),

    Object.freeze({
      id: "plan-trip",
      type: "planTrip",
      title: "Plan Trip",
      priority: 20,
      enabled: true,
    }),

    Object.freeze({
      id: "food",
      type: "food",
      title: "Food",
      priority: 30,
      enabled: true,
    }),

    Object.freeze({
      id: "ask-sarthee",
      type: "ai",
      title: "Ask Sarthee",
      priority: 40,
      enabled: true,
    }),
  ]),
});

// =============================================================================
// REPOSITORY
// =============================================================================

export class HomeRepository {
  constructor({
    source = DEFAULT_HOME_CONTENT,
    clock = () => new Date(),
  } = {}) {
    validateSource(source);
    validateClock(clock);

    this._source = source;
    this._clock = clock;
  }

  // ==========================================================================
  // HOME CONTENT
  // ==========================================================================

  /**
   * Returns source data required to construct the Home experience.
   *
   * At present the repository uses a deterministic default source.
   *
   * Later this method can aggregate persisted/provider-backed data while
   * keeping the public contract unchanged.
   */
  async getHomeContent({
    locationName,
    latitude,
    longitude,
    locale,
    userId,
    forcePersonalization = false,
  } = {}) {
    const context = createContext({
      locationName,
      latitude,
      longitude,
      locale,
      userId,
      forcePersonalization,
    });

    const sections = this._source.sections.filter(isEnabled).map(cloneSection);

    const quickActions = this._source.quickActions
      .filter(isEnabled)
      .map(cloneAction);

    return Object.freeze({
      sections: freezeCollection(sections),

      quickActions: freezeCollection(quickActions),

      context,

      generatedAt: this._clock().toISOString(),
    });
  }

  // ==========================================================================
  // SECTIONS
  // ==========================================================================

  /**
   * Returns Home sections independently.
   *
   * Useful for future partial-refresh or composition workflows.
   */
  async getSections() {
    return freezeCollection(
      this._source.sections.filter(isEnabled).map(cloneSection),
    );
  }

  /**
   * Finds one Home section by stable identifier.
   */
  async findSectionById(sectionId) {
    const normalizedId = normalizeOptionalText(sectionId);

    if (!normalizedId) {
      return null;
    }

    const section = this._source.sections.find(
      (item) => item.enabled !== false && item.id === normalizedId,
    );

    return section ? Object.freeze(cloneSection(section)) : null;
  }

  // ==========================================================================
  // QUICK ACTIONS
  // ==========================================================================

  async getQuickActions() {
    return freezeCollection(
      this._source.quickActions.filter(isEnabled).map(cloneAction),
    );
  }

  // ==========================================================================
  // HEALTH / READINESS
  // ==========================================================================

  /**
   * Lightweight repository readiness check.
   *
   * Later this can check database/provider connectivity.
   */
  async isReady() {
    return (
      Array.isArray(this._source.sections) &&
      Array.isArray(this._source.quickActions)
    );
  }
}

// =============================================================================
// CONTEXT
// =============================================================================

function createContext({
  locationName,
  latitude,
  longitude,
  locale,
  userId,
  forcePersonalization,
}) {
  const normalizedLocation = normalizeOptionalText(locationName);

  const normalizedLocale = normalizeOptionalText(locale);

  const normalizedUserId = normalizeOptionalText(userId);

  const hasCoordinates =
    Number.isFinite(latitude) && Number.isFinite(longitude);

  return Object.freeze({
    locationName: normalizedLocation,

    latitude: hasCoordinates ? latitude : undefined,

    longitude: hasCoordinates ? longitude : undefined,

    locale: normalizedLocale,

    /*
     * Do not expose the raw user identifier through repository metadata.
     * The service only needs to know whether user context exists.
     */
    hasUserContext: normalizedUserId !== undefined,

    personalized: Boolean(normalizedUserId || forcePersonalization),
  });
}

// =============================================================================
// CLONING
// =============================================================================

function cloneSection(section) {
  return {
    id: section.id,
    type: section.type,
    title: section.title,
    subtitle: section.subtitle,
    priority: section.priority,
    enabled: section.enabled !== false,

    items: Array.isArray(section.items) ? section.items.map(cloneValue) : [],
  };
}

function cloneAction(action) {
  return {
    id: action.id,
    type: action.type,
    title: action.title,
    priority: action.priority,
    enabled: action.enabled !== false,

    ...(action.route !== undefined && {
      route: action.route,
    }),

    ...(action.icon !== undefined && {
      icon: action.icon,
    }),
  };
}

function cloneValue(value) {
  if (value === null || typeof value !== "object") {
    return value;
  }

  if (Array.isArray(value)) {
    return value.map(cloneValue);
  }

  return Object.fromEntries(
    Object.entries(value).map(([key, nestedValue]) => [
      key,
      cloneValue(nestedValue),
    ]),
  );
}

// =============================================================================
// IMMUTABILITY
// =============================================================================

function freezeCollection(values) {
  return Object.freeze(values.map((value) => deepFreeze(value)));
}

function deepFreeze(value) {
  if (value === null || typeof value !== "object" || Object.isFrozen(value)) {
    return value;
  }

  for (const nestedValue of Object.values(value)) {
    deepFreeze(nestedValue);
  }

  return Object.freeze(value);
}

// =============================================================================
// FILTERING
// =============================================================================

function isEnabled(value) {
  return value?.enabled !== false;
}

// =============================================================================
// NORMALIZATION
// =============================================================================

function normalizeOptionalText(value) {
  if (typeof value !== "string") {
    return undefined;
  }

  const normalized = value.trim();

  return normalized.length > 0 ? normalized : undefined;
}

// =============================================================================
// VALIDATION
// =============================================================================

function validateSource(source) {
  if (source === null || typeof source !== "object") {
    throw new TypeError("HomeRepository source must be an object.");
  }

  if (!Array.isArray(source.sections)) {
    throw new TypeError("HomeRepository source.sections must be an array.");
  }

  if (!Array.isArray(source.quickActions)) {
    throw new TypeError("HomeRepository source.quickActions must be an array.");
  }
}

function validateClock(clock) {
  if (typeof clock !== "function") {
    throw new TypeError("HomeRepository clock must be a function.");
  }
}

// =============================================================================
// FACTORY
// =============================================================================

export function createHomeRepository(options) {
  return new HomeRepository(options);
}

// =============================================================================
// DEFAULT INSTANCE
// =============================================================================

export const homeRepository = new HomeRepository();

export default homeRepository;

