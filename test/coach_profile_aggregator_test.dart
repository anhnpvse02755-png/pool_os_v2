import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/domain/services/coach_profile_aggregator.dart';
import 'package:pool_os_v2/data/repositories/match_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/core/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  test('profile with no matches returns zero analyzed', () async {
    final agg = CoachProfileAggregator(LocalMatchRepository());
    final p = await agg.generate('p1');
    expect(p.matchesAnalyzed, 0);
    expect(p.tone, 'Steady');
    expect(p.skillScores.isEmpty, isTrue);
  });
}