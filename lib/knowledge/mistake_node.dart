// ============================================================================
// MISTAKE NODE - Knowledge Graph Node
// Represents a common pool mistake in the knowledge graph
// ============================================================================

/// Mistake node in the knowledge graph
/// Represents a common mistake players make
class MistakeNode {
  final String id;
  final String name;
  final String nameVi;
  final String? description;

  /// Root causes (what leads to this mistake) - Phase 5B
  final List<String> causes;

  /// Symptoms (how this mistake manifests)
  final List<String> symptoms;

  /// Consequences (what happens as result)
  final List<String> consequences;

  /// Skills needed to fix this mistake
  final List<String> relatedSkills;

  /// Drills that fix this mistake
  final List<String> fixesByDrills;

  /// Related mistake IDs
  final List<String> relatedMistakes;

  /// Difficulty to fix (easy/medium/hard)
  final FixDifficulty fixDifficulty;

  /// Category of mistake
  final MistakeCategory category;

  /// Observations that suggest this mistake (Phase 5B)
  final List<String> suggestedByObservations;

  const MistakeNode({
    required this.id,
    required this.name,
    required this.nameVi,
    this.description,
    this.causes = const [],
    this.symptoms = const [],
    this.consequences = const [],
    this.relatedSkills = const [],
    this.fixesByDrills = const [],
    this.relatedMistakes = const [],
    this.fixDifficulty = FixDifficulty.medium,
    this.category = MistakeCategory.execution,
    this.suggestedByObservations = const [],
  });

  /// Check if this mistake is related to a skill
  bool isRelatedToSkill(String skillId) => relatedSkills.contains(skillId);

  /// Check if this mistake can be fixed by a specific drill
  bool canBeFixedBy(String drillCode) => fixesByDrills.contains(drillCode);

  /// Check if this mistake is caused by a specific cause
  bool causedBy(String causeId) => causes.contains(causeId);
}

/// Difficulty of fixing a mistake
enum FixDifficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case FixDifficulty.easy:
        return 'Dễ sửa';
      case FixDifficulty.medium:
        return 'Trung bình';
      case FixDifficulty.hard:
        return 'Khó sửa';
    }
  }
}

/// Mistake categories
enum MistakeCategory {
  execution,    // Technique execution
  strategy,     // Strategic decisions
  mental,       // Mental game
  position,     // Position play
  safety;       // Safety play

  String get label {
    switch (this) {
      case MistakeCategory.execution:
        return 'Kỹ thuật';
      case MistakeCategory.strategy:
        return 'Chiến thuật';
      case MistakeCategory.mental:
        return 'Tâm lý';
      case MistakeCategory.position:
        return 'Vị trí';
      case MistakeCategory.safety:
        return 'Phòng thủ';
    }
  }
}

/// Predefined common mistakes
class CommonMistakes {
  // Cue ball control mistakes
  static const cueBallOverrun = 'cue_ball_overrun';
  static const cueBallStop = 'cue_ball_stop';
  static const englishMiss = 'english_miss';
  static const positionMiss = 'position_miss';

  // Aiming mistakes
  static const thinHit = 'thin_hit';
  static const thickHit = 'thick_hit';
  static const misalign = 'misalign';

  // Stroke mistakes
  static const jerkyStroke = 'jerky_stroke';
  static const offCenterHit = 'off_center_hit';
  static const shortStroke = 'short_stroke';

  // Position mistakes
  static const overRun = 'over_run';
  static const underRun = 'under_run';
  static const angleMiss = 'angle_miss';

  // Mental mistakes
  static const rushShot = 'rush_shot';
  static const intimidation = 'intimidation';
  static const giveUp = 'give_up';

  /// All mistake IDs
  static const List<String> all = [
    cueBallOverrun,
    cueBallStop,
    englishMiss,
    positionMiss,
    thinHit,
    thickHit,
    misalign,
    jerkyStroke,
    offCenterHit,
    shortStroke,
    overRun,
    underRun,
    angleMiss,
    rushShot,
    intimidation,
    giveUp,
  ];
}
