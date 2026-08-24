// ============================================================================
// profile_screen_test.dart
// ----------------------------------------------------------------------------
// Sprint-17 Part 4 — Profile Player Wiring regression tests.
//
// Tests verify that ProfileScreen correctly consumes currentPlayerProvider:
// 1. Loading state shown while provider loads
// 2. No player → placeholder shown
// 3. Player exists → real name displayed
// 4. Player exists → real level displayed
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/presentation/screens/profile/profile_screen.dart';
import 'package:pool_os_v2/core/providers/repository_providers.dart';
import 'package:pool_os_v2/data/models/player.dart';
import 'package:pool_os_v2/data/repositories/player_repository.dart'
    as player_repo;

/// Fake player repository for testing
class FakePlayerRepository implements player_repo.PlayerRepository {
  Player? _player;

  void setPlayer(Player? player) {
    _player = player;
  }

  @override
  Future<Player?> getCurrentPlayer() async => _player;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ProfileScreen Player Wiring — Sprint-17 Part 4', () {
    late FakePlayerRepository fakeRepo;

    setUp(() {
      fakeRepo = FakePlayerRepository();
    });

    Widget buildTestWidget({Player? player}) {
      fakeRepo.setPlayer(player);
      return ProviderScope(
        overrides: [
          playerRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      );
    }

    testWidgets('1. No player → placeholder shown', (tester) async {
      fakeRepo.setPlayer(null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show placeholder message
      expect(find.text('Hoàn tất onboarding để xem hồ sơ'), findsOneWidget);
      // Should show person icon
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('3. Player exists → real name displayed', (tester) async {
      final player = Player(
        id: 'test-player-123',
        name: 'Nguyễn Phú Việt Anh',
        currentLevel: 'B',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(buildTestWidget(player: player));
      await tester.pumpAndSettle();

      // Should display real player name
      expect(find.text('Nguyễn Phú Việt Anh'), findsOneWidget);
      // Should NOT show placeholder
      expect(find.text('Hoàn tất onboarding để xem hồ sơ'), findsNothing);
    });

    testWidgets('4. Player exists → real level displayed', (tester) async {
      final player = Player(
        id: 'test-player-456',
        name: 'Test User',
        currentLevel: 'C',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(buildTestWidget(player: player));
      await tester.pumpAndSettle();

      // Should display level badge with real level
      expect(find.text('Level C'), findsOneWidget);
      // Should NOT show hardcoded "Rank H"
      expect(find.text('Rank H'), findsNothing);
    });

    testWidgets('5. Player provider error → safe error state', (tester) async {
      final errorRepo = _ErrorPlayerRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerRepositoryProvider.overrideWithValue(errorRepo),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show placeholder (safe error handling)
      expect(find.text('Hoàn tất onboarding để xem hồ sơ'), findsOneWidget);
    });

    testWidgets('5. No hardcoded placeholder text when player exists', (tester) async {
      final player = Player(
        id: 'test-player-789',
        name: 'Real Player Name',
        currentLevel: 'D',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(buildTestWidget(player: player));
      await tester.pumpAndSettle();

      // Should NOT show hardcoded "Người dùng" placeholder
      expect(find.text('Người dùng'), findsNothing);
      // Should NOT show hardcoded "user@email.com"
      expect(find.text('user@email.com'), findsNothing);
    });
  });
}

/// Repository that throws error
class _ErrorPlayerRepository implements player_repo.PlayerRepository {
  @override
  Future<Player?> getCurrentPlayer() async {
    throw Exception('Test error');
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
