/**
 * ============================================================================
 * SARTHEE AI — HOME MAPPER
 * ============================================================================
 *
 * Maps internal Home module data into a stable API-facing representation.
 *
 * Architecture:
 *
 * Repository Data
 *      ↓
 * HomeService
 *      ↓
 * HomeMapper
 *      ↓
 * HomeController
 *      ↓
 * ApiResponse
 *      ↓
 * Flutter HomeContentModel
 *
 * Responsibilities:
 *
 * • Normalize Home sections
 * • Normalize quick actions
 * • Normalize nested items
 * • Remove disabled entries
 * • Produce deterministic ordering
 * • Prevent internal/private fields leaking into the API
 * • Normalize metadata/context
 * • Provide safe defaults
 * • Return immutable output
 *
 * IMPORTANT:
 *
 * Repository owns data access.
 * Service owns orchestration.
 * Mapper owns output transformation.
 */

// =============================================================================
// PUBLIC MAPPER
// =============================================================================

export class HomeMapper {
  /**
   * Converts internal Home data into the public Home payload.
   */
  static toResponse(source = {}) {
    const sections = normalizeSections(source.sections);

    const quickActions = normalizeQuickActions(source.quickActions);

    const context = normalizeContext(source.context);

    const generatedAt = normalizeTimestamp(source.generatedAt);

    return deepFreeze({
      sections,

      quickActions,

      context,

      generatedAt,
    });
  }

  /**
   * Maps a single section.
   *
   * Useful for future partial Home endpoints.
   */
  static sectionToResponse(section) {
    const normalized = normalizeSection(section);

    return normalized ? deepFreeze(normalized) : null;
  }

  /**
   * Maps one quick action.
   */
  static actionToResponse(action) {
    const normalized = normalizeAction(action);

    return normalized ? deepFreeze(normalized) : null;
  }
}

// =============================================================================
// SECTIONS
// =============================================================================

function normalizeSections(sections) {
  if (!Array.isArray(sections)) {
    return Object.freeze([]);
  }

  const normalized = sections
    .map(normalizeSection)
    .filter(Boolean)
    .sort(compareByPriorityAndId);

  return deepFreeze(normalized);
}

function normalizeSection(section) {
  if (section === null || typeof section !== "object") {
    return null;
  }

  if (section.enabled === false) {
    return null;
  }

  const id = normalizeRequiredText(section.id);

  const type = normalizeRequiredText(section.type);

  const title = normalizeRequiredText(section.title);

  /*
   * Invalid structural entries should not escape the mapper.
   */
  if (!id || !type || !title) {
    return null;
  }

  const subtitle = normalizeOptionalText(section.subtitle);

  const items = normalizeItems(section.items);

  return {
    id,

    type,

    title,

    ...(subtitle !== undefined && {
      subtitle,
    }),

    priority: normalizePriority(section.priority),

    items,
  };
}

// =============================================================================
// SECTION ITEMS
// =============================================================================

function normalizeItems(items) {
  if (!Array.isArray(items)) {
    return Object.freeze([]);
  }

  const normalized = items
    .filter((item) => item !== null && item !== undefined)
    .map(normalizePublicValue);

  return deepFreeze(normalized);
}

// =============================================================================
// QUICK ACTIONS
// =============================================================================

function normalizeQuickActions(actions) {
  if (!Array.isArray(actions)) {
    return Object.freeze([]);
  }

  const normalized = actions
    .map(normalizeAction)
    .filter(Boolean)
    .sort(compareByPriorityAndId);

  return deepFreeze(normalized);
}

function normalizeAction(action) {
  if (action === null || typeof action !== "object") {
    return null;
  }

  if (action.enabled === false) {
    return null;
  }

  const id = normalizeRequiredText(action.id);

  const type = normalizeRequiredText(action.type);

  const title = normalizeRequiredText(action.title);

  if (!id || !type || !title) {
    return null;
  }

  const route = normalizeOptionalText(action.route);

  const icon = normalizeOptionalText(action.icon);

  return {
    id,

    type,

    title,

    priority: normalizePriority(action.priority),

    ...(route !== undefined && {
      route,
    }),

    ...(icon !== undefined && {
      icon,
    }),
  };
}

// =============================================================================
// CONTEXT
// =============================================================================

function normalizeContext(context) {
  if (context === null || typeof context !== "object") {
    return deepFreeze({
      hasLocation: false,
      hasCoordinates: false,
      hasUserContext: false,
      personalized: false,
    });
  }

  const locationName = normalizeOptionalText(context.locationName);

  const locale = normalizeOptionalText(context.locale);

  const latitude = normalizeCoordinate(context.latitude, -90, 90);

  const longitude = normalizeCoordinate(context.longitude, -180, 180);

  const hasCoordinates = latitude !== undefined && longitude !== undefined;

  const hasLocation = locationName !== undefined || hasCoordinates;

  return deepFreeze({
    ...(locationName !== undefined && {
      locationName,
    }),

    ...(hasCoordinates && {
      latitude,
      longitude,
    }),

    ...(locale !== undefined && {
      locale,
    }),

    hasLocation,

    hasCoordinates,

    hasUserContext: Boolean(context.hasUserContext),

    personalized: Boolean(context.personalized),
  });
}

// =============================================================================
// TIMESTAMP
// =============================================================================

function normalizeTimestamp(value) {
  if (value instanceof Date) {
    if (!Number.isNaN(value.getTime())) {
      return value.toISOString();
    }
  }

  if (typeof value === "string") {
    const parsed = new Date(value);

    if (!Number.isNaN(parsed.getTime())) {
      return parsed.toISOString();
    }
  }

  /*
   * Do not silently generate Date.now() here.
   *
   * Repository/service should own generation time.
   * This keeps mapper output deterministic during testing.
   */
  return null;
}

// =============================================================================
// PUBLIC VALUE SANITIZATION
// =============================================================================

/**
 * Recursively converts arbitrary repository values into safe JSON-compatible
 * values.
 *
 * It also strips keys commonly intended for internal/private use.
 */
function normalizePublicValue(value) {
  if (
    value === null ||
    typeof value === "string" ||
    typeof value === "boolean"
  ) {
    return value;
  }

  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value.toISOString();
  }

  if (Array.isArray(value)) {
    return value.map(normalizePublicValue);
  }

  if (typeof value === "object") {
    const result = {};

    for (const [key, nestedValue] of Object.entries(value)) {
      if (!isPublicKey(key)) {
        continue;
      }

      if (
        nestedValue === undefined ||
        typeof nestedValue === "function" ||
        typeof nestedValue === "symbol"
      ) {
        continue;
      }

      result[key] = normalizePublicValue(nestedValue);
    }

    return result;
  }

  return null;
}

// =============================================================================
// PRIVATE FIELD PROTECTION
// =============================================================================

function isPublicKey(key) {
  if (typeof key !== "string" || key.length === 0) {
    return false;
  }

  /*
   * Convention:
   *
   * _field
   * __field
   *
   * are internal implementation fields and should never leak through the
   * public Home API.
   */
  return !key.startsWith("_");
}

// =============================================================================
// ORDERING
// =============================================================================

function compareByPriorityAndId(first, second) {
  const priorityComparison =
    normalizePriority(first.priority) - normalizePriority(second.priority);

  if (priorityComparison !== 0) {
    return priorityComparison;
  }

  return String(first.id).localeCompare(String(second.id));
}

// =============================================================================
// NORMALIZATION
// =============================================================================

function normalizeRequiredText(value) {
  if (typeof value !== "string") {
    return null;
  }

  const normalized = value.trim();

  return normalized.length > 0 ? normalized : null;
}

function normalizeOptionalText(value) {
  if (typeof value !== "string") {
    return undefined;
  }

  const normalized = value.trim();

  return normalized.length > 0 ? normalized : undefined;
}

function normalizePriority(value) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return Math.trunc(value);
  }

  if (typeof value === "string" && value.trim().length > 0) {
    const parsed = Number(value);

    if (Number.isFinite(parsed)) {
      return Math.trunc(parsed);
    }
  }

  return 0;
}

function normalizeCoordinate(value, minimum, maximum) {
  if (typeof value !== "number" || !Number.isFinite(value)) {
    return undefined;
  }

  if (value < minimum || value > maximum) {
    return undefined;
  }

  return value;
}

// =============================================================================
// IMMUTABILITY
// =============================================================================

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
// FUNCTIONAL API
// =============================================================================

/**
 * Functional alternative for callers that do not need the HomeMapper class.
 */
export function mapHomeResponse(source) {
  return HomeMapper.toResponse(source);
}

export function mapHomeSection(section) {
  return HomeMapper.sectionToResponse(section);
}

export function mapHomeAction(action) {
  return HomeMapper.actionToResponse(action);
}

// =============================================================================
// DEFAULT EXPORT
// =============================================================================

export default HomeMapper;

