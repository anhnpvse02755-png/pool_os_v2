// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShotModel _$ShotModelFromJson(Map<String, dynamic> json) => ShotModel(
  id: json['id'] as String,
  rackId: json['rackId'] as String,
  shotType: json['shotType'] as String,
  difficulty: json['difficulty'] as String? ?? 'medium',
  spinUsed:
      (json['spinUsed'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  result: json['result'] as String,
  events:
      (json['events'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  confidence: (json['confidence'] as num?)?.toInt() ?? 5,
  challenge: json['challenge'] as String?,
  shotOrder: (json['shotOrder'] as num?)?.toInt() ?? 1,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ShotModelToJson(ShotModel instance) => <String, dynamic>{
  'id': instance.id,
  'rackId': instance.rackId,
  'shotType': instance.shotType,
  'difficulty': instance.difficulty,
  'spinUsed': instance.spinUsed,
  'result': instance.result,
  'events': instance.events,
  'confidence': instance.confidence,
  'challenge': instance.challenge,
  'shotOrder': instance.shotOrder,
  'createdAt': instance.createdAt.toIso8601String(),
};
