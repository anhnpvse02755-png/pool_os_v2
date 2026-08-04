import '../models/equipment.dart';

/// Equipment repository contract — restores V1 capability surface.
///
/// Mirrors V1 `features/equipment/data/repositories/equipment_repository.dart`
/// plus V2 additions: maintenance log, statistics, recommendations.
abstract class EquipmentRepository {
  // -- CRUD --------------------------------------------------------------
  Future<List<Equipment>> getAllEquipment({String? playerId, bool includeArchived = false});
  Future<Equipment?> getEquipmentById(String id);
  Future<String> createEquipment(Equipment equipment);
  Future<void> updateEquipment(Equipment equipment);
  Future<void> deleteEquipment(String id);

  // -- Archive -----------------------------------------------------------
  Future<void> archiveEquipment(String id);
  Future<void> unarchiveEquipment(String id);

  // -- Maintenance --------------------------------------------------------
  Future<void> addMaintenanceEntry(String equipmentId, MaintenanceEntry entry);
  Future<void> removeMaintenanceEntry(String equipmentId, String entryId);

  // -- Active-role resolution (V1 capability) ----------------------------
  /// Legacy binary lookup (playing vs break). Kept for callers that still
  /// think in two roles.
  Future<Equipment?> getActiveCue({required bool isBreakCue, String? playerId});

  /// RFC-302 Task F: the active cue actually used for [cueType].
  /// 'playing' always resolves to a dedicated playing cue. 'break' or 'jump'
  /// falls back to a 'break_jump' cue if no dedicated one is active.
  Future<Equipment?> getActiveCueByType(String cueType, {String? playerId});

  /// Set this cue as the active playing cue (unsets the previous).
  Future<void> setActiveCue(String cueId);

  /// Set this cue as the active break cue (unsets the previous).
  Future<void> setActiveBreakCue(String cueId);

  /// Set this cue as the active jump cue (unsets the previous).
  Future<void> setActiveJumpCue(String cueId);

  // -- Statistics ---------------------------------------------------------
  Future<EquipmentStats> getStatsForCue(String cueId);
  Future<double> getTotalEquipmentValue({String? playerId});

  /// Returns Top-N cues ranked by usage (matches + hours).
  Future<List<Equipment>> getRecommendedEquipment({int topN = 3, String? playerId});
}
