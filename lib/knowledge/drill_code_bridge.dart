// ============================================================================
// drill_code_bridge.dart — V1 drill code → V2 DrillLibrary code
//
// V1 knowledge articles (10 live + 100 migrated) reference V1-era drill codes
// with _LV suffix (e.g. STOP_LV1). V2 DrillLibrary uses numbered codes
// (e.g. BT07). This bridge resolves them at navigation time so callers
// don't need to rewrite article payloads.
//
// (Dong tren tung ghi "e.g. BT07" o CA HAI ve — di chung cua cung mot lan
// thay the hang loat da lam ba bai Stop/Follow/Draw dinh chung ma BT07.)
//
// V1 base → V2 mapping (doi chieu voi DrillLibrary sinh tu
// `new knowledge/Danh-Sach-Bai-Tap-Billiard.md`):
//   STOP → BT07 · FOLLOW → BT08 · DRAW → BT09  (ba bai rieng, cung cu ly)
//   STRAIGHT / BASIC     → BT01  (cam co & day co thang)
//   POSITION             → BT11  (vi tri 3 bi lien tiep)
//   SAFETY               → BT12  (safety co ban)
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
    case 'FOLLOW':
      return 'BT08';
    case 'DRAW':
      return 'BT09';
    case 'STRAIGHT':
    case 'BT01':
      return 'BT01';
    case 'POSITION':
      return 'BT11';
    case 'SAFETY':
      return 'BT12';
    case 'BASIC':
      return 'BT01';

    // ── Mã DrillNode của knowledge graph ────────────────────────────────
    //
    // Buổi tập hôm nay đề xuất bài theo các mã này. Thiếu chúng thì nút
    // "Bắt đầu buổi tập" đưa người dùng tới màn lỗi — xem
    // `test/knowledge/drill_code_bridge_coverage_test.dart`, test đó bắt
    // buộc MỌI DrillNode phải có đích đến.
    case 'STUN_SHOT':
      return 'BT07'; // bi cái dừng — chính là bài Stop
    case 'THIN_CUT':
      return 'BT05'; // cắt mỏng <30° — ngắm bi sát băng & bi góc lệch
    case 'THICK_CUT':
      return 'BT03'; // cắt dày >45° — ngắm bi ảo theo góc tăng dần
    case 'BANK_SHOT':
      return 'BT16';
    case 'KICK_SHOT':
      return 'BT15';
    case 'SAFETY_PLAY':
      return 'BT12';
    case 'BREAK_SHOT':
      return 'BT06';
    case 'POSITION_CONTROL':
      return 'BT11';
    case 'RUN_OUT':
      return 'BT13';
    case 'SPEED_CONTROL':
      return 'BT19';
    case 'ESCAPING':
      return 'BT15'; // thoát kẹt bi đi bằng kick shot một băng

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
