import 'package:json_annotation/json_annotation.dart';

part 'match_model.g.dart';

@JsonSerializable()
class MatchModel {
  final String id;
  final String sessionId;
  final String? opponent;
  final int raceTo;
  final String result;
  final String matchType;
  final String? opponentLevel;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? tableCondition;
  final String? environment;
  final String? lighting;
  final int playerScore;
  final int opponentScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  MatchModel({
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
    this.playerScore = 0,
    this.opponentScore = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) =>
      _$MatchModelFromJson(json);

  Map<String, dynamic> toJson() => _$MatchModelToJson(this);
}
