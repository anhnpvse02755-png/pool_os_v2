// ============================================================================
// DRILL NODE - Knowledge Graph Node
// Represents a drill in the knowledge graph
// ============================================================================

/// Drill difficulty level
enum DrillDifficulty {
  beginner,    // H
  intermediate, // M
  advanced,     // HH
  expert;      // HHH

  String get label {
    switch (this) {
      case DrillDifficulty.beginner:
        return 'Dễ';
      case DrillDifficulty.intermediate:
        return 'Trung bình';
      case DrillDifficulty.advanced:
        return 'Khó';
      case DrillDifficulty.expert:
        return 'Chuyên gia';
    }
  }

  String get symbol {
    switch (this) {
      case DrillDifficulty.beginner:
        return 'H';
      case DrillDifficulty.intermediate:
        return 'M';
      case DrillDifficulty.advanced:
        return 'HH';
      case DrillDifficulty.expert:
        return 'HHH';
    }
  }
}

/// Drill node in the knowledge graph
class DrillNode {
  final String code;
  final String name;
  final String nameVi;
  final String? description;

  /// Skills this drill trains
  final List<String> skillsTrained;

  /// Mistakes this drill helps fix
  final List<String> fixesMistakes;

  /// Causes this drill addresses (Phase 5B)
  final List<String> fixesCauses;

  /// Prerequisite drill codes (should master first)
  final List<String> prerequisites;

  /// Next drills to practice after this
  final List<String> nextDrills;

  /// Related drills (similar skills)
  final List<String> relatedDrills;

  /// Tips for this drill
  final List<String> tips;

  /// Common mistakes when practicing this drill
  final List<String> commonMistakes;

  /// Metrics to track for this drill
  final List<String> metrics;

  /// Difficulty level
  final DrillDifficulty difficulty;

  /// Equipment needed (cue_tip, two_piece, any)
  final String? equipment;

  /// Estimated time per session (minutes)
  final int estimatedMinutes;

  const DrillNode({
    required this.code,
    required this.name,
    required this.nameVi,
    this.description,
    this.skillsTrained = const [],
    this.fixesMistakes = const [],
    this.fixesCauses = const [],
    this.prerequisites = const [],
    this.nextDrills = const [],
    this.relatedDrills = const [],
    this.tips = const [],
    this.commonMistakes = const [],
    this.metrics = const ['accuracy', 'success_rate'],
    this.difficulty = DrillDifficulty.beginner,
    this.equipment,
    this.estimatedMinutes = 15,
  });

  /// Check if drill trains a specific skill
  bool trainsSkill(String skillId) => skillsTrained.contains(skillId);

  /// Check if drill fixes a specific mistake
  bool fixesMistake(String mistakeId) => fixesMistakes.contains(mistakeId);

  /// Check if drill addresses a specific cause (Phase 5B)
  bool fixesCause(String causeId) => fixesCauses.contains(causeId);

  /// Check if drill has prerequisites
  bool get hasPrerequisites => prerequisites.isNotEmpty;

  /// Check if drill is suitable for beginner
  bool get isForBeginner => difficulty == DrillDifficulty.beginner;
}
