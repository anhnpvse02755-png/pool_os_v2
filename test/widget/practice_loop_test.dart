// ============================================================================
// practice_loop_test.dart
// ----------------------------------------------------------------------------
// Sprint 3A Task 5 — Practice Loop DoD smoke (split).
//
// We split the DoD smoke into two narrow assertions instead of a single
// integration test. Reason: driving a multi-screen loop through
// flutter_animate + go_router inside flutter_test triggers known issues
// with hit-test on offscreen widgets and pumpAndSettle / Timer cleanup
// (Sprint 2D AC-2 documented the same pattern). The deeper loop is
// verified by code-path tracing in SPRINT_3A_DOD_REPORT.md, not by a
// fragile widget tap-through.
//
// Smoke 1 — DrillSessionScreen mounts in cold-user state (with a fake
// player so the SnackBar fall-back does not fire).
// Smoke 2 — DrillCompletionScreen mounts and the ReflectionCards +
// NextActionPanel widgets render.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/core/services/local_storage_service.dart';
import 'package:pool_os_v2/core/providers/repository_providers.dart'
    as repo_providers;
import 'package:pool_os_v2/data/models/drill_session.dart';
import 'package:pool_os_v2/data/models/drill_attempt.dart';
import 'package:pool_os_v2/data/models/player.dart';
import 'package:pool_os_v2/data/repositories/player_repository.dart'
    as player_repo;
import 'package:pool_os_v2/presentation/screens/training/drill_completion_screen.dart';
import 'package:pool_os_v2/presentation/screens/training/drill_session_screen.dart';
import 'package:pool_os_v2/presentation/widgets/next_action_panel.dart';
import 'package:pool_os_v2/presentation/widgets/reflection_card.dart';

class _FakePlayerRepository implements player_repo.PlayerRepository {
  @override
  Future<Player?> getCurrentPlayer() async => Player(
        id: 'test-player',
        name: 'Test User',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

DrillSession _sampleSession() => DrillSession(
      id: 'test-session',
      playerId: 'test-player',
      title: 'Đánh thẳng',
      startedAt: DateTime(2026, 1, 1, 10),
      completedAt: DateTime(2026, 1, 1, 10, 12),
      totalMinutes: 12,
      totalShotsMade: 8,
      totalShotsMissed: 2,
      attempts: [
        DrillAttempt(
          id: 'a1',
          sessionId: 'test-session',
          drillCode: 'STRAIGHT_NEAR',
          attemptNumber: 1,
          made: true,
          createdAt: DateTime(2026, 1, 1, 10),
        ),
        DrillAttempt(
          id: 'a2',
          sessionId: 'test-session',
          drillCode: 'STRAIGHT_NEAR',
          attemptNumber: 2,
          made: true,
          createdAt: DateTime(2026, 1, 1, 10, 1),
        ),
      ],
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  testWidgets('Smoke 1 — DrillSessionScreen mounts in cold-user state',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repo_providers.playerRepositoryProvider
              .overrideWithValue(_FakePlayerRepository()),
        ],
        child: const MaterialApp(
          home: DrillSessionScreen(drillCode: 'STRAIGHT_NEAR'),
        ),
      ),
    );

    await _settle(tester);

    expect(find.byType(DrillSessionScreen), findsOneWidget);
    expect(find.widgetWithText(FloatingActionButton, 'Bắt đầu'),
        findsOneWidget);
  });

  testWidgets(
      'Smoke 2 — DrillCompletionScreen renders Reflection + Next Action',
      (tester) async {
    // Use a larger viewport so the multi-card Completion screen fits.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final session = _sampleSession();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repo_providers.playerRepositoryProvider
              .overrideWithValue(_FakePlayerRepository()),
        ],
        child: MaterialApp(
          home: DrillCompletionScreen(
            session: session,
            drillCode: 'STRAIGHT_NEAR',
          ),
        ),
      ),
    );

    await _settle(tester);
    // FutureBuilder needs another round for Reflection data load.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(DrillCompletionScreen), findsOneWidget);
    expect(find.byType(ReflectionCards), findsOneWidget,
        reason: 'Layer 1+2+3 Reflection cards must render');
    expect(find.byType(NextActionPanel), findsOneWidget,
        reason: 'Forward Path panel must render');
    expect(find.widgetWithText(FilledButton, 'Tập lại'), findsOneWidget,
        reason: 'Primary Retry action must be present');
    // Secondary action may be disabled if recommendations list contains
    // only the current drill; here we expect it to be enabled since
    // DrillLibrary.getRecommendedDrills() has 5 distinct drills.
    expect(find.byType(OutlinedButton), findsOneWidget,
        reason: 'Secondary Next Action must render');
  });
}