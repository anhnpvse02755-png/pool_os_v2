import 'package:equatable/equatable.dart';

class CoachRecommendation extends Equatable {
  final String id;
  final String playerId;

  // Insight components
  final String observation; // What was detected
  final Map<String, dynamic>? evidence; // Data backing
  final String? reason; // Why this matters
  final int dataConfidence; // How reliable this insight is (1-100)

  // Action
  final String recommendation; // Specific action to take
  final String? expectedResult; // What improvement to expect
  final List<String> drillSuggestions;

  // Navigation
  final String actionLabel; // e.g., "Luyện Jump"
  final String actionRoute; // Navigation target

  // Tracking
  final String priority; // 'critical' | 'blocking' | 'improvement' | 'knowledge' | 'positive'
  final String status; // 'active' | 'completed' | 'ignored' | 'expired'
  final DateTime createdAt;
  final DateTime? validUntil;

  const CoachRecommendation({
    required this.id,
    required this.playerId,
    required this.observation,
    this.evidence,
    this.reason,
    required this.dataConfidence,
    required this.recommendation,
    this.expectedResult,
    this.drillSuggestions = const [],
    required this.actionLabel,
    required this.actionRoute,
    this.priority = 'improvement',
    this.status = 'active',
    required this.createdAt,
    this.validUntil,
  });

  CoachRecommendation copyWith({
    String? id,
    String? playerId,
    String? observation,
    Map<String, dynamic>? evidence,
    String? reason,
    int? dataConfidence,
    String? recommendation,
    String? expectedResult,
    List<String>? drillSuggestions,
    String? actionLabel,
    String? actionRoute,
    String? priority,
    String? status,
    DateTime? createdAt,
    DateTime? validUntil,
  }) {
    return CoachRecommendation(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      observation: observation ?? this.observation,
      evidence: evidence ?? this.evidence,
      reason: reason ?? this.reason,
      dataConfidence: dataConfidence ?? this.dataConfidence,
      recommendation: recommendation ?? this.recommendation,
      expectedResult: expectedResult ?? this.expectedResult,
      drillSuggestions: drillSuggestions ?? this.drillSuggestions,
      actionLabel: actionLabel ?? this.actionLabel,
      actionRoute: actionRoute ?? this.actionRoute,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      validUntil: validUntil ?? this.validUntil,
    );
  }

  @override
  List<Object?> get props => [
        id,
        playerId,
        observation,
        evidence,
        reason,
        dataConfidence,
        recommendation,
        expectedResult,
        drillSuggestions,
        actionLabel,
        actionRoute,
        priority,
        status,
        createdAt,
        validUntil,
      ];
}
