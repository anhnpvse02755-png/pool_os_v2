// ============================================================================
// drill_code_bridge.dart — V1 drill code → V2 DrillLibrary code
//
// V1 knowledge articles (10 live + 100 migrated) reference V1-era drill codes
// with _LV suffix (e.g. BT07). V2 DrillLibrary uses different codes
// (e.g. BT07). This bridge resolves them at navigation time so callers
// don't need to rewrite article payloads.
//
// V1 base → V2 mapping (doi chieu voi DrillLibrary sinh tu
// `new knowledge/Danh-Sach-Bai-Tap-Billiard.md`):
//   STOP / DRAW / FOLLOW → BT07  (Stop – Follow – Draw cung cu ly)
//   STRAIGHT / BASIC     → BT01  (cam co & day co thang)
//   POSITION             → BT09  (vi tri 3 bi lien tiep)
//   SAFETY               → BT10  (safety co ban)
//   AIM / GHOST          → BT03  (ngam bi ao)
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
      return 'BT07';
    case 'DRAW':
      return 'BT07';
    case 'FOLLOW':
      return 'BT07';
    case 'STRAIGHT':
    case 'BT01':
      return 'BT01';
    case 'POSITION':
      return 'BT09';
    case 'SAFETY':
      return 'BT10';
    case 'BASIC':
      return 'BT01';
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
