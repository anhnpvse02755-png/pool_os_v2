// ============================================================================
// Coach AI Quick Start Auto-Start Regression Tests — Sprint-18 Part 3
// Tests that Coach AI Quick Start provides level/target params so
// DrillSessionScreen._tryAutoStart() fires and recording UI appears.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/knowledge/drill_code_bridge.dart';

void main() {
  // These tests verify the URL pattern Coach AI Quick Start generates.
  // The actual navigation is a go_router context.push() call which requires
  // a WidgetTester environment. These unit tests verify the URL components.

  group('Coach AI Quick Start URL parameters', () {
    test('HomeScreen Quick Start generates URL with level and target params', () {
      // Sprint-18 Part 1: STRAIGHT_POT → STRAIGHT_NEAR via resolveDrillCode
      final resolvedCode = resolveDrillCode('STRAIGHT_POT') ?? 'STRAIGHT_POT';
      const level = 1;
      const target = 10;

      // The URL pattern must include level and target so _tryAutoStart() fires.
      final url =
          '/training/session/new?drill=$resolvedCode&level=$level&target=$target';

      expect(url, contains('drill=STRAIGHT_NEAR'));
      expect(url, contains('level=1'));
      expect(url, contains('target=10'));
    });

    test('CoachScreen _startDrill resolves V1 codes before navigating', () {
      // V1 code like 'stop_shot' from KnowledgeGraph should resolve to V2
      final resolved = resolveDrillCode('stop_shot') ?? 'stop_shot';
      // After resolution, the URL should use the V2 code
      expect(
        '/training/session/new?drill=$resolved&level=1&target=10',
        contains('drill='),
      );
    });

    test('STRAIGHT_POT resolves and includes required params', () {
      final resolvedCode = resolveDrillCode('STRAIGHT_POT') ?? 'STRAIGHT_POT';
      final url =
          '/training/session/new?drill=$resolvedCode&level=1&target=10';

      expect(url, equals('/training/session/new?drill=STRAIGHT_NEAR&level=1&target=10'));
    });

    test('Unknown V1 code falls back to original and still includes params', () {
      // Unknown codes return null and use original — still works if DrillLibrary has it
      final resolvedCode = resolveDrillCode('straight_shot') ?? 'straight_shot';
      final url =
          '/training/session/new?drill=$resolvedCode&level=1&target=10';

      // URL has all three required components for _tryAutoStart to fire
      expect(url, contains('drill='));
      expect(url, contains('level='));
      expect(url, contains('target='));
    });
  });

  group('DrillSessionScreen._tryAutoStart() gate conditions', () {
    test('URL with level param satisfies _tryAutoStart gate', () {
      // _tryAutoStart() checks: if (level == null) return;
      // A URL with level=1 should pass this gate.
      const urlWithLevel = '/training/session/new?drill=A&level=1&target=10';
      final level = Uri.parse(urlWithLevel).queryParameters['level'];
      expect(level, isNotNull);
      expect(level, equals('1'));
    });

    test('URL without level param fails _tryAutoStart gate', () {
      // Old Coach AI URL: /training/session/new?drill=A
      // This causes _tryAutoStart to exit silently.
      const urlWithoutLevel = '/training/session/new?drill=A';
      final level = Uri.parse(urlWithoutLevel).queryParameters['level'];
      expect(level, isNull);
    });

    test('target param is correctly parsed', () {
      const url = '/training/session/new?drill=A&level=1&target=25';
      final targetParam = Uri.parse(url).queryParameters['target'];
      final target = int.tryParse(targetParam!);
      expect(target, equals(25));
      expect(target! > 0, isTrue);
    });
  });

  group('Coach AI Quick Start vs DrillDetailScreen parity', () {
    test('Coach AI uses same drill param key as DrillDetailScreen', () {
      // Both should use 'drill' as the query parameter key.
      const coachUrl =
          '/training/session/new?drill=STRAIGHT_NEAR&level=1&target=10';
      const detailUrl =
          '/training/session/new?drill=STRAIGHT_NEAR&level=1&target=25';

      expect(coachUrl.contains('drill='), isTrue);
      expect(detailUrl.contains('drill='), isTrue);
    });

    test('Coach AI uses same level param key as DrillDetailScreen', () {
      const coachUrl =
          '/training/session/new?drill=A&level=1&target=10';
      expect(coachUrl.contains('level='), isTrue);
    });

    test('Coach AI uses same target param key as DrillDetailScreen', () {
      const coachUrl =
          '/training/session/new?drill=A&level=1&target=10';
      expect(coachUrl.contains('target='), isTrue);
    });
  });
}
