import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/data/models/drill_attempt.dart';
import 'package:pool_os_v2/data/models/drill_session.dart';
import 'package:pool_os_v2/domain/services/drill_session_recovery_service.dart';
import 'package:pool_os_v2/data/repositories/drill_session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/core/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  test('pause / resume sets and clears pausedAt', () async {
    final repo = LocalDrillSessionRepository();
    final svc = DrillSessionRecoveryService(repo);
    final now = DateTime.now();
    final session = DrillSession(
      id: 's1',
      playerId: 'p1',
      title: 'Test',
      startedAt: now,
    );
    await repo.save(session);
    final paused = await svc.pause(session);
    expect(paused.pausedAt, isNotNull);

    final recovered = await svc.recover('p1');
    expect(recovered, isNotNull);
    expect(recovered!.id, 's1');

    final resumed = await svc.resume(recovered);
    expect(resumed.pausedAt, isNull);
  });

  test('recordAttempt increments totals and persists', () async {
    final repo = LocalDrillSessionRepository();
    final svc = DrillSessionRecoveryService(repo);
    final now = DateTime.now();
    final session = DrillSession(
      id: 's2',
      playerId: 'p2',
      title: 'Test2',
      startedAt: now,
    );
    await repo.save(session);
    var s = await svc.recordAttempt(session,
        drillCode: 'drill-A', attemptNumber: 1, made: true);
    s = await svc.recordAttempt(s,
        drillCode: 'drill-A', attemptNumber: 2, made: false);
    final saved = await repo.getById('s2');
    expect(saved!.attempts.length, 2);
    expect(saved.totalShotsMade, 1);
    expect(saved.totalShotsMissed, 1);
    expect(saved.accuracy, 50.0);
  });

  test('complete sets duration and totals', () async {
    final repo = LocalDrillSessionRepository();
    final svc = DrillSessionRecoveryService(repo);
    final session = DrillSession(
      id: 's3',
      playerId: 'p3',
      title: 'Test3',
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      attempts: [
        DrillAttempt(
          id: 'a1',
          sessionId: 's3',
          drillCode: 'X',
          attemptNumber: 1,
          made: true,
          createdAt: DateTime.now(),
        ),
        DrillAttempt(
          id: 'a2',
          sessionId: 's3',
          drillCode: 'X',
          attemptNumber: 2,
          made: false,
          createdAt: DateTime.now(),
        ),
      ],
    );
    await repo.save(session);
    final completed = await svc.complete(session);
    expect(completed.completedAt, isNotNull);
    expect(completed.totalMinutes, greaterThanOrEqualTo(5));
    expect(completed.totalShotsMade, 1);
    expect(completed.totalShotsMissed, 1);
    expect(completed.isActive, isFalse);
  });
}