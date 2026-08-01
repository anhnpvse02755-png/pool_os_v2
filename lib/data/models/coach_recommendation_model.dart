import 'package:json_annotation/json_annotation.dart';

part 'coach_recommendation_model.g.dart';

@JsonSerializable()
class CoachRecommendationModel {
  final String id;
  final String playerId;
  final String observation;
  final Map<String, dynamic>? evidence;
  final String? reason;
  final int dataConfidence;
  final String recommendation;
  final String? expectedResult;
  final List<String> drillSuggestions;
  final String? actionLabel;
  final String? actionRoute;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime? validUntil;
  final DateTime? completedAt;

  CoachRecommendationModel({
    required this.id,
    required this.playerId,
    required this.observation,
    this.evidence,
    this.reason,
    required this.dataConfidence,
    required this.recommendation,
    this.expectedResult,
    this.drillSuggestions = const [],
    this.actionLabel,
    this.actionRoute,
    this.priority = 'improvement',
    this.status = 'active',
    required this.createdAt,
    this.validUntil,
    this.completedAt,
  });

  factory CoachRecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$CoachRecommendationModelFromJson(json);

  Map<String, dynamic> toJson() => _$CoachRecommendationModelToJson(this);
}
