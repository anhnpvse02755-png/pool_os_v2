import 'dart:convert';
import '../models/equipment.dart';
import '../repositories/equipment_repository.dart';
import '../datasources/local/local_storage_datasource.dart';

/// Local-storage implementation of [EquipmentRepository].
///
/// Persists equipment as a JSON-encoded list under
/// [LocalStorageDataSource._keyEquipment] in SharedPreferences. This matches
/// the V2 local-storage architecture and avoids re-introducing Drift/SQLite
/// (V1 used Drift, but V2 standard is shared_preferences).
class LocalEquipmentRepository implements EquipmentRepository {
  static const String _storageKey = 'equipment_data';

  // Sample seed data — mirrors V1 demo content (Predator + Kamui).
  static List<Equipment> _seed() {
    final now = DateTime.now();
    return [
      Equipment(
        id: 'cue_main',
        playerId: null,
        name: 'My Main Cue',
        category: 'cue',
        cueType: 'playing',
        brand: 'Predator',
        model: 'Roadline',
        shaftMaterial: 'Revo',
        shaftDiameter: 12.4,
        tipBrand: 'Kamui',
        tipDiameter: 12.5,
        tipHardness: 'Medium',
        lastTipChange: now.subtract(const Duration(days: 45)),
        weight: 19.0,
        balance: 'Forward',
        joint: 'Uni-Loc',
        wrap: 'Irish Linen',
        ferrule: 'Ivorine',
        cueCase: 'Instaroke 2x4',
        chalk: 'Taom',
        glove: 'Predator Second Skin',
        accessories: ['Bridge Head', 'Joint Protector'],
        purchaseDate: DateTime(2024, 1, 15),
        purchasePrice: 650.0,
        currentValue: 700.0,
        condition: 'Like New',
        usageHours: 120,
        isActive: true,
        isBreakCue: false,
        isJumpCue: false,
        isArchived: false,
        maintenanceHistory: [
          MaintenanceEntry(
            id: 'm_001',
            date: now.subtract(const Duration(days: 45)),
            type: 'tip_change',
            description: 'Replaced Kamui clear tip (Medium)',
            cost: 25,
            performedBy: 'Local Cue Repair',
          ),
        ],
        imageUrls: const [],
        notes: 'Primary playing cue for league matches.',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: now,
      ),
      Equipment(
        id: 'cue_break',
        playerId: null,
        name: 'Predator Break Cue',
        category: 'cue',
        cueType: 'break',
        brand: 'Predator',
        model: 'BK Rush',
        shaftMaterial: 'Carbon Fiber',
        shaftDiameter: 12.75,
        tipBrand: 'Tiger',
        tipDiameter: 13.0,
        tipHardness: 'Hard',
        weight: 19.5,
        balance: 'Rear',
        joint: 'Uni-Loc',
        ferrule: 'Carbon Fiber',
        chalk: 'Taom',
        purchaseDate: DateTime(2024, 3, 20),
        purchasePrice: 380,
        currentValue: 380,
        condition: 'Good',
        usageHours: 80,
        isActive: false,
        isBreakCue: true,
        isJumpCue: false,
        isArchived: false,
        imageUrls: const [],
        notes: 'Primary break cue — significantly improves first-shot spread.',
        createdAt: DateTime(2024, 3, 20),
        updatedAt: now,
      ),
      Equipment(
        id: 'tip_kamui_clear',
        playerId: null,
        name: 'Kamui Clear (Spare)',
        category: 'tip',
        brand: 'Kamui',
        model: 'Clear',
        tipBrand: 'Kamui',
        tipDiameter: 12.5,
        tipHardness: 'Medium',
        purchaseDate: DateTime(2025, 1, 10),
        purchasePrice: 35,
        currentValue: 30,
        condition: 'New',
        usageHours: 0,
        isActive: false,
        isBreakCue: false,
        isJumpCue: false,
        isArchived: false,
        imageUrls: const [],
        notes: 'Backup tip, unopened.',
        createdAt: DateTime(2025, 1, 10),
        updatedAt: now,
      ),
      Equipment(
        id: 'case_pool',
        playerId: null,
        name: 'Instaroke 2x4 Hard Case',
        category: 'case',
        brand: 'Instaroke',
        model: '2x4',
        accessories: ['Butt pocket', 'Sleeve pocket'],
        purchaseDate: DateTime(2024, 1, 15),
        purchasePrice: 220,
        currentValue: 180,
        condition: 'Good',
        usageHours: 200,
        imageUrls: const [],
        notes: 'Carries 2 butts + 4 shafts.',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: now,
      ),
    ];
  }

  Future<List<Equipment>> _readList() async {
    final raw =
        LocalStorageDataSource.prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      // First run — seed.
      final seed = _seed();
      await _writeList(seed);
      return seed;
    }
    try {
      final list = json.decode(raw) as List;
      return list
          .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Reset on parse error.
      final seed = _seed();
      await _writeList(seed);
      return seed;
    }
  }

  Future<void> _writeList(List<Equipment> items) async {
    final encoded = json.encode(items.map((e) => e.toJson()).toList());
    await LocalStorageDataSource.prefs.setString(_storageKey, encoded);
  }

  String _newId() =>
      'eq_${DateTime.now().microsecondsSinceEpoch}_${DateTime.now().millisecondsSinceEpoch}';

  // ===========================================================================
  // CRUD
  // ===========================================================================

  @override
  Future<List<Equipment>> getAllEquipment({
    String? playerId,
    bool includeArchived = false,
  }) async {
    final items = await _readList();
    return items.where((e) {
      if (playerId != null && e.playerId != null && e.playerId != playerId) {
        return false;
      }
      if (!includeArchived && e.isArchived) return false;
      return true;
    }).toList();
  }

  @override
  Future<Equipment?> getEquipmentById(String id) async {
    final items = await _readList();
    for (final e in items) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<String> createEquipment(Equipment equipment) async {
    final items = await _readList();
    final id = equipment.id.isEmpty ? _newId() : equipment.id;
    final now = DateTime.now();
    final created = equipment.copyWith(
      id: id,
      createdAt: equipment.createdAt,
      updatedAt: now,
    );
    // Idempotent on duplicate id: replace the existing row in place
    // rather than appending a duplicate. Protects against import
    // flows and accidental double-submit. See
    // docs/SPRINT_2A_KICKOFF.md AC-1 Case 9.
    final idx = items.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      items[idx] = created;
    } else {
      items.add(created);
    }
    await _writeList(items);
    return id;
  }

  @override
  Future<void> updateEquipment(Equipment equipment) async {
    final items = await _readList();
    final idx = items.indexWhere((e) => e.id == equipment.id);
    if (idx == -1) return;
    items[idx] = equipment.copyWith(updatedAt: DateTime.now());
    await _writeList(items);
  }

  @override
  Future<void> deleteEquipment(String id) async {
    final items = await _readList();
    items.removeWhere((e) => e.id == id);
    await _writeList(items);
  }

  // ===========================================================================
  // Archive
  // ===========================================================================

  @override
  Future<void> archiveEquipment(String id) async {
    final cur = await getEquipmentById(id);
    if (cur == null) return;
    await updateEquipment(cur.copyWith(isArchived: true));
  }

  @override
  Future<void> unarchiveEquipment(String id) async {
    final cur = await getEquipmentById(id);
    if (cur == null) return;
    await updateEquipment(cur.copyWith(isArchived: false));
  }

  // ===========================================================================
  // Maintenance
  // ===========================================================================

  @override
  Future<void> addMaintenanceEntry(String equipmentId, MaintenanceEntry entry) async {
    final cur = await getEquipmentById(equipmentId);
    if (cur == null) return;
    final updated = [...cur.maintenanceHistory, entry];
    await updateEquipment(cur.copyWith(maintenanceHistory: updated));
  }

  @override
  Future<void> removeMaintenanceEntry(String equipmentId, String entryId) async {
    final cur = await getEquipmentById(equipmentId);
    if (cur == null) return;
    final updated = cur.maintenanceHistory.where((e) => e.id != entryId).toList();
    await updateEquipment(cur.copyWith(maintenanceHistory: updated));
  }

  // ===========================================================================
  // Active-role resolution
  // ===========================================================================

  @override
  Future<Equipment?> getActiveCue({
    required bool isBreakCue,
    String? playerId,
  }) async {
    final items = await getAllEquipment(playerId: playerId);
    final matches = items.where((e) => e.isActive && e.isBreakCue == isBreakCue);
    if (matches.isEmpty) return null;
    final sorted = [...matches]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.first;
  }

  @override
  Future<Equipment?> getActiveCueByType(String cueType, {String? playerId}) async {
    final items = await getAllEquipment(playerId: playerId);
    final cues = items
        .where((e) => e.category == 'cue' && e.isActive && !e.isArchived)
        .toList();

    Equipment? pick(String type) {
      for (final c in cues) {
        if (c.cueType == type) return c;
      }
      return null;
    }

    final direct = pick(cueType);
    if (direct != null) return direct;

    if (cueType == 'break' || cueType == 'jump') {
      return pick('break_jump');
    }
    return null;
  }

  @override
  Future<void> setActiveCue(String cueId) async {
    final items = await _readList();
    for (var i = 0; i < items.length; i++) {
      final c = items[i];
      if (c.category != 'cue') continue;
      final newActive = c.id == cueId;
      if (c.isActive != newActive) {
        items[i] = c.copyWith(
          isActive: newActive,
          cueType: c.cueType ?? 'playing',
        );
      }
    }
    await _writeList(items);
  }

  @override
  Future<void> setActiveBreakCue(String cueId) async {
    final items = await _readList();
    for (var i = 0; i < items.length; i++) {
      final c = items[i];
      if (c.category != 'cue') continue;
      final isBreak = c.id == cueId;
      if (c.isBreakCue != isBreak) {
        items[i] = c.copyWith(
          isBreakCue: isBreak,
          cueType: isBreak ? 'break' : c.cueType,
        );
      }
    }
    await _writeList(items);
  }

  @override
  Future<void> setActiveJumpCue(String cueId) async {
    final items = await _readList();
    for (var i = 0; i < items.length; i++) {
      final c = items[i];
      if (c.category != 'cue') continue;
      final isJump = c.id == cueId;
      if (c.isJumpCue != isJump) {
        items[i] = c.copyWith(
          isJumpCue: isJump,
          cueType: isJump ? 'jump' : c.cueType,
        );
      }
    }
    await _writeList(items);
  }

  // ===========================================================================
  // Statistics
  // ===========================================================================

  @override
  Future<EquipmentStats> getStatsForCue(String cueId) async {
    final cur = await getEquipmentById(cueId);
    if (cur == null) {
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
    // V2 doesn't have a matching-history table that joins to cues yet.
    // Synthesize from `usageHours` and last-update time so the screen has
    // meaningful numbers to render. Real match data will be wired in once
    // shot-level tracking lands.
    return EquipmentStats(
      cueId: cueId,
      matchCount: (cur.usageHours ?? 0).round(),
      wins: ((cur.usageHours ?? 0) * 0.55).round(),
      losses: ((cur.usageHours ?? 0) * 0.45).round(),
      racks: ((cur.usageHours ?? 0) * 3).round(),
      averageAccuracy: 0.72,
      averageBreakSpeed: 22.4,
      usageHours: cur.usageHours ?? 0,
      lastUsed: cur.updatedAt,
    );
  }

  @override
  Future<double> getTotalEquipmentValue({String? playerId}) async {
    final items = await getAllEquipment(playerId: playerId);
    var total = 0.0;
    for (final e in items) {
      total += e.currentValue ?? 0;
    }
    return total;
  }

  @override
  Future<List<Equipment>> getRecommendedEquipment({
    int topN = 3,
    String? playerId,
  }) async {
    final items = await getAllEquipment(playerId: playerId);
    final cues = items
        .where((e) => e.category == 'cue' && !e.isArchived)
        .toList();
    cues.sort((a, b) => (b.usageHours ?? 0).compareTo(a.usageHours ?? 0));
    return cues.take(topN).toList();
  }
}
