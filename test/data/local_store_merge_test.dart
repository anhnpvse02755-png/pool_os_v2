import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';

void main() {
  setUp(() async {
    LocalStorageDataSource.reset();
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
    LocalStorageDataSource.setTestPrefs(await SharedPreferences.getInstance());
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
    // reset() must come BEFORE setMockInitialValues — because _prefs is a static
    // singleton that setMockInitialValues does NOT reset.
    LocalStorageDataSource.reset();
    SharedPreferences.setMockInitialValues({
      'latest_match_analysis': '{"score":9}',
      'player_intelligence': '{"level":5}',
    });
    await LocalStorageDataSource.init();

    expect(LocalStorageDataSource.getLatestMatchAnalysis(), equals({'score': 9}));
    expect(LocalStorageDataSource.getPlayerIntelligence(), equals({'level': 5}));
  });

  // =========================================================================
  // B: wipeAllLocalData() must clear coach keys so a subsequent init() does
  // NOT re-migrate orphan drill_sessions back into the freshly-wiped history.
  // The correct order: wipe both drill_sessions AND the migration flag,
  // then wipe everything else.  Wiping only the flag (leaving drill_sessions)
  // makes the next init() re-migrate — the wipe command defeats itself.
  // =========================================================================

  test('wipeAllLocalData clears coach keys', () async {
    await LocalStorageDataSource.saveLatestMatchAnalysis({'score': 7});
    await LocalStorageDataSource.savePlayerIntelligence({'level': 3});

    await LocalStorageDataSource.wipeAllLocalData();

    expect(LocalStorageDataSource.getLatestMatchAnalysis(), isNull);
    expect(LocalStorageDataSource.getPlayerIntelligence(), isNull);
  });

  test('wipeAllLocalData then init leaves training_history empty (no re-migration)',
      () async {
    // Pre-populate via getTrainingHistory path (not via drill_sessions).
    // WipeAll must clear drill_sessions AND the migration flag so that init()
    // cannot re-migrate anything.
    await LocalStorageDataSource.saveTrainingHistory([
      {'id': 's1', 'drillCode': 'BT01', 'score': 80},
    ]);
    await LocalStorageDataSource.wipeAllLocalData();
    await LocalStorageDataSource.init();

    final history = await LocalStorageDataSource.getTrainingHistory();
    expect(history, isEmpty,
        reason:
            'wipeAllLocalData must clear the migration flag so init() '
            'does not re-migrate orphan drill_sessions back into '
            'the freshly-wiped training_history');
  });
}
