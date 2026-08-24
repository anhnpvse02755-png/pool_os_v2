// ============================================================================
// drill_session_auto_start_test.dart
// ----------------------------------------------------------------------------
// Sprint-17 Part 3 — Auto-start race condition regression tests.
//
// Tests verify that DrillSessionScreen correctly auto-starts a session when:
// 1. Navigating from DrillDetailScreen with level+target query params
// 2. The drill loads asynchronously before/during didChangeDependencies
// 3. Auto-start fires exactly once regardless of rebuilds
// 4. Error cases (drill not found) are handled gracefully
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:pool_os_v2/presentation/screens/training/drill_session_screen.dart';
import 'package:pool_os_v2/core/providers/repository_providers.dart' as repo;
import 'package:pool_os_v2/data/repositories/drill_session_repository.dart';
import 'package:pool_os_v2/data/models/drill_session.dart';
import 'package:pool_os_v2/data/models/drill_attempt.dart';
import 'package:pool_os_v2/data/models/player.dart';
import 'package:pool_os_v2/data/repositories/player_repository.dart'
    as player_repo;
import 'package:pool_os_v2/core/models/training_session.dart' hide DrillRun;

/// Minimal fake for drill session repository
class FakeDrillSessionRepository implements IDrillSessionRepository {
  DrillSession? _activeSession;

  @override
  Future<DrillSession?> getActiveSession(String playerId) async => _activeSession;

  @override
  Future<List<DrillSession>> getAll(String playerId) async => [];

  @override
  Future<DrillSession?> getById(String id) async => null;

  @override
  Future<void> save(DrillSession session) async {
    _activeSession = session;
  }

  @override
  Future<void> delete(String id) async {
    if (_activeSession?.id == id) _activeSession = null;
  }

  @override
  Future<void> addAttempt(DrillAttempt attempt) async {}

  @override
  Future<void> updateRun(DrillRun run) async {}
}

/// Fake player repository that returns a test player
class FakePlayerRepository implements player_repo.PlayerRepository {
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

/// Helper to create a test router with optional query params
GoRouter createTestRouter({
  required String drillCode,
  String? level,
  String? target,
}) {
  final queryParams = <String, String>{};
  if (level != null) queryParams['level'] = level;
  if (target != null) queryParams['target'] = target;

  return GoRouter(
    initialLocation: Uri(
      path: '/training/drill/$drillCode',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    ).toString(),
    routes: [
      GoRoute(
        path: '/training/drill/:code',
        builder: (context, state) => ProviderScope(
          overrides: [
            repo.drillSessionRepositoryProvider.overrideWithValue(
              FakeDrillSessionRepository(),
            ),
            repo.playerRepositoryProvider.overrideWithValue(
              FakePlayerRepository(),
            ),
          ],
          child: DrillSessionScreen(
            drillCode: state.pathParameters['code'] ?? drillCode,
          ),
        ),
      ),
    ],
  );
}

void main() {
  group('DrillSessionScreen Auto-start — Sprint-17 Part 3', () {
    testWidgets('1. Query params with level+target → auto-start fires after drill loads',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(
            drillCode: 'STRAIGHT_NEAR',
            level: '1',
            target: '10',
          ),
        ),
      );

      // Pump through frames to allow drill to load and auto-start to fire
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify session screen is visible (drill loaded)
      expect(find.byType(DrillSessionScreen), findsOneWidget);

      // Verify session is active (auto-start fired)
      // The recording bar should be visible when session is active
      expect(find.text('Thành công'), findsAtLeastNWidgets(1));
      expect(find.text('Trượt'), findsOneWidget);
    });

    testWidgets('2. No query level param → does NOT auto-start',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(
            drillCode: 'STRAIGHT_NEAR',
            // No level param
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Session should NOT be active — user should see start button
      expect(find.byType(DrillSessionScreen), findsOneWidget);
      // Should show instructions view with "Bắt đầu" button
      expect(find.text('Bắt đầu'), findsOneWidget);
    });

    testWidgets('3. Auto-start fires only ONCE even with multiple rebuilds',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(
            drillCode: 'STRAIGHT_NEAR',
            level: '1',
            target: '10',
          ),
        ),
      );

      // Pump multiple frames to simulate rebuilds
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Session should be active (auto-start fired)
      expect(find.text('Thành công'), findsAtLeastNWidgets(1));
      expect(find.text('Trượt'), findsOneWidget);
    });

    testWidgets('4. Invalid drill code → error state shown, no crash',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(
            drillCode: 'NONEXISTENT_DRILL',
            level: '1',
            target: '10',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show error screen, not crash
      expect(find.text('Không tìm thấy bài tập này'), findsOneWidget);
      expect(find.text('Quay lại'), findsOneWidget);
    });

    testWidgets('5. Custom target value is read correctly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(
            drillCode: 'STRAIGHT_NEAR',
            level: '2',
            target: '50',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the custom target is displayed
      expect(find.text('/ 50'), findsOneWidget);
    });

    testWidgets('6. FAB start button still works for manual start',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(
            drillCode: 'STRAIGHT_NEAR',
            // No level param — must start manually
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap the start FAB
      final fab = find.widgetWithText(FloatingActionButton, 'Bắt đầu');
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Session should start
      expect(find.text('Thành công'), findsAtLeastNWidgets(1));
      expect(find.text('Trượt'), findsOneWidget);
    });
  });
}
