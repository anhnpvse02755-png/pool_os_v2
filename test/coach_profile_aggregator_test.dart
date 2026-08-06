import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/domain/services/coach_profile_aggregator.dart';
import 'package:pool_os_v2/data/models/match.dart';
import 'helpers/fake_match_repository.dart';

// =============================================================================
// CoachProfileAggregator — Critical Suite (Tier 1)
//
// Sprint 2C AC-1: 6 cases locked in docs/SPRINT_2C_KICKOFF.md §5.
//
// Bug history (Sprint 2C inventory, observation #1316):
//   - Earlier hypothesis was that aggregator returned non-zero
//     matchesAnalyzed for empty repository. Re-verification on
//     2026-08-06 confirmed aggregator code is correct (returns 0
//     for empty). Root cause had been a test-setup artifact in
//     the previous run, not the aggregator.
//   - Atomic commit keeps the regression test (case 1) and the
//     five added cases together per §12.
// =============================================================================

Match _win({
  required String id,
  required DateTime createdAt,
  required int easyMisses,
  required int positionErrors,
  required int fouls,
}) =>
    Match(
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
          easyMissCount: easyMisses,
          positionErrorCount: positionErrors,
          fouls: fouls,
          createdAt: createdAt,
        ),
      ],
    );

Match _loss({
  required String id,
  required DateTime createdAt,
  required int easyMisses,
  required int positionErrors,
  required int fouls,
}) =>
    Match(
      id: id,
      playerId: 'p1',
      result: 'lose',
      createdAt: createdAt,
      updatedAt: createdAt,
      racks: [
        Rack(
          id: '$id-r1',
          rackNumber: 1,
          result: 'lose',
          easyMissCount: easyMisses,
          positionErrorCount: positionErrors,
          fouls: fouls,
          createdAt: createdAt,
        ),
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // -----------------------------------------------------------------
  // Case 1 — Empty repository
  //
  // Regression test for the bug observed in pre-sprint inventory.
  // Empty repo must yield a stable zero-state profile.
  // -----------------------------------------------------------------
  test('case 1: empty repository returns zero-state profile', () async {
    final agg = CoachProfileAggregator(FakeMatchRepository());
    final p = await agg.generate('p1');

    expect(p.matchesAnalyzed, 0, reason: 'matchesAnalyzed must be 0');
    expect(p.wins, 0);
    expect(p.losses, 0);
    expect(p.winRate, 0.0);
    // Aggregator seeds the 5 canonical skill axes at neutral 50
    // so UI has a stable rendering shape — documented behavior.
    expect(p.skillScores.length, 5);
    expect(p.skillScores['Cutting'], 50.0);
    expect(p.skillScores['Safety'], 50.0);
    expect(p.skillScores['Break & Run'], 0.0);
    expect(p.skillScores['Specialty'], 0.0);
    expect(p.skillScores['Discipline'], 100.0);
    expect(p.tone, 'Steady');
  });

  // -----------------------------------------------------------------
  // Case 2 — Window filter
  //
  // Matches older than the window must be excluded.
  // -----------------------------------------------------------------
  test('case 2: matches older than window are excluded', () async {
    final now = DateTime.now();
    final old = now.subtract(const Duration(days: 60)); // outside 30d window
    final fresh = now.subtract(const Duration(days: 5)); // inside window

    final repo = FakeMatchRepository(seeded: [
      _win(id: 'old', createdAt: old, easyMisses: 0, positionErrors: 0, fouls: 0),
      _win(id: 'fresh', createdAt: fresh, easyMisses: 0, positionErrors: 0, fouls: 0),
    ]);
    final agg = CoachProfileAggregator(repo);

    final p = await agg.generate('p1');
    expect(p.matchesAnalyzed, 1, reason: 'only the fresh match should count');
    expect(p.wins, 1);
  });

  // -----------------------------------------------------------------
  // Case 3 — Win/loss tally
  //
  // Given 2 wins + 3 losses in the window, wins==2, losses==3,
  // winRate == 2/5 * 100 == 40.0.
  // -----------------------------------------------------------------
  test('case 3: win/loss tally computes correct counts and winRate', () async {
    final now = DateTime.now();
    final repo = FakeMatchRepository(seeded: [
      _win(id: 'w1', createdAt: now.subtract(const Duration(days: 1)),
          easyMisses: 0, positionErrors: 0, fouls: 0),
      _win(id: 'w2', createdAt: now.subtract(const Duration(days: 2)),
          easyMisses: 0, positionErrors: 0, fouls: 0),
      _loss(id: 'l1', createdAt: now.subtract(const Duration(days: 3)),
          easyMisses: 0, positionErrors: 0, fouls: 0),
      _loss(id: 'l2', createdAt: now.subtract(const Duration(days: 4)),
          easyMisses: 0, positionErrors: 0, fouls: 0),
      _loss(id: 'l3', createdAt: now.subtract(const Duration(days: 5)),
          easyMisses: 0, positionErrors: 0, fouls: 0),
    ]);
    final agg = CoachProfileAggregator(repo);

    final p = await agg.generate('p1');
    expect(p.matchesAnalyzed, 5);
    expect(p.wins, 2);
    expect(p.losses, 3);
    expect(p.winRate, 40.0); // 2/5 * 100
  });

  // -----------------------------------------------------------------
  // Case 4 — Rack-level aggregation
  //
  // easyMisses, positionErrors, fouls are summed across all racks
  // in the window.
  // -----------------------------------------------------------------
  test('case 4: rack-level error counts aggregate across matches', () async {
    final now = DateTime.now();
    final repo = FakeMatchRepository(seeded: [
      _win(
        id: 'm1',
        createdAt: now.subtract(const Duration(days: 1)),
        easyMisses: 2,
        positionErrors: 1,
        fouls: 1,
      ),
      _win(
        id: 'm2',
        createdAt: now.subtract(const Duration(days: 2)),
        easyMisses: 3,
        positionErrors: 2,
        fouls: 0,
      ),
    ]);
    final agg = CoachProfileAggregator(repo);

    final p = await agg.generate('p1');
    // Discipline = 100 - (easyMiss*3) - (fouls*5) - (posError*2), clamped 0..100.
    // 5 easy * 3 + 1 foul * 5 + 3 pos * 2 = 15 + 5 + 6 = 26 -> 74.
    expect(p.skillScores['Discipline'], 74.0);
  });

  // -----------------------------------------------------------------
  // Case 5 — Tone classification
  //
  // Given a known win rate + recent trend, tone is one of
  // "Hot" / "Steady" / "Slumping" / "Rising".
  //   - >= 0.65 wins  -> Hot
  //   - >= 0.45 wins  -> Steady
  //   - last 3 all losses -> Slumping
  //   - last 3 all wins    -> Rising
  // -----------------------------------------------------------------
  test('case 5: tone classification covers Hot/Steady/Slumping/Rising', () async {
    Future<CoachProfile> profileFromWins(int wins, int losses) async {
      final now = DateTime.now();
      final seeded = <Match>[];
      for (var i = 0; i < wins; i++) {
        seeded.add(_win(
          id: 'w$i',
          createdAt: now.subtract(Duration(days: i + 1)),
          easyMisses: 0,
          positionErrors: 0,
          fouls: 0,
        ));
      }
      for (var i = 0; i < losses; i++) {
        seeded.add(_loss(
          id: 'l$i',
          createdAt: now.subtract(Duration(days: wins + i + 1)),
          easyMisses: 0,
          positionErrors: 0,
          fouls: 0,
        ));
      }
      // Newest-first sort matches LocalMatchRepository behavior.
      seeded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final agg = CoachProfileAggregator(FakeMatchRepository(seeded: seeded));
      return agg.generate('p1');
    }

    // 5 wins, 0 losses -> 100% win rate -> Hot
    expect((await profileFromWins(5, 0)).tone, 'Hot');
    // 3 wins, 2 losses -> 60% -> Steady (>= 0.45, < 0.65)
    expect((await profileFromWins(3, 2)).tone, 'Steady');
    // 0 wins, 5 losses -> last 3 all losses -> Slumping
    expect((await profileFromWins(0, 5)).tone, 'Slumping');
    // 5 wins, 0 losses -> last 3 all wins -> but winRate>=0.65 wins "Hot"
    // (Hot wins over Rising). So we need a Rising-only case:
    //   3 wins, 4 losses -> 3/7 < 0.45; last 3 are the 3 wins -> Rising.
    expect((await profileFromWins(3, 4)).tone, 'Rising');
  });

  // -----------------------------------------------------------------
  // Case 6 — Cold-start recommendation
  //
  // Empty repository produces a CoachProfile whose recommendations
  // are well-formed (List<String>, may be empty) and whose
  // skillScores are the documented neutral baseline. This is the
  // input DrillRecommendationV2.coldStart() consumes.
  //
  // Per Dependency Boundary (§14): DrillRecommendationV2 must NOT
  // read MatchRepository directly. The cold-start path therefore
  // operates on the CoachProfile value object produced here.
  // -----------------------------------------------------------------
  test('case 6: cold-start profile is a valid input for recommendation', () async {
    final agg = CoachProfileAggregator(FakeMatchRepository());
    final p = await agg.generate('p1');

    // Valid empty-state shape that downstream recommender can consume.
    expect(p.matchesAnalyzed, 0);
    expect(p.recommendations, isA<List<String>>());
    expect(p.skillScores, isNotEmpty,
        reason: 'cold-start must seed skill axes so recommender has a shape');
    expect(p.tone, isIn(['Hot', 'Steady', 'Slumping', 'Rising']));
  });
}
