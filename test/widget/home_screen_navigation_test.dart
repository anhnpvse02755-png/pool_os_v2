// ============================================================================
// Home Screen Quick Start Navigation Tests — Sprint-18 Part 1
// Tests that "Bắt đầu ngay" button on home navigates to a valid drill.
// Regression for: STRAIGHT_POT not resolved to STRAIGHT_NEAR.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/core/utils/drills_library.dart';
import 'package:pool_os_v2/knowledge/drill_code_bridge.dart';

void main() {
  group('Home Quick Start Drill Code Resolution', () {
    test('STRAIGHT_POT resolves to STRAIGHT_NEAR (V1 → V2)', () {
      final resolved = resolveDrillCode('STRAIGHT_POT');
      expect(resolved, equals('STRAIGHT_NEAR'));
    });

    test('STRAIGHT_NEAR passes through unchanged', () {
      final resolved = resolveDrillCode('STRAIGHT_NEAR');
      expect(resolved, equals('STRAIGHT_NEAR'));
    });

    test('STRAIGHT base resolves to STRAIGHT_NEAR', () {
      final resolved = resolveDrillCode('STRAIGHT');
      expect(resolved, equals('STRAIGHT_NEAR'));
    });

    test('STOP_BALL passes through (already V2)', () {
      final resolved = resolveDrillCode('STOP_BALL');
      expect(resolved, equals('STOP_BALL'));
    });

    test('STOP resolves to STOP_BALL (V1 → V2)', () {
      final resolved = resolveDrillCode('STOP');
      expect(resolved, equals('STOP_BALL'));
    });

    test('DRAW_SHOT passes through (already V2)', () {
      final resolved = resolveDrillCode('DRAW_SHOT');
      expect(resolved, equals('DRAW_SHOT'));
    });

    test('DRAW resolves to DRAW_SHOT (V1 → V2)', () {
      final resolved = resolveDrillCode('DRAW');
      expect(resolved, equals('DRAW_SHOT'));
    });

    test('Unknown code returns null (navigation falls back gracefully)', () {
      final resolved = resolveDrillCode('UNKNOWN_CODE');
      expect(resolved, isNull);
    });
  });

  group('Resolved drill code exists in DrillLibrary', () {
    test('STRAIGHT_POT → STRAIGHT_NEAR is found in DrillLibrary', () {
      final resolved = resolveDrillCode('STRAIGHT_POT')!;
      final drill = DrillLibrary.getDrill(resolved);
      expect(drill, isNotNull);
      expect(drill!.code, equals('STRAIGHT_NEAR'));
    });

    test('All V2 codes resolve to valid drills', () {
      final v2Codes = ['STRAIGHT_NEAR', 'STOP_BALL', 'DRAW_SHOT', 'FOLLOW_SHOT'];
      for (final code in v2Codes) {
        final drill = DrillLibrary.getDrill(code);
        expect(drill, isNotNull, reason: '$code should exist in DrillLibrary');
      }
    });

    test('All V1→V2 mapped codes resolve to valid drills', () {
      final mappings = {
        'STOP': 'STOP_BALL',
        'DRAW': 'DRAW_SHOT',
        'FOLLOW': 'FOLLOW_SHOT',
        'STRAIGHT': 'STRAIGHT_NEAR',
        'POSITION': 'POSITION_BASIC',
        'SAFETY': 'SAFETY_BASIC',
        'BASIC': 'STRAIGHT_NEAR',
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
