// ============================================================================
// SITUATION NODE - Knowledge Graph Node
// Represents game situations where tactical decisions are made
// ============================================================================

/// Situation node - When Coach AI makes tactical recommendations
class SituationNode {
  final String id;
  final String name;
  final String nameVi;
  final String? description;

  /// What this situation describes
  final List<String> descriptors;

  /// Conditions that define this situation
  final List<SituationCondition> conditions;

  /// Tactics recommended for this situation
  final List<String> recommendedTactics;

  /// Tactics to avoid in this situation
  final List<String> avoidTactics;

  /// Priority: how urgent is tactical decision (1=low, 3=high)
  final int priority;

  /// Category of situation
  final SituationCategory category;

  const SituationNode({
    required this.id,
    required this.name,
    required this.nameVi,
    this.description,
    this.descriptors = const [],
    this.conditions = const [],
    this.recommendedTactics = const [],
    this.avoidTactics = const [],
    this.priority = 2,
    this.category = SituationCategory.offensive,
  });

  /// Check if situation matches given game state
  bool matchesGameState(GameState state) {
    for (final condition in conditions) {
      if (!condition.evaluate(state)) {
        return false;
      }
    }
    return true;
  }
}

/// Situation condition - defines when a situation applies
class SituationCondition {
  final String field;      // e.g., "shotDifficulty", "cueBallPosition"
  final String operator;   // e.g., ">", "<", "==", "in"
  final dynamic value;     // e.g., "hard", 3, ["open", "half"]

  const SituationCondition({
    required this.field,
    required this.operator,
    required this.value,
  });

  bool evaluate(GameState state) {
    final fieldValue = state.get(field);
    if (fieldValue == null) return false;

    switch (operator) {
      case '==':
        return fieldValue == value;
      case '!=':
        return fieldValue != value;
      case '>':
        return (fieldValue as num) > (value as num);
      case '<':
        return (fieldValue as num) < (value as num);
      case '>=':
        return (fieldValue as num) >= (value as num);
      case '<=':
        return (fieldValue as num) <= (value as num);
      case 'in':
        return (value as List).contains(fieldValue);
      case 'not in':
        return !(value as List).contains(fieldValue);
      default:
        return false;
    }
  }
}

/// Game state - current conditions in a match/rack
class GameState {
  final Map<String, dynamic> _state;

  GameState(this._state);

  dynamic get(String field) => _state[field];

  /// Common game state fields
  static const String shotDifficulty = 'shotDifficulty';
  static const String cueBallPosition = 'cueBallPosition';
  static const String tableCondition = 'tableCondition';
  static const String opponentStrength = 'opponentStrength';
  static const String scoreDifference = 'scoreDifference';
  static const String rackProgress = 'rackProgress';
  static const String ballsRemaining = 'ballsRemaining';
  static const String opponentBallsRemaining = 'opponentBallsRemaining';
  static const String matchPhase = 'matchPhase';
  static const String pressureLevel = 'pressureLevel';
}

/// Situation categories
enum SituationCategory {
  offensive,     // When to attack
  defensive,     // When to play safe
  strategic,     // Long-term decisions
  pressure;      // High-pressure situations

  String get label {
    switch (this) {
      case SituationCategory.offensive:
        return 'Tấn công';
      case SituationCategory.defensive:
        return 'Phòng thủ';
      case SituationCategory.strategic:
        return 'Chiến lược';
      case SituationCategory.pressure:
        return 'Áp lực';
    }
  }
}

/// Predefined situations
class CommonSituations {
  // Offensive situations
  static const easyShot = 'easy_shot';
  static const routineShot = 'routine_shot';
  static const difficultShot = 'difficult_shot';
  static const longDistanceShot = 'long_distance_shot';
  static const thinCut = 'thin_cut';

  // Defensive situations
  static const noGoodShot = 'no_good_shot';
  static const cueBallTight = 'cue_ball_tight';
  static const ballsClumped = 'balls_clumped';

  // Strategic situations
  static const earlyMatch = 'early_match';
  static const lateMatch = 'late_match';
  static const hillHill = 'hill_hill';
  static const bigLead = 'big_lead';
  static const bigDeficit = 'big_deficit';

  // Pressure situations
  static const matchBall = 'match_ball';
  static const gameBall = 'game_ball';
  static const breakAfterFoul = 'break_after_foul';

  /// All situation IDs
  static const List<String> all = [
    easyShot,
    routineShot,
    difficultShot,
    longDistanceShot,
    thinCut,
    noGoodShot,
    cueBallTight,
    ballsClumped,
    earlyMatch,
    lateMatch,
    hillHill,
    bigLead,
    bigDeficit,
    matchBall,
    gameBall,
    breakAfterFoul,
  ];
}
