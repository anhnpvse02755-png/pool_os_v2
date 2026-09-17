import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';

/// Khoa co di tru — trung voi _keyMigratedDrillSessions trong datasource.
const _migratedFlag = 'poolos_v2.migrated_drill_sessions';

/// Mot ban ghi drill_sessions dinh dang CU (shotsAttempted + date).
Map<String, dynamic> _orphan(String id) => {
      'id': id,
      'drillCode': 'BT01',
      'drillName': 'Bai 1',
      'level': 1,
      'score': 70,
      'shotsAttempted': 10,
      'shotsMade': 7,
      'duration': 10,
      'date': '2026-09-15T10:00:00.000',
    };

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageDataSource.init();
  });

  test('latest_match_analysis: luu roi doc lai', () async {
    await LocalStorageDataSource.saveLatestMatchAnalysis({'score': 7});
    expect(LocalStorageDataSource.getLatestMatchAnalysis(), equals({'score': 7}));

    await LocalStorageDataSource.clearLatestMatchAnalysis();
    expect(LocalStorageDataSource.getLatestMatchAnalysis(), isNull);
  });

  test('player_intelligence: luu roi doc lai', () async {
    await LocalStorageDataSource.savePlayerIntelligence({'level': 3});
    expect(LocalStorageDataSource.getPlayerIntelligence(), equals({'level': 3}));
  });

  test('giu nguyen ten key nen du lieu cu van doc duoc', () async {
    // setMockInitialValues() dat lai `_completer` cua shared_preferences, nen
    // init() ngay sau do lay dung kho moi nay.
    SharedPreferences.setMockInitialValues({
      'latest_match_analysis': '{"score":9}',
      'player_intelligence': '{"level":5}',
    });
    await LocalStorageDataSource.init();

    expect(LocalStorageDataSource.getLatestMatchAnalysis(), equals({'score': 9}));
    expect(LocalStorageDataSource.getPlayerIntelligence(), equals({'level': 5}));
  });

  // =========================================================================
  // B: bay thu tu cua wipeAllLocalData().
  //
  // wipe phai xoa CA HAI khoa cua duong di tru — `drill_sessions` va co
  // `poolos_v2.migrated_drill_sessions` — va hai nua do hong theo hai kieu
  // NGUOC NHAU, nen phai co HAI test rieng:
  //
  //   * quen xoa `drill_sessions`  => init() sau wipe di tru NGUOC du lieu
  //     vua xoa tro lai history. Test 1 canh cho nay.
  //   * quen xoa co di tru         => kho khong con tro ve trang thai
  //     "chua tung di tru"; lan wipe nay lam cho mot dot di tru ve sau khong
  //     bao gio chay duoc nua. Test 2 canh cho nay.
  //
  // Mot test khong du: neu chi kiem "history rong sau wipe" thi khi bo
  // remove(co di tru), init() thoat som o G1 va history VAN rong — test xanh
  // du chot da chet.
  // =========================================================================

  test('wipeAllLocalData clears coach keys', () async {
    await LocalStorageDataSource.saveLatestMatchAnalysis({'score': 7});
    await LocalStorageDataSource.savePlayerIntelligence({'level': 3});

    await LocalStorageDataSource.wipeAllLocalData();

    expect(LocalStorageDataSource.getLatestMatchAnalysis(), isNull);
    expect(LocalStorageDataSource.getPlayerIntelligence(), isNull);
  });

  test('1) wipeAllLocalData roi init() KHONG di tru nguoc drill_sessions',
      () async {
    // Kho rieng cho test nay: setUp da init() mot lan (dat co di tru tren kho
    // rong), nen phai dung lai tu dau de lan init() duoi day THAT SU di tru.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('drill_sessions', jsonEncode([_orphan('orphan1')]));

    await LocalStorageDataSource.init();

    // Canh gac: neu di tru khong chay thi ba dong duoi day chang chung minh
    // gi — history rong ke ca khi wipe hong.
    expect(
      (await LocalStorageDataSource.getTrainingHistory()).length,
      equals(1),
      reason: 'phai co du lieu da di tru truoc khi wipe, neu khong test nay '
          'khang dinh tren mot kho von da rong',
    );

    await LocalStorageDataSource.wipeAllLocalData();
    await LocalStorageDataSource.init();

    // Neu wipe quen `remove(drill_sessions)`: co di tru da bi xoa nen G1
    // khong chan, drill_sessions mo coi con nguyen => orphan1 quay lai day.
    expect(
      await LocalStorageDataSource.getTrainingHistory(),
      isEmpty,
      reason: 'wipeAllLocalData phai xoa ca drill_sessions, neu khong init() '
          'ngay sau do se di tru nguoc du lieu vua bi xoa tro lai',
    );
  });

  test('2) wipeAllLocalData xoa co di tru nen dot di tru ve sau van chay duoc',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('drill_sessions', jsonEncode([_orphan('orphan1')]));

    await LocalStorageDataSource.init();
    expect(
      prefs.getBool(_migratedFlag),
      isTrue,
      reason: 'canh gac: di tru lan 1 phai da chay va bat co',
    );

    await LocalStorageDataSource.wipeAllLocalData();

    // Sau wipe, kho phai tro ve dung trang thai "chua tung di tru". Du lieu
    // dinh dang cu xuat hien lai (ban cu ghi tiep, hoac khoi phuc backup)
    // phai duoc di tru binh thuong.
    await prefs.setString('drill_sessions', jsonEncode([_orphan('orphan2')]));
    await LocalStorageDataSource.init();

    // Neu wipe quen `remove(co di tru)`: co van la true => G1 chan =>
    // orphan2 khong bao gio vao history => cho nay do.
    expect(
      (await LocalStorageDataSource.getTrainingHistory())
          .map((s) => s['id']),
      contains('orphan2'),
      reason: 'wipeAllLocalData phai xoa co di tru, neu khong mot lan wipe '
          'khoa vinh vien duong di tru cho moi du lieu cu ve sau',
    );
  });
}
