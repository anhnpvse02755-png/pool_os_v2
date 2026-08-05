// ============================================================================
// FakeEquipmentRepository — in-memory IEquipmentRepository for widget tests
// ============================================================================
//
// Used by Sprint 2A widget smoke (AC-2). Implements only the methods the
// Equipment screen actually calls, mirroring the FakeMatchRepository
// pattern. When new methods are needed, add them here.
// ============================================================================

import 'package:pool_os_v2/data/models/equipment.dart';
import 'package:pool_os_v2/data/repositories/equipment_repository.dart';

class FakeEquipmentRepository implements EquipmentRepository {
  FakeEquipmentRepository({List<Equipment>? seeded})
      : _items = List.of(seeded ?? const []);

  final List<Equipment> _items;

  @override
  Future<List<Equipment>> getAllEquipment({
    String? playerId,
    bool includeArchived = false,
  }) async {
    return _items.where((e) {
      if (!includeArchived && e.isArchived) return false;
      if (playerId != null && e.playerId != null && e.playerId != playerId) {
        return false;
      }
      return true;
    }).toList();
  }

  // -- The rest are stubbed because widget smoke only needs the list. ---
  // -- Add real implementations when a widget test demands them. -------

  @override
  Future<Equipment?> getEquipmentById(String id) async =>
      _items.where((e) => e.id == id).firstOrNull;

  @override
  Future<String> createEquipment(Equipment equipment) async {
    _items.add(equipment);
    return equipment.id;
  }

  @override
  Future<void> updateEquipment(Equipment equipment) async {
    final i = _items.indexWhere((e) => e.id == equipment.id);
    if (i >= 0) _items[i] = equipment;
  }

  @override
  Future<void> deleteEquipment(String id) async {
    _items.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> archiveEquipment(String id) async {
    final cur = await getEquipmentById(id);
    if (cur == null) return;
    final i = _items.indexWhere((e) => e.id == id);
    _items[i] = cur.copyWith(isArchived: true);
  }

  @override
  Future<void> unarchiveEquipment(String id) async {
    final cur = await getEquipmentById(id);
    if (cur == null) return;
    final i = _items.indexWhere((e) => e.id == id);
    _items[i] = cur.copyWith(isArchived: false);
  }

  @override
  Future<void> addMaintenanceEntry(String id, MaintenanceEntry entry) async {
    final cur = await getEquipmentById(id);
    if (cur == null) return;
    final i = _items.indexWhere((e) => e.id == id);
    _items[i] = cur.copyWith(
      maintenanceHistory: [...cur.maintenanceHistory, entry],
    );
  }

  @override
  Future<void> removeMaintenanceEntry(String id, String entryId) async {
    final cur = await getEquipmentById(id);
    if (cur == null) return;
    final i = _items.indexWhere((e) => e.id == id);
    _items[i] = cur.copyWith(
      maintenanceHistory:
          cur.maintenanceHistory.where((e) => e.id != entryId).toList(),
    );
  }

  @override
  Future<Equipment?> getActiveCue({
    required bool isBreakCue,
    String? playerId,
  }) async {
    final matches = _items.where(
      (e) => e.isActive && e.isBreakCue == isBreakCue,
    );
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<Equipment?> getActiveCueByType(
    String cueType, {
    String? playerId,
  }) async {
    Equipment? pick(String type) {
      for (final c in _items) {
        if (c.category == 'cue' && c.cueType == type && c.isActive) return c;
      }
      return null;
    }

    final direct = pick(cueType);
    if (direct != null) return direct;
    if (cueType == 'break' || cueType == 'jump') return pick('break_jump');
    return null;
  }

  @override
  Future<void> setActiveCue(String cueId) async {
    for (var i = 0; i < _items.length; i++) {
      final c = _items[i];
      if (c.category != 'cue') continue;
      _items[i] = c.copyWith(
        isActive: c.id == cueId,
        cueType: c.cueType ?? 'playing',
      );
    }
  }

  @override
  Future<void> setActiveBreakCue(String cueId) async {
    for (var i = 0; i < _items.length; i++) {
      final c = _items[i];
      if (c.category != 'cue') continue;
      _items[i] = c.copyWith(
        isBreakCue: c.id == cueId,
        cueType: c.id == cueId ? 'break' : c.cueType,
      );
    }
  }

  @override
  Future<void> setActiveJumpCue(String cueId) async {
    for (var i = 0; i < _items.length; i++) {
      final c = _items[i];
      if (c.category != 'cue') continue;
      _items[i] = c.copyWith(
        isJumpCue: c.id == cueId,
        cueType: c.id == cueId ? 'jump' : c.cueType,
      );
    }
  }

  @override
  Future<EquipmentStats> getStatsForCue(String cueId) async {
    return EquipmentStats(
      cueId: cueId,
      matchCount: 0,
      wins: 0,
      losses: 0,
      racks: 0,
      averageAccuracy: 0,
      averageBreakSpeed: 0,
      usageHours: 0,
    );
  }

  @override
  Future<double> getTotalEquipmentValue({String? playerId}) async {
    return _items
        .where((e) => !e.isArchived)
        .fold<double>(0, (s, e) => s + (e.currentValue ?? 0));
  }

  @override
  Future<List<Equipment>> getRecommendedEquipment({
    int topN = 3,
    String? playerId,
  }) async {
    final out = List<Equipment>.of(_items.where((e) => !e.isArchived));
    if (out.length > topN) return out.sublist(0, topN);
    return out;
  }
}
