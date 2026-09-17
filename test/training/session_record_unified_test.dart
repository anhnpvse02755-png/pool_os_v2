import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/core/providers/repository_providers.dart';
import 'package:pool_os_v2/core/providers/training_provider.dart';
import 'package:pool_os_v2/data/models/training_session.dart';
import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';
import 'package:pool_os_v2/core/services/local_storage_service.dart';

/// Runs fresh mock init for each test.
Future<void> _freshInit() async {
  SharedPreferences.setMockInitialValues({});
  await LocalStorageDataSource.init();
  await LocalStorageService.init();
}

void main() {
  // ── migrateDrillSessions ────────────────────────────────────────────────
  group('migrateDrillSessions', () {
    setUp(() async {
      // LocalStorageService.init() uses _prefs = (always fetches fresh), so it
      // picks up the fresh mock. init() is called per test body after seeding.
      SharedPreferences.setMockInitialValues({});
      await LocalStorageService.init();
    });

    test('old drill_sessions migrates to training_history', () async {
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

      // Seed drill_sessions via LocalStorageService (which has _prefs from setUp).
      await LocalStorageService.prefs.setString(
        'drill_sessions',
        jsonEncode(oldSessions),
      );

      // init() luon gan lai _prefs, va setMockInitialValues dat _completer=null,
      // nen getInstance() o day tra ve instance moi doc tu store rong.
      await LocalStorageDataSource.init();

      final history = await LocalStorageDataSource.getTrainingHistory();
      expect(history.length, equals(2));

      final s1 = history.firstWhere((s) => s['id'] == 'old1');
      expect(s1['shotsMade'], equals(7));
      expect(s1['shotsMissed'], equals(3)); // 10 - 7
      expect(s1['completedAt'], equals('2026-09-15T10:00:00.000'));

      final s2 = history.firstWhere((s) => s['id'] == 'old2');
      expect(s2['shotsMade'], equals(17));
      expect(s2['shotsMissed'], equals(3)); // 20 - 17
      expect(s2['completedAt'], equals('2026-09-14T08:30:00.000'));
    });

    test('existing training_history is NOT overwritten', () async {
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

      // First init(): drill_sessions is empty, flag gets set to true.
      await LocalStorageDataSource.init();

      // Seed both keys after flag is set.
      await LocalStorageDataSource.prefs.setString(
        'training_history',
        jsonEncode(existingHistory),
      );
      await LocalStorageDataSource.prefs.setString(
        'drill_sessions',
        jsonEncode(oldSessions),
      );

      // Second init(): flag already true — skips migration, preserves history.
      await LocalStorageDataSource.init();

      final history = await LocalStorageDataSource.getTrainingHistory();
      expect(history.length, equals(1));
      expect(history.first['id'], equals('existing1'));
      expect(history.first['drillCode'], equals('BT03'));
    });

    test('drill_sessions key is preserved after migration', () async {
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
      // Seed via LocalStorageService (which has _prefs from setUp).
      await LocalStorageService.prefs.setString(
        'drill_sessions',
        jsonEncode(oldSessions),
      );

      // init() luon gan lai _prefs tu mock moi — khong can API reset nao.
      await LocalStorageDataSource.init();

      // drill_sessions must still be present — no deletion.
      final raw = LocalStorageDataSource.prefs.getString('drill_sessions');
      expect(raw, isNotNull);
      final remaining =
          (jsonDecode(raw!) as List).cast<Map<String, dynamic>>();
      expect(remaining.length, equals(1));
      expect(remaining.first['id'], equals('old1'));
    });

    test('init() called twice does NOT duplicate training_history records',
        () async {
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
      // Seed via LocalStorageService (which has _prefs from setUp).
      await LocalStorageService.prefs.setString(
        'drill_sessions',
        jsonEncode(oldSessions),
      );

      // init() luon gan lai _prefs tu mock moi — khong can API reset nao.
      await LocalStorageDataSource.init();

      // Second init() must NOT re-run migration (would duplicate).
      await LocalStorageDataSource.init();

      final history = await LocalStorageDataSource.getTrainingHistory();
      expect(history.length, equals(1));
      expect(history.first['id'], equals('old1'));
    });
  });

  // ── session record unified ───────────────────────────────────────────────
  group('session record unified', () {
    setUp(() async {
      await _freshInit();
    });

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

    test('buoi tap luu qua repository phai hien ra o notifier sau refresh',
        () async {
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

    test('trainingHistoryProvider reflects new session after addSession',
        () async {
      // Verify Important 2: read BEFORE addSession to prime the FutureProvider
      // with the empty state.  Without ref.invalidate, the second read would
      // return the same stale value.  With ref.invalidate, it re-fetches.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Prime the FutureProvider — it is now cached with empty data.
      await container.read(trainingHistoryProvider.future);

      // Add a new session through the notifier.
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

      // Read trainingHistoryProvider again.  If addSession called
      // ref.invalidate(trainingHistoryProvider), this re-fetches from storage.
      // If the invalidate call is removed, this still returns the cached empty
      // list and the test FAILS — proving the test guards the right behaviour.
      final historyValue =
          await container.read(trainingHistoryProvider.future);

      expect(historyValue.map((s) => s.id), contains('t1'),
          reason: 'addSession must invalidate trainingHistoryProvider so '
              'FutureProvider readers see the new record');
    });
  });
}
