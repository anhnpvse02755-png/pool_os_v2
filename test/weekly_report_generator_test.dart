import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/domain/services/weekly_report_generator.dart';
import 'package:pool_os_v2/domain/services/match_statistics_service.dart';
import 'package:pool_os_v2/data/repositories/match_repository.dart';
import 'package:pool_os_v2/data/repositories/shot_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/core/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  test('empty week generates zero matches report', () async {
    final generator = WeeklyReportGenerator(
      LocalMatchRepository(),
      MatchStatisticsService(LocalMatchRepository(), LocalShotRepository()),
    );
    final r = await generator.generate();
    expect(r.matchesPlayed, 0);
    expect(r.winRate, 0);
    expect(r.topStrengths.isEmpty, isTrue);
  });
}