/// Drill Progress Model
/// Tracks user's progress through drill levels.
///
/// `playerId` added for repository-keyed lookup. JSON keys are camelCase
/// consistently — the seeder calls use camelCase keys too (see issue #633).
class DrillProgress {
  final String playerId;
  final String drillCode;
  final int currentLevel;
  final int bestScore;
  final int attempts;
  final DateTime? completedAt;
  final DateTime? lastAttemptAt;

  DrillProgress({
    this.playerId = '',
    required this.drillCode,
    required this.currentLevel,
    this.bestScore = 0,
    this.attempts = 0,
    this.completedAt,
    this.lastAttemptAt,
  });

  factory DrillProgress.fromJson(Map<String, dynamic> json) {
    return DrillProgress(
      playerId: json['playerId'] ?? json['player_id'] ?? '',
      drillCode: json['drillCode'] ?? json['drill_code'] ?? '',
      currentLevel: json['currentLevel'] ?? json['current_level'] ?? 1,
      bestScore: json['bestScore'] ?? json['best_score'] ?? 0,
      attempts: json['attempts'] ?? json['total_attempts'] ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : (json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null),
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.parse(json['lastAttemptAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'drillCode': drillCode,
      'currentLevel': currentLevel,
      'bestScore': bestScore,
      'attempts': attempts,
      'completedAt': completedAt?.toIso8601String(),
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
    };
  }

  double get successRate {
    if (attempts == 0) return 0;
    return (bestScore / attempts) * 100;
  }

  bool isLevelUnlocked(int level) {
    if (level <= 1) return true;
    return level <= currentLevel + 1;
  }

  DrillProgress copyWith({
    int? currentLevel,
    int? bestScore,
    int? attempts,
    DateTime? completedAt,
    DateTime? lastAttemptAt,
  }) {
    return DrillProgress(
      playerId: playerId,
      drillCode: drillCode,
      currentLevel: currentLevel ?? this.currentLevel,
      bestScore: bestScore ?? this.bestScore,
      attempts: attempts ?? this.attempts,
      completedAt: completedAt ?? this.completedAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }
}
