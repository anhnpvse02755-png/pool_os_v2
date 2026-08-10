import 'dart:convert';

import '../../core/services/local_storage_service.dart';
import '../models/drill_attempt.dart';
import '../models/drill_session.dart';
import 'local_json_store.dart';

/// Repository interface for drill sessions — offline-first.
abstract class IDrillSessionRepository {
  Future<DrillSession?> getActiveSession(String playerId);
  Future<List<DrillSession>> getAll(String playerId);
  Future<DrillSession?> getById(String id);
  Future<void> save(DrillSession session);
  Future<void> delete(String id);

  Future<void> addAttempt(DrillAttempt attempt);
  Future<void> updateRun(DrillRun run);
}

class LocalDrillSessionRepository implements IDrillSessionRepository {
  LocalDrillSessionRepository()
      : _store = LocalJsonStore<DrillSession>(
          key: 'poolos_v2.drill_sessions',
          fromJson: DrillSession.fromJson,
          toJson: (s) => s.toJson(),
        );

  final LocalJsonStore<DrillSession> _store;

  static const _kAttemptsPrefix = 'poolos_v2.drill_attempts.';
  static const _kActiveKey = 'poolos_v2.active_drill_session.';

  @override
  Future<DrillSession?> getActiveSession(String playerId) async {
    final activeId = LocalStorageService.prefs.getString('$_kActiveKey$playerId');
    if (activeId == null || activeId.isEmpty) return null;
    final session = await getById(activeId);
    if (session == null) return null;
    if (session.isActive) return session;
    await LocalStorageService.prefs.remove('$_kActiveKey$playerId');
    return null;
  }

  @override
  Future<List<DrillSession>> getAll(String playerId) async {
    final all = await _store.readAll();
    return all.where((s) => s.playerId == playerId).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<DrillSession?> getById(String id) async {
    final all = await _store.readAll();
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(DrillSession session) async {
    final all = await _store.readAll();
    final idx = all.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      all[idx] = session;
    } else {
      all.add(session);
    }
    // Use verified write with error handling
    final result = await _store.writeAll(all);
    if (!result.success) {
      assert(() {
        print('WARN: DrillSession save failed: ${result.error}');
        return true;
      }());
    }
    if (session.isActive) {
      await LocalStorageService.prefs.setString(
          '$_kActiveKey${session.playerId}', session.id);
    } else {
      await LocalStorageService.prefs.remove('$_kActiveKey${session.playerId}');
    }
  }

  @override
  Future<void> delete(String id) async {
    final all = await _store.readAll();
    all.removeWhere((s) => s.id == id);
    final result = await _store.writeAll(all);
    if (!result.success) {
      assert(() {
        print('WARN: DrillSession delete failed: ${result.error}');
        return true;
      }());
    }
    await LocalStorageService.prefs.remove('$_kAttemptsPrefix$id');
  }

  @override
  Future<void> addAttempt(DrillAttempt attempt) async {
    final raw = LocalStorageService.prefs.getString('$_kAttemptsPrefix${attempt.sessionId}');
    final list = (raw == null || raw.isEmpty)
        ? <Map<String, dynamic>>[]
        : (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    list.add(attempt.toJson());
    await LocalStorageService.prefs.setString(
        '$_kAttemptsPrefix${attempt.sessionId}', jsonEncode(list));
  }

  @override
  Future<void> updateRun(DrillRun run) async {
    final session = await getById(run.sessionId);
    if (session == null) return;
    final newRuns = [...session.drillRuns];
    final idx = newRuns.indexWhere((r) => r.id == run.id);
    if (idx >= 0) {
      newRuns[idx] = run;
    } else {
      newRuns.add(run);
    }
    await save(session.copyWith(drillRuns: newRuns));
  }
}
