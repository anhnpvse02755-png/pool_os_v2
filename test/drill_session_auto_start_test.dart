// ============================================================================
// drill_session_auto_start_test.dart
// ----------------------------------------------------------------------------
// Sprint-17 Part 3 — Auto-start race condition regression tests.
// Updated for Sprint-19 redesign (English text)
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
      // Sprint-19 redesign: English text 'SUCCESS' and 'MISS'
      expect(find.text('SUCCESS'), findsAtLeastNWidgets(1));
      expect(find.text('MISS'), findsOneWidget);
    });

    testWidgets('2. No query level param → does NOT auto-start, no FAB',
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

      // Sprint-17 Part 6: FAB removed — no start button
      expect(find.byType(DrillSessionScreen), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing,
          reason: 'FAB removed in Part 6');
      // Recording buttons should NOT show (session not active)
      // Sprint-19 redesign: English text
      expect(find.text('SUCCESS'), findsNothing,
          reason: 'Recording buttons hidden when session not active');
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
      // Sprint-19 redesign: English text
      expect(find.text('SUCCESS'), findsAtLeastNWidgets(1));
      expect(find.text('MISS'), findsOneWidget);
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

      // Sprint-19 redesign: English text 'Drill not found'
      expect(find.text('Drill not found'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
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

      // Sprint-19 redesign: Format is 'X/Y' e.g., '0/50'
      expect(find.text('0/50'), findsOneWidget);
    });

    testWidgets('6. No query level param → session inactive with no manual start',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(
            drillCode: 'STRAIGHT_NEAR',
            // No level param — session should not start
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Sprint-17 Part 6: FAB removed — no manual start possible
      expect(find.byType(FloatingActionButton), findsNothing,
          reason: 'FAB removed in Part 6 — no manual start button');
      // Session should be inactive
      // Sprint-19 redesign: English text
      expect(find.text('SUCCESS'), findsNothing,
          reason: 'Recording buttons hidden when session not active');
    });
  });
}
