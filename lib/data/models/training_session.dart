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

  /// Tong so cu da danh. DU LIEU DAN XUAT — khong luu tru.
  /// Giu ten nay de cac noi doc `session.shotsAttempted` khong phai sua.
  int get shotsAttempted => shotsMade + shotsMissed;

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    final int made = (json['shotsMade'] ?? json['shots_made'] ?? 0) as int;

    // Khoa cu chi luu `shotsAttempted`. Suy ra so truot, chan so am
    // phong khi du lieu ban.
    final int missed;
    if (json['shotsMissed'] != null || json['shots_missed'] != null) {
      missed = (json['shotsMissed'] ?? json['shots_missed']) as int;
    } else if (json['shotsAttempted'] != null) {
      final attempted = json['shotsAttempted'] as int;
      missed = attempted - made < 0 ? 0 : attempted - made;
    } else {
      missed = 0;
    }

    // Khoa cu dung `date`. Bo qua no thi moi buoi tap deu mang gio DOC.
    final rawDate =
        json['completedAt'] ?? json['completed_at'] ?? json['date'];

    return TrainingSession(
      id: json['id'] ?? json['drillCode'] ?? '',
      drillCode: json['drillCode'] ?? json['drill_code'] ?? '',
      drillName: json['drillName'] ?? json['drill_name'] ?? '',
      level: json['level'] ?? 1,
      score: json['score'] ?? 0,
      shotsMade: made,
      shotsMissed: missed,
      duration: json['duration'] ?? 0,
      completedAt:
          rawDate != null ? DateTime.parse(rawDate as String) : DateTime.now(),
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
