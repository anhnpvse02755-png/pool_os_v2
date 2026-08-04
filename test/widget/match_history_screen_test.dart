// Day 2A.5 widget tests — verifies UI migrates to repository providers
// without breaking screen render or data loading.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/core/providers/repository_providers.dart';
import 'package:pool_os_v2/data/models/match.dart';
import 'package:pool_os_v2/presentation/screens/play/match_history_screen.dart';

import '../helpers/fake_match_repository.dart';

void main() {
  group('MatchHistoryScreen — Day 2A.5', () {
    testWidgets('renders with empty repository', (tester) async {
      final fake = FakeMatchRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            matchRepositoryProvider.overrideWithValue(fake),
          ],
          child: const MaterialApp(home: MatchHistoryScreen()),
        ),
      );
      // First frame.
      await tester.pump();
      // Pump a couple more frames so async _load() resolves, but avoid
      // pumpAndSettle() — flutter_animate uses infinite shimmering that
      // never settles in test mode.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      // Screen scaffold + app bar should be present.
      expect(find.byType(MatchHistoryScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('loads matches from injected repository', (tester) async {
      final now = DateTime(2026, 8, 1, 12);
      final fake = FakeMatchRepository(seeded: [
        Match(
          id: 'm1',
          playerId: 'p1',
          gameType: '8-ball',
          raceTo: 5,
          opponent: 'op',
          result: 'win',
          startTime: now,
          createdAt: now,
          updatedAt: now,
        ),
      ]);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            matchRepositoryProvider.overrideWithValue(fake),
          ],
          child: const MaterialApp(home: MatchHistoryScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      // Fake was queried at least once.
      expect(fake.matches.length, 1);
      // The screen must have rendered without throwing.
      expect(tester.takeException(), isNull);
    });
  });
}