// ============================================================================
// coach_recommendation_panel_test.dart
// ----------------------------------------------------------------------------
// Sprint 2C AC-2 widget smoke. Three assertions per Constitution Article 8:
//   (1) panel mounts without crash,
//   (2) recommendation section (or empty-state CTA) renders,
//   (3) tapping a recommendation does not throw.
//
// Widget under test is CoachProfilePanel (the actual widget surfaced in the
// app — spec §5 AC-2 refers to it as "coach_recommendation_panel" for the
// Reader's-eye view of the same component).
//
// No score assertions, no trend chart testing, no knowledge-gap
// edge cases. Manual QA on a real device covers the rest.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/core/providers/repository_providers.dart'
    as repo_providers;
import 'package:pool_os_v2/data/models/match.dart';
import 'package:pool_os_v2/presentation/widgets/coach_profile_panel.dart';

import '../helpers/fake_match_repository.dart';

Match _winMatch({required String id, required DateTime createdAt}) => Match(
      id: id,
      playerId: 'p1',
      result: 'win',
      createdAt: createdAt,
      updatedAt: createdAt,
      racks: [
        Rack(
          id: '$id-r1',
          rackNumber: 1,
          result: 'win',
          // Many easy misses trigger the heuristic recommendation in
          // CoachProfileAggregator so the panel surfaces a rec. row.
          easyMissCount: 10,
          positionErrorCount: 8,
          fouls: 6,
          createdAt: createdAt,
        ),
      ],
    );

void main() {
  testWidgets('Coach panel mounts, renders, and tap on rec. does not throw',
      (tester) async {
    final now = DateTime.now();
    final fake = FakeMatchRepository(seeded: [
      _winMatch(id: 'm1', createdAt: now.subtract(const Duration(days: 1))),
      _winMatch(id: 'm2', createdAt: now.subtract(const Duration(days: 2))),
      _winMatch(id: 'm3', createdAt: now.subtract(const Duration(days: 3))),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repo_providers.matchRepositoryProvider.overrideWithValue(fake),
        ],
        child: const MaterialApp(
          home: Scaffold(body: CoachProfilePanel(playerId: 'p1')),
        ),
      ),
    );

    // Allow async aggregator to resolve. Avoid pumpAndSettle (flutter_animate).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Assertion 1: panel mounts without crash.
    expect(find.byType(CoachProfilePanel), findsOneWidget);

    // Assertion 2: recommendation section renders (recommendations list
    // contains lines triggered by the high easy-miss / fouls counts above).
    expect(find.text('Recommendations'), findsOneWidget,
        reason: 'profile should surface a Recommendations section');
    expect(find.textContaining('easy miss', findRichText: false),
        findsAtLeastNWidgets(1),
        reason: 'profile should include at least one recommendation line');

    // Assertion 3: tapping a recommendation does not throw.
    final recFinder = find.textContaining('easy miss').first;
    await tester.tap(recFinder);
    await tester.pump();
  });
}
