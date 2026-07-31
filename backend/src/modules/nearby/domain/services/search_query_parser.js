/**
 * SearchQueryParser — Decoupled Smart Search Query Parser
 *
 * Extracts structured intent, category, and attribute tags from natural language
 * queries like:
 *   "Best Veg Restaurant near me" → { category: 'food', tags: ['veg'], keywords: ['restaurant'] }
 *   "Family friendly fort for sunset" → { category: 'heritage', tags: ['familyFriendly', 'sunset', 'photography'], keywords: ['fort'] }
 *   "Budget AC hotel" → { category: 'hotels', tags: ['budget', 'ac', 'indoor'], keywords: ['hotel'] }
 */
export class SearchQueryParser {
  /**
   * Keyword mappings to categories & attribute tags
   */
  static CATEGORY_KEYWORDS = {
    heritage: ['fort', 'palace', 'monument', 'museum', 'ruins', 'heritage', 'castle', 'temple'],
    food: ['restaurant', 'food', 'cafe', 'dhaba', 'bakery', 'coffee', 'tea', 'diner', 'eatery', 'sweets'],
    hotels: ['hotel', 'stay', 'resort', 'hostel', 'room', 'lodging', 'guesthouse'],
    emergency: ['hospital', 'police', 'doctor', 'clinic', 'pharmacy', 'chemist', 'ambulance', 'fire'],
    temples: ['temple', 'mandir', 'mosque', 'gurudwara', 'church', 'shrine'],
    parks: ['park', 'garden', 'lake', 'nature', 'zoo', 'playground'],
    shopping: ['mall', 'market', 'bazaar', 'shop', 'shopping', 'store'],
    fuel: ['fuel', 'petrol', 'diesel', 'cng', 'ev', 'charging', 'gas'],
  };

  static TAG_KEYWORDS = {
    familyFriendly: ['family', 'kids', 'children', 'everyone'],
    veg: ['veg', 'vegetarian', 'vegan', 'pure veg'],
    budget: ['budget', 'cheap', 'affordable', 'low cost'],
    sunset: ['sunset', 'viewpoint', 'scenic', 'view'],
    romantic: ['romantic', 'couple', 'date'],
    photography: ['photo', 'photography', 'instagram', 'scenic'],
    indoor: ['indoor', 'museum', 'ac', 'air conditioned'],
    ac: ['ac', 'aircon', 'air conditioned'],
    petFriendly: ['pet', 'dog', 'animal'],
  };

  /**
   * Parses a raw query string into a structured query intent object.
   * @param {string} rawQuery User search string
   * @returns {{
   *   rawQuery: string,
   *   inferredCategory: string,
   *   detectedTags: string[],
   *   cleanKeywords: string[]
   * }}
   */
  parse(rawQuery) {
    if (!rawQuery || typeof rawQuery !== 'string') {
      return { rawQuery: '', inferredCategory: 'all', detectedTags: [], cleanKeywords: [] };
    }

    const normalized = rawQuery.toLowerCase().trim();
    const words = normalized.split(/\s+/);

    let inferredCategory = 'all';
    const detectedTags = new Set();
    const matchedWords = new Set();

    // ── 1. Detect Category ──────────────────────────────────────────────────
    for (const [cat, keywords] of Object.entries(SearchQueryParser.CATEGORY_KEYWORDS)) {
      for (const kw of keywords) {
        if (normalized.includes(kw)) {
          inferredCategory = cat;
          matchedWords.add(kw);
          break;
        }
      }
      if (inferredCategory !== 'all') break;
    }

    // ── 2. Detect Attribute Tags ───────────────────────────────────────────
    for (const [tag, tagKws] of Object.entries(SearchQueryParser.TAG_KEYWORDS)) {
      for (const kw of tagKws) {
        if (normalized.includes(kw)) {
          detectedTags.add(tag);
          matchedWords.add(kw);
        }
      }
    }

    // ── 3. Extract remaining clean search keywords ─────────────────────────
    const stopWords = new Set(['near', 'me', 'best', 'top', 'good', 'find', 'search', 'for', 'in', 'around', 'a', 'the']);
    const cleanKeywords = words.filter(
      (w) => !stopWords.has(w) && !matchedWords.has(w) && w.length > 2
    );

    return {
      rawQuery,
      inferredCategory,
      detectedTags: Array.from(detectedTags),
      cleanKeywords,
    };
  }
}
