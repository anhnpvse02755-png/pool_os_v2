/// Match Recording Model
class Match {
  final String id;
  final String? opponent;
  final int raceTo;
  final String result; // win, lose, draw
  final String matchType; // practice, friendly, tournament
  final String? opponentLevel;
  final DateTime? startTime;
  final DateTime? endTime;
  final int playerScore;
  final int opponentScore;
  final List<Rack> racks;
  final String? tableCondition;
  final String? environment;
  final DateTime createdAt;

  Match({
    required this.id,
    this.opponent,
    this.raceTo = 1,
    required this.result,
    this.matchType = 'friendly',
    this.opponentLevel,
    this.startTime,
    this.endTime,
    this.playerScore = 0,
    this.opponentScore = 0,
    this.racks = const [],
    this.tableCondition,
    this.environment,
    required this.createdAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      opponent: json['opponent'],
      raceTo: json['race_to'] ?? 1,
      result: json['result'] ?? 'lose',
      matchType: json['match_type'] ?? 'friendly',
      opponentLevel: json['opponent_level'],
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : null,
      playerScore: json['player_score'] ?? 0,
      opponentScore: json['opponent_score'] ?? 0,
      tableCondition: json['table_condition'],
      environment: json['environment'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'opponent': opponent,
      'race_to': raceTo,
      'result': result,
      'match_type': matchType,
      'opponent_level': opponentLevel,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'player_score': playerScore,
      'opponent_score': opponentScore,
      'table_condition': tableCondition,
      'environment': environment,
    };
  }

  bool get isInProgress => endTime == null && startTime != null;

  Duration? get duration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!);
  }

  Match copyWith({
    String? opponent,
    int? raceTo,
    String? result,
    String? matchType,
    String? opponentLevel,
    DateTime? startTime,
    DateTime? endTime,
    int? playerScore,
    int? opponentScore,
    List<Rack>? racks,
    String? tableCondition,
    String? environment,
  }) {
    return Match(
      id: id,
      opponent: opponent ?? this.opponent,
      raceTo: raceTo ?? this.raceTo,
      result: result ?? this.result,
      matchType: matchType ?? this.matchType,
      opponentLevel: opponentLevel ?? this.opponentLevel,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      playerScore: playerScore ?? this.playerScore,
      opponentScore: opponentScore ?? this.opponentScore,
      racks: racks ?? this.racks,
      tableCondition: tableCondition ?? this.tableCondition,
      environment: environment ?? this.environment,
      createdAt: createdAt,
    );
  }
}

/// Rack (Frame) within a match
class Rack {
  final int rackNumber;
  final String result; // win, lose
  final bool breakShot;
  final bool? breakSuccess;
  final int ballsPottedOnBreak;
  final int longestRun;
  final int totalBallsPotted;
  final int safetyPlays;
  final int fouls;
  final String? howWon;
  final String? biggestMistake;
  final String? biggestStrength;
  final int confidence; // 1-5
  final String? note;

  Rack({
    required this.rackNumber,
    required this.result,
    this.breakShot = false,
    this.breakSuccess,
    this.ballsPottedOnBreak = 0,
    this.longestRun = 0,
    this.totalBallsPotted = 0,
    this.safetyPlays = 0,
    this.fouls = 0,
    this.howWon,
    this.biggestMistake,
    this.biggestStrength,
    this.confidence = 3,
    this.note,
  });

  factory Rack.fromJson(Map<String, dynamic> json) {
    return Rack(
      rackNumber: json['rack_number'] ?? 1,
      result: json['result'] ?? 'lose',
      breakShot: json['break_shot'] ?? false,
      breakSuccess: json['break_success'],
      ballsPottedOnBreak: json['balls_potted_on_break'] ?? 0,
      longestRun: json['longest_run'] ?? 0,
      totalBallsPotted: json['total_balls_potted'] ?? 0,
      safetyPlays: json['safety_plays'] ?? 0,
      fouls: json['fouls'] ?? 0,
      howWon: json['how_won'],
      biggestMistake: json['biggest_mistake'],
      biggestStrength: json['biggest_strength'],
      confidence: json['confidence'] ?? 3,
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rack_number': rackNumber,
      'result': result,
      'break_shot': breakShot,
      'break_success': breakSuccess,
      'balls_potted_on_break': ballsPottedOnBreak,
      'longest_run': longestRun,
      'total_balls_potted': totalBallsPotted,
      'safety_plays': safetyPlays,
      'fouls': fouls,
      'how_won': howWon,
      'biggest_mistake': biggestMistake,
      'biggest_strength': biggestStrength,
      'confidence': confidence,
      'note': note,
    };
  }

  Rack copyWith({
    int? rackNumber,
    String? result,
    bool? breakShot,
    bool? breakSuccess,
    int? ballsPottedOnBreak,
    int? longestRun,
    int? totalBallsPotted,
    int? safetyPlays,
    int? fouls,
    String? howWon,
    String? biggestMistake,
    String? biggestStrength,
    int? confidence,
    String? note,
  }) {
    return Rack(
      rackNumber: rackNumber ?? this.rackNumber,
      result: result ?? this.result,
      breakShot: breakShot ?? this.breakShot,
      breakSuccess: breakSuccess ?? this.breakSuccess,
      ballsPottedOnBreak: ballsPottedOnBreak ?? this.ballsPottedOnBreak,
      longestRun: longestRun ?? this.longestRun,
      totalBallsPotted: totalBallsPotted ?? this.totalBallsPotted,
      safetyPlays: safetyPlays ?? this.safetyPlays,
      fouls: fouls ?? this.fouls,
      howWon: howWon ?? this.howWon,
      biggestMistake: biggestMistake ?? this.biggestMistake,
      biggestStrength: biggestStrength ?? this.biggestStrength,
      confidence: confidence ?? this.confidence,
      note: note ?? this.note,
    );
  }
}

/// Match statistics
class MatchStats {
  final int totalRacks;
  final int racksWon;
  final int racksLost;
  final int totalBallsPotted;
  final int longestRun;
  final int totalFouls;
  final int breakSuccessCount;
  final double winRate;

  MatchStats({
    required this.totalRacks,
    required this.racksWon,
    required this.racksLost,
    required this.totalBallsPotted,
    required this.longestRun,
    required this.totalFouls,
    required this.breakSuccessCount,
    required this.winRate,
  });

  factory MatchStats.fromRacks(List<Rack> racks) {
    final won = racks.where((r) => r.result == 'win').length;
    final lost = racks.where((r) => r.result == 'lose').length;
    final totalBalls = racks.fold<int>(0, (sum, r) => sum + r.totalBallsPotted);
    final longestRun = racks.fold<int>(0, (max, r) => r.longestRun > max ? r.longestRun : max);
    final totalFouls = racks.fold<int>(0, (sum, r) => sum + r.fouls);
    final breakSuccess = racks.where((r) => r.breakShot && r.breakSuccess == true).length;

    return MatchStats(
      totalRacks: racks.length,
      racksWon: won,
      racksLost: lost,
      totalBallsPotted: totalBalls,
      longestRun: longestRun,
      totalFouls: totalFouls,
      breakSuccessCount: breakSuccess,
      winRate: racks.isEmpty ? 0 : (won / racks.length) * 100,
    );
  }
}
