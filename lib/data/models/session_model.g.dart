// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
  id: json['id'] as String,
  playerId: json['playerId'] as String,
  date: DateTime.parse(json['date'] as String),
  type: json['type'] as String,
  arrivalTime: json['arrivalTime'] == null
      ? null
      : DateTime.parse(json['arrivalTime'] as String),
  warmupDuration: (json['warmupDuration'] as num?)?.toInt(),
  warmupDrills: (json['warmupDrills'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  warmupScore: (json['warmupScore'] as num?)?.toInt(),
  matchPurpose: json['matchPurpose'] as String?,
  opponentType: json['opponentType'] as String?,
  tableCondition: json['tableCondition'] as String?,
  energyLevel: (json['energyLevel'] as num?)?.toInt() ?? 3,
  focusLevel: (json['focusLevel'] as num?)?.toInt() ?? 3,
  confidenceLevel: (json['confidenceLevel'] as num?)?.toInt() ?? 3,
  fatigueLevel: json['fatigueLevel'] as String?,
  fatigueLocations: (json['fatigueLocations'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  mentalState: json['mentalState'] as String?,
  selfRating: (json['selfRating'] as num?)?.toInt(),
  keyFactor: json['keyFactor'] as String?,
  status: json['status'] as String? ?? 'active',
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'playerId': instance.playerId,
      'date': instance.date.toIso8601String(),
      'type': instance.type,
      'arrivalTime': instance.arrivalTime?.toIso8601String(),
      'warmupDuration': instance.warmupDuration,
      'warmupDrills': instance.warmupDrills,
      'warmupScore': instance.warmupScore,
      'matchPurpose': instance.matchPurpose,
      'opponentType': instance.opponentType,
      'tableCondition': instance.tableCondition,
      'energyLevel': instance.energyLevel,
      'focusLevel': instance.focusLevel,
      'confidenceLevel': instance.confidenceLevel,
      'fatigueLevel': instance.fatigueLevel,
      'fatigueLocations': instance.fatigueLocations,
      'mentalState': instance.mentalState,
      'selfRating': instance.selfRating,
      'keyFactor': instance.keyFactor,
      'status': instance.status,
      'durationMinutes': instance.durationMinutes,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
