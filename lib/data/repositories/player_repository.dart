import '../models/player.dart';
import '../models/player_interests.dart';

/// Player Repository Interface
/// Abstracts data access for player-related operations
abstract class PlayerRepository {
  /// Get current player profile
  Future<Player?> getCurrentPlayer();

  /// Create new player profile
  Future<Player> createPlayer({
    required String name,
    String? email,
    String? avatarUrl,
  });

  /// Update player profile
  Future<Player> updatePlayer(Player player);

  /// Get player by ID
  Future<Player?> getPlayerById(String playerId);

  /// Get player interests
  Future<PlayerInterests?> getPlayerInterests(String playerId);

  /// Save player interests
  Future<PlayerInterests> savePlayerInterests({
    required String playerId,
    required List<String> interests,
  });

  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted();

  /// Mark onboarding as completed
  Future<void> completeOnboarding();

  /// Check if first launch
  Future<bool> isFirstLaunch();

  /// Mark first launch complete
  Future<void> markFirstLaunchComplete();
}
