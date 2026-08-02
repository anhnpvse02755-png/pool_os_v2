import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/player.dart';
import '../models/player_interests.dart';

/// Player Service - Handles player-related database operations
class PlayerService {
  final SupabaseClient _client;

  PlayerService(this._client);

  /// Get current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Get current player profile
  Future<Player?> getCurrentPlayer() async {
    if (currentUser == null) return null;

    final response = await _client
        .from('players')
        .select()
        .eq('user_id', currentUser!.id)
        .maybeSingle();

    if (response == null) return null;
    return Player.fromJson(response);
  }

  /// Create new player profile
  Future<Player> createPlayer({
    required String name,
    String? email,
    String? avatarUrl,
  }) async {
    final response = await _client.from('players').insert({
      'user_id': currentUser!.id,
      'name': name,
      'email': email ?? currentUser!.email,
      'avatar_url': avatarUrl,
    }).select().single();

    return Player.fromJson(response);
  }

  /// Update player profile
  Future<Player> updatePlayer(Player player) async {
    final response = await _client
        .from('players')
        .update(player.toJson())
        .eq('id', player.id)
        .select()
        .single();

    return Player.fromJson(response);
  }

  /// Get player by ID
  Future<Player?> getPlayerById(String playerId) async {
    final response = await _client
        .from('players')
        .select()
        .eq('id', playerId)
        .maybeSingle();

    if (response == null) return null;
    return Player.fromJson(response);
  }

  /// Get player interests
  Future<PlayerInterests?> getPlayerInterests(String playerId) async {
    final response = await _client
        .from('player_interests')
        .select()
        .eq('player_id', playerId)
        .maybeSingle();

    if (response == null) return null;
    return PlayerInterests.fromJson(response);
  }

  /// Save player interests
  Future<PlayerInterests> savePlayerInterests({
    required String playerId,
    required List<String> interests,
  }) async {
    // Check if interests already exist
    final existing = await _client
        .from('player_interests')
        .select()
        .eq('player_id', playerId)
        .maybeSingle();

    if (existing != null) {
      // Update existing
      final response = await _client
          .from('player_interests')
          .update({
            'interests': interests,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing['id'])
          .select()
          .single();
      return PlayerInterests.fromJson(response);
    } else {
      // Insert new
      final response = await _client.from('player_interests').insert({
        'player_id': playerId,
        'interests': interests,
      }).select().single();
      return PlayerInterests.fromJson(response);
    }
  }
}
