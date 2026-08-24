// ============================================================================
// drill_session_ux_test.dart
// ----------------------------------------------------------------------------
// Sprint-17 Part 6 — Training UX regression tests.
//
// Tests verify the streamlined training flow:
// - No redundant "Bắt đầu" FAB
// - No instructions screen intermediate step
// - User goes directly to recording UI after confirming repetitions
//
// Flow:
// DrillDetailScreen → repetitions dialog → "Bắt đầu tập X lần"
//   → DrillSessionScreen → active session UI (no intermediate steps)
//   → Success/Failure recording buttons
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

  group('DrillSessionScreen UX — Sprint-17 Part 6', () {
    testWidgets('1. No FAB "Bắt đầu" when auto-starting', (tester) async {
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
      expect(find.widgetWithText(FloatingActionButton, 'Bắt đầu'), findsNothing,
          reason: 'No "Bắt đầu" text in FAB');
    });

    testWidgets('2. Success button visible after auto-start', (tester) async {
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

      // Success button must render immediately
      expect(find.widgetWithText(ElevatedButton, 'Thành công'), findsOneWidget,
          reason: 'Success button must appear immediately');
    });

    testWidgets('3. Failure button visible after auto-start', (tester) async {
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

      // Failure button must render immediately
      expect(find.widgetWithText(ElevatedButton, 'Trượt'), findsOneWidget,
          reason: 'Failure button must appear immediately');
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

      // Progress bar should show the target (10 reps)
      expect(find.text('/ 10'), findsOneWidget,
          reason: 'Progress should show target of 10 reps');
    });

    testWidgets('5. Kết thúc button visible when session active', (tester) async {
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

      // End session button should be visible
      expect(find.widgetWithText(TextButton, 'Kết thúc'), findsOneWidget,
          reason: 'End session button must appear when active');
    });

    testWidgets(
        '6. Screen title shows drill name when session active',
        (tester) async {
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

      // Drill name should appear in AppBar
      expect(find.text('Đánh thẳng gần'), findsOneWidget,
          reason: 'Drill name should appear in AppBar');
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

    testWidgets('8. Drill loads successfully with drill code param', (tester) async {
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

      // Drill name should appear (proves drill loaded successfully)
      expect(find.text('Đánh thẳng gần'), findsOneWidget,
          reason: 'Drill should load and display its name');
    });

    testWidgets(
        '9. No intermediate instruction screen rendered',
        (tester) async {
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
      // Active session shows progress bar with stats
      expect(find.text('Lần'), findsOneWidget,
          reason: 'Progress stats should appear (active session indicator)');
      expect(find.text('Tỷ lệ'), findsOneWidget,
          reason: 'Accuracy rate should appear');
      // Instructions screen had "Các bước" - should NOT be present
      expect(find.text('Các bước'), findsNothing,
          reason: 'Instructions screen should NOT appear');
    });

    testWidgets('10. No instructions content rendered', (tester) async {
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

      // Sprint-17 Part 6: Instructions content should NOT be shown
      // The old instructions had "Các bước" header
      expect(find.text('Các bước'), findsNothing,
          reason: 'Instructions steps should not render');
    });
  });
}
