// ============================================================================
// Home Screen Quick Start Navigation Tests — Sprint-18 Part 1
// Tests that "Bắt đầu ngay" button on home navigates to a valid drill.
// Regression for: BT01 not resolved to BT01.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/core/utils/drills_library.dart';
import 'package:pool_os_v2/knowledge/drill_code_bridge.dart';

void main() {
  group('Home Quick Start Drill Code Resolution', () {
    test('BT01 resolves to BT01 (V1 → V2)', () {
      final resolved = resolveDrillCode('BT01');
      expect(resolved, equals('BT01'));
    });

    test('BT01 passes through unchanged', () {
      final resolved = resolveDrillCode('BT01');
      expect(resolved, equals('BT01'));
    });

    test('STRAIGHT base resolves to BT01', () {
      final resolved = resolveDrillCode('STRAIGHT');
      expect(resolved, equals('BT01'));
    });

    test('BT07 passes through (already V2)', () {
      final resolved = resolveDrillCode('BT07');
      expect(resolved, equals('BT07'));
    });

    test('STOP resolves to BT07 (V1 → V2)', () {
      final resolved = resolveDrillCode('STOP');
      expect(resolved, equals('BT07'));
    });

    test('BT07 passes through (already V2)', () {
      final resolved = resolveDrillCode('BT07');
      expect(resolved, equals('BT07'));
    });

    test('DRAW resolves to BT07 (V1 → V2)', () {
      final resolved = resolveDrillCode('DRAW');
      expect(resolved, equals('BT07'));
    });

    test('Unknown code returns null (navigation falls back gracefully)', () {
      final resolved = resolveDrillCode('UNKNOWN_CODE');
      expect(resolved, isNull);
    });
  });

  group('Resolved drill code exists in DrillLibrary', () {
    test('BT01 → BT01 is found in DrillLibrary', () {
      final resolved = resolveDrillCode('BT01')!;
      final drill = DrillLibrary.getDrill(resolved);
      expect(drill, isNotNull);
      expect(drill!.code, equals('BT01'));
    });

    test('All V2 codes resolve to valid drills', () {
      final v2Codes = ['BT01', 'BT07', 'BT07', 'BT07'];
      for (final code in v2Codes) {
        final drill = DrillLibrary.getDrill(code);
        expect(drill, isNotNull, reason: '$code should exist in DrillLibrary');
      }
    });

    test('All V1→V2 mapped codes resolve to valid drills', () {
      final mappings = {
        'STOP': 'BT07',
        'DRAW': 'BT07',
        'FOLLOW': 'BT07',
        'STRAIGHT': 'BT01',
        'POSITION': 'BT09',
        'SAFETY': 'BT10',
        'BASIC': 'BT01',
      };
      for (final entry in mappings.entries) {
        final resolved = resolveDrillCode(entry.key)!;
        expect(resolved, equals(entry.value));
        final drill = DrillLibrary.getDrill(resolved);
        expect(drill, isNotNull, reason: '${entry.key} → $resolved should exist');
      }
    });
  });
}
