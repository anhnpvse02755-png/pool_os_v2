import '../../data/models/drill_attempt.dart';
import '../../data/models/drill_session.dart';
import '../../data/repositories/drill_session_repository.dart';

/// Recovery service for in-progress drill sessions.
///
/// Goals:
///   - Pause / resume without losing state.
///   - Recover a session if the app crashed (paused session is detected
///     on next launch via [recover]).
class DrillSessionRecoveryService {
  DrillSessionRecoveryService(this._repo);
  final IDrillSessionRepository _repo;

  /// Pause an active session, capturing its current state.
  Future<DrillSession> pause(DrillSession session) async {
    final updated = session.copyWith(pausedAt: DateTime.now());
    await _repo.save(updated);
    return updated;
  }

  /// Resume a paused session by clearing pausedAt.
  Future<DrillSession> resume(DrillSession session) async {
    final updated = session.copyWith(pausedAt: null);
    await _repo.save(updated);
    return updated;
  }

  /// Complete the session, computing totals.
  Future<DrillSession> complete(DrillSession session) async {
    final totalMinutes = DateTime.now().difference(session.startedAt).inMinutes;
    int made = 0, missed = 0;
    for (final a in session.attempts) {
      if (a.made) {
        made++;
      } else {
        missed++;
      }
    }
    final completed = session.copyWith(
      completedAt: DateTime.now(),
      pausedAt: null,
      totalMinutes: totalMinutes,
      totalShotsMade: made,
      totalShotsMissed: missed,
    );
    await _repo.save(completed);
    return completed;
  }

  /// Abandon / discard the session.
  Future<void> discard(DrillSession session) async {
    await _repo.delete(session.id);
  }

  /// Find an active session for a player. Call on app launch.
  Future<DrillSession?> recover(String playerId) async {
    final active = await _repo.getActiveSession(playerId);
    if (active == null) return null;
    if (active.pausedAt != null) return active; // surface paused session
    return active;
  }

  /// Add an attempt to the session without persisting per-run.
  Future<DrillSession> recordAttempt(
    DrillSession session, {
    required String drillCode,
    required int attemptNumber,
    required bool made,
    int? timeMs,
    String? notes,
  }) async {
    final attempt = DrillAttempt(
      id: 'attempt-${DateTime.now().microsecondsSinceEpoch}',
      sessionId: session.id,
      drillCode: drillCode,
      attemptNumber: attemptNumber,
      made: made,
      timeMs: timeMs,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await _repo.addAttempt(attempt);
    final updated = session.copyWith(
      attempts: [...session.attempts, attempt],
      totalShotsMade: session.totalShotsMade + (made ? 1 : 0),
      totalShotsMissed: session.totalShotsMissed + (made ? 0 : 1),
    );
    await _repo.save(updated);
    return updated;
  }
}
