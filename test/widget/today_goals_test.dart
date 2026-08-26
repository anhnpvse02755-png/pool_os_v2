// ============================================================================
// Today Goals Provider Tests — Sprint-18 Part 2
// Tests the TodayGoals class and provider behavior.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/core/providers/dashboard_provider.dart';

void main() {
  group('TodayGoals class', () {
    test('default values are correct', () {
      final goals = TodayGoals();
      expect(goals.drillsCompleted, equals(0));
      expect(goals.drillsTarget, equals(2));
      expect(goals.knowledgeRead, equals(false));
      expect(goals.testPassed, equals(false));
    });

    test('custom values can be set', () {
      final goals = TodayGoals(
        drillsCompleted: 5,
        drillsTarget: 10,
        knowledgeRead: true,
        testPassed: true,
      );
      expect(goals.drillsCompleted, equals(5));
      expect(goals.drillsTarget, equals(10));
      expect(goals.knowledgeRead, equals(true));
      expect(goals.testPassed, equals(true));
    });

    test('drillsProgress calculates correctly for 1/2', () {
      final goals = TodayGoals(drillsCompleted: 1, drillsTarget: 2);
      expect(goals.drillsProgress, equals(0.5));
    });

    test('drillsProgress calculates correctly for 2/2', () {
      final goals = TodayGoals(drillsCompleted: 2, drillsTarget: 2);
      expect(goals.drillsProgress, equals(1.0));
    });

    test('drillsProgress is 0 when target is 0', () {
      final goals = TodayGoals(drillsCompleted: 0, drillsTarget: 0);
      expect(goals.drillsProgress, equals(0));
    });

    test('allCompleted is false when not enough drills', () {
      final goals = TodayGoals(
        drillsCompleted: 1,
        drillsTarget: 2,
        knowledgeRead: true,
        testPassed: true,
      );
      expect(goals.allCompleted, equals(false));
    });

    test('allCompleted is true when all conditions met', () {
      final goals = TodayGoals(
        drillsCompleted: 2,
        drillsTarget: 2,
        knowledgeRead: true,
        testPassed: true,
      );
      expect(goals.allCompleted, equals(true));
    });

    test('allCompleted is false when knowledge not read', () {
      final goals = TodayGoals(
        drillsCompleted: 2,
        drillsTarget: 2,
        knowledgeRead: false,
        testPassed: true,
      );
      expect(goals.allCompleted, equals(false));
    });

    test('allCompleted is false when test not passed', () {
      final goals = TodayGoals(
        drillsCompleted: 2,
        drillsTarget: 2,
        knowledgeRead: true,
        testPassed: false,
      );
      expect(goals.allCompleted, equals(false));
    });

    test('allCompleted is false when no drills completed even if others true', () {
      final goals = TodayGoals(
        drillsCompleted: 0,
        drillsTarget: 2,
        knowledgeRead: true,
        testPassed: true,
      );
      expect(goals.allCompleted, equals(false));
    });
  });

  group('todayGoalsProvider exists and is accessible', () {
    test('todayGoalsProvider is defined', () {
      // This test just verifies the provider exists and can be read
      // The actual persistence test is manual testing
      expect(todayGoalsProvider, isNotNull);
    });
  });
}
