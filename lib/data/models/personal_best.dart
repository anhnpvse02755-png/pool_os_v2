/// Personal best per drill — either fastest, highest accuracy, longest
/// run, or most balls in a single session.
class PersonalBest {
  final String playerId;
  final String drillCode;
  final String metric; // fastest | highest_accuracy | longest_run | most_balls
  final double value;
  final int level;
  final DateTime achievedAt;

  const PersonalBest({
    required this.playerId,
    required this.drillCode,
    required this.metric,
    required this.value,
    required this.level,
    required this.achievedAt,
  });

  PersonalBest copyWith({
    double? value,
    int? level,
    DateTime? achievedAt,
  }) =>
      PersonalBest(
        playerId: playerId,
        drillCode: drillCode,
        metric: metric,
        value: value ?? this.value,
        level: level ?? this.level,
        achievedAt: achievedAt ?? this.achievedAt,
      );

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'drillCode': drillCode,
        'metric': metric,
        'value': value,
        'level': level,
        'achievedAt': achievedAt.toIso8601String(),
      };

  factory PersonalBest.fromJson(Map<String, dynamic> json) => PersonalBest(
        playerId: json['playerId'] as String? ?? '',
        drillCode: json['drillCode'] as String,
        metric: json['metric'] as String,
        value: (json['value'] as num).toDouble(),
        level: json['level'] as int? ?? 1,
        achievedAt: DateTime.parse(json['achievedAt'] as String),
      );
}

class PbMetric {
  static const String fastest = 'fastest';
  static const String highestAccuracy = 'highest_accuracy';
  static const String longestRun = 'longest_run';
  static const String mostBalls = 'most_balls';

  static const List<String> all = [fastest, highestAccuracy, longestRun, mostBalls];
}
