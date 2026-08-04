import '../models/drill_progress.dart';
import 'local_json_store.dart';

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
  LocalDrillProgressRepository()
      : _store = LocalJsonStore<DrillProgress>(
          key: 'poolos_v2.drill_progress',
          fromJson: DrillProgress.fromJson,
          toJson: (p) => p.toJson(),
        );

  final LocalJsonStore<DrillProgress> _store;

  @override
  Future<List<DrillProgress>> getAll(String playerId) async {
    final all = await _store.readAll();
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
    final all = await _store.readAll();
    final idx = all.indexWhere((p) =>
        p.playerId == progress.playerId && p.drillCode == progress.drillCode);
    if (idx >= 0) {
      all[idx] = progress;
    } else {
      all.add(progress);
    }
    await _store.writeAll(all);
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
