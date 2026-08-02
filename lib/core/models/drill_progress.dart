/// Drill Progress Model
/// Tracks user's progress through drill levels
class DrillProgress {
  final String id;
  final String playerId;
  final String drillCode;
  final int currentLevel;
  final int bestScore; // best success rate achieved
  final int totalAttempts;
  final int totalSuccesses;
  final DateTime? lastAttemptAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  DrillProgress({
    required this.id,
    required this.playerId,
    required this.drillCode,
    required this.currentLevel,
    this.bestScore = 0,
    this.totalAttempts = 0,
    this.totalSuccesses = 0,
    this.lastAttemptAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DrillProgress.fromJson(Map<String, dynamic> json) {
    return DrillProgress(
      id: json['id'],
      playerId: json['player_id'],
      drillCode: json['drill_code'],
      currentLevel: json['current_level'] ?? 1,
      bestScore: json['best_score'] ?? 0,
      totalAttempts: json['total_attempts'] ?? 0,
      totalSuccesses: json['total_successes'] ?? 0,
      lastAttemptAt: json['last_attempt_at'] != null
          ? DateTime.parse(json['last_attempt_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'drill_code': drillCode,
      'current_level': currentLevel,
      'best_score': bestScore,
      'total_attempts': totalAttempts,
      'total_successes': totalSuccesses,
      'last_attempt_at': lastAttemptAt?.toIso8601String(),
    };
  }

  double get overallSuccessRate {
    if (totalAttempts == 0) return 0;
    return (totalSuccesses / totalAttempts) * 100;
  }

  /// Check if a specific level is unlocked
  /// Level 1 is always unlocked
  /// Level N requires Level N-1 to be passed
  bool isLevelUnlocked(int level) {
    if (level <= 1) return true;
    return level <= currentLevel + 1;
  }

  /// Check if a level has been passed
  bool isLevelPassed(int level) {
    return level < currentLevel;
  }

  DrillProgress copyWith({
    int? currentLevel,
    int? bestScore,
    int? totalAttempts,
    int? totalSuccesses,
    DateTime? lastAttemptAt,
  }) {
    return DrillProgress(
      id: id,
      playerId: playerId,
      drillCode: drillCode,
      currentLevel: currentLevel ?? this.currentLevel,
      bestScore: bestScore ?? this.bestScore,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      totalSuccesses: totalSuccesses ?? this.totalSuccesses,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Drill Level Attempt - Records a single attempt at a drill level
class DrillLevelAttempt {
  final String id;
  final String playerId;
  final String drillCode;
  final int level;
  final int attempts;
  final int successes;
  final double successRate;
  final bool passed;
  final DateTime attemptedAt;

  DrillLevelAttempt({
    required this.id,
    required this.playerId,
    required this.drillCode,
    required this.level,
    required this.attempts,
    required this.successes,
    required this.successRate,
    required this.passed,
    required this.attemptedAt,
  });

  factory DrillLevelAttempt.fromJson(Map<String, dynamic> json) {
    return DrillLevelAttempt(
      id: json['id'],
      playerId: json['player_id'],
      drillCode: json['drill_code'],
      level: json['level'],
      attempts: json['attempts'],
      successes: json['successes'],
      successRate: (json['success_rate'] ?? 0).toDouble(),
      passed: json['passed'] ?? false,
      attemptedAt: DateTime.parse(json['attempted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_id': playerId,
      'drill_code': drillCode,
      'level': level,
      'attempts': attempts,
      'successes': successes,
      'passed': passed,
      'attempted_at': attemptedAt.toIso8601String(),
    };
  }
}
