// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rack_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RackModel _$RackModelFromJson(Map<String, dynamic> json) => RackModel(
  id: json['id'] as String,
  matchId: json['matchId'] as String,
  rackNumber: (json['rackNumber'] as num).toInt(),
  result: json['result'] as String,
  breakShot: json['breakShot'] as bool? ?? false,
  breakSuccess: json['breakSuccess'] as bool?,
  ballsPottedOnBreak: (json['ballsPottedOnBreak'] as num?)?.toInt() ?? 0,
  longestRun: (json['longestRun'] as num?)?.toInt() ?? 0,
  totalBallsPotted: (json['totalBallsPotted'] as num?)?.toInt() ?? 0,
  safetyPlays: (json['safetyPlays'] as num?)?.toInt() ?? 0,
  fouls: (json['fouls'] as num?)?.toInt() ?? 0,
  howWon: json['howWon'] as String?,
  biggestMistake: json['biggestMistake'] as String?,
  biggestStrength: json['biggestStrength'] as String?,
  confidence: (json['confidence'] as num?)?.toInt() ?? 3,
  note: json['note'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RackModelToJson(RackModel instance) => <String, dynamic>{
  'id': instance.id,
  'matchId': instance.matchId,
  'rackNumber': instance.rackNumber,
  'result': instance.result,
  'breakShot': instance.breakShot,
  'breakSuccess': instance.breakSuccess,
  'ballsPottedOnBreak': instance.ballsPottedOnBreak,
  'longestRun': instance.longestRun,
  'totalBallsPotted': instance.totalBallsPotted,
  'safetyPlays': instance.safetyPlays,
  'fouls': instance.fouls,
  'howWon': instance.howWon,
  'biggestMistake': instance.biggestMistake,
  'biggestStrength': instance.biggestStrength,
  'confidence': instance.confidence,
  'note': instance.note,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
