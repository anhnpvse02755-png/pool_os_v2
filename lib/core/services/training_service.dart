import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/training_session.dart';
import '../models/drill_progress.dart';

/// Training Service - Handles training-related database operations
class TrainingService {
  final SupabaseClient _client;

  TrainingService(this._client);

  /// Start a new training session
  Future<TrainingSession> startSession(String playerId) async {
    final response = await _client.from('training_sessions').insert({
      'player_id': playerId,
      'started_at': DateTime.now().toIso8601String(),
    }).select().single();

    return TrainingSession.fromJson(response);
  }

  /// Complete a training session
  Future<TrainingSession> completeSession(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) throw Exception('Session not found');

    final duration = DateTime.now().difference(session.startedAt).inMinutes;

    final response = await _client
        .from('training_sessions')
        .update({
          'completed_at': DateTime.now().toIso8601String(),
          'duration_minutes': duration,
        })
        .eq('id', sessionId)
        .select()
        .single();

    return TrainingSession.fromJson(response);
  }

  /// Get session by ID
  Future<TrainingSession?> getSession(String sessionId) async {
    final response = await _client
        .from('training_sessions')
        .select()
        .eq('id', sessionId)
        .maybeSingle();

    if (response == null) return null;
    return TrainingSession.fromJson(response);
  }

  /// Get all training sessions for a player
  Future<List<TrainingSession>> getPlayerSessions(String playerId) async {
    final response = await _client
        .from('training_sessions')
        .select()
        .eq('player_id', playerId)
        .order('started_at', ascending: false);

    return response.map((e) => TrainingSession.fromJson(e)).toList();
  }

  /// Get recent training sessions
  Future<List<TrainingSession>> getRecentSessions(String playerId, {int limit = 10}) async {
    final response = await _client
        .from('training_sessions')
        .select()
        .eq('player_id', playerId)
        .order('started_at', ascending: false)
        .limit(limit);

    return response.map((e) => TrainingSession.fromJson(e)).toList();
  }

  // ============================================
  // DRILL RUNS
  // ============================================

  /// Add a drill run to a session
  Future<DrillRun> addDrillRun({
    required String sessionId,
    required String drillCode,
    required String drillName,
    String? category,
    int? targetReps,
  }) async {
    final response = await _client.from('drill_runs').insert({
      'session_id': sessionId,
      'drill_code': drillCode,
      'drill_name': drillName,
      'category': category,
      'target_reps': targetReps,
      'attempts': 0,
      'successes': 0,
    }).select().single();

    return DrillRun.fromJson(response);
  }

  /// Update drill run with results
  Future<DrillRun> updateDrillRun({
    required String runId,
    required int attempts,
    required int successes,
    int? durationSeconds,
    String? notes,
  }) async {
    final successRate = attempts > 0 ? (successes / attempts) * 100 : 0.0;

    final response = await _client
        .from('drill_runs')
        .update({
          'attempts': attempts,
          'successes': successes,
          'success_rate': successRate,
          'duration_seconds': durationSeconds,
          'notes': notes,
        })
        .eq('id', runId)
        .select()
        .single();

    return DrillRun.fromJson(response);
  }

  /// Get drill runs for a session
  Future<List<DrillRun>> getSessionDrillRuns(String sessionId) async {
    final response = await _client
        .from('drill_runs')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);

    return response.map((e) => DrillRun.fromJson(e)).toList();
  }

  /// Get drill runs for a specific drill code
  Future<List<DrillRun>> getDrillRunHistory(String playerId, String drillCode) async {
    final response = await _client
        .from('drill_runs')
        .select('''
          id,
          session_id,
          drill_code,
          drill_name,
          category,
          target_reps,
          attempts,
          successes,
          success_rate,
          duration_seconds,
          notes,
          created_at
        ''')
        .eq('drill_code', drillCode)
        .order('created_at', ascending: false);

    return response.map((e) => DrillRun.fromJson(e)).toList();
  }

  // ============================================
  // DRILL PROGRESS
  // ============================================

  /// Get drill progress for a player
  Future<DrillProgress?> getDrillProgress(String playerId, String drillCode) async {
    final response = await _client
        .from('drill_progress')
        .select()
        .eq('player_id', playerId)
        .eq('drill_code', drillCode)
        .maybeSingle();

    if (response == null) return null;
    return DrillProgress.fromJson(response);
  }

  /// Get all drill progress for a player
  Future<List<DrillProgress>> getAllDrillProgress(String playerId) async {
    final response = await _client
        .from('drill_progress')
        .select()
        .eq('player_id', playerId);

    return response.map((e) => DrillProgress.fromJson(e)).toList();
  }

  /// Initialize drill progress for a player
  Future<DrillProgress> initializeDrillProgress({
    required String playerId,
    required String drillCode,
  }) async {
    final response = await _client.from('drill_progress').insert({
      'player_id': playerId,
      'drill_code': drillCode,
      'current_level': 1,
      'best_score': 0,
      'total_attempts': 0,
      'total_successes': 0,
    }).select().single();

    return DrillProgress.fromJson(response);
  }

  /// Update drill progress after a drill run
  Future<DrillProgress> updateDrillProgress({
    required String playerId,
    required String drillCode,
    required int attempts,
    required int successes,
    required double successRate,
  }) async {
    // Get existing progress
    var progress = await getDrillProgress(playerId, drillCode);

    if (progress == null) {
      // Initialize if doesn't exist
      progress = await initializeDrillProgress(
        playerId: playerId,
        drillCode: drillCode,
      );
    }

    // Calculate new totals
    final newTotalAttempts = progress.totalAttempts + attempts;
    final newTotalSuccesses = progress.totalSuccesses + successes;
    final newBestScore = successRate > progress.bestScore
        ? successRate.toInt()
        : progress.bestScore;

    // Determine if level should be upgraded
    // Pass criteria: 80%+ success rate
    int newLevel = progress.currentLevel;
    if (successRate >= 80 && progress.currentLevel < 5) {
      newLevel = progress.currentLevel + 1;
    }

    final response = await _client
        .from('drill_progress')
        .update({
          'current_level': newLevel,
          'best_score': newBestScore,
          'total_attempts': newTotalAttempts,
          'total_successes': newTotalSuccesses,
          'last_attempt_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', progress.id)
        .select()
        .single();

    return DrillProgress.fromJson(response);
  }

  /// Record a drill level attempt
  Future<DrillLevelAttempt> recordLevelAttempt({
    required String playerId,
    required String drillCode,
    required int level,
    required int attempts,
    required int successes,
  }) async {
    final successRate = attempts > 0 ? (successes / attempts) * 100 : 0.0;
    final passed = successRate >= 80;

    final response = await _client.from('drill_level_attempts').insert({
      'player_id': playerId,
      'drill_code': drillCode,
      'level': level,
      'attempts': attempts,
      'successes': successes,
      'success_rate': successRate,
      'passed': passed,
      'attempted_at': DateTime.now().toIso8601String(),
    }).select().single();

    return DrillLevelAttempt.fromJson(response);
  }

  /// Get level attempts for a drill
  Future<List<DrillLevelAttempt>> getLevelAttempts(
    String playerId,
    String drillCode,
  ) async {
    final response = await _client
        .from('drill_level_attempts')
        .select()
        .eq('player_id', playerId)
        .eq('drill_code', drillCode)
        .order('attempted_at', ascending: false);

    return response.map((e) => DrillLevelAttempt.fromJson(e)).toList();
  }
}
