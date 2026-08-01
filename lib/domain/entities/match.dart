import 'package:equatable/equatable.dart';

class Match extends Equatable {
  final String id;
  final String sessionId;
  final String? opponent;
  final int raceTo;
  final String result; // 'win' | 'lose' | 'draw'
  final String matchType; // 'practice' | 'friendly' | 'tournament' | 'league'
  final String? opponentLevel; // 'weaker' | 'equal' | 'stronger'
  final DateTime? startTime;
  final DateTime? endTime;

  // Table context
  final String? tableCondition; // 'familiar' | 'unfamiliar'
  final String? environment; // 'home' | 'club' | 'tournament'
  final String? lighting; // 'good' | 'normal' | 'poor'

  const Match({
    required this.id,
    required this.sessionId,
    this.opponent,
    required this.raceTo,
    required this.result,
    this.matchType = 'friendly',
    this.opponentLevel,
    this.startTime,
    this.endTime,
    this.tableCondition,
    this.environment,
    this.lighting,
  });

  Match copyWith({
    String? id,
    String? sessionId,
    String? opponent,
    int? raceTo,
    String? result,
    String? matchType,
    String? opponentLevel,
    DateTime? startTime,
    DateTime? endTime,
    String? tableCondition,
    String? environment,
    String? lighting,
  }) {
    return Match(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      opponent: opponent ?? this.opponent,
      raceTo: raceTo ?? this.raceTo,
      result: result ?? this.result,
      matchType: matchType ?? this.matchType,
      opponentLevel: opponentLevel ?? this.opponentLevel,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      tableCondition: tableCondition ?? this.tableCondition,
      environment: environment ?? this.environment,
      lighting: lighting ?? this.lighting,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        opponent,
        raceTo,
        result,
        matchType,
        opponentLevel,
        startTime,
        endTime,
        tableCondition,
        environment,
        lighting,
      ];
}
