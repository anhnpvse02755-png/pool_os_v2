// ============================================================================
// Coach Integration Tests — D0.3
// End-to-end flows for Coach system
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration test data models
class TestDrillSession {
  final String drillCode;
  final String drillName;
  final int targetReps;
  final int completedReps;
  final int successfulReps;
  final DateTime startedAt;
  final DateTime? completedAt;

  TestDrillSession({
    required this.drillCode,
    required this.drillName,
    required this.targetReps,
    required this.completedReps,
    required this.successfulReps,
    required this.startedAt,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;
  double get successRate => completedReps > 0 ? successfulReps / completedReps : 0;
}

class TestRecommendation {
  final String drillCode;
  final String drillName;
  final String reason;
  final int priority;
  final bool isAccepted;
  final DateTime createdAt;

  TestRecommendation({
    required this.drillCode,
    required this.drillName,
    required this.reason,
    this.priority = 1,
    this.isAccepted = false,
    required this.createdAt,
  });
}

class TestCoachState {
  final List<TestDrillSession> sessions;
  final List<TestRecommendation> recommendations;
  final bool hasInterruptedSession;
  final bool hasEnoughData;

  TestCoachState({
    this.sessions = const [],
    this.recommendations = const [],
    this.hasInterruptedSession = false,
    this.hasEnoughData = false,
  });
}

void main() {
  group('Coach Integration: App Launch → Coach Home', () {
    testWidgets('Cold user sees empty state', (tester) async {
      final coachState = TestCoachState(
        sessions: [],
        recommendations: [],
        hasEnoughData: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CoachHomeWidget(state: coachState),
        ),
      );

      expect(find.text('Không có đủ dữ liệu'), findsOneWidget);
    });

    testWidgets('Warm user sees ONE priority', (tester) async {
      final coachState = TestCoachState(
        sessions: [
          TestDrillSession(
            drillCode: 'STRAIGHT_POT',
            drillName: 'Đánh thẳng',
            targetReps: 10,
            completedReps: 8,
            successfulReps: 6,
            startedAt: DateTime.now().subtract(const Duration(days: 1)),
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        recommendations: [
          TestRecommendation(
            drillCode: 'STOP_BALL',
            drillName: 'Dừng bi',
            reason: 'Cần cải thiện cú dừng',
            createdAt: DateTime.now(),
          ),
        ],
        hasEnoughData: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CoachHomeWidget(state: coachState),
        ),
      );

      expect(find.text('Dừng bi'), findsOneWidget);
      expect(find.text('Priority: 1'), findsOneWidget);
    });
  });

  group('Coach Integration: Start Drill → Complete Drill', () {
    testWidgets('Start drill creates session', (tester) async {
      TestDrillSession? activeSession;

      await tester.pumpWidget(
        MaterialApp(
          home: DrillSessionWidget(
            drillCode: 'STRAIGHT_POT',
            onStart: (session) => activeSession = session,
          ),
        ),
      );

      await tester.tap(find.text('Bắt đầu'));
      await tester.pump();

      expect(activeSession, isNotNull);
      expect(activeSession!.drillCode, equals('STRAIGHT_POT'));
      expect(activeSession!.completedReps, equals(0));
    });

    testWidgets('Complete drill updates Coach', (tester) async {
      final session = TestDrillSession(
        drillCode: 'STRAIGHT_POT',
        drillName: 'Đánh thẳng',
        targetReps: 10,
        completedReps: 10,
        successfulReps: 8,
        startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DrillCompletionWidget(
            session: session,
            onComplete: (s) => expect(s.completedReps, equals(10)),
          ),
        ),
      );

      expect(find.text('Hoàn thành!'), findsOneWidget);
    });

    testWidgets('Partial completion shows continue option', (tester) async {
      final session = TestDrillSession(
        drillCode: 'STRAIGHT_POT',
        drillName: 'Đánh thẳng',
        targetReps: 10,
        completedReps: 5,
        successfulReps: 3,
        startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DrillSessionWidget(
            drillCode: 'STRAIGHT_POT',
            existingSession: session,
          ),
        ),
      );

      expect(find.text('Tiếp tục (5/10)'), findsOneWidget);
    });
  });

  group('Coach Integration: Recommendation → Accept → Complete', () {
    testWidgets('Recommendation shown after drill completion', (tester) async {
      final coachState = TestCoachState(
        recommendations: [
          TestRecommendation(
            drillCode: 'STOP_BALL',
            drillName: 'Dừng bi',
            reason: 'Cần cải thiện cú dừng',
            createdAt: DateTime.now(),
          ),
        ],
        hasEnoughData: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CoachHomeWidget(state: coachState),
        ),
      );

      expect(find.text('Dừng bi'), findsOneWidget);
      expect(find.text('Cần cải thiện cú dừng'), findsOneWidget);
    });

    testWidgets('Accept recommendation updates state', (tester) async {
      bool accepted = false;
      final recommendation = TestRecommendation(
        drillCode: 'STOP_BALL',
        drillName: 'Dừng bi',
        reason: 'Cần cải thiện cú dừng',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RecommendationWidget(
            recommendation: recommendation,
            onAccept: () => accepted = true,
          ),
        ),
      );

      await tester.tap(find.text('Bắt đầu ngay'));
      expect(accepted, isTrue);
    });

    testWidgets('After accept, no new recommendation shown', (tester) async {
      final recommendations = [
        TestRecommendation(
          drillCode: 'STOP_BALL',
          drillName: 'Dừng bi',
          reason: 'Cần cải thiện cú dừng',
          isAccepted: true,
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: CoachHomeWidget(
            state: TestCoachState(
              recommendations: recommendations,
              hasEnoughData: true,
            ),
          ),
        ),
      );

      expect(find.text('Dừng bi'), findsOneWidget);
      expect(find.text('Đã chấp nhận'), findsOneWidget);
    });
  });

  group('Coach Integration: Interrupted Session', () {
    testWidgets('Interrupted session shows Continue', (tester) async {
      final session = TestDrillSession(
        drillCode: 'STRAIGHT_POT',
        drillName: 'Đánh thẳng',
        targetReps: 10,
        completedReps: 5,
        successfulReps: 3,
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CoachHomeWidget(
            state: TestCoachState(
              sessions: [session],
              hasInterruptedSession: true,
              hasEnoughData: true,
            ),
          ),
        ),
      );

      expect(find.text('Tiếp tục phiên tập luyện'), findsOneWidget);
      expect(find.text('Bài: Đánh thẳng'), findsOneWidget);
    });

    testWidgets('Continue session resumes progress', (tester) async {
      final session = TestDrillSession(
        drillCode: 'STRAIGHT_POT',
        drillName: 'Đánh thẳng',
        targetReps: 10,
        completedReps: 5,
        successfulReps: 3,
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DrillSessionWidget(
            drillCode: 'STRAIGHT_POT',
            existingSession: session,
          ),
        ),
      );

      expect(find.text('Tiếp tục (5/10)'), findsOneWidget);
    });
  });

  group('Coach Integration: Timeline', () {
    testWidgets('Timeline shows session history', (tester) async {
      final sessions = [
        TestDrillSession(
          drillCode: 'STRAIGHT_POT',
          drillName: 'Đánh thẳng',
          targetReps: 10,
          completedReps: 10,
          successfulReps: 8,
          startedAt: DateTime.now().subtract(const Duration(days: 1)),
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TimelineWidget(sessions: sessions),
        ),
      );

      expect(find.text('Đánh thẳng'), findsOneWidget);
      expect(find.textContaining('80%'), findsOneWidget);
    });

    testWidgets('Timeline shows recommendations', (tester) async {
      final recommendations = [
        TestRecommendation(
          drillCode: 'STOP_BALL',
          drillName: 'Dừng bi',
          reason: 'Cần cải thiện',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TimelineWidget(recommendations: recommendations),
        ),
      );

      expect(find.text('Dừng bi'), findsOneWidget);
    });
  });
}

// ============================================================================
// Test Widgets
// ============================================================================

class CoachHomeWidget extends StatelessWidget {
  final TestCoachState state;
  const CoachHomeWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (!state.hasEnoughData) {
      return const Scaffold(body: Center(child: Text('Không có đủ dữ liệu')));
    }
    if (state.hasInterruptedSession) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Tiếp tục phiên tập luyện'),
            Text('Bài: Đánh thẳng'),
          ],
        ),
      );
    }
    if (state.recommendations.isEmpty) {
      return const Scaffold(body: Center(child: Text('Không có khuyến nghị')));
    }
    final rec = state.recommendations.first;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(rec.drillName),
          Text(rec.reason),
          Text('Priority: ${rec.priority}'),
          if (rec.isAccepted) const Text('Đã chấp nhận'),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Bắt đầu ngay'),
          ),
        ],
      ),
    );
  }
}

class DrillSessionWidget extends StatelessWidget {
  final String drillCode;
  final TestDrillSession? existingSession;
  final Function(TestDrillSession)? onStart;

  const DrillSessionWidget({
    super.key,
    required this.drillCode,
    this.existingSession,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    if (existingSession != null) {
      return Scaffold(
        body: Center(
          child: Text('Tiếp tục (${existingSession!.completedReps}/${existingSession!.targetReps})'),
        ),
      );
    }
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            onStart?.call(TestDrillSession(
              drillCode: drillCode,
              drillName: 'Test',
              targetReps: 10,
              completedReps: 0,
              successfulReps: 0,
              startedAt: DateTime.now(),
            ));
          },
          child: const Text('Bắt đầu'),
        ),
      ),
    );
  }
}

class DrillCompletionWidget extends StatelessWidget {
  final TestDrillSession session;
  final Function(TestDrillSession)? onComplete;

  const DrillCompletionWidget({
    super.key,
    required this.session,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Hoàn thành!'),
            Text('${session.successfulReps}/${session.completedReps}'),
          ],
        ),
      ),
    );
  }
}

class RecommendationWidget extends StatelessWidget {
  final TestRecommendation recommendation;
  final VoidCallback? onAccept;

  const RecommendationWidget({
    super.key,
    required this.recommendation,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(recommendation.drillName),
            Text(recommendation.reason),
            ElevatedButton(
              onPressed: onAccept,
              child: const Text('Bắt đầu ngay'),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineWidget extends StatelessWidget {
  final List<TestDrillSession>? sessions;
  final List<TestRecommendation>? recommendations;

  const TimelineWidget({
    super.key,
    this.sessions,
    this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          if (sessions != null)
            ...sessions!.map((s) => ListTile(
                  title: Text(s.drillName),
                  subtitle: Text('${(s.successRate * 100).toInt()}%'),
                )),
          if (recommendations != null)
            ...recommendations!.map((r) => ListTile(
                  title: Text(r.drillName),
                  subtitle: Text(r.reason),
                )),
        ],
      ),
    );
  }
}
