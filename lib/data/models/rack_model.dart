import 'package:json_annotation/json_annotation.dart';

part 'rack_model.g.dart';

@JsonSerializable()
class RackModel {
  final String id;
  final String matchId;
  final int rackNumber;
  final String result;
  final bool breakShot;
  final bool? breakSuccess;
  final int ballsPottedOnBreak;
  final int longestRun;
  final int totalBallsPotted;
  final int safetyPlays;
  final int fouls;
  final String? howWon;
  final String? biggestMistake;
  final String? biggestStrength;
  final int confidence;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  RackModel({
    required this.id,
    required this.matchId,
    required this.rackNumber,
    required this.result,
    this.breakShot = false,
    this.breakSuccess,
    this.ballsPottedOnBreak = 0,
    this.longestRun = 0,
    this.totalBallsPotted = 0,
    this.safetyPlays = 0,
    this.fouls = 0,
    this.howWon,
    this.biggestMistake,
    this.biggestStrength,
    this.confidence = 3,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RackModel.fromJson(Map<String, dynamic> json) =>
      _$RackModelFromJson(json);

  Map<String, dynamic> toJson() => _$RackModelToJson(this);
}
