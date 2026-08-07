// ============================================================================
// CAUSE NODE - Knowledge Graph Node
// Represents root causes of mistakes
// ============================================================================

import 'mistake_node.dart'; // Reuses FixDifficulty

/// Cause node - Why a mistake happens
/// Coach AI explains this in the reasoning chain
class CauseNode {
  final String id;
  final String name;
  final String nameVi;
  final String? description;

  /// What this cause affects
  final List<String> affectsSkills;

  /// What mistakes this cause leads to
  final List<String> leadsToMistakes;

  /// What drills improve this cause
  final List<String> fixedByDrills;

  /// Difficulty to fix (easy/medium/hard)
  final FixDifficulty difficulty;

  /// Root cause category
  final CauseCategory category;

  /// Related causes (often co-occur)
  final List<String> relatedCauses;

  /// Questions Coach asks to diagnose this cause
  final List<String> diagnosticQuestions;

  /// Common indicators (what to look for)
  final List<String> indicators;

  const CauseNode({
    required this.id,
    required this.name,
    required this.nameVi,
    this.description,
    this.affectsSkills = const [],
    this.leadsToMistakes = const [],
    this.fixedByDrills = const [],
    this.difficulty = FixDifficulty.medium,
    this.category = CauseCategory.technique,
    this.relatedCauses = const [],
    this.diagnosticQuestions = const [],
    this.indicators = const [],
  });

  /// Check if this cause relates to a skill
  bool affectsSkill(String skillId) => affectsSkills.contains(skillId);

  /// Check if this cause leads to a mistake
  bool causesMistake(String mistakeId) => leadsToMistakes.contains(mistakeId);

  /// Check if this cause is fixed by a drill
  bool fixedBy(String drillCode) => fixedByDrills.contains(drillCode);
}

/// Cause categories
enum CauseCategory {
  technique,      // Technical execution issues
  mental,         // Mental game issues
  physical,       // Physical setup issues
  strategic,      // Strategic decisions
  equipment;      // Equipment-related

  String get label {
    switch (this) {
      case CauseCategory.technique:
        return 'Kỹ thuật';
      case CauseCategory.mental:
        return 'Tâm lý';
      case CauseCategory.physical:
        return 'Thể chất';
      case CauseCategory.strategic:
        return 'Chiến thuật';
      case CauseCategory.equipment:
        return 'Dụng cụ';
    }
  }
}

// FixDifficulty is defined in mistake_node.dart - reuse it

/// Predefined causes
class CommonCauses {
  // Technique causes
  static const rollingCueBall = 'rolling_cue_ball';
  static const overHit = 'over_hit';
  static const underHit = 'under_hit';
  static const poorStun = 'poor_stun';
  static const misalignedAim = 'misaligned_aim';
  static const inconsistentSpeed = 'inconsistent_speed';
  static const wrongEnglish = 'wrong_english';
  static const shortStroke = 'short_stroke';
  static const jerkyStroke = 'jerky_stroke';
  static const wrongBridging = 'wrong_bridging';
  static const poorStance = 'poor_stance';

  // Mental causes
  static const rushDecision = 'rush_decision';
  static const overconfidence = 'overconfidence';
  static const anxiety = 'anxiety';
  static const tilt = 'tilt';
  static const lossOfFocus = 'loss_of_focus';
  static const pressureChoking = 'pressure_choking';

  // Strategic causes
  static const noPlanning = 'no_planning';
  static const poorShotSelection = 'poor_shot_selection';
  static const badSafetyChoice = 'bad_safety_choice';
  static const wrongPriority = 'wrong_priority';

  // Physical causes
  static const fatigue = 'fatigue';
  static const poorVision = 'poor_vision';
  static const gripTension = 'grip_tension';

  /// All cause IDs
  static const List<String> all = [
    // Technique
    rollingCueBall,
    overHit,
    underHit,
    poorStun,
    misalignedAim,
    inconsistentSpeed,
    wrongEnglish,
    shortStroke,
    jerkyStroke,
    wrongBridging,
    poorStance,
    // Mental
    rushDecision,
    overconfidence,
    anxiety,
    tilt,
    lossOfFocus,
    pressureChoking,
    // Strategic
    noPlanning,
    poorShotSelection,
    badSafetyChoice,
    wrongPriority,
    // Physical
    fatigue,
    poorVision,
    gripTension,
  ];
}
