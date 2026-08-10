import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/data/models/personal_best.dart';
import 'package:pool_os_v2/data/repositories/personal_best_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/core/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  test('personal best only updated when better', () async {
    final repo = LocalPersonalBestRepository();
    final player = 'p1';
    final drill = 'stun_line';
    // For fastest metric: lower value = better (faster time).
    await repo.save(PersonalBest(
      playerId: player,
      drillCode: drill,
      metric: PbMetric.fastest,
      value: 30.0,  // 30 seconds
      level: 1,
      achievedAt: DateTime.now(),
    ));
    await repo.save(PersonalBest(
      playerId: player,
      drillCode: drill,
      metric: PbMetric.fastest,
      value: 25.0,  // 25 seconds — faster, should replace
      level: 1,
      achievedAt: DateTime.now(),
    ));
    final all = await repo.getAll(player);
    expect(all.length, 1);
    expect(all.first.value, 25.0);  // Correct: 25 < 30, so faster = better
  });

  test('highest accuracy — higher value = better', () async {
    final repo = LocalPersonalBestRepository();
    final player = 'p1';
    final drill = 'stun_line';
    await repo.save(PersonalBest(
      playerId: player,
      drillCode: drill,
      metric: PbMetric.highestAccuracy,
      value: 75.0,
      level: 1,
      achievedAt: DateTime.now(),
    ));
    await repo.save(PersonalBest(
      playerId: player,
      drillCode: drill,
      metric: PbMetric.highestAccuracy,
      value: 80.0,  // Higher accuracy — should replace
      level: 1,
      achievedAt: DateTime.now(),
    ));
    final all = await repo.getAll(player);
    expect(all.length, 1); // Only one accuracy PB (75 replaced by 80)
    final acc = all.first;
    expect(acc.metric, PbMetric.highestAccuracy);
    expect(acc.value, 80.0);
  });
}