// ============================================================================
// category_mapper.dart — V1 free-form category → V2 categoryId
// ============================================================================
//
// Sprint 1, Commit 2.
//
// V1 categories are free-form strings. V2 categories live in
// assets/knowledge/categories.json with strict IDs.
//
// Per spec Section 2.2:
//   - stroke              → cat_fundamentals
//   - aiming, aim         → cat_aiming
//   - cueball             → cat_positioning
//   - strategy            → cat_strategy
//   - safety, safety_play → cat_strategy
//   - bridge              → cat_fundamentals
//   - pattern             → cat_strategy
//   - mental              → cat_psychology
//   - equipment           → cat_equipment
//   - rules               → cat_rules
//   - spin                → cat_positioning
//   - mistake             → (no mapping → null)
//
// Unmapped categories return null; the article is SKIPPED with
// reason "no V2 category mapping for {category}".
// ============================================================================

class CategoryMapper {
  /// Returns V2 categoryId for a V1 category, or null if unmapped.
  static String? map(String v1Category) {
    switch (v1Category.toLowerCase().trim()) {
      case 'stroke':
      case 'bridge':
      case 'fundamentals':
      case 'stance':
      case 'grip':
        return 'cat_fundamentals';
      case 'aiming':
      case 'aim':
        return 'cat_aiming';
      case 'cueball':
      case 'cue ball control':
      case 'positioning':
      case 'position':
      case 'spin':
        return 'cat_positioning';
      case 'strategy':
      case 'pattern':
      case 'pattern_play':
      case 'safety':
      case 'safety_play':
        return 'cat_strategy';
      case 'mental':
        return 'cat_psychology';
      case 'equipment':
        return 'cat_equipment';
      case 'rules':
        return 'cat_rules';
      default:
        return null;
    }
  }

  /// True if the V1 category has a V2 mapping.
  static bool isMapped(String v1Category) =>
      map(v1Category) != null;
}