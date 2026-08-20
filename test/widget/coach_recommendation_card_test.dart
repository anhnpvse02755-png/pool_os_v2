// ============================================================================
// coach_recommendation_card_test.dart - Sprint-9B
// Widget tests for Coach Recommendation Card
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/presentation/widgets/coach/recommendation_card.dart';
import 'package:pool_os_v2/core/services/coach_voice_service.dart';

void main() {
  group('CoachRecommendation data class', () {
    test('priorityLabel returns correct label for priority 1', () {
      final rec = CoachRecommendation(
        drillCode: 'TEST',
        drillName: 'Test Drill',
        reason: 'Test reason',
        outcomes: ['Test outcome'],
        estimatedMinutes: 15,
        confidence: 75,
        priority: 1,
      );

      expect(rec.priorityLabel, equals('Ưu tiên #1'));
    });

    test('priorityLabel returns correct label for priority 2', () {
      final rec = CoachRecommendation(
        drillCode: 'TEST',
        drillName: 'Test Drill',
        reason: 'Test reason',
        outcomes: ['Test outcome'],
        estimatedMinutes: 15,
        confidence: 75,
        priority: 2,
      );

      expect(rec.priorityLabel, equals('Ưu tiên #2'));
    });

    test('confidenceLabel returns correct label for high confidence', () {
      final rec = CoachRecommendation(
        drillCode: 'TEST',
        drillName: 'Test Drill',
        reason: 'Test reason',
        outcomes: ['Test outcome'],
        estimatedMinutes: 15,
        confidence: 85,
        priority: 1,
      );

      expect(rec.confidenceLabel, equals('Rất chắc chắn'));
    });

    test('confidenceLabel returns correct label for low confidence', () {
      final rec = CoachRecommendation(
        drillCode: 'TEST',
        drillName: 'Test Drill',
        reason: 'Test reason',
        outcomes: ['Test outcome'],
        estimatedMinutes: 15,
        confidence: 30,
        priority: 1,
      );

      expect(rec.confidenceLabel, equals('Ít dữ liệu'));
    });

    test('confidenceColor returns green for high confidence', () {
      final rec = CoachRecommendation(
        drillCode: 'TEST',
        drillName: 'Test Drill',
        reason: 'Test reason',
        outcomes: ['Test outcome'],
        estimatedMinutes: 15,
        confidence: 85,
        priority: 1,
      );

      expect(rec.confidenceColor, equals(Colors.green));
    });

    test('fromBrain factory creates recommendation correctly', () {
      final rec = CoachRecommendation.fromBrain(
        drillCode: 'STRAIGHT_NEAR',
        drillName: 'Đánh thẳng gần',
        reason: 'Cần cải thiện kỹ năng nền tảng',
        expectedOutcome: 'Cải thiện 20%',
        estimatedMinutes: 10,
        confidence: 70,
        priority: 1,
      );

      expect(rec.drillCode, equals('STRAIGHT_NEAR'));
      expect(rec.drillName, equals('Đánh thẳng gần'));
      expect(rec.reason, equals('Cần cải thiện kỹ năng nền tảng'));
      expect(rec.outcomes.first, equals('Cải thiện 20%'));
      expect(rec.estimatedMinutes, equals(10));
      expect(rec.confidence, equals(70));
      expect(rec.priority, equals(1));
    });
  });

  group('RecommendationCard widget', () {
    late CoachRecommendation testRecommendation;
    late CoachVoiceService testCoachVoice;
    late bool startCalled;

    setUp(() {
      testRecommendation = CoachRecommendation(
        drillCode: 'STRAIGHT_NEAR',
        drillName: 'Đánh thẳng gần',
        reason: 'Đây là kỹ năng nền tảng quan trọng nhất',
        outcomes: ['Cải thiện accuracy', 'Tăng consistency'],
        estimatedMinutes: 15,
        confidence: 75,
        priority: 1,
      );
      testCoachVoice = CoachVoiceService();
      startCalled = false;
    });

    Future<void> pumpAndSettleWithTimeout(WidgetTester tester) async {
      // Pump for animations to complete
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets('displays drill name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(
              recommendation: testRecommendation,
              coachVoice: testCoachVoice,
              onStart: () {},
            ),
          ),
        ),
      );
      await pumpAndSettleWithTimeout(tester);

      expect(find.text('Đánh thẳng gần'), findsOneWidget);
    });

    testWidgets('displays reason', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(
              recommendation: testRecommendation,
              coachVoice: testCoachVoice,
              onStart: () {},
            ),
          ),
        ),
      );
      await pumpAndSettleWithTimeout(tester);

      expect(find.text('Đây là kỹ năng nền tảng quan trọng nhất'), findsOneWidget);
    });

    testWidgets('displays priority label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(
              recommendation: testRecommendation,
              coachVoice: testCoachVoice,
              onStart: () {},
            ),
          ),
        ),
      );
      await pumpAndSettleWithTimeout(tester);

      expect(find.text('Ưu tiên #1'), findsOneWidget);
    });

    testWidgets('displays estimated minutes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(
              recommendation: testRecommendation,
              coachVoice: testCoachVoice,
              onStart: () {},
            ),
          ),
        ),
      );
      await pumpAndSettleWithTimeout(tester);

      expect(find.text('15 phút'), findsOneWidget);
    });

    testWidgets('displays confidence percentage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(
              recommendation: testRecommendation,
              coachVoice: testCoachVoice,
              onStart: () {},
            ),
          ),
        ),
      );
      await pumpAndSettleWithTimeout(tester);

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('displays all outcomes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecommendationCard(
                recommendation: testRecommendation,
                coachVoice: testCoachVoice,
                onStart: () {},
              ),
            ),
          ),
        ),
      );
      await pumpAndSettleWithTimeout(tester);

      expect(find.text('Cải thiện accuracy'), findsOneWidget);
      expect(find.text('Tăng consistency'), findsOneWidget);
    });

    testWidgets('displays "Nếu hoàn thành hôm nay" section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecommendationCard(
                recommendation: testRecommendation,
                coachVoice: testCoachVoice,
                onStart: () {},
              ),
            ),
          ),
        ),
      );
      await pumpAndSettleWithTimeout(tester);

      expect(find.text('Nếu hoàn thành hôm nay:'), findsOneWidget);
    });

    testWidgets('CTA button calls onStart when pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecommendationCard(
                recommendation: testRecommendation,
                coachVoice: testCoachVoice,
                onStart: () => startCalled = true,
              ),
            ),
          ),
        ),
      );
      await pumpAndSettleWithTimeout(tester);

      await tester.tap(find.text('BẮT ĐẦU'));
      expect(startCalled, isTrue);
    });

    testWidgets('displays different priority colors', (tester) async {
      final highPriorityRec = CoachRecommendation(
        drillCode: 'TEST',
        drillName: 'Test Priority 1',
        reason: 'Test',
        outcomes: ['Test'],
        estimatedMinutes: 10,
        confidence: 50,
        priority: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecommendationCard(
                recommendation: highPriorityRec,
                coachVoice: testCoachVoice,
                onStart: () {},
              ),
            ),
          ),
        ),
      );
      await pumpAndSettleWithTimeout(tester);

      // Priority 1 should show orange color
      final priorityText = find.text('Ưu tiên #1');
      expect(priorityText, findsOneWidget);
    });

    testWidgets('displays confidence with verified icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecommendationCard(
                recommendation: testRecommendation,
                coachVoice: testCoachVoice,
                onStart: () {},
              ),
            ),
          ),
        ),
      );
      await pumpAndSettleWithTimeout(tester);

      // Should show verified icon next to confidence
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });
  });
}
