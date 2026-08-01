import 'package:json_annotation/json_annotation.dart';

part 'session_model.g.dart';

@JsonSerializable()
class SessionModel {
  final String id;
  final String playerId;
  final DateTime date;
  final String type;

  // Pre-Match
  final DateTime? arrivalTime;
  final int? warmupDuration;
  final List<String>? warmupDrills;
  final int? warmupScore;
  final String? matchPurpose;
  final String? opponentType;
  final String? tableCondition;

  // Readiness
  final int energyLevel;
  final int focusLevel;
  final int confidenceLevel;

  // Post-Match
  final String? fatigueLevel;
  final List<String>? fatigueLocations;
  final String? mentalState;
  final int? selfRating;
  final String? keyFactor;

  // Status
  final String status;
  final int? durationMinutes;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SessionModel({
    required this.id,
    required this.playerId,
    required this.date,
    required this.type,
    this.arrivalTime,
    this.warmupDuration,
    this.warmupDrills,
    this.warmupScore,
    this.matchPurpose,
    this.opponentType,
    this.tableCondition,
    this.energyLevel = 3,
    this.focusLevel = 3,
    this.confidenceLevel = 3,
    this.fatigueLevel,
    this.fatigueLocations,
    this.mentalState,
    this.selfRating,
    this.keyFactor,
    this.status = 'active',
    this.durationMinutes,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);
}
