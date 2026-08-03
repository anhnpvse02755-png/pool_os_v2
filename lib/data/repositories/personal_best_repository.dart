import 'dart:convert';

import '../../core/services/local_storage_service.dart';
import '../models/personal_best.dart';

abstract class IPersonalBestRepository {
  Future<List<PersonalBest>> getAll(String playerId);
  Future<List<PersonalBest>> getForDrill(String playerId, String drillCode);
  Future<void> save(PersonalBest pb);
}

class LocalPersonalBestRepository implements IPersonalBestRepository {
  LocalPersonalBestRepository();
  static const _kKey = 'poolos_v2.personal_bests';

  Future<List<PersonalBest>> _readAll() async {
    final raw = LocalStorageService.prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((j) => PersonalBest.fromJson(j)).toList();
  }

  Future<void> _writeAll(List<PersonalBest> all) async {
    await LocalStorageService.prefs.setString(
        _kKey, jsonEncode(all.map((b) => b.toJson()).toList()));
  }

  @override
  Future<List<PersonalBest>> getAll(String playerId) async {
    final all = await _readAll();
    return all.where((b) => b.playerId == playerId).toList();
  }

  @override
  Future<List<PersonalBest>> getForDrill(
      String playerId, String drillCode) async {
    final all = await getAll(playerId);
    return all.where((b) => b.drillCode == drillCode).toList();
  }

  @override
  Future<void> save(PersonalBest pb) async {
    final all = await _readAll();
    final idx = all.indexWhere((b) =>
        b.playerId == pb.playerId &&
        b.drillCode == pb.drillCode &&
        b.metric == pb.metric);
    if (idx >= 0) {
      // Replace if better.
      if (pb.value > all[idx].value) all[idx] = pb;
    } else {
      all.add(pb);
    }
    await _writeAll(all);
  }
}
