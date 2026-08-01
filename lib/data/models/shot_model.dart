import 'package:json_annotation/json_annotation.dart';

part 'shot_model.g.dart';

@JsonSerializable()
class ShotModel {
  final String id;
  final String rackId;
  final String shotType;
  final String difficulty;
  final List<String> spinUsed;
  final String result;
  final List<String> events;
  final int confidence;
  final String? challenge;
  final int shotOrder;
  final DateTime createdAt;

  ShotModel({
    required this.id,
    required this.rackId,
    required this.shotType,
    this.difficulty = 'medium',
    this.spinUsed = const [],
    required this.result,
    this.events = const [],
    this.confidence = 5,
    this.challenge,
    this.shotOrder = 1,
    required this.createdAt,
  });

  factory ShotModel.fromJson(Map<String, dynamic> json) =>
      _$ShotModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShotModelToJson(this);
}
