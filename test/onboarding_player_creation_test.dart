import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';
import 'package:pool_os_v2/data/impl/local_player_repository.dart';
import 'package:pool_os_v2/data/repositories/player_repository.dart';
import 'package:pool_os_v2/core/utils/pool_rating_calculator.dart';

void main() {
  // Initialize SharedPreferences before all tests
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageDataSource.init();
  });

  group('Onboarding Player Creation', () {
    test('onboarding completion → isOnboardingCompleted is true', () async {
      // Wipe first to ensure clean state
      await LocalStorageDataSource.wipeAllLocalData();
      final repo = LocalPlayerRepository();

      // Given: onboarding not completed
      var completed = await repo.isOnboardingCompleted();
      expect(completed, isFalse);

      // When: complete onboarding
      await repo.completeOnboarding();

      // Then: onboarding is marked complete
      completed = await repo.isOnboardingCompleted();
      expect(completed, isTrue);
    });

    test('PoolRatingCalculator maps assessment answers to levels', () {
      // Test various answer combinations
      final beginnerAnswers = {1: 0, 2: 1, 3: 1, 4: 1, 5: 0, 6: 0, 7: 1, 8: 1};
      final rating1 = PoolRatingCalculator.calculateFromAssessment(beginnerAnswers);

      final intermediateAnswers = {1: 4, 2: 3, 3: 5, 4: 5, 5: 3, 6: 3, 7: 4, 8: 4};
      final rating2 = PoolRatingCalculator.calculateFromAssessment(intermediateAnswers);

      // Verify different levels based on answers
      expect(rating1, lessThan(rating2));
    });

    test('createPlayer saves player data correctly', () async {
      // Wipe first to ensure clean state
      await LocalStorageDataSource.wipeAllLocalData();
      final repo = LocalPlayerRepository();

      // When: create player
      final player = await repo.createPlayer(
        name: 'Test Player',
        currentLevel: 'B',
        yearsPlaying: 2,
        hoursPerWeek: 5.0,
      );

      // Then: player has correct data
      expect(player.id, startsWith('local_'));
      expect(player.name, 'Test Player');
      expect(player.currentLevel, 'B');
      expect(player.yearsPlaying, 2);
      expect(player.hoursPerWeek, 5.0);
    });

    test('createPlayer with defaults works', () async {
      // Wipe first to ensure clean state
      await LocalStorageDataSource.wipeAllLocalData();
      final repo = LocalPlayerRepository();

      // When: create player with minimal data
      final player = await repo.createPlayer(
        name: 'Minimal Player',
      );

      // Then: player has defaults
      expect(player.name, 'Minimal Player');
      expect(player.currentLevel, 'beginner'); // default
      expect(player.yearsPlaying, 0); // default
      expect(player.hoursPerWeek, 0.0); // default
    });
  });
}
