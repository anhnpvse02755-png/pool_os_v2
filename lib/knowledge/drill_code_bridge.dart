// ============================================================================
// drill_code_bridge.dart — V1 drill code → V2 DrillLibrary code
//
// V1 knowledge articles (10 live + 100 migrated) reference V1-era drill codes
// with _LV suffix (e.g. STOP_LV1). V2 DrillLibrary uses different codes
// (e.g. STOP_BALL). This bridge resolves them at navigation time so callers
// don't need to rewrite article payloads.
//
// V1 base → V2 mapping (verified against DrillLibrary.codes):
//   STOP       → STOP_BALL
//   DRAW       → DRAW_SHOT
//   FOLLOW     → FOLLOW_SHOT
//   STRAIGHT   → STRAIGHT_NEAR
//   POSITION   → POSITION_BASIC
//   SAFETY     → SAFETY_BASIC
//   BASIC      → STRAIGHT_NEAR   (BASIC_LV1 maps to closest beginner drill)
//
// Codes already in V2 form pass through unchanged. Codes that cannot be
// mapped return null so the UI can fall back gracefully (no navigation).
// ============================================================================

import '../core/utils/drills_library.dart';

/// Returns the V2 DrillLibrary code for a V1 code (with or without _LV suffix).
/// Returns null if no V2 equivalent is defined.
String? v1ToV2Code(String v1Code) {
  // Strip any _LV* suffix (case-insensitive).
  final base = v1Code.replaceFirst(RegExp(r'_LV\d+$', caseSensitive: false), '').toUpperCase();
  switch (base) {
    case 'STOP':
      return 'STOP_BALL';
    case 'DRAW':
      return 'DRAW_SHOT';
    case 'FOLLOW':
      return 'FOLLOW_SHOT';
    case 'STRAIGHT':
    case 'STRAIGHT_POT':  // Sprint-18: knowledge graph uses STRAIGHT_POT
    case 'STRAIGHT_NEAR': // already V2 but pass through
      return 'STRAIGHT_NEAR';
    case 'POSITION':
      return 'POSITION_BASIC';
    case 'SAFETY':
      return 'SAFETY_BASIC';
    case 'BASIC':
      return 'STRAIGHT_NEAR';
    default:
      return null;
  }
}

/// Resolves any drill code (V1 or V2) to a V2 DrillLibrary code.
/// Returns null if the code cannot be mapped.
String? resolveDrillCode(String code) {
  // Pass-through if already a known V2 code.
  if (DrillLibrary.getDrill(code) != null) return code;
  // Try V1 → V2 mapping.
  return v1ToV2Code(code);
}

/// Resolves a list of drill codes (mixed V1/V2) to V2 codes, deduped,
/// preserving first-occurrence order.
List<String> resolveDrillCodes(List<String> codes) {
  final seen = <String>{};
  final out = <String>[];
  for (final c in codes) {
    final resolved = resolveDrillCode(c);
    if (resolved != null && seen.add(resolved)) {
      out.add(resolved);
    }
  }
  return out;
}
