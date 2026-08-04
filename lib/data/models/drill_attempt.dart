/// Per-attempt drill outcome.
class DrillAttempt {
  final String id;
  final String sessionId;
  final String drillCode;
  final int attemptNumber;
  final bool made;
  final int? timeMs;
  final String? notes;
  final DateTime createdAt;

  const DrillAttempt({
    required this.id,
    required this.sessionId,
    required this.drillCode,
    required this.attemptNumber,
    required this.made,
    this.timeMs,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'drillCode': drillCode,
        'attemptNumber': attemptNumber,
        'made': made,
        'timeMs': timeMs,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DrillAttempt.fromJson(Map<String, dynamic> json) => DrillAttempt(
        id: json['id'] as String,
        sessionId: json['sessionId'] as String,
        drillCode: json['drillCode'] as String,
        attemptNumber: json['attemptNumber'] as int,
        made: json['made'] as bool,
        timeMs: json['timeMs'] as int?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
