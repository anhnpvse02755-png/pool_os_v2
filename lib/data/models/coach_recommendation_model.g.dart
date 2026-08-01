// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_recommendation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachRecommendationModel _$CoachRecommendationModelFromJson(
  Map<String, dynamic> json,
) => CoachRecommendationModel(
  id: json['id'] as String,
  playerId: json['playerId'] as String,
  observation: json['observation'] as String,
  evidence: json['evidence'] as Map<String, dynamic>?,
  reason: json['reason'] as String?,
  dataConfidence: (json['dataConfidence'] as num).toInt(),
  recommendation: json['recommendation'] as String,
  expectedResult: json['expectedResult'] as String?,
  drillSuggestions:
      (json['drillSuggestions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  actionLabel: json['actionLabel'] as String?,
  actionRoute: json['actionRoute'] as String?,
  priority: json['priority'] as String? ?? 'improvement',
  status: json['status'] as String? ?? 'active',
  createdAt: DateTime.parse(json['createdAt'] as String),
  validUntil: json['validUntil'] == null
      ? null
      : DateTime.parse(json['validUntil'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$CoachRecommendationModelToJson(
  CoachRecommendationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'playerId': instance.playerId,
  'observation': instance.observation,
  'evidence': instance.evidence,
  'reason': instance.reason,
  'dataConfidence': instance.dataConfidence,
  'recommendation': instance.recommendation,
  'expectedResult': instance.expectedResult,
  'drillSuggestions': instance.drillSuggestions,
  'actionLabel': instance.actionLabel,
  'actionRoute': instance.actionRoute,
  'priority': instance.priority,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
  'validUntil': instance.validUntil?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
};
