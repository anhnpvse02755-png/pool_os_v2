// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerModel _$PlayerModelFromJson(Map<String, dynamic> json) => PlayerModel(
  id: json['id'] as String,
  userId: json['userId'] as String?,
  name: json['name'] as String,
  email: json['email'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  phone: json['phone'] as String?,
  dominantHand: json['dominantHand'] as String? ?? 'right',
  currentLevel: json['currentLevel'] as String? ?? 'beginner',
  targetLevel: json['targetLevel'] as String?,
  playingStyle:
      (json['playingStyle'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  yearsPlaying: (json['yearsPlaying'] as num?)?.toInt() ?? 0,
  hoursPerWeek: (json['hoursPerWeek'] as num?)?.toDouble() ?? 0,
  shortTermGoal: json['shortTermGoal'] as String?,
  longTermGoal: json['longTermGoal'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PlayerModelToJson(PlayerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'phone': instance.phone,
      'dominantHand': instance.dominantHand,
      'currentLevel': instance.currentLevel,
      'targetLevel': instance.targetLevel,
      'playingStyle': instance.playingStyle,
      'yearsPlaying': instance.yearsPlaying,
      'hoursPerWeek': instance.hoursPerWeek,
      'shortTermGoal': instance.shortTermGoal,
      'longTermGoal': instance.longTermGoal,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
