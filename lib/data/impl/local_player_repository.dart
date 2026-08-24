import '../../data/datasources/local/local_storage_datasource.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/models/player.dart';
import '../../data/models/player_interests.dart';

/// Local Player Repository Implementation
class LocalPlayerRepository implements PlayerRepository {
  @override
  Future<Player?> getCurrentPlayer() async {
    final data = await LocalStorageDataSource.getPlayer();
    if (data == null) return null;
    return Player.fromJson(data);
  }

  @override
  Future<Player> createPlayer({
    required String name,
    String? email,
    String? avatarUrl,
    String? currentLevel,
    int? yearsPlaying,
    double? hoursPerWeek,
  }) async {
    final player = Player(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      currentLevel: currentLevel ?? 'beginner',
      yearsPlaying: yearsPlaying ?? 0,
      hoursPerWeek: hoursPerWeek ?? 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await LocalStorageDataSource.savePlayer(player.toJson());
    return player;
  }

  @override
  Future<Player> updatePlayer(Player player) async {
    final updated = player.copyWith(updatedAt: DateTime.now());
    await LocalStorageDataSource.savePlayer(updated.toJson());
    return updated;
  }

  @override
  Future<Player?> getPlayerById(String playerId) async {
    final current = await getCurrentPlayer();
    if (current?.id == playerId) return current;
    return null;
  }

  @override
  Future<PlayerInterests?> getPlayerInterests(String playerId) async {
    final data = await LocalStorageDataSource.getPlayerInterests();
    if (data == null) return null;
    return PlayerInterests.fromJson(data);
  }

  @override
  Future<PlayerInterests> savePlayerInterests({
    required String playerId,
    required List<String> interests,
  }) async {
    final playerInterests = PlayerInterests(
      id: 'interests_${DateTime.now().millisecondsSinceEpoch}',
      playerId: playerId,
      interests: interests,
      updatedAt: DateTime.now(),
    );
    await LocalStorageDataSource.savePlayerInterests(playerInterests.toJson());
    return playerInterests;
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return LocalStorageDataSource.isOnboardingCompleted();
  }

  @override
  Future<void> completeOnboarding() async {
    await LocalStorageDataSource.setOnboardingCompleted(true);
  }

  @override
  Future<bool> isFirstLaunch() async {
    return LocalStorageDataSource.isFirstLaunch();
  }

  @override
  Future<void> markFirstLaunchComplete() async {
    await LocalStorageDataSource.markFirstLaunchComplete();
  }
}
