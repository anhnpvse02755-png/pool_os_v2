// ============================================================================
// OBSERVATION NODE - Knowledge Graph Node
// Represents observable data signals from player performance
// ============================================================================

/// Observation node - Coach AI reads this from data (Phase 3-4)
/// Examples: "accuracy_drop", "cue_ball_overrun", "position_recovery_increase"
class ObservationNode {
  final String id;
  final String name;
  final String nameVi;
  final String? description;

  /// Data source: where this observation comes from
  /// training_session, match, rack, attempt
  final String dataSource;

  /// Metrics that indicate this observation
  /// e.g., ["accuracy", "success_rate"]
  final List<String> metrics;

  /// Thresholds or conditions for this observation
  /// e.g., "accuracy < 70%", "sessions >= 5"
  final List<String> conditions;

  /// What patterns this observation indicates
  final List<String> indicatesPatterns;

  /// Related mistakes this observation suggests
  final List<String> suggestsMistakes;

  /// Category of observation
  final ObservationCategory category;

  const ObservationNode({
    required this.id,
    required this.name,
    required this.nameVi,
    this.description,
    required this.dataSource,
    this.metrics = const [],
    this.conditions = const [],
    this.indicatesPatterns = const [],
    this.suggestsMistakes = const [],
    this.category = ObservationCategory.performance,
  });

  /// Check if this observation applies given metric values
  bool matchesConditions(Map<String, dynamic> metricValues) {
    // This would be implemented with actual condition evaluation
    return true;
  }
}

/// Observation categories
enum ObservationCategory {
  performance,    // Accuracy, success rate, etc.
  technique,     // Cue ball control, position, etc.
  mental,        // Focus, pressure, tilt
  behavior,      // Rush shots, hesitation
  consistency;   // Variance, stability

  String get label {
    switch (this) {
      case ObservationCategory.performance:
        return 'Hiệu suất';
      case ObservationCategory.technique:
        return 'Kỹ thuật';
      case ObservationCategory.mental:
        return 'Tâm lý';
      case ObservationCategory.behavior:
        return 'Hành vi';
      case ObservationCategory.consistency:
        return 'Ổn định';
    }
  }
}

/// Predefined observations from training sessions
class TrainingObservations {
  static const accuracyDrop = 'accuracy_drop';
  static const accuracyIncrease = 'accuracy_increase';
  static const highVariance = 'high_variance';
  static const lowVariance = 'low_variance';
  static const scorePlateau = 'score_plateau';
  static const scoreDecline = 'score_decline';
  static const scoreImprovement = 'score_improvement';
  static const timeoutIncrease = 'timeout_increase';

  static const List<String> all = [
    accuracyDrop,
    accuracyIncrease,
    highVariance,
    lowVariance,
    scorePlateau,
    scoreDecline,
    scoreImprovement,
    timeoutIncrease,
  ];
}

/// Predefined observations from match play
class MatchObservations {
  static const foulIncrease = 'foul_increase';
  static const safetyFailure = 'safety_failure';
  static const positionMiss = 'position_miss';
  static const breakEfficiencyDrop = 'break_efficiency_drop';
  static const runOutFail = 'run_out_fail';
  static const safetyWinDecrease = 'safety_win_decrease';
  static const opponentDominance = 'opponent_dominance';

  static const List<String> all = [
    foulIncrease,
    safetyFailure,
    positionMiss,
    breakEfficiencyDrop,
    runOutFail,
    safetyWinDecrease,
    opponentDominance,
  ];
}

/// Predefined observations from rack analysis
class RackObservations {
  static const cueBallOverrun = 'cue_ball_overrun';
  static const cueBallUnderrun = 'cue_ball_underrun';
  static const thinHit = 'thin_hit';
  static const thickHit = 'thick_hit';
  static const scratchOnBreak = 'scratch_on_break';
  static const noBreakPocket = 'no_break_pocket';
  static const easyMiss = 'easy_miss';
  static const kickMiss = 'kick_miss';
  static const bankMiss = 'bank_miss';

  static const List<String> all = [
    cueBallOverrun,
    cueBallUnderrun,
    thinHit,
    thickHit,
    scratchOnBreak,
    noBreakPocket,
    easyMiss,
    kickMiss,
    bankMiss,
  ];
}
