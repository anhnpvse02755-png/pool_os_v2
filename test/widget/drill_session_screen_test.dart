// ============================================================================
// drill_session_screen_test.dart
// ----------------------------------------------------------------------------
// Sprint-17 Part 6 — Training UX smoke test.
//
// Tests verify:
//   (1) DrillSessionScreen mounts without crash,
//   (2) No instructions view (removed in Part 6),
//   (3) No FAB start button (removed in Part 6),
//   (4) Active session UI with recording buttons shown.
//
// Widget under test is DrillSessionScreen
// (lib/presentation/screens/training/drill_session_screen.dart).
//
// Sprint-17 Part 6: User goes directly to recording UI after confirming
// repetitions. No intermediate start screen.
//
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pool_os_v2/core/services/local_storage_service.dart';
import 'package:pool_os_v2/presentation/screens/training/drill_session_screen.dart';
import 'package:pool_os_v2/core/providers/repository_providers.dart' as repo;
import 'package:pool_os_v2/data/repositories/drill_session_repository.dart';
import 'package:pool_os_v2/data/repositories/player_repository.dart'
    as player_repo;
import 'package:pool_os_v2/data/models/drill_session.dart';
import 'package:pool_os_v2/data/models/drill_attempt.dart';
import 'package:pool_os_v2/data/models/player.dart';
import 'package:pool_os_v2/core/models/training_session.dart' hide DrillRun;

/// Minimal fake for drill session repository
class FakeDrillSessionRepository implements IDrillSessionRepository {
  @override
  Future<DrillSession?> getActiveSession(String playerId) async => null;

  @override
  Future<List<DrillSession>> getAll(String playerId) async => [];

  @override
  Future<DrillSession?> getById(String id) async => null;

  @override
  Future<void> save(DrillSession session) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> addAttempt(DrillAttempt attempt) async {}

  @override
  Future<void> updateRun(DrillRun run) async {}
}

/// Fake player repository for testing
class FakePlayerRepository implements player_repo.PlayerRepository {
  @override
  Future<Player?> getCurrentPlayer() async => Player(
        id: 'test-player',
        name: 'Test User',
        currentLevel: 'B',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  testWidgets('DrillSessionScreen mounts with active session UI (Part 6)',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repo.drillSessionRepositoryProvider.overrideWithValue(FakeDrillSessionRepository()),
          repo.playerRepositoryProvider.overrideWithValue(FakePlayerRepository()),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/training/session/new?drill=STRAIGHT_NEAR&level=1&target=10',
            routes: [
              GoRoute(
                path: '/training/session/new',
                builder: (context, state) => DrillSessionScreen(
                  drillCode: state.uri.queryParameters['drill'] ?? 'STRAIGHT_NEAR',
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Allow async flutter_animate tweens to settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Assertion 1: screen is reachable.
    expect(find.byType(DrillSessionScreen), findsOneWidget);

    // Assertion 2: Drill name in AppBar.
    expect(find.text('Đánh thẳng gần'), findsOneWidget,
        reason: 'drill name should appear in AppBar');

    // Assertion 3: Sprint-17 Part 6 — NO FAB start button.
    expect(find.byType(FloatingActionButton), findsNothing,
        reason: 'FAB removed in Part 6');

    // Assertion 4: Sprint-17 Part 6 — Recording buttons shown.
    expect(find.widgetWithText(ElevatedButton, 'Thành công'), findsOneWidget,
        reason: 'Success button should appear');
    expect(find.widgetWithText(ElevatedButton, 'Trượt'), findsOneWidget,
        reason: 'Failure button should appear');
  });
}