// ============================================================================
// Sprint-14 Product Verification Gate
// Verifies Product Closed Loop through automated tests
// ============================================================================
//
// This test suite verifies that the TRAINING + MATCH loop actually produces
// different Coach recommendations based on real player data.
//
// Scenario A: Training weakness → Coach recommendation
// Scenario B: Training improvement → Coach acknowledgment
// Scenario C: Losing streak → Recovery mode
// Scenario D: Winning streak → Challenge mode
// Scenario E: Combined → Training + Match context

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/knowledge/player_intelligence.dart';
import 'package:pool_os_v2/knowledge/priority_engine.dart';
import 'package:pool_os_v2/knowledge/knowledge_graph_service.dart';

void main() {
  group('Sprint-14 Product Verification Gate', () {
    late KnowledgeGraphService kg;

    setUpAll(() {
      kg = KnowledgeGraphService.instance;
    });

    // =========================================================================
    // Scenario A: Training weakness → Coach recommendation changes
    // =========================================================================
    test('SCENARIO A: Repeated low-performance training creates weakness that reaches Coach', () {
      // GIVEN: Player does aiming drill 5 times with low scores
      var pi = PlayerIntelligence.empty('verification_test');

      for (var i = 0; i < 5; i++) {
        pi = pi.updateWithSession(
          TrainingSessionData(
            drillCode: 'STRAIGHT_POT',
            score: 35, // Low performance
            durationMinutes: 10,
            completedAt: DateTime.now(),
            mistakes: [],
          ),
          drillSkills: ['aiming', 'stroke'],
        );
      }

      // THEN: PlayerIntelligence should have:
      // 1. Low skill level for aiming
      // 2. Weakness signal in mistake patterns
      expect(pi.skillProfile.skills['aiming'], isNotNull,
          reason: 'Aiming skill should be tracked');
      expect(pi.skillProfile.skills['aiming']!.level, lessThan(50),
          reason: 'Aiming skill level should be low from repeated poor performance');
      expect(pi.mistakePatterns.patterns.isNotEmpty, isTrue,
          reason: 'Should have weakness signals from low performance');

      // WHEN: Coach generates recommendation
      final engine = PriorityEngine(
        playerIntelligence: pi,
        knowledgeGraph: kg,
      );
      final plan = engine.getCoachingPlan();

      // THEN: Recommendation should reference the training weakness
      // Coach reasoning should mention sessions and potentially weakness
      expect(plan.reasoning, contains('buổi tập'),
          reason: 'Coach should mention training sessions');
      print('SCENARIO A - Reasoning: ${plan.reasoning}');
      print('SCENARIO A - Avoids: ${plan.avoidRecommendations.map((a) => a.item).join(", ")}');
    });

    // =========================================================================
    // Scenario B: Training improvement → Coach acknowledges
    // =========================================================================
    test('SCENARIO B: Improving performance reflects in Coach data', () {
      // GIVEN: Player had poor sessions, then improved
      var pi = PlayerIntelligence.empty('verification_test');

      // 5 older sessions with low scores
      for (var i = 0; i < 5; i++) {
        final oldDate = DateTime.now().subtract(Duration(days: i + 15));
        pi = pi.updateWithSession(
          TrainingSessionData(
            drillCode: 'STRAIGHT_POT',
            score: 50,
            durationMinutes: 10,
            completedAt: oldDate,
            mistakes: [],
          ),
          drillSkills: ['aiming'],
        );
      }

      // 5 recent sessions with higher scores
      for (var i = 0; i < 5; i++) {
        final recentDate = DateTime.now().subtract(Duration(days: i));
        pi = pi.updateWithSession(
          TrainingSessionData(
            drillCode: 'STRAIGHT_POT',
            score: 75,
            durationMinutes: 10,
            completedAt: recentDate,
            mistakes: [],
          ),
          drillSkills: ['aiming'],
        );
      }

      // THEN: Improvement rate should be positive
      expect(pi.progress.improvementRate, greaterThan(0),
          reason: 'Improvement rate should be positive when recent > older');

      // WHEN: Coach generates recommendation
      final engine = PriorityEngine(
        playerIntelligence: pi,
        knowledgeGraph: kg,
      );
      final plan = engine.getCoachingPlan();

      // THEN: Coach should mention the sessions
      expect(plan.reasoning, contains('buổi tập'),
          reason: 'Coach should mention training sessions');
      expect(plan.reasoning, contains('trận'),
          reason: 'Coach should mention matches');

      print('SCENARIO B - Improvement Rate: ${pi.progress.improvementRate.toStringAsFixed(1)}%');
      print('SCENARIO B - Reasoning: ${plan.reasoning}');
    });

    // =========================================================================
    // Scenario C: Losing streak → Recovery recommendation
    // =========================================================================
    test('SCENARIO C: 3+ consecutive losses triggers recovery mode', () {
      // GIVEN: Player lost 3 matches in a row
      var pi = PlayerIntelligence.empty('verification_test');

      for (var i = 0; i < 3; i++) {
        pi = pi.updateWithMatch(MatchData(
          opponentName: 'TestOpponent',
          won: false, // Loss
          playerScore: 3,
          opponentScore: 5,
          durationMinutes: 30,
          playedAt: DateTime.now(),
          mistakes: [],
        ));
      }

      // THEN: PlayerIntelligence should have losing streak
      expect(pi.matchPatterns.currentStreak.type, equals(StreakType.loss),
          reason: 'Should have losing streak');
      expect(pi.matchPatterns.currentStreak.count, equals(3),
          reason: 'Streak count should be 3');

      // WHEN: Coach generates recommendation
      final engine = PriorityEngine(
        playerIntelligence: pi,
        knowledgeGraph: kg,
      );
      final plan = engine.getCoachingPlan();

      // THEN: Coach should have recovery-oriented recommendations
      // Avoid recommendations should include recovery advice
      final hasRecoveryAvoid = plan.avoidRecommendations.any((a) =>
          a.item.contains('khó') || a.reason.contains('thua'));
      expect(hasRecoveryAvoid, isTrue,
          reason: 'Coach should recommend avoiding hard drills during losing streak');

      // THEN: Reasoning should mention the streak
      expect(plan.reasoning, contains('thua'),
          reason: 'Coach should mention losing streak');

      print('SCENARIO C - Streak: ${pi.matchPatterns.currentStreak.count} ${pi.matchPatterns.currentStreak.type}');
      print('SCENARIO C - Avoids: ${plan.avoidRecommendations.map((a) => a.item).join(", ")}');
      print('SCENARIO C - Reasoning: ${plan.reasoning}');
    });

    // =========================================================================
    // Scenario D: Winning streak → Challenge mode
    // =========================================================================
    test('SCENARIO D: 5+ consecutive wins enables challenge mode', () {
      // GIVEN: Player won 5 matches in a row
      var pi = PlayerIntelligence.empty('verification_test');

      for (var i = 0; i < 5; i++) {
        pi = pi.updateWithMatch(MatchData(
          opponentName: 'TestOpponent',
          won: true, // Win
          playerScore: 5,
          opponentScore: 3,
          durationMinutes: 30,
          playedAt: DateTime.now(),
          mistakes: [],
        ));
      }

      // THEN: PlayerIntelligence should have winning streak
      expect(pi.matchPatterns.currentStreak.type, equals(StreakType.win),
          reason: 'Should have winning streak');
      expect(pi.matchPatterns.currentStreak.count, equals(5),
          reason: 'Streak count should be 5');

      // WHEN: Coach generates recommendation
      final engine = PriorityEngine(
        playerIntelligence: pi,
        knowledgeGraph: kg,
      );
      final plan = engine.getCoachingPlan();

      // THEN: Reasoning should mention the winning streak
      expect(plan.reasoning, contains('thắng'),
          reason: 'Coach should mention winning streak');

      print('SCENARIO D - Streak: ${pi.matchPatterns.currentStreak.count} ${pi.matchPatterns.currentStreak.type}');
      print('SCENARIO D - Reasoning: ${plan.reasoning}');
    });

    // =========================================================================
    // Scenario E: Combined - Training weakness + Match streak
    // =========================================================================
    test('SCENARIO E: Training weakness + losing streak → combined Coach context', () {
      // GIVEN: Player has training weakness AND losing streak
      var pi = PlayerIntelligence.empty('verification_test');

      // Add training weakness (low aiming scores)
      for (var i = 0; i < 3; i++) {
        pi = pi.updateWithSession(
          TrainingSessionData(
            drillCode: 'STRAIGHT_POT',
            score: 40,
            durationMinutes: 10,
            completedAt: DateTime.now(),
            mistakes: [],
          ),
          drillSkills: ['aiming'],
        );
      }

      // Add losing streak
      for (var i = 0; i < 3; i++) {
        pi = pi.updateWithMatch(MatchData(
          opponentName: 'TestOpponent',
          won: false,
          playerScore: 3,
          opponentScore: 5,
          durationMinutes: 30,
          playedAt: DateTime.now(),
          mistakes: [],
        ));
      }

      // THEN: PlayerIntelligence should have BOTH signals
      expect(pi.skillProfile.skills.isNotEmpty, isTrue,
          reason: 'Should have skill profile from training');
      expect(pi.matchPatterns.currentStreak.type, equals(StreakType.loss),
          reason: 'Should have losing streak');

      // WHEN: Coach generates recommendation
      final engine = PriorityEngine(
        playerIntelligence: pi,
        knowledgeGraph: kg,
      );
      final plan = engine.getCoachingPlan();

      // THEN: Coach reasoning should mention BOTH training and match context
      final reasoning = plan.reasoning;
      expect(reasoning, contains('buổi tập'),
          reason: 'Coach should mention training');
      expect(reasoning, contains('thua'),
          reason: 'Coach should mention losing streak');

      // AND: Should have recovery-oriented avoid recommendations
      final hasRecoveryAvoid = plan.avoidRecommendations.any((a) =>
          a.item.contains('khó') || a.reason.contains('thua'));
      expect(hasRecoveryAvoid, isTrue,
          reason: 'Should have recovery advice for losing streak + weakness');

      print('SCENARIO E - Training Skills: ${pi.skillProfile.skills.keys.join(", ")}');
      print('SCENARIO E - Match Streak: ${pi.matchPatterns.currentStreak.count} ${pi.matchPatterns.currentStreak.type}');
      print('SCENARIO E - Reasoning: $reasoning');
      print('SCENARIO E - Avoids: ${plan.avoidRecommendations.map((a) => "${a.item}: ${a.reason}").join("; ")}');
    });

    // =========================================================================
    // Edge Case: No data → No artificial intelligence
    // =========================================================================
    test('EDGE CASE: Empty state should not create artificial weaknesses', () {
      // GIVEN: Player has NO training and NO matches
      final pi = PlayerIntelligence.empty('verification_test');

      // THEN: No skill data
      expect(pi.skillProfile.skills.isEmpty, isTrue);

      // THEN: No mistake patterns
      expect(pi.mistakePatterns.patterns.isEmpty, isTrue);

      // THEN: No match history
      expect(pi.matchPatterns.totalMatches, equals(0));

      // THEN: Improvement rate is 0 (insufficient data)
      expect(pi.progress.improvementRate, equals(0));

      // WHEN: Coach generates recommendation
      final engine = PriorityEngine(
        playerIntelligence: pi,
        knowledgeGraph: kg,
      );
      final plan = engine.getCoachingPlan();

      // THEN: Coach should still function (cold start)
      expect(plan.reasoning, isNotEmpty,
          reason: 'Coach should still provide reasoning for new users');

      print('EDGE CASE - Reasoning: ${plan.reasoning}');
    });
  });
}
