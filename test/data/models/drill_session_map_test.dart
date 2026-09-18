import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/data/models/drill_session.dart';
import 'package:pool_os_v2/data/models/training_session.dart';

void main() {
  test('toTrainingSessionMap phat ra shotsMissed va completedAt', () {
    final now = DateTime.now();
    final run = DrillRun(
      id: 'run-1',
      sessionId: 'sess-1',
      drillCode: '3-BALL',
      drillName: '3 Ball Drill',
      level: 1,
      targetScore: 5,
      attempts: 10,
      successes: 7,
      successRate: 7 / 10,
      durationSeconds: 300,
      createdAt: now,
      updatedAt: now,
    );

    final session = DrillSession(
      id: 'sess-1',
      playerId: 'player-1',
      title: 'Practice Session',
      startedAt: now.subtract(const Duration(minutes: 30)),
      completedAt: now,
      drillRuns: [run],
    );

    final map = session.toTrainingSessionMap();

    expect(map.containsKey('shotsMissed'), isTrue,
        reason: 'thieu khoa nay thi model dich doc ra 0');
    expect(map['shotsMissed'], equals(3));
    expect(map.containsKey('completedAt'), isTrue,
        reason: 'thieu khoa nay thi buoi tap mang gio doc');

    // Vong tron: map -> model phai giu nguyen y nghia
    final restored = TrainingSession.fromJson(map);
    expect(restored.shotsMade, equals(7));
    expect(restored.shotsMissed, equals(3));
    expect(restored.shotsAttempted, equals(10));
  });
}
