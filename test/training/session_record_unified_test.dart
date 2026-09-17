import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/core/providers/repository_providers.dart';
import 'package:pool_os_v2/core/providers/training_provider.dart';
import 'package:pool_os_v2/data/models/training_session.dart';
import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';

/// Runs fresh mock init for each test.
Future<void> _freshInit() async {
  SharedPreferences.setMockInitialValues({});
  await LocalStorageDataSource.init();
}

void main() {
  // ── migrateDrillSessions ────────────────────────────────────────────────
  group('migrateDrillSessions', () {
    // Khoa co di tru — trung voi _keyMigratedDrillSessions trong datasource.
    const migratedFlag = 'poolos_v2.migrated_drill_sessions';

    /// Handle truc tiep toi kho in-memory. Moi test o group nay phai seed
    /// TRUOC init(), ma `LocalStorageDataSource.prefs` thi nem neu chua init().
    /// setMockInitialValues() dat lai `_completer` cua shared_preferences, nen
    /// getInstance() o day tra ve dung instance ma init() se nhan sau do.
    late SharedPreferences seedPrefs;

    setUp(() async {
      // Kho sach tuyet doi: khong seed drill_sessions gi ca. Test nao can
      // drill_sessions thi tu ghi trong than test — neu setUp seed san "[]"
      // thi chot early-exit (G2) khong bao gio chay va cong G2 chet.
      SharedPreferences.setMockInitialValues({});
      seedPrefs = await SharedPreferences.getInstance();
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

      // Seed drill_sessions BEFORE init() so migration sees it.
      await seedPrefs.setString(
        'drill_sessions',
        jsonEncode(oldSessions),
      );

      // This init() runs migration against the seeded data.
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

      // Seed CA HAI khoa TRUOC lan init(). Co di tru chua bat, nen
      // G1 khong chan; drill_sessions co du lieu nen G2 khong chan. Thu duy
      // nhat giu 'existing1' lai la G3 (existingHistory.isNotEmpty).
      await seedPrefs.setString(
        'drill_sessions',
        jsonEncode(oldSessions),
      );
      await seedPrefs.setString(
        'training_history',
        jsonEncode(existingHistory),
      );

      await LocalStorageDataSource.init();

      final history = await LocalStorageDataSource.getTrainingHistory();
      expect(history.length, equals(1));
      // Neu G3 bi vo hieu, cho nay thanh 'old1' — do la cong dot bien cua G3.
      expect(history.first['id'], equals('existing1'));
      expect(history.first['drillCode'], equals('BT03'));
    });

    test('G2: khong co drill_sessions thi co di tru VAN duoc dat', () async {
      // Kho hoan toan sach: setUp KHONG seed drill_sessions, va test nay cung
      // khong seed. Nen `prefs.getString('drill_sessions')` tra null va luong
      // di dung vao khoi early-exit cua G2.
      await LocalStorageDataSource.init();

      // Chinh khoi early-exit (G2) phai dat co roi `return`. Neu bo lenh
      // setBool trong khoi do, ham thoat ma khong dat co — khong con setBool
      // nao khac chay vi `return` chan duong xuong cuoi ham — nen cho nay do.
      expect(
        seedPrefs.getBool(migratedFlag),
        isTrue,
        reason: 'khong co gi de di tru van phai danh dau da xong, '
            'neu khong init() nao cung chay lai vo ich',
      );
    });

    test('G1: da di tru roi thi init() sau KHONG chay lai', () async {
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

      // Lan 1: di tru chay, dat co, history=[old1].
      await seedPrefs.setString(
        'drill_sessions',
        jsonEncode(oldSessions),
      );
      await LocalStorageDataSource.init();

      // Dung trang thai ma G1 la thu DUY NHAT ngan thay doi:
      //   - training_history RONG  => G3 khong do thay
      //   - drill_sessions co 2 ban ghi => G2 khong do thay
      await seedPrefs
          .setString('training_history', jsonEncode(<Map<String, dynamic>>[]));
      await seedPrefs.setString(
        'drill_sessions',
        jsonEncode([
          ...oldSessions,
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
        ]),
      );

      // KHONG dat lai co di tru bang tay: lan init() o tren da dat no roi
      // (setBool cuoi ham di tru). Dat lai la tu tay dung trang thai ma G1
      // can, khien test khong con phu duoc chot setBool cuoi ham.
      await LocalStorageDataSource.init();

      // Neu G1 bi vo hieu, di tru chay lai va ghi 2 ban ghi vao day.
      expect(
        await LocalStorageDataSource.getTrainingHistory(),
        isEmpty,
        reason: 'co di tru da bat, init() sau khong duoc cham vao '
            'training_history nua',
      );
    });

    test('C: drill_sessions hong thi khong nem, va co KHONG duoc bat',
        () async {
      await seedPrefs.setString(
        'drill_sessions',
        '{khong phai json hop le',
      );

      // (a) init() khong duoc nem — du lieu hong khong duoc chan app khoi dong.
      // Bat tuong minh thay vi matcher `completes`: matcher do bao lai nguyen
      // exception goc, con cach nay do o dung mot dong expect.
      Object? thrown;
      try {
        await LocalStorageDataSource.init();
      } catch (e) {
        thrown = e;
      }
      expect(
        thrown,
        isNull,
        reason: 'du lieu hong khong duoc lam vo init(): app van phai khoi '
            'dong duoc, chi la chua di tru',
      );

      // (b) ve dat nhat: dat co khi that bai nghia la du lieu cu KET VINH VIEN.
      expect(
        seedPrefs.getBool(migratedFlag),
        isNot(isTrue),
        reason: 'di tru that bai ma van danh dau da xong thi khong bao gio '
            'thu lai duoc nua',
      );

      // (c) sua du lieu thanh hop le roi init() lai => di tru chay duoc.
      await seedPrefs.setString(
        'drill_sessions',
        jsonEncode([
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
        ]),
      );
      await LocalStorageDataSource.init();

      final history = await LocalStorageDataSource.getTrainingHistory();
      expect(history.length, equals(1));
      expect(history.first['id'], equals('old1'));
      expect(seedPrefs.getBool(migratedFlag), isTrue);
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
      // Seed drill_sessions BEFORE init() so migration sees it.
      await seedPrefs.setString(
        'drill_sessions',
        jsonEncode(oldSessions),
      );

      // init() runs migration against the seeded data.
      await LocalStorageDataSource.init();

      // Truoc het phai chac chan di tru THAT SU da chay — neu khong, khang
      // dinh "khoa con nguyen" ben duoi la khang dinh tren trang thai khong
      // co di tru nao, va no dung ke ca khi tat han di tru.
      final history = await LocalStorageDataSource.getTrainingHistory();
      expect(history.length, equals(1));
      expect(history.first['id'], equals('old1'));
      expect(history.first['shotsMissed'], equals(3)); // 10 - 7
      expect(history.first['completedAt'], equals('2026-09-15T10:00:00.000'));

      // ... VA drill_sessions van con nguyen: di tru la sao chep, khong phai
      // di chuyen. Xoa khoa cu di la mat duong lui neu di tru sai.
      final raw = seedPrefs.getString('drill_sessions');
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
      // Seed drill_sessions BEFORE init() so migration sees it.
      await seedPrefs.setString(
        'drill_sessions',
        jsonEncode(oldSessions),
      );

      // init() runs migration.
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
