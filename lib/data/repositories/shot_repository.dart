import 'dart:convert';

import '../../core/services/local_storage_service.dart';
import '../models/shot.dart';

/// Repository interface for shots.
abstract class IShotRepository {
  Future<List<Shot>> getShotsByRack(String rackId);
  Future<List<Shot>> getShotsByMatch(String matchId);
  Future<void> saveShot(Shot shot);
  Future<void> deleteShot(String id);

  /// Stats aggregated at the rack level.
  Future<Map<String, int>> getShotCountsByTypeForRack(String rackId);
}

class LocalShotRepository implements IShotRepository {
  LocalShotRepository();

  static const _kShotsPrefix = 'poolos_v2.shots.';

  Future<List<Shot>> _readRack(String rackId) async {
    final raw = LocalStorageService.prefs.getString('$_kShotsPrefix$rackId');
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((j) => Shot.fromJson(j)).toList();
  }

  Future<void> _writeRack(String rackId, List<Shot> shots) async {
    final raw = jsonEncode(shots.map((s) => s.toJson()).toList());
    await LocalStorageService.prefs.setString('$_kShotsPrefix$rackId', raw);
  }

  @override
  Future<List<Shot>> getShotsByRack(String rackId) async {
    final shots = await _readRack(rackId);
    shots.sort((a, b) => a.shotNumber.compareTo(b.shotNumber));
    return shots;
  }

  @override
  Future<List<Shot>> getShotsByMatch(String matchId) async {
    final raw = LocalStorageService.prefs.getString('poolos_v2.match_racks.$matchId');
    if (raw == null || raw.isEmpty) return [];
    final rackIds = (jsonDecode(raw) as List).cast<String>();
    final List<Shot> all = [];
    for (final rid in rackIds) {
      all.addAll(await getShotsByRack(rid));
    }
    all.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return all;
  }

  @override
  Future<void> saveShot(Shot shot) async {
    final shots = await _readRack(shot.rackId);
    final idx = shots.indexWhere((s) => s.id == shot.id);
    if (idx >= 0) {
      shots[idx] = shot;
    } else {
      shots.add(shot);
    }
    await _writeRack(shot.rackId, shots);
  }

  @override
  Future<void> deleteShot(String id) async {
    for (final key in LocalStorageService.prefs.getKeys()) {
      if (!key.startsWith(_kShotsPrefix)) continue;
      final raw = LocalStorageService.prefs.getString(key);
      if (raw == null || raw.isEmpty) continue;
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final newList = list.where((j) => j['id'] != id).toList();
      if (newList.length != list.length) {
        await LocalStorageService.prefs.setString(key, jsonEncode(newList));
      }
    }
  }

  @override
  Future<Map<String, int>> getShotCountsByTypeForRack(String rackId) async {
    final shots = await getShotsByRack(rackId);
    final out = <String, int>{};
    for (final s in shots) {
      out.update(s.shotType, (v) => v + 1, ifAbsent: () => 1);
    }
    return out;
  }
}
