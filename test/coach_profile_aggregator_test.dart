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
    // With no matches, the aggregator still seeds the 5 canonical skill
    // axes at the neutral 50.0 baseline so the UI has a stable rendering
    // shape. This is a documented behavior — see skillScores in
    // lib/domain/services/coach_profile_aggregator.dart.
    expect(p.skillScores, isNotEmpty);
    expect(p.skillScores.length, 5);
    // Cutting and Safety default to 50 (neutral midpoint); Break & Run,
    // Specialty, and Discipline depend on input counts so are 0 here.
    expect(p.skillScores['Cutting'], 50.0);
    expect(p.skillScores['Safety'], 50.0);
    expect(p.skillScores['Break & Run'], 0.0);
    expect(p.skillScores['Specialty'], 0.0);
    expect(p.skillScores['Discipline'], 100.0);
  });
}