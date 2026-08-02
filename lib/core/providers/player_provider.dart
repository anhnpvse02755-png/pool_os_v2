import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/player_interests.dart';
import '../services/player_service.dart';
import 'auth_provider.dart';

/// Player Profile Provider
final playerProvider = FutureProvider<Player?>((ref) async {
  final playerService = ref.watch(playerServiceProvider);
  return await playerService.getCurrentPlayer();
});

/// Player Interests Provider
final playerInterestsProvider = FutureProvider<PlayerInterests?>((ref) async {
  final player = await ref.watch(playerProvider.future);
  if (player == null) return null;

  final playerService = ref.watch(playerServiceProvider);
  return await playerService.getPlayerInterests(player.id);
});

/// Player Interests Notifier for updating
class PlayerInterestsNotifier extends StateNotifier<AsyncValue<PlayerInterests?>> {
  final PlayerService _playerService;
  final String? _playerId;

  PlayerInterestsNotifier(this._playerService, this._playerId)
      : super(const AsyncValue.data(null));

  Future<void> loadInterests() async {
    if (_playerId == null) return;
    state = const AsyncValue.loading();
    try {
      final interests = await _playerService.getPlayerInterests(_playerId!);
      state = AsyncValue.data(interests);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveInterests(List<String> interests) async {
    if (_playerId == null) return;
    state = const AsyncValue.loading();
    try {
      final saved = await _playerService.savePlayerInterests(
        playerId: _playerId!,
        interests: interests,
      );
      state = AsyncValue.data(saved);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final playerInterestsNotifierProvider =
    StateNotifierProvider<PlayerInterestsNotifier, AsyncValue<PlayerInterests?>>((ref) {
  final playerService = ref.watch(playerServiceProvider);
  final player = ref.watch(playerProvider);

  String? playerId;
  player.whenData((p) => playerId = p?.id);

  return PlayerInterestsNotifier(playerService, playerId);
});
