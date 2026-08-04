import 'dart:convert';

import '../../core/services/local_storage_service.dart';
import '../models/equipment_change_log.dart';

abstract class IEquipmentChangeLogRepository {
  Future<List<EquipmentChangeLog>> getAll(String playerId);
  Future<void> record(EquipmentChangeLog log);
}

class LocalEquipmentChangeLogRepository
    implements IEquipmentChangeLogRepository {
  LocalEquipmentChangeLogRepository();
  static const _kKey = 'poolos_v2.equipment_change_log';

  @override
  Future<List<EquipmentChangeLog>> getAll(String playerId) async {
    final raw = LocalStorageService.prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list
        .map((j) => EquipmentChangeLog.fromJson(j))
        .where((l) => l.playerId == playerId)
        .toList()
      ..sort((a, b) => b.changedAt.compareTo(a.changedAt));
  }

  @override
  Future<void> record(EquipmentChangeLog log) async {
    final raw = LocalStorageService.prefs.getString(_kKey);
    final list = (raw == null || raw.isEmpty)
        ? <Map<String, dynamic>>[]
        : (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    list.add(log.toJson());
    await LocalStorageService.prefs.setString(_kKey, jsonEncode(list));
  }
}