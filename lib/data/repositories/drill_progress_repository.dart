import 'dart:convert';

import '../../core/services/local_storage_service.dart';
import '../models/drill_progress.dart';

/// Repository for DrillProgress (camelCase JSON — matches DrillProgress).
abstract class IDrillProgressRepository {
  Future<List<DrillProgress>> getAll(String playerId);
  Future<DrillProgress?> get(String playerId, String drillCode);
  Future<void> save(DrillProgress progress);
  Future<void> recordAttempt({
    required String playerId,
    required String drillCode,
    required bool made,
  });
}

class LocalDrillProgressRepository implements IDrillProgressRepository {
  LocalDrillProgressRepository();

  static const _kKey = 'poolos_v2.drill_progress';

  Future<List<DrillProgress>> _readAll() async {
    final raw = LocalStorageService.prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((j) => DrillProgress.fromJson(j)).toList();
  }

  Future<void> _writeAll(List<DrillProgress> all) async {
    await LocalStorageService.prefs.setString(
        _kKey, jsonEncode(all.map((p) => p.toJson()).toList()));
  }

  @override
  Future<List<DrillProgress>> getAll(String playerId) async {
    final all = await _readAll();
    return all.where((p) => p.playerId == playerId).toList();
  }

  @override
  Future<DrillProgress?> get(String playerId, String drillCode) async {
    final all = await getAll(playerId);
    try {
      return all.firstWhere((p) => p.drillCode == drillCode);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(DrillProgress progress) async {
    final all = await _readAll();
    final idx = all.indexWhere((p) =>
        p.playerId == progress.playerId && p.drillCode == progress.drillCode);
    if (idx >= 0) {
      all[idx] = progress;
    } else {
      all.add(progress);
    }
    await _writeAll(all);
  }

  @override
  Future<void> recordAttempt({
    required String playerId,
    required String drillCode,
    required bool made,
  }) async {
    final existing = await get(playerId, drillCode);
    final next = existing ??
        DrillProgress(
            playerId: playerId, drillCode: drillCode, currentLevel: 1);
    final newAttempts = next.attempts + 1;
    final newBest = !made
        ? next.bestScore
        : (next.bestScore < newAttempts ? newAttempts : next.bestScore);
    final doneAt = newAttempts >= next.currentLevel * 10 ? DateTime.now() : null;
    await save(next.copyWith(
      attempts: newAttempts,
      bestScore: newBest,
      completedAt: doneAt,
    ));
  }
}
