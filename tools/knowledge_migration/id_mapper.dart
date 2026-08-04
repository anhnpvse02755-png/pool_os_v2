// ============================================================================
// id_mapper.dart — V1 dotted id → V2 id + slug
// ============================================================================
//
// Sprint 1, Commit 2.
//
// V1 ids are dotted (`technique.stroke.fundamentals`). V2 preserves
// the dotted form (backward-compatible, easier diff). Slug is the
// dashed lowercase version.
//
// Rules:
//   - id  = V1 id (preserved verbatim).
//   - slug = id with all dots replaced by hyphens, lowercased.
//   - Example: 'technique.stroke.fundamentals' → slug 'technique-stroke-fundamentals'
// ============================================================================

class IdMapper {
  /// Derives a V2 slug from a V1 dotted id.
  static String deriveSlug(String v1Id) {
    return v1Id.replaceAll('.', '-').toLowerCase();
  }

  /// Sanity check: a V1 id must be non-empty, contain at least one
  /// dot, and only contain lowercase letters, digits, dots, and
  /// underscores.
  static bool isValidV1Id(String id) {
    if (id.isEmpty) return false;
    if (!id.contains('.')) return false;
    return RegExp(r'^[a-z0-9._]+$').hasMatch(id);
  }
}