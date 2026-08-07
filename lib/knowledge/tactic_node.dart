// ============================================================================
// TACTIC NODE - Knowledge Graph Node
// Represents a tactical decision with full context
// ============================================================================

/// Tactic node - A tactical decision Coach AI can reason about
class TacticNode {
  final String id;
  final String name;
  final String nameVi;
  final String? description;

  /// What this tactic achieves
  final String objective;

  /// When to use this tactic (situation IDs)
  final List<String> whenToUse;

  /// When NOT to use this tactic (situation IDs)
  final List<String> whenToAvoid;

  /// Skills required to execute this tactic
  final List<String> requiredSkills;

  /// Skills improved by practicing this tactic
  final List<String> improvesSkills;

  /// Risk profile for this tactic
  final RiskProfile riskProfile;

  /// Success conditions
  final List<String> successConditions;

  /// Failure conditions
  final List<String> failureConditions;

  /// Prerequisites before using this tactic
  final List<String> prerequisites;

  /// Difficulty level
  final TacticDifficulty difficulty;

  /// Category
  final TacticCategory category;

  /// Tips for execution
  final List<String> tips;

  const TacticNode({
    required this.id,
    required this.name,
    required this.nameVi,
    this.description,
    this.objective = '',
    this.whenToUse = const [],
    this.whenToAvoid = const [],
    this.requiredSkills = const [],
    this.improvesSkills = const [],
    required this.riskProfile,
    this.successConditions = const [],
    this.failureConditions = const [],
    this.prerequisites = const [],
    this.difficulty = TacticDifficulty.intermediate,
    this.category = TacticCategory.offensive,
    this.tips = const [],
  });

  /// Check if this tactic is appropriate for a situation
  bool isAppropriateFor(String situationId) {
    return whenToUse.contains(situationId);
  }

  /// Check if this tactic should be avoided in a situation
  bool shouldAvoidIn(String situationId) {
    return whenToAvoid.contains(situationId);
  }

  /// Check if player has required skills
  bool canExecute(List<String> playerSkills) {
    return requiredSkills.every((skill) => playerSkills.contains(skill));
  }
}

/// Risk profile for a tactic
class RiskProfile {
  /// Overall risk level
  final RiskLevel riskLevel;

  /// Specific risks
  final List<RiskItem> risks;

  /// Risk mitigation strategies
  final List<String> mitigations;

  const RiskProfile({
    required this.riskLevel,
    this.risks = const [],
    this.mitigations = const [],
  });

  static const low = RiskProfile(
    riskLevel: RiskLevel.low,
    risks: [],
    mitigations: [],
  );

  static const medium = RiskProfile(
    riskLevel: RiskLevel.medium,
    risks: [],
    mitigations: [],
  );

  static const high = RiskProfile(
    riskLevel: RiskLevel.high,
    risks: [],
    mitigations: [],
  );
}

/// Risk level
enum RiskLevel {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Thấp';
      case RiskLevel.medium:
        return 'Trung bình';
      case RiskLevel.high:
        return 'Cao';
    }
  }
}

/// Individual risk item
class RiskItem {
  final String id;
  final String description;
  final String? consequence;
  final double probability; // 0.0 - 1.0

  const RiskItem({
    required this.id,
    required this.description,
    this.consequence,
    required this.probability,
  });
}

/// Tactic difficulty
enum TacticDifficulty {
  easy,
  intermediate,
  advanced,
  expert;

  String get label {
    switch (this) {
      case TacticDifficulty.easy:
        return 'Dễ';
      case TacticDifficulty.intermediate:
        return 'Trung bình';
      case TacticDifficulty.advanced:
        return 'Khó';
      case TacticDifficulty.expert:
        return 'Chuyên gia';
    }
  }
}

/// Tactic categories
enum TacticCategory {
  offensive,   // Attack tactics
  defensive,   // Safety play
  positional,  // Position play
  mental;      // Mental game tactics

  String get label {
    switch (this) {
      case TacticCategory.offensive:
        return 'Tấn công';
      case TacticCategory.defensive:
        return 'Phòng thủ';
      case TacticCategory.positional:
        return 'Vị trí';
      case TacticCategory.mental:
        return 'Tâm lý';
    }
  }
}

/// Predefined tactics
class CommonTactics {
  // Offensive tactics
  static const aggressiveBreak = 'aggressive_break';
  static const controlledBreak = 'controlled_break';
  static const thinCutAttack = 'thin_cut_attack';
  static const bankShot = 'bank_shot_attack';
  static const runOutAttempt = 'run_out_attempt';
  static const chipShot = 'chip_shot';
  static const riskyShot = 'risky_shot';

  // Defensive tactics
  static const safetyPlay = 'safety_play';
  static const kickSafety = 'kick_safety';
  static const bankSafety = 'bank_safety';
  static const pushOut = 'push_out';
  static const legalFoul = 'legal_foul';

  // Position tactics
  static const positionPlay = 'position_play';
  static const leaveOption = 'leave_option';
  static const controlCueBall = 'control_cue_ball';

  // Mental tactics
  static const slowDown = 'slow_down';
  static const pressureShot = 'pressure_shot';
  static const conservativePlay = 'conservative_play';

  /// All tactic IDs
  static const List<String> all = [
    aggressiveBreak,
    controlledBreak,
    thinCutAttack,
    bankShot,
    runOutAttempt,
    chipShot,
    riskyShot,
    safetyPlay,
    kickSafety,
    bankSafety,
    pushOut,
    legalFoul,
    positionPlay,
    leaveOption,
    controlCueBall,
    slowDown,
    pressureShot,
    conservativePlay,
  ];
}
