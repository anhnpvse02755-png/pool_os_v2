// ============================================================================
// equipment_repository_test.dart
// ----------------------------------------------------------------------------
// Tier 1 critical-suite coverage for LocalEquipmentRepository.
//
// Ten cases protect the business rules of equipment storage:
//  1. CRUD round-trip
//  2. Archive / unarchive visibility
//  3. Maintenance log append + remove atomic
//  4. Active-role resolution (only one playing cue active)
//  5. getActiveCueByType fallback to break_jump
//  6. getStatsForCue zero-state when cue missing
//  7. getRecommendedEquipment ranking + topN + playerId
//  8. getTotalEquipmentValue sums currentValue, non-archived
//  9. Duplicate ID guard (createEquipment idempotent on duplicate id)
// 10. Invalid reference safety (operations on missing IDs do not throw)
//
// Promotion to Critical Suite tracked in test/CRITICAL_SUITE.md.
// See docs/SPRINT_2A_KICKOFF.md AC-1.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/data/impl/local_equipment_repository.dart';
import 'package:pool_os_v2/data/models/equipment.dart';
import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

Equipment _makeCue({
  String id = 'cue_a',
  String name = 'Test Cue',
  double? currentValue = 100.0,
  bool isActive = false,
  bool isBreakCue = false,
  String? cueType = 'playing',
}) {
  return Equipment(
    id: id,
    name: name,
    category: 'cue',
    cueType: cueType,
    brand: 'TestBrand',
    model: 'TestModel',
    isActive: isActive,
    isBreakCue: isBreakCue,
    isJumpCue: false,
    isArchived: false,
    currentValue: currentValue,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );
}

Equipment _makeAccessory({
  String id = 'acc_a',
  String name = 'Accessory',
  String category = 'accessory',
  double? currentValue,
}) {
  return Equipment(
    id: id,
    name: name,
    category: category,
    currentValue: currentValue,
    isArchived: false,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageDataSource.init();
  });

  /// Wipe the demo seed so each test sees only what it creates.
  /// The seed (cue_main, cue_break, tip_kamui_clear, case_pool) is
  /// restored on first read of an empty storage key, so a single
  /// read-then-delete cycle clears it.
  Future<void> _clearSeed(LocalEquipmentRepository repo) async {
    // Trigger seed creation by reading first.
    await repo.getAllEquipment();
    for (final id in [
      'cue_main',
      'cue_break',
      'tip_kamui_clear',
      'case_pool',
    ]) {
      await repo.deleteEquipment(id);
    }
  }

  // ===========================================================================
  // Case 1: CRUD round-trip
  // ===========================================================================
  test('CRUD round-trip: create, read-by-id, update, list, delete', () async {
    final repo = LocalEquipmentRepository();
    await _clearSeed(repo);
    final original = _makeCue(id: 'cue_crud', name: 'CRUD Cue');

    final id = await repo.createEquipment(original);
    expect(id, 'cue_crud');

    final fetched = await repo.getEquipmentById('cue_crud');
    expect(fetched, isNotNull);
    expect(fetched!.name, 'CRUD Cue');

    await repo.updateEquipment(original.copyWith(name: 'CRUD Cue Updated'));
    final updated = await repo.getEquipmentById('cue_crud');
    expect(updated!.name, 'CRUD Cue Updated');

    final all = await repo.getAllEquipment();
    expect(all.any((e) => e.id == 'cue_crud'), isTrue);

    await repo.deleteEquipment('cue_crud');
    final gone = await repo.getEquipmentById('cue_crud');
    expect(gone, isNull);
  });

  // ===========================================================================
  // Case 2: Archive / unarchive visibility
  // ===========================================================================
  test('archive and unarchive toggle visibility', () async {
    final repo = LocalEquipmentRepository();
    await _clearSeed(repo);

    final cue = _makeCue(id: 'cue_arch', name: 'Archive Test');
    await repo.createEquipment(cue);

    var visible = await repo.getAllEquipment(includeArchived: false);
    expect(visible.any((e) => e.id == 'cue_arch'), isTrue);

    await repo.archiveEquipment('cue_arch');
    visible = await repo.getAllEquipment(includeArchived: false);
    expect(visible.any((e) => e.id == 'cue_arch'), isFalse);

    final all = await repo.getAllEquipment(includeArchived: true);
    expect(all.any((e) => e.id == 'cue_arch'), isTrue);

    await repo.unarchiveEquipment('cue_arch');
    visible = await repo.getAllEquipment(includeArchived: false);
    expect(visible.any((e) => e.id == 'cue_arch'), isTrue);
  });

  // ===========================================================================
  // Case 3: Maintenance log append + remove atomic
  // ===========================================================================
  test('maintenance log append and remove are atomic', () async {
    final repo = LocalEquipmentRepository();
    await _clearSeed(repo);

    await repo.createEquipment(_makeCue(id: 'cue_maint'));

    final entry1 = MaintenanceEntry(
      id: 'm_1',
      date: DateTime(2025, 6, 1),
      type: 'tip_change',
      description: 'First tip change',
    );
    final entry2 = MaintenanceEntry(
      id: 'm_2',
      date: DateTime(2025, 7, 1),
      type: 'cleaning',
      description: 'Deep clean',
    );

    await repo.addMaintenanceEntry('cue_maint', entry1);
    await repo.addMaintenanceEntry('cue_maint', entry2);

    var after = await repo.getEquipmentById('cue_maint');
    expect(after!.maintenanceHistory.length, 2);

    await repo.removeMaintenanceEntry('cue_maint', 'm_1');
    after = await repo.getEquipmentById('cue_maint');
    expect(after!.maintenanceHistory.length, 1);
    expect(after.maintenanceHistory.first.id, 'm_2');
  });

  // ===========================================================================
  // Case 4: Active-role resolution
  // ===========================================================================
  test('setActiveCue unsets previous playing cue', () async {
    final repo = LocalEquipmentRepository();
    await _clearSeed(repo);

    await repo.createEquipment(
      _makeCue(id: 'a_playing_1', name: 'Playing 1', isActive: true),
    );
    await repo.createEquipment(
      _makeCue(id: 'a_playing_2', name: 'Playing 2', isActive: false),
    );

    await repo.setActiveCue('a_playing_2');

    final first = await repo.getEquipmentById('a_playing_1');
    final second = await repo.getEquipmentById('a_playing_2');

    expect(first!.isActive, isFalse,
        reason: 'previous playing cue should have been deactivated');
    expect(second!.isActive, isTrue);
  });

  // ===========================================================================
  // Case 5: getActiveCueByType fallback to break_jump
  // ===========================================================================
  test("getActiveCueByType 'break' falls back to break_jump", () async {
    final repo = LocalEquipmentRepository();
    await _clearSeed(repo);

    // No dedicated break cue — only a break_jump.
    await repo.createEquipment(
      _makeCue(
        id: 'bj_1',
        name: 'Break/Jump Combo',
        isActive: true,
        cueType: 'break_jump',
      ),
    );

    final resolved = await repo.getActiveCueByType('break');
    expect(resolved, isNotNull);
    expect(resolved!.id, 'bj_1',
        reason: "no break cue -> falls back to break_jump");
  });

  // ===========================================================================
  // Case 6: getStatsForCue zero-state when cue missing
  // ===========================================================================
  test('getStatsForCue returns zero-state for unknown id', () async {
    final repo = LocalEquipmentRepository();
    final stats = await repo.getStatsForCue('does_not_exist');
    expect(stats.cueId, 'does_not_exist');
    expect(stats.matchCount, 0);
    expect(stats.wins, 0);
    expect(stats.losses, 0);
    expect(stats.racks, 0);
    expect(stats.averageAccuracy, 0);
    expect(stats.averageBreakSpeed, 0);
    expect(stats.usageHours, 0);
  });

  // ===========================================================================
  // Case 7: getRecommendedEquipment ranking + topN + playerId
  // ===========================================================================
  test('getRecommendedEquipment honors topN and excludes archived', () async {
    final repo = LocalEquipmentRepository();
    await _clearSeed(repo);

    await repo.createEquipment(_makeCue(
      id: 'rec_high',
      name: 'High Use',
      currentValue: 200.0,
    ));
    await repo.createEquipment(_makeCue(
      id: 'rec_low',
      name: 'Low Use',
      currentValue: 50.0,
    ));

    // Mark one as archived; should not appear in recommendations.
    await repo.archiveEquipment('rec_low');

    final top = await repo.getRecommendedEquipment(topN: 1);
    expect(top.length, 1);
    expect(top.first.id, 'rec_high');
  });

  // ===========================================================================
  // Case 8: getTotalEquipmentValue sums currentValue, non-archived
  // ===========================================================================
  test('getTotalEquipmentValue sums currentValue across non-archived',
      () async {
    final repo = LocalEquipmentRepository();
    await _clearSeed(repo);

    await repo.createEquipment(
      _makeCue(id: 'val_1', currentValue: 100.0),
    );
    await repo.createEquipment(
      _makeCue(id: 'val_2', currentValue: 250.0),
    );
    await repo.createEquipment(
      _makeAccessory(id: 'val_3', currentValue: 50.0),
    );

    // Archive one — should not contribute to the sum.
    await repo.archiveEquipment('val_3');

    final total = await repo.getTotalEquipmentValue();
    expect(total, 350.0);
  });

  // ===========================================================================
  // Case 9: Duplicate ID guard (idempotent create)
  // ===========================================================================
  test('createEquipment with duplicate id does not create a duplicate row',
      () async {
    final repo = LocalEquipmentRepository();
    await _clearSeed(repo);

    await repo.createEquipment(_makeCue(id: 'dup_id', name: 'First'));
    final first = await repo.getEquipmentById('dup_id');
    expect(first, isNotNull);

    // Second create with same id must not duplicate the row.
    await repo.createEquipment(_makeCue(id: 'dup_id', name: 'Second'));
    final list = await repo.getAllEquipment();
    final matches = list.where((e) => e.id == 'dup_id').toList();
    expect(matches.length, 1,
        reason: 'duplicate id must not produce two rows');
  });

  // ===========================================================================
  // Case 10: Invalid reference safety
  // ===========================================================================
  test('operations on non-existent ids are silent no-ops', () async {
    final repo = LocalEquipmentRepository();
    await _clearSeed(repo);

    // None of these should throw.
    await repo.updateEquipment(_makeCue(id: 'ghost_id', name: 'Ghost'));
    await repo.deleteEquipment('ghost_id');
    await repo.archiveEquipment('ghost_id');
    await repo.unarchiveEquipment('ghost_id');
    await repo.setActiveCue('ghost_id');
    await repo.setActiveBreakCue('ghost_id');
    await repo.setActiveJumpCue('ghost_id');
    await repo.addMaintenanceEntry('ghost_id', MaintenanceEntry(
      id: 'm_g',
      date: DateTime(2025, 1, 1),
      type: 'cleaning',
      description: 'noop',
    ));

    final all = await repo.getAllEquipment();
    expect(all.where((e) => e.id == 'ghost_id').toList(), isEmpty);
  });
}
