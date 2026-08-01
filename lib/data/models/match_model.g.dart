// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchModel _$MatchModelFromJson(Map<String, dynamic> json) => MatchModel(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  opponent: json['opponent'] as String?,
  raceTo: (json['raceTo'] as num).toInt(),
  result: json['result'] as String,
  matchType: json['matchType'] as String? ?? 'friendly',
  opponentLevel: json['opponentLevel'] as String?,
  startTime: json['startTime'] == null
      ? null
      : DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  tableCondition: json['tableCondition'] as String?,
  environment: json['environment'] as String?,
  lighting: json['lighting'] as String?,
  playerScore: (json['playerScore'] as num?)?.toInt() ?? 0,
  opponentScore: (json['opponentScore'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MatchModelToJson(MatchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'opponent': instance.opponent,
      'raceTo': instance.raceTo,
      'result': instance.result,
      'matchType': instance.matchType,
      'opponentLevel': instance.opponentLevel,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'tableCondition': instance.tableCondition,
      'environment': instance.environment,
      'lighting': instance.lighting,
      'playerScore': instance.playerScore,
      'opponentScore': instance.opponentScore,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
