import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/data/models/match.dart';
import 'package:pool_os_v2/data/repositories/match_repository.dart';
import 'package:pool_os_v2/domain/services/streak_calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/core/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  Future<void> _seed(List<DateTime> dates) async {
    final repo = LocalMatchRepository();
    for (int i = 0; i < dates.length; i++) {
      await repo.saveMatch(Match(
        id: 'm-$i',
        playerId: 'p1',
        gameType: '8-ball',
        raceTo: 5,
        opponent: 'op',
        result: 'win',
        startTime: dates[i],
        createdAt: dates[i],
        updatedAt: dates[i],
      ));
    }
  }

  test('current streak counts back-to-back days', () async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 12);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    await _seed([today, yesterday, twoDaysAgo]);
    final calc = StreakCalculator(LocalMatchRepository());
    final streak = await calc.currentStreak(playerId: 'p1');
    expect(streak, 3);
  });

  test('streak breaks on a gap', () async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 12);
    await _seed([today, today.subtract(const Duration(days: 2))]);
    final calc = StreakCalculator(LocalMatchRepository());
    final streak = await calc.currentStreak(playerId: 'p1');
    expect(streak, 1);
  });
}