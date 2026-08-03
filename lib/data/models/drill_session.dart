import 'drill_attempt.dart';

/// Drill run inside a session (one attempt at a specific drill +
/// level + outcome).
class DrillRun {
  final String id;
  final String sessionId;
  final String drillCode;
  final String drillName;
  final String? category;
  final int level;
  final int targetScore;
  final int attempts;
  final int successes;
  final double successRate;
  final int durationSeconds;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DrillRun({
    required this.id,
    required this.sessionId,
    required this.drillCode,
    required this.drillName,
    this.category,
    required this.level,
    required this.targetScore,
    required this.attempts,
    required this.successes,
    required this.successRate,
    required this.durationSeconds,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  DrillRun copyWith({
    int? attempts,
    int? successes,
    double? successRate,
    int? durationSeconds,
    String? notes,
    DateTime? updatedAt,
  }) =>
      DrillRun(
        id: id,
        sessionId: sessionId,
        drillCode: drillCode,
        drillName: drillName,
        category: category,
        level: level,
        targetScore: targetScore,
        attempts: attempts ?? this.attempts,
        successes: successes ?? this.successes,
        successRate: successRate ?? this.successRate,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  bool get isPassed => successRate >= 80;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'drillCode': drillCode,
        'drillName': drillName,
        'category': category,
        'level': level,
        'targetScore': targetScore,
        'attempts': attempts,
        'successes': successes,
        'successRate': successRate,
        'durationSeconds': durationSeconds,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DrillRun.fromJson(Map<String, dynamic> json) => DrillRun(
        id: json['id'] as String,
        sessionId: json['sessionId'] as String,
        drillCode: json['drillCode'] as String,
        drillName: json['drillName'] as String,
        category: json['category'] as String?,
        level: json['level'] as int? ?? 1,
        targetScore: json['targetScore'] as int? ?? 0,
        attempts: json['attempts'] as int? ?? 0,
        successes: json['successes'] as int? ?? 0,
        successRate: (json['successRate'] as num?)?.toDouble() ?? 0,
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

/// Aggregate TrainingSession owned by the player.
///
/// Holds 1..N DrillRun and 0..N DrillAttempt. Persists pause / resume
/// state via [pausedAt] so it can be revived after a crash.
class DrillSession {
  final String id;
  final String playerId;
  final String title;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? pausedAt;
  final int totalMinutes;
  final int totalShotsMade;
  final int totalShotsMissed;
  final List<DrillRun> drillRuns;
  final List<DrillAttempt> attempts;

  /// True iff the session has not been completed yet.
  /// Computed on access — not stored.
  bool get isActive => completedAt == null;

  const DrillSession({
    required this.id,
    required this.playerId,
    required this.title,
    required this.startedAt,
    this.completedAt,
    this.pausedAt,
    this.totalMinutes = 0,
    this.totalShotsMade = 0,
    this.totalShotsMissed = 0,
    this.drillRuns = const [],
    this.attempts = const [],
  });

  DrillSession copyWith({
    String? id,
    String? playerId,
    String? title,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? pausedAt,
    int? totalMinutes,
    int? totalShotsMade,
    int? totalShotsMissed,
    List<DrillRun>? drillRuns,
    List<DrillAttempt>? attempts,
  }) =>
      DrillSession(
        id: id ?? this.id,
        playerId: playerId ?? this.playerId,
        title: title ?? this.title,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
        pausedAt: pausedAt ?? this.pausedAt,
        totalMinutes: totalMinutes ?? this.totalMinutes,
        totalShotsMade: totalShotsMade ?? this.totalShotsMade,
        totalShotsMissed: totalShotsMissed ?? this.totalShotsMissed,
        drillRuns: drillRuns ?? this.drillRuns,
        attempts: attempts ?? this.attempts,
      );

  double get accuracy =>
      (totalShotsMade + totalShotsMissed) == 0
          ? 0
          : totalShotsMade / (totalShotsMade + totalShotsMissed) * 100;

  Map<String, dynamic> toJson() => {
        'id': id,
        'playerId': playerId,
        'title': title,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'pausedAt': pausedAt?.toIso8601String(),
        'totalMinutes': totalMinutes,
        'totalShotsMade': totalShotsMade,
        'totalShotsMissed': totalShotsMissed,
        'drillRuns': drillRuns.map((r) => r.toJson()).toList(),
        'attempts': attempts.map((a) => a.toJson()).toList(),
      };

  factory DrillSession.fromJson(Map<String, dynamic> json) => DrillSession(
        id: json['id'] as String,
        playerId: json['playerId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        startedAt: DateTime.parse(json['startedAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        pausedAt: json['pausedAt'] != null
            ? DateTime.parse(json['pausedAt'] as String)
            : null,
        totalMinutes: json['totalMinutes'] as int? ?? 0,
        totalShotsMade: json['totalShotsMade'] as int? ?? 0,
        totalShotsMissed: json['totalShotsMissed'] as int? ?? 0,
        drillRuns: (json['drillRuns'] as List?)
                ?.map((r) => DrillRun.fromJson(r as Map<String, dynamic>))
                .toList() ??
            const [],
        attempts: (json['attempts'] as List?)
                ?.map((a) => DrillAttempt.fromJson(a as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
