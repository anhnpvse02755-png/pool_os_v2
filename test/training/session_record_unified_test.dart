import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/core/providers/repository_providers.dart';
import 'package:pool_os_v2/core/providers/training_provider.dart';
import 'package:pool_os_v2/data/models/training_session.dart';
import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';
import 'package:pool_os_v2/core/services/local_storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    await LocalStorageDataSource.init();
    // _migrated was set to true by init().  Reset it so that the test body
    // (which calls init() again) can re-trigger the migration.
    await LocalStorageDataSource.resetMigrationFlag();
  });

  group('migrateDrillSessions', () {
    test('old drill_sessions migrates to training_history', () async {
      // Seed OLD-format data written by TrainingNotifier (old training_provider).
      // Format: shotsAttempted, date (not shotsMissed/completedAt).
      final oldSessions = [
        {
          'id': 'old1',
          'drillCode': 'BT01',
          'drillName': 'Bai 1',
          'level': 1,
          'score': 70,
          'shotsAttempted': 10,
          'shotsMade': 7,
          'duration': 10,
          'date': '2026-09-15T10:00:00.000',
        },
        {
          'id': 'old2',
          'drillCode': 'BT02',
          'drillName': 'Bai 2',
          'level': 2,
          'score': 85,
          'shotsAttempted': 20,
          'shotsMade': 17,
          'duration': 15,
          'date': '2026-09-14T08:30:00.000',
        },
      ];

      // LocalStorageService uses the same SharedPreferences as LocalStorageDataSource,
      // so writing via LocalStorageService.prefs lands in the same store.
      await LocalStorageService.prefs.setString(
        'drill_sessions',
        jsonEncode(oldSessions),
      );

      // training_history must be EMPTY for migration to trigger.
      expect(await LocalStorageDataSource.getTrainingHistory(), isEmpty);

      // Trigger the one-time migration.
      await LocalStorageDataSource.init();

      // Verify training_history now contains migrated records.
      final history = await LocalStorageDataSource.getTrainingHistory();

      expect(history.length, equals(2));

      final s1 = history.firstWhere((s) => s['id'] == 'old1');
      // TrainingSession.fromJson derives shotsMissed correctly from shotsAttempted.
      expect(s1['shotsMade'], equals(7));
      expect(s1['shotsMissed'], equals(3)); // 10 - 7
      // TrainingSession.fromJson reads 'date' as completedAt.
      expect(s1['completedAt'], equals('2026-09-15T10:00:00.000'));
      expect(s1['drillCode'], equals('BT01'));
      expect(s1['level'], equals(1));

      final s2 = history.firstWhere((s) => s['id'] == 'old2');
      expect(s2['shotsMade'], equals(17));
      expect(s2['shotsMissed'], equals(3)); // 20 - 17
      expect(s2['completedAt'], equals('2026-09-14T08:30:00.000'));
    });

    test('existing training_history is NOT overwritten', () async {
      // Seed existing (already-migrated) data in training_history.
      final existingHistory = [
        {
          'id': 'existing1',
          'drillCode': 'BT03',
          'drillName': 'Bai 3',
          'level': 1,
          'score': 90,
          'shotsMade': 9,
          'shotsMissed': 1,
          'duration': 8,
          'completedAt': '2026-09-16T14:00:00.000',
        },
      ];
      await LocalStorageDataSource.saveTrainingHistory(existingHistory);

      // Also seed old-format drill_sessions (simulating pre-migration data).
      final oldSessions = [
        {
          'id': 'old1',
          'drillCode': 'BT01',
          'drillName': 'Bai 1',
          'level': 1,
          'score': 70,
          'shotsAttempted': 10,
          'shotsMade': 7,
          'duration': 10,
          'date': '2026-09-15T10:00:00.000',
        },
      ];
      await LocalStorageService.prefs.setString(
        'drill_sessions',
        jsonEncode(oldSessions),
      );

      // Trigger the one-time migration.
      await LocalStorageDataSource.init();

      // training_history must still contain only the pre-existing record.
      final history = await LocalStorageDataSource.getTrainingHistory();

      expect(history.length, equals(1));
      expect(history.first['id'], equals('existing1'));
      expect(history.first['drillCode'], equals('BT03'));
    });
  });

  group('session record unified', () {
    test('buoi tap luu qua notifier phai hien ra o repository', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(trainingNotifierProvider.notifier);
      final repo = container.read(drillRepositoryProvider);

      await notifier.addSession(TrainingSession(
        id: 's1',
        drillCode: 'BT01',
        drillName: 'Bai 1',
        level: 1,
        score: 70,
        shotsMade: 7,
        shotsMissed: 3,
        duration: 10,
        completedAt: DateTime(2026, 9, 17),
      ));

      final history = await repo.getTrainingHistory();

      expect(history.map((s) => s.id), contains('s1'),
          reason: 'hai ban ghi tach roi: notifier ghi vao drill_sessions, '
              'repository doc tu training_history');
    });

    test('buoi tap luu qua repository phai hien ra o notifier sau refresh', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(drillRepositoryProvider);
      await repo.saveTrainingSession(TrainingSession(
        id: 's2',
        drillCode: 'BT02',
        drillName: 'Bai 2',
        level: 1,
        score: 80,
        shotsMade: 8,
        shotsMissed: 2,
        duration: 12,
        completedAt: DateTime(2026, 9, 17),
      ));

      final notifier = container.read(trainingNotifierProvider.notifier);
      await notifier.refresh();

      expect(
        container.read(trainingNotifierProvider).sessions.map((s) => s.id),
        contains('s2'),
      );
    });

    test('trainingHistoryProvider reflects new session after addSession', () async {
      // Verify Important 2: after addSession, trainingHistoryProvider (FutureProvider
      // that is NOT autoDispose and has no invalidation) is refreshed via
      // ref.invalidate inside TrainingNotifier.addSession.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(trainingNotifierProvider.notifier);

      await notifier.addSession(TrainingSession(
        id: 't1',
        drillCode: 'BT05',
        drillName: 'Bai 5',
        level: 1,
        score: 75,
        shotsMade: 15,
        shotsMissed: 5,
        duration: 20,
        completedAt: DateTime(2026, 9, 17),
      ));

      // trainingHistoryProvider is a FutureProvider — read it to get current data.
      final historyValue = await container.read(trainingHistoryProvider.future);

      expect(historyValue.map((s) => s.id), contains('t1'),
          reason: 'addSession must invalidate trainingHistoryProvider so '
              'FutureProvider readers see the new record');
    });
  });
}
