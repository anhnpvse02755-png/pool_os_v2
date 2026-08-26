// ============================================================================
// drill_session_ux_test.dart
// ----------------------------------------------------------------------------
// Sprint-17 Part 6 — Training UX regression tests.
// Updated for Sprint-19 redesign (English text)
//
// Tests verify the streamlined training flow:
// - No redundant "Bắt đầu" FAB
// - No instructions screen intermediate step
// - User goes directly to recording UI after confirming repetitions
//
// Sprint-19: Redesigned with English text (SUCCESS/MISS)
//
// Flow:
// DrillDetailScreen → repetitions dialog → "Start X reps"
//   → DrillSessionScreen → active session UI (no intermediate steps)
//   → SUCCESS/MISS recording buttons
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pool_os_v2/core/services/local_storage_service.dart';
import 'package:pool_os_v2/core/providers/repository_providers.dart'
    as repo_providers;
import 'package:pool_os_v2/data/models/player.dart';
import 'package:pool_os_v2/data/repositories/player_repository.dart'
    as player_repo;
import 'package:pool_os_v2/presentation/screens/training/drill_session_screen.dart';

class _FakePlayerRepository implements player_repo.PlayerRepository {
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

class _FakePlayerRepositoryNull implements player_repo.PlayerRepository {
  @override
  Future<Player?> getCurrentPlayer() async => null;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  group('DrillSessionScreen UX — Sprint-17 Part 6 / Sprint-19 Redesign', () {
    testWidgets('1. No FAB when auto-starting', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repo_providers.playerRepositoryProvider
                .overrideWithValue(_FakePlayerRepository()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation:
                  '/training/session/new?drill=STRAIGHT_NEAR&level=1&target=10',
              routes: [
                GoRoute(
                  path: '/training/session/new',
                  builder: (context, state) => DrillSessionScreen(
                    drillCode:
                        state.uri.queryParameters['drill'] ?? 'STRAIGHT_NEAR',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await _settle(tester);

      // Sprint-17 Part 6: FAB should NOT exist
      expect(find.byType(FloatingActionButton), findsNothing,
          reason: 'FAB removed — no redundant start button');
    });

    testWidgets('2. SUCCESS button visible after auto-start', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repo_providers.playerRepositoryProvider
                .overrideWithValue(_FakePlayerRepository()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation:
                  '/training/session/new?drill=STRAIGHT_NEAR&level=1&target=10',
              routes: [
                GoRoute(
                  path: '/training/session/new',
                  builder: (context, state) => DrillSessionScreen(
                    drillCode:
                        state.uri.queryParameters['drill'] ?? 'STRAIGHT_NEAR',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await _settle(tester);

      // Sprint-19 redesign: SUCCESS button must render immediately
      expect(find.text('SUCCESS'), findsOneWidget,
          reason: 'SUCCESS button must appear immediately');
    });

    testWidgets('3. MISS button visible after auto-start', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repo_providers.playerRepositoryProvider
                .overrideWithValue(_FakePlayerRepository()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation:
                  '/training/session/new?drill=STRAIGHT_NEAR&level=1&target=10',
              routes: [
                GoRoute(
                  path: '/training/session/new',
                  builder: (context, state) => DrillSessionScreen(
                    drillCode:
                        state.uri.queryParameters['drill'] ?? 'STRAIGHT_NEAR',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await _settle(tester);

      // Sprint-19 redesign: MISS button must render immediately
      expect(find.text('MISS'), findsOneWidget,
          reason: 'MISS button must appear immediately');
    });

    testWidgets('4. Progress display shows target reps', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repo_providers.playerRepositoryProvider
                .overrideWithValue(_FakePlayerRepository()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation:
                  '/training/session/new?drill=STRAIGHT_NEAR&level=1&target=10',
              routes: [
                GoRoute(
                  path: '/training/session/new',
                  builder: (context, state) => DrillSessionScreen(
                    drillCode:
                        state.uri.queryParameters['drill'] ?? 'STRAIGHT_NEAR',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await _settle(tester);

      // Sprint-19 redesign: Progress shows format X/Y (e.g., '0/10')
      expect(find.text('0/10'), findsOneWidget,
          reason: 'Progress should show 0/10 reps');
    });

    testWidgets('5. Stop button visible when session active', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repo_providers.playerRepositoryProvider
                .overrideWithValue(_FakePlayerRepository()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation:
                  '/training/session/new?drill=STRAIGHT_NEAR&level=1&target=10',
              routes: [
                GoRoute(
                  path: '/training/session/new',
                  builder: (context, state) => DrillSessionScreen(
                    drillCode:
                        state.uri.queryParameters['drill'] ?? 'STRAIGHT_NEAR',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await _settle(tester);

      // Sprint-19 redesign: Stop button should be visible
      expect(find.text('Stop'), findsOneWidget,
          reason: 'Stop button must appear when active');
    });

    testWidgets('6. Session shows correct accuracy format', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repo_providers.playerRepositoryProvider
                .overrideWithValue(_FakePlayerRepository()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation:
                  '/training/session/new?drill=STRAIGHT_NEAR&level=1&target=10',
              routes: [
                GoRoute(
                  path: '/training/session/new',
                  builder: (context, state) => DrillSessionScreen(
                    drillCode:
                        state.uri.queryParameters['drill'] ?? 'STRAIGHT_NEAR',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await _settle(tester);

      // Sprint-19 redesign: Accuracy shows percentage format (0% initially)
      expect(find.text('0%'), findsOneWidget,
          reason: 'Accuracy should show 0% initially');
    });

    testWidgets('7. SnackBar shown when no player exists', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repo_providers.playerRepositoryProvider
                .overrideWithValue(_FakePlayerRepositoryNull()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation:
                  '/training/session/new?drill=STRAIGHT_NEAR&level=1&target=10',
              routes: [
                GoRoute(
                  path: '/training/session/new',
                  builder: (context, state) => DrillSessionScreen(
                    drillCode:
                        state.uri.queryParameters['drill'] ?? 'STRAIGHT_NEAR',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await _settle(tester);
      await tester.pump(); // Allow SnackBar to appear

      // SnackBar should appear indicating player profile needed
      expect(find.textContaining('Cần hoàn tất hồ sơ'), findsOneWidget,
          reason: 'SnackBar should indicate player profile is needed');
    });

    testWidgets('8. Active session stats visible', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repo_providers.playerRepositoryProvider
                .overrideWithValue(_FakePlayerRepository()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation:
                  '/training/session/new?drill=STRAIGHT_NEAR&level=1&target=10',
              routes: [
                GoRoute(
                  path: '/training/session/new',
                  builder: (context, state) => DrillSessionScreen(
                    drillCode:
                        state.uri.queryParameters['drill'] ?? 'STRAIGHT_NEAR',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await _settle(tester);

      // Sprint-17 Part 6: Should show active session UI, not instructions
      // Sprint-19 redesign: Stats show Reps and Accuracy
      expect(find.text('Reps'), findsOneWidget,
          reason: 'Reps stat should appear (active session indicator)');
      expect(find.text('Accuracy'), findsOneWidget,
          reason: 'Accuracy stat should appear');
    });
  });
}
