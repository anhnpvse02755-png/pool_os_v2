/// Training Session Model
class TrainingSession {
  final String id;
  final String playerId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationMinutes;
  final String? notes;
  final List<DrillRun> drillRuns;

  TrainingSession({
    required this.id,
    required this.playerId,
    required this.startedAt,
    this.completedAt,
    this.durationMinutes,
    this.notes,
    this.drillRuns = const [],
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'],
      playerId: json['player_id'],
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      durationMinutes: json['duration_minutes'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'notes': notes,
    };
  }

  bool get isCompleted => completedAt != null;

  TrainingSession copyWith({
    DateTime? completedAt,
    int? durationMinutes,
    String? notes,
  }) {
    return TrainingSession(
      id: id,
      playerId: playerId,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      drillRuns: drillRuns,
    );
  }
}

/// Drill Run Model - Individual drill attempt within a session
class DrillRun {
  final String id;
  final String sessionId;
  final String drillCode;
  final String drillName;
  final String? category;
  final int? targetReps;
  final int attempts;
  final int successes;
  final double successRate;
  final int? durationSeconds;
  final String? notes;
  final DateTime createdAt;

  DrillRun({
    required this.id,
    required this.sessionId,
    required this.drillCode,
    required this.drillName,
    this.category,
    this.targetReps,
    this.attempts = 0,
    this.successes = 0,
    this.successRate = 0,
    this.durationSeconds,
    this.notes,
    required this.createdAt,
  });

  factory DrillRun.fromJson(Map<String, dynamic> json) {
    return DrillRun(
      id: json['id'],
      sessionId: json['session_id'],
      drillCode: json['drill_code'],
      drillName: json['drill_name'],
      category: json['category'],
      targetReps: json['target_reps'],
      attempts: json['attempts'] ?? 0,
      successes: json['successes'] ?? 0,
      successRate: (json['success_rate'] ?? 0).toDouble(),
      durationSeconds: json['duration_seconds'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'drill_code': drillCode,
      'drill_name': drillName,
      'category': category,
      'target_reps': targetReps,
      'attempts': attempts,
      'successes': successes,
      'duration_seconds': durationSeconds,
      'notes': notes,
    };
  }

  bool get passed {
    if (targetReps == null) return false;
    // Pass criteria: at least 80% success rate
    return attempts >= targetReps! && successRate >= 80;
  }

  DrillRun copyWith({
    int? attempts,
    int? successes,
    int? durationSeconds,
    String? notes,
  }) {
    final newAttempts = attempts ?? this.attempts;
    final newSuccesses = successes ?? this.successes;
    return DrillRun(
      id: id,
      sessionId: sessionId,
      drillCode: drillCode,
      drillName: drillName,
      category: category,
      targetReps: targetReps,
      attempts: newAttempts,
      successes: newSuccesses,
      successRate: newAttempts > 0 ? (newSuccesses / newAttempts) * 100 : 0,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
