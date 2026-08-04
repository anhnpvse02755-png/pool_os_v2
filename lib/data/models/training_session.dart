/// Training Session Model
class TrainingSession {
  final String id;
  final String drillCode;
  final String drillName;
  final int level;
  final int score;
  final int shotsMade;
  final int shotsMissed;
  final int duration;
  final DateTime completedAt;

  TrainingSession({
    required this.id,
    required this.drillCode,
    required this.drillName,
    required this.level,
    required this.score,
    required this.shotsMade,
    required this.shotsMissed,
    required this.duration,
    required this.completedAt,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'] ?? json['drillCode'] ?? '',
      drillCode: json['drillCode'] ?? json['drill_code'] ?? '',
      drillName: json['drillName'] ?? json['drill_name'] ?? '',
      level: json['level'] ?? 1,
      score: json['score'] ?? 0,
      shotsMade: json['shotsMade'] ?? json['shots_made'] ?? 0,
      shotsMissed: json['shotsMissed'] ?? json['shots_missed'] ?? 0,
      duration: json['duration'] ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : (json['completed_at'] != null ? DateTime.parse(json['completed_at']) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'drillCode': drillCode,
      'drillName': drillName,
      'level': level,
      'score': score,
      'shotsMade': shotsMade,
      'shotsMissed': shotsMissed,
      'duration': duration,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  TrainingSession copyWith({
    String? id,
    String? drillCode,
    String? drillName,
    int? level,
    int? score,
    int? shotsMade,
    int? shotsMissed,
    int? duration,
    DateTime? completedAt,
  }) {
    return TrainingSession(
      id: id ?? this.id,
      drillCode: drillCode ?? this.drillCode,
      drillName: drillName ?? this.drillName,
      level: level ?? this.level,
      score: score ?? this.score,
      shotsMade: shotsMade ?? this.shotsMade,
      shotsMissed: shotsMissed ?? this.shotsMissed,
      duration: duration ?? this.duration,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
