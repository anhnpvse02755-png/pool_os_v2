// ============================================================================
// FakeDrillSessionRepository — in-memory IDrillSessionRepository for unit tests
// ============================================================================
//
// Sprint 2D: provides a no-op IDrillSessionRepository for unit tests. The fake
// records calls and stores drill sessions / attempts in maps. It deliberately
// implements only the methods that AC-1 tests use — when new methods are
// needed for tests, add them here, not as a global mock library.
// ============================================================================

import 'package:pool_os_v2/data/models/drill_attempt.dart';
import 'package:pool_os_v2/data/models/drill_session.dart';
import 'package:pool_os_v2/data/repositories/drill_session_repository.dart';

class FakeDrillSessionRepository implements IDrillSessionRepository {
  FakeDrillSessionRepository({
    List<DrillSession>? seededSessions,
    List<DrillAttempt>? seededAttempts,
  })  : _sessions = List.of(seededSessions ?? const []),
        _attempts = _groupAttempts(seededAttempts ?? const []);

  final List<DrillSession> _sessions;

  /// Per-session attempt list. Insertion order preserved (List, not Set).
  final Map<String, List<DrillAttempt>> _attempts;

  static Map<String, List<DrillAttempt>> _groupAttempts(
      List<DrillAttempt> attempts) {
    final map = <String, List<DrillAttempt>>{};
    for (final a in attempts) {
      map.putIfAbsent(a.sessionId, () => []).add(a);
    }
    return map;
  }

  String? _activeSessionId;

  // -- Read ---------------------------------------------------------------

  @override
  Future<DrillSession?> getActiveSession(String playerId) async {
    if (_activeSessionId == null) return null;
    return _sessions.firstWhere(
      (s) => s.id == _activeSessionId,
      orElse: () => _sessions.firstWhere((s) => s.id == _activeSessionId),
    );
  }

  @override
  Future<List<DrillSession>> getAll(String playerId) async {
    final list = _sessions.where((s) => s.playerId == playerId).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list;
  }

  @override
  Future<DrillSession?> getById(String id) async {
    for (final s in _sessions) {
      if (s.id == id) return s;
    }
    return null;
  }

  // -- Write --------------------------------------------------------------

  @override
  Future<void> save(DrillSession session) async {
    final idx = _sessions.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      _sessions[idx] = session;
    } else {
      _sessions.add(session);
    }
    if (session.isActive) {
      _activeSessionId = session.id;
    } else if (_activeSessionId == session.id) {
      _activeSessionId = null;
    }
  }

  @override
  Future<void> delete(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    _attempts.remove(id);
    if (_activeSessionId == id) _activeSessionId = null;
  }

  /// Append-only: each call to addAttempt writes to the per-session list.
  /// Mirrors LocalDrillSessionRepository semantics — duplicate ids are
  /// appended (caller's responsibility to deduplicate).
  @override
  Future<void> addAttempt(DrillAttempt attempt) async {
    _attempts.putIfAbsent(attempt.sessionId, () => []).add(attempt);
  }

  @override
  Future<void> updateRun(DrillRun run) async {
    final idx = _sessions.indexWhere((s) => s.id == run.sessionId);
    if (idx < 0) return;
    final session = _sessions[idx];
    final newRuns = [...session.drillRuns];
    final ridx = newRuns.indexWhere((r) => r.id == run.id);
    if (ridx >= 0) {
      newRuns[ridx] = run;
    } else {
      newRuns.add(run);
    }
    _sessions[idx] = session.copyWith(drillRuns: newRuns);
  }

  // -- Test helpers (not part of IDrillSessionRepository) -----------------

  /// Snapshot of all attempts for a given session (insertion order).
  List<DrillAttempt> attemptsFor(String sessionId) =>
      List.unmodifiable(_attempts[sessionId] ?? const []);
}