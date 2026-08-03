// ============================================================================
// tag_mapper.dart — V1 free-form tag → V2 tagId
// ============================================================================
//
// Sprint 1, Commit 2.
//
// Per spec Section 2.4:
//   - fundamentals  → tag_basic
//   - stroke        → tag_technique
//   - beginner      → tag_basic
//   - intermediate  → tag_intermediate
//   - advanced      → tag_advanced
//   - expert        → tag_expert
//   - aiming        → tag_aiming
//   - position, positioning, cueball → tag_positioning
//   - strategy      → tag_strategy
//   - safety, defense → tag_defense
//   - power         → tag_speed
//   - consistency   → tag_technique
//   - precision     → tag_accuracy
//   - basics        → tag_basic
//
// Unmapped tags return null. They are NOT added to tagIds but the
// unmapped tag is recorded as a warning in the migration report.
// ============================================================================

class TagMapper {
  /// Returns V2 tagId for a V1 tag, or null if unmapped.
  static String? map(String v1Tag) {
    switch (v1Tag.toLowerCase().trim()) {
      case 'fundamentals':
      case 'basics':
      case 'beginner':
        return 'tag_basic';
      case 'intermediate':
        return 'tag_intermediate';
      case 'advanced':
        return 'tag_advanced';
      case 'expert':
        return 'tag_expert';
      case 'stroke':
      case 'technique':
      case 'consistency':
      case 'mechanics':
        return 'tag_technique';
      case 'aiming':
      case 'aim':
        return 'tag_aiming';
      case 'position':
      case 'positioning':
      case 'cueball':
        return 'tag_positioning';
      case 'strategy':
      case 'tactics':
        return 'tag_strategy';
      case 'safety':
      case 'defense':
      case 'defensive':
        return 'tag_defense';
      case 'power':
      case 'speed':
        return 'tag_speed';
      case 'precision':
      case 'accuracy':
        return 'tag_accuracy';
      case 'mental':
      case 'psychology':
      case 'concentration':
        return 'tag_strategy';
      case 'cueball control':
        return 'tag_cueball';
      case 'stun':
      case 'stop':
        return 'tag_cueball';
      case 'follow':
        return 'tag_topspin';
      case 'draw':
      case 'backspin':
        return 'tag_backspin';
      default:
        return null;
    }
  }

  /// Map a list of V1 tags to V2 tagIds. Unmapped tags are dropped
  /// and recorded in `unmapped`.
  static TagMapResult mapAll(List<String> v1Tags) {
    final ids = <String>[];
    final unmapped = <String>[];
    final seen = <String>{};

    for (final t in v1Tags) {
      final id = map(t);
      if (id == null) {
        unmapped.add(t);
      } else if (seen.add(id)) {
        ids.add(id);
      }
    }
    return TagMapResult(ids: ids, unmapped: unmapped);
  }
}

class TagMapResult {
  TagMapResult({required this.ids, required this.unmapped});

  final List<String> ids;
  final List<String> unmapped;
}