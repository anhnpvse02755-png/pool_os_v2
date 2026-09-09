// ============================================================================
// PLAYER SERVICE — trên nền Directus
// ============================================================================
//
// Thay bản Supabase cũ. Bản cũ KHÔNG BAO GIỜ chạy được: nó lấy client từ
// `Supabase.instance.client`, mà Supabase chưa từng được khởi tạo (thiếu
// --dart-define), nên `playerProvider` luôn ở trạng thái lỗi.
//
// Collection: `poolos_players`. Quyền đã lọc theo `user_created`, nên mỗi
// người chỉ đọc/ghi hồ sơ của chính mình — không cần lọc thêm ở client.
// ============================================================================

import '../../data/remote/directus_client.dart';
import '../models/player.dart';
import '../models/player_interests.dart';

class PlayerService {
  PlayerService(this._client);

  final DirectusClient _client;

  static const String _collection = 'poolos_players';

  /// Hồ sơ của người đang đăng nhập, hoặc null nếu chưa đăng nhập / chưa tạo.
  Future<Player?> getCurrentPlayer() async {
    final session = await _client.tokenStore.read();
    if (session == null) return null;

    final rows = await _client.readItems(_collection, query: {'limit': 1});
    if (rows.isEmpty) return null;
    return _toPlayer(rows.first);
  }

  Future<Player?> getPlayerById(String playerId) async {
    final rows = await _client.readItems(_collection, query: {
      'filter[id][_eq]': playerId,
      'limit': 1,
    });
    return rows.isEmpty ? null : _toPlayer(rows.first);
  }

  Future<Player> createPlayer({
    required String name,
    String? email,
    String? avatarUrl,
  }) async {
    final row = await _client.createItem(_collection, {'display_name': name});
    return _toPlayer(row, email: email, avatarUrl: avatarUrl);
  }

  Future<Player> updatePlayer(Player player) async {
    final row = await _client.updateItem(_collection, player.id, {
      'display_name': player.name,
      'current_level': player.currentLevel,
      'dominant_hand': player.dominantHand,
      'years_playing': player.yearsPlaying,
      'hours_per_week': player.hoursPerWeek,
    });
    return _toPlayer(row, email: player.email, avatarUrl: player.avatarUrl);
  }

  // `poolos_players` chưa có cột interests. Giữ chữ ký để `player_provider`
  // và màn onboarding không phải đổi, trả về null cho tới khi mục "nối các
  // repository còn lại" (sprint 4) xử lý.
  Future<PlayerInterests?> getPlayerInterests(String playerId) async => null;

  Future<PlayerInterests> savePlayerInterests({
    required String playerId,
    required List<String> interests,
  }) async {
    return PlayerInterests(
      id: playerId,
      playerId: playerId,
      interests: interests,
      updatedAt: DateTime.now(),
    );
  }

  Player _toPlayer(
    Map<String, dynamic> row, {
    String? email,
    String? avatarUrl,
  }) {
    DateTime parse(Object? v) =>
        v is String ? (DateTime.tryParse(v) ?? DateTime.now()) : DateTime.now();

    return Player(
      id: row['id'] as String,
      userId: row['user_created'] as String?,
      name: (row['display_name'] as String?) ?? '',
      email: email,
      avatarUrl: avatarUrl,
      dominantHand: (row['dominant_hand'] as String?) ?? 'right',
      currentLevel: (row['current_level'] as String?) ?? 'beginner',
      yearsPlaying: (row['years_playing'] as num?)?.toInt() ?? 0,
      hoursPerWeek: (row['hours_per_week'] as num?)?.toDouble() ?? 0,
      createdAt: parse(row['date_created']),
      updatedAt: parse(row['date_updated']),
    );
  }
}
