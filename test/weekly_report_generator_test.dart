import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/domain/services/weekly_report_generator.dart';
import 'package:pool_os_v2/data/repositories/match_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LocalStorageDataSource.reset();
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
    LocalStorageDataSource.setTestPrefs(await SharedPreferences.getInstance());
    await LocalStorageDataSource.init();
  });

  test('empty week generates zero matches report', () async {
    final generator = WeeklyReportGenerator(LocalMatchRepository());
    final r = await generator.generate();
    expect(r.matchesPlayed, 0);
    expect(r.winRate, 0);
    expect(r.topStrengths.isEmpty, isTrue);
  });
}