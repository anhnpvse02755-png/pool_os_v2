import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../../core/config/supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late SupabaseClient _client;

  /// True iff [initialize] successfully bootstrapped a Supabase client.
  /// When false, the app must use local repositories and not call
  /// [client].
  bool _isReady = false;
  bool get isReady => _isReady;

  SupabaseClient get client {
    if (!_isReady) {
      throw StateError(
        'SupabaseService not ready. Either SupabaseConfig env vars are '
        'missing or initialize() failed. Check --dart-define values.',
      );
    }
    return _client;
  }

  Future<void> initialize() async {
    if (_isReady) return;
    if (!SupabaseConfig.isConfigured) {
      // Offline mode — app continues with local storage only.
      return;
    }
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _isReady = true;
    } catch (_) {
      // Swallow; app continues in offline mode.
      _isReady = false;
    }
  }

  // Auth
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  // Player
  Future<PlayerModel?> getPlayer() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('players')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return PlayerModel.fromJson(response);
  }

  Future<PlayerModel> createPlayer({
    required String name,
    String? email,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final player = PlayerModel(
      id: '',
      userId: userId,
      name: name,
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final response = await _client
        .from('players')
        .insert(player.toJson())
        .select()
        .single();

    return PlayerModel.fromJson(response);
  }

  Future<void> updatePlayer(PlayerModel player) async {
    await _client
        .from('players')
        .update(player.toJson())
        .eq('id', player.id);
  }

  // Sessions
  Future<List<SessionModel>> getSessions({int limit = 50}) async {
    final player = await getPlayer();
    if (player == null) return [];

    final response = await _client
        .from('sessions')
        .select()
        .eq('player_id', player.id)
        .order('date', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => SessionModel.fromJson(json))
        .toList();
  }

  Future<SessionModel> createSession({
    required String type,
    int? energyLevel,
    int? focusLevel,
    int? confidenceLevel,
  }) async {
    final player = await getPlayer();
    if (player == null) throw Exception('No player profile');

    final session = SessionModel(
      id: '',
      playerId: player.id,
      date: DateTime.now(),
      type: type,
      energyLevel: energyLevel ?? 3,
      focusLevel: focusLevel ?? 3,
      confidenceLevel: confidenceLevel ?? 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final response = await _client
        .from('sessions')
        .insert(session.toJson())
        .select()
        .single();

    return SessionModel.fromJson(response);
  }

  Future<void> updateSession(SessionModel session) async {
    await _client
        .from('sessions')
        .update(session.toJson())
        .eq('id', session.id);
  }

  // Matches
  Future<MatchModel> createMatch({
    required String sessionId,
    required int raceTo,
    String? opponent,
    String? matchType,
  }) async {
    final match = MatchModel(
      id: '',
      sessionId: sessionId,
      raceTo: raceTo,
      opponent: opponent,
      matchType: matchType ?? 'friendly',
      result: 'draw',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final response = await _client
        .from('matches')
        .insert(match.toJson())
        .select()
        .single();

    return MatchModel.fromJson(response);
  }

  Future<void> updateMatch(MatchModel match) async {
    await _client
        .from('matches')
        .update(match.toJson())
        .eq('id', match.id);
  }

  // Racks
  Future<RackModel> createRack({
    required String matchId,
    required int rackNumber,
    required String result,
    bool breakShot = false,
  }) async {
    final rack = RackModel(
      id: '',
      matchId: matchId,
      rackNumber: rackNumber,
      result: result,
      breakShot: breakShot,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final response = await _client
        .from('racks')
        .insert(rack.toJson())
        .select()
        .single();

    return RackModel.fromJson(response);
  }

  Future<void> updateRack(RackModel rack) async {
    await _client
        .from('racks')
        .update(rack.toJson())
        .eq('id', rack.id);
  }

  // Shots
  Future<ShotModel> createShot({
    required String rackId,
    required String shotType,
    required String result,
    String difficulty = 'medium',
    List<String> spinUsed = const [],
    List<String> events = const [],
    int confidence = 5,
  }) async {
    final shot = ShotModel(
      id: '',
      rackId: rackId,
      shotType: shotType,
      result: result,
      difficulty: difficulty,
      spinUsed: spinUsed,
      events: events,
      confidence: confidence,
      createdAt: DateTime.now(),
    );

    final response = await _client
        .from('shots')
        .insert(shot.toJson())
        .select()
        .single();

    return ShotModel.fromJson(response);
  }

  // Coach Recommendations
  Future<List<CoachRecommendationModel>> getRecommendations({
    String status = 'active',
  }) async {
    final player = await getPlayer();
    if (player == null) return [];

    final response = await _client
        .from('coach_recommendations')
        .select()
        .eq('player_id', player.id)
        .eq('status', status)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CoachRecommendationModel.fromJson(json))
        .toList();
  }

  Future<void> updateRecommendationStatus(String id, String status) async {
    final updates = <String, dynamic>{'status': status};
    if (status == 'completed') {
      updates['completed_at'] = DateTime.now().toIso8601String();
    }

    await _client
        .from('coach_recommendations')
        .update(updates)
        .eq('id', id);
  }

  // Real-time subscriptions
  Stream<dynamic> watchSessions() {
    return _client
        .from('sessions')
        .stream(primaryKey: ['id']);
  }

  Stream<dynamic> watchRecommendations() {
    return _client
        .from('coach_recommendations')
        .stream(primaryKey: ['id']);
  }
}
