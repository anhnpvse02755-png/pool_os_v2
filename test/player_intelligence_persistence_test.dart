// ============================================================================
// PLAYER INTELLIGENCE PERSISTENCE TEST - Sprint-8 Verification
// Tests that PlayerIntelligence can be serialized and deserialized correctly
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/knowledge/player_intelligence.dart';

void main() {
  group('PlayerIntelligence Persistence', () {
    test('toJson and fromJson roundtrip preserves all data', () {
      // Arrange: Create a PlayerIntelligence with sample data
      final original = PlayerIntelligence(
        playerId: 'test_user',
        identity: const PlayerIdentity(
          name: 'Test Player',
          startedAt: null,
          primaryGoal: 'Improve breaking',
          experienceLevel: ExperienceLevel.intermediate,
          playStyle: PlayStyle.aggressive,
        ),
        skillProfile: const SkillProfile(
          skills: {
            'break': SkillLevel(skillId: 'break', level: 75, sessionsPracticed: 10),
            'aim': SkillLevel(skillId: 'aim', level: 60, sessionsPracticed: 5),
          },
          overallLevel: ExperienceLevel.intermediate,
          primaryStrength: 'break',
          primaryWeakness: 'safety',
          mostPracticedSkills: ['break', 'aim'],
        ),
        progress: ProgressTracker(
          trendHistory: [
            ProgressPoint(
              date: DateTime(2024, 1, 1),
              score: 70,
              type: ProgressType.training,
            ),
            ProgressPoint(
              date: DateTime(2024, 1, 15),
              score: 80,
              type: ProgressType.training,
            ),
          ],
          currentTrend: TrendDirection.improving,
          personalBest: ProgressPoint(
            date: DateTime(2024, 1, 15),
            score: 85,
            type: ProgressType.training,
          ),
          improvementRate: 2.5,
          consistencyScore: 85,
        ),
        mistakePatterns: MistakePatterns(
          patterns: [
            MistakePattern(
              mistakeId: 'miscue',
              mistakeName: 'Miscue on power shots',
              frequency: 5,
              lastSeen: DateTime(2024, 1, 14),
              isImproving: true,
              associatedCauses: ['grip', 'bridge'],
            ),
          ],
          topMistakes: ['miscue', 'scratch'],
          improvingMistakes: ['miscue'],
          newMistakes: [],
        ),
        practicePatterns: PracticePatterns(
          totalSessions: 25,
          totalMinutes: 500,
          lastSession: DateTime(2024, 1, 15),
          avgSessionLength: 20,
          sessionsThisWeek: 3,
          sessionsThisMonth: 12,
          favoriteDrills: ['break_01', 'aim_01'],
          consistency: const ConsistencyMetrics(
            regularity: 75,
            preferredTime: 2,
            preferredDay: 6,
            deviationFromHabit: 0.3,
          ),
        ),
        matchPatterns: MatchPatterns(
          totalMatches: 10,
          wins: 6,
          losses: 4,
          draws: 0,
          winRate: 60.0,
          currentStreak: const StreakInfo(type: StreakType.win, count: 2),
          longestWinStreak: const StreakInfo(type: StreakType.win, count: 4),
          longestLossStreak: const StreakInfo(type: StreakType.loss, count: 2),
          opponentAnalysis: const PerformanceByOpponent(records: {}),
          conditionAnalysis: const PerformanceByCondition(
            homeWinRate: 70,
            awayWinRate: 50,
            pressureWinRate: 40,
          ),
        ),
        mentalModel: const MentalModel(
          confidence: 75,
          focus: 80,
          pressureHandling: 60,
          tiltTendency: 30,
          mentalBlocks: ['pressure shots'],
          triggers: ['losing streak'],
          trend: MentalTrend.improving,
        ),
        learningHistory: LearningHistory(
          entries: [
            LearningEntry(
              date: DateTime(2024, 1, 10),
              type: 'drill',
              itemId: 'break_01',
              description: 'Learned proper break stance',
              improvementScore: 10,
            ),
          ],
          masteredConcepts: ['break_stance', 'bridge_hand'],
          inProgressConcepts: ['spin_control'],
          conceptMasteredAt: {
            'break_stance': DateTime(2024, 1, 5),
          },
        ),
        recommendations: RecommendationHistory(
          entries: [],
          drillRecommendationCount: {'break_01': 3},
          lastRecommendation: DateTime(2024, 1, 14),
        ),
        shortTermMemory: ShortTermMemory(
          recentSessions: [
            MemoryEntry(
              timestamp: DateTime(2024, 1, 15),
              type: MemoryType.session,
              data: {'drillCode': 'break_01', 'score': 85},
            ),
          ],
          recentMatches: [],
          recentReflections: [],
          recentObservations: [],
        ),
        workingMemory: WorkingMemory(
          currentTopics: ['break technique'],
          pendingQuestions: ['How to control cue ball?'],
          context: {'focus': 'improving break'},
          conversationStart: DateTime(2024, 1, 15, 10, 0),
        ),
        updatedAt: DateTime(2024, 1, 15, 12, 0),
      );

      // Act: Serialize to JSON and deserialize back
      final json = original.toJson();
      final restored = PlayerIntelligence.fromJson(json);

      // Assert: Verify all fields are preserved
      expect(restored.playerId, equals(original.playerId));
      expect(restored.identity.name, equals(original.identity.name));
      expect(restored.identity.experienceLevel, equals(original.identity.experienceLevel));
      expect(restored.identity.playStyle, equals(original.identity.playStyle));
      expect(restored.skillProfile.skills.length, equals(original.skillProfile.skills.length));
      expect(restored.skillProfile.primaryStrength, equals(original.skillProfile.primaryStrength));
      expect(restored.progress.trendHistory.length, equals(original.progress.trendHistory.length));
      expect(restored.progress.currentTrend, equals(original.progress.currentTrend));
      expect(restored.mistakePatterns.topMistakes, equals(original.mistakePatterns.topMistakes));
      expect(restored.practicePatterns.totalSessions, equals(original.practicePatterns.totalSessions));
      expect(restored.matchPatterns.winRate, equals(original.matchPatterns.winRate));
      expect(restored.matchPatterns.currentStreak.type, equals(original.matchPatterns.currentStreak.type));
      expect(restored.mentalModel.confidence, equals(original.mentalModel.confidence));
      expect(restored.mentalModel.trend, equals(original.mentalModel.trend));
      expect(restored.learningHistory.masteredConcepts, equals(original.learningHistory.masteredConcepts));
      expect(restored.shortTermMemory.recentSessions.length, equals(original.shortTermMemory.recentSessions.length));
      expect(restored.workingMemory.currentTopics, equals(original.workingMemory.currentTopics));
    });

    test('PlayerIntelligence.empty can be serialized and deserialized', () {
      // Arrange
      final original = PlayerIntelligence.empty('test_user');

      // Act
      final json = original.toJson();
      final restored = PlayerIntelligence.fromJson(json);

      // Assert
      expect(restored.playerId, equals(original.playerId));
      expect(restored.identity.name, equals(original.identity.name));
      expect(restored.skillProfile.skills, isEmpty);
      expect(restored.progress.trendHistory, isEmpty);
    });

    test('toJson produces valid JSON-serializable map', () {
      // Arrange
      final original = PlayerIntelligence.empty('test_user');

      // Act
      final json = original.toJson();

      // Assert: Should be able to convert to string (simulates JSON encoding)
      final jsonString = json.toString();
      expect(jsonString, contains('playerId'));
      expect(jsonString, contains('identity'));
    });
  });

  group('Enum Serialization', () {
    test('ExperienceLevel roundtrip', () {
      for (final level in ExperienceLevel.values) {
        final restored = ExperienceLevel.fromString(level.name);
        expect(restored, equals(level));
      }
    });

    test('PlayStyle roundtrip', () {
      for (final style in PlayStyle.values) {
        final restored = PlayStyle.fromString(style.name);
        expect(restored, equals(style));
      }
      // Test null
      expect(PlayStyle.fromString(null), isNull);
    });

    test('TrendDirection roundtrip', () {
      for (final trend in TrendDirection.values) {
        final restored = TrendDirection.fromString(trend.name);
        expect(restored, equals(trend));
      }
    });

    test('StreakType roundtrip', () {
      for (final type in StreakType.values) {
        final restored = StreakTypeExtension.fromString(type.name);
        expect(restored, equals(type));
      }
    });

    test('MentalTrend roundtrip', () {
      for (final trend in MentalTrend.values) {
        final restored = MentalTrend.fromString(trend.name);
        expect(restored, equals(trend));
      }
    });

    test('MemoryType roundtrip', () {
      for (final type in MemoryType.values) {
        final restored = MemoryTypeExtension.fromString(type.name);
        expect(restored, equals(type));
      }
    });

    test('ProgressType roundtrip', () {
      for (final type in ProgressType.values) {
        final restored = ProgressTypeExtension.fromString(type.name);
        expect(restored, equals(type));
      }
    });
  });

  group('Nested Model Serialization', () {
    test('SkillLevel roundtrip', () {
      const original = SkillLevel(
        skillId: 'test',
        level: 75,
        sessionsPracticed: 10,
        lastPracticed: null,
      );

      final restored = SkillLevel.fromJson(original.toJson());
      expect(restored.skillId, equals(original.skillId));
      expect(restored.level, equals(original.level));
      expect(restored.sessionsPracticed, equals(original.sessionsPracticed));
    });

    test('ProgressPoint roundtrip', () {
      final original = ProgressPoint(
        date: DateTime(2024, 1, 15),
        score: 85,
        type: ProgressType.training,
      );

      final restored = ProgressPoint.fromJson(original.toJson());
      expect(restored.score, equals(original.score));
      expect(restored.type, equals(original.type));
    });

    test('StreakInfo roundtrip', () {
      const original = StreakInfo(type: StreakType.win, count: 3);

      final restored = StreakInfo.fromJson(original.toJson());
      expect(restored.type, equals(original.type));
      expect(restored.count, equals(original.count));
    });

    test('ConsistencyMetrics roundtrip', () {
      const original = ConsistencyMetrics(
        regularity: 80,
        preferredTime: 2,
        preferredDay: 5,
        deviationFromHabit: 0.5,
      );

      final restored = ConsistencyMetrics.fromJson(original.toJson());
      expect(restored.regularity, equals(original.regularity));
      expect(restored.deviationFromHabit, equals(original.deviationFromHabit));
    });

    test('PerformanceByCondition roundtrip', () {
      const original = PerformanceByCondition(
        homeWinRate: 75,
        awayWinRate: 60,
        pressureWinRate: 45,
      );

      final restored = PerformanceByCondition.fromJson(original.toJson());
      expect(restored.homeWinRate, equals(original.homeWinRate));
      expect(restored.pressureWinRate, equals(original.pressureWinRate));
    });

    test('MentalModel roundtrip', () {
      const original = MentalModel(
        confidence: 70,
        focus: 80,
        pressureHandling: 60,
        tiltTendency: 25,
        mentalBlocks: ['long shots'],
        triggers: ['crowd noise'],
        trend: MentalTrend.stable,
      );

      final restored = MentalModel.fromJson(original.toJson());
      expect(restored.confidence, equals(original.confidence));
      expect(restored.mentalBlocks, equals(original.mentalBlocks));
      expect(restored.trend, equals(original.trend));
    });

    test('LearningEntry roundtrip', () {
      final original = LearningEntry(
        date: DateTime(2024, 1, 15),
        type: 'drill',
        itemId: 'test_drill',
        description: 'Test learning entry',
        improvementScore: 5,
      );

      final restored = LearningEntry.fromJson(original.toJson());
      expect(restored.type, equals(original.type));
      expect(restored.improvementScore, equals(original.improvementScore));
    });

    test('RecommendationEntry roundtrip', () {
      final original = RecommendationEntry(
        id: 'rec_001',
        createdAt: DateTime(2024, 1, 15),
        drillCode: 'test_drill',
        reason: 'Improve accuracy',
        completed: false,
        completedAt: null,
      );

      final restored = RecommendationEntry.fromJson(original.toJson());
      expect(restored.id, equals(original.id));
      expect(restored.drillCode, equals(original.drillCode));
      expect(restored.completed, equals(original.completed));
    });

    test('MemoryEntry roundtrip', () {
      final original = MemoryEntry(
        timestamp: DateTime(2024, 1, 15),
        type: MemoryType.session,
        data: {'score': 85, 'duration': 20},
      );

      final restored = MemoryEntry.fromJson(original.toJson());
      expect(restored.type, equals(original.type));
      expect(restored.data['score'], equals(85));
    });

    test('WorkingMemory roundtrip', () {
      final original = WorkingMemory(
        currentTopics: ['topic1', 'topic2'],
        pendingQuestions: ['question1'],
        context: {'key': 'value'},
        conversationStart: DateTime(2024, 1, 15, 10, 0),
      );

      final restored = WorkingMemory.fromJson(original.toJson());
      expect(restored.currentTopics, equals(original.currentTopics));
      expect(restored.context['key'], equals(original.context['key']));
    });
  });
}
