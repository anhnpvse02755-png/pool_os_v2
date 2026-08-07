// ============================================================================
// SKILL NODE - Knowledge Graph Node
// Represents a pool skill in the knowledge graph
// ============================================================================

/// Skill node in the knowledge graph
/// Skills are the core competencies in pool
class SkillNode {
  final String id;
  final String name;
  final String nameVi;
  final String? description;

  /// Related technique IDs
  final List<String> relatedTechniques;

  /// Related mistake IDs
  final List<String> relatedMistakes;

  /// Related drill codes
  final List<String> relatedDrills;

  /// Prerequisites (skills that should be learned first)
  final List<String> prerequisites;

  /// Category: foundation, offensive, defensive, mental
  final SkillCategory category;

  const SkillNode({
    required this.id,
    required this.name,
    required this.nameVi,
    this.description,
    this.relatedTechniques = const [],
    this.relatedMistakes = const [],
    this.relatedDrills = const [],
    this.prerequisites = const [],
    this.category = SkillCategory.foundation,
  });
}

/// Skill categories
enum SkillCategory {
  foundation,  // Basic skills
  offensive,   // Scoring skills
  defensive,  // Safety, position control
  mental;     // Mental game

  String get label {
    switch (this) {
      case SkillCategory.foundation:
        return 'Nền tảng';
      case SkillCategory.offensive:
        return 'Tấn công';
      case SkillCategory.defensive:
        return 'Phòng thủ';
      case SkillCategory.mental:
        return 'Tâm lý';
    }
  }
}

/// Predefined pool skills
class PoolSkills {
  // Foundation skills
  static const aiming = 'aiming';
  static const bridge = 'bridge';
  static const stroke = 'stroke';
  static const stance = 'stance';

  // Cue ball control
  static const cueBallControl = 'cue_ball_control';
  static const speedControl = 'speed_control';
  static const english = 'english';
  static const positionPlay = 'position_play';

  // Shot types
  static const cutShot = 'cut_shot';
  static const bankShot = 'bank_shot';
  static const kickShot = 'kick_shot';
  static const jumpShot = 'jump_shot';
  static const masse = 'masse';

  // Offensive
  static const breakShot = 'break_shot';
  static const runOut = 'run_out';
  static const safetyPlay = 'safety_play';

  // Defensive
  static const kicking = 'kicking';
  static const blocking = 'blocking';
  static const escaping = 'escaping';

  // Mental
  static const mentalGame = 'mental_game';
  static const focus = 'focus';
  static const pressure = 'pressure';

  /// All skill IDs
  static const List<String> all = [
    // Foundation
    aiming, bridge, stroke, stance,
    // Cue ball
    cueBallControl, speedControl, english, positionPlay,
    // Shots
    cutShot, bankShot, kickShot, jumpShot, masse,
    // Offensive
    breakShot, runOut, safetyPlay,
    // Defensive
    kicking, blocking, escaping,
    // Mental
    mentalGame, focus, pressure,
  ];
}
