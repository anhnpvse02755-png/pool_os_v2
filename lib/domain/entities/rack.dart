import 'package:equatable/equatable.dart';
import 'shot.dart';

class Rack extends Equatable {
  final String id;
  final String matchId;
  final int rackNumber;
  final String result; // 'win' | 'lose'

  // Break
  final bool breakShot;
  final bool? breakSuccess;
  final int ballsPottedOnBreak;

  // Performance
  final int longestRun;
  final int totalBallsPotted;
  final int safetyPlays;
  final int fouls;

  // Analysis
  final String? howWon;
  final Shot? biggestMistake;
  final String? biggestStrength;

  // Confidence at rack end (1-5)
  final int confidence;

  // Notes
  final String? note;

  // Shots
  final List<Shot> shots;

  const Rack({
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
    this.shots = const [],
  });

  Rack copyWith({
    String? id,
    String? matchId,
    int? rackNumber,
    String? result,
    bool? breakShot,
    bool? breakSuccess,
    int? ballsPottedOnBreak,
    int? longestRun,
    int? totalBallsPotted,
    int? safetyPlays,
    int? fouls,
    String? howWon,
    Shot? biggestMistake,
    String? biggestStrength,
    int? confidence,
    String? note,
    List<Shot>? shots,
  }) {
    return Rack(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      rackNumber: rackNumber ?? this.rackNumber,
      result: result ?? this.result,
      breakShot: breakShot ?? this.breakShot,
      breakSuccess: breakSuccess ?? this.breakSuccess,
      ballsPottedOnBreak: ballsPottedOnBreak ?? this.ballsPottedOnBreak,
      longestRun: longestRun ?? this.longestRun,
      totalBallsPotted: totalBallsPotted ?? this.totalBallsPotted,
      safetyPlays: safetyPlays ?? this.safetyPlays,
      fouls: fouls ?? this.fouls,
      howWon: howWon ?? this.howWon,
      biggestMistake: biggestMistake ?? this.biggestMistake,
      biggestStrength: biggestStrength ?? this.biggestStrength,
      confidence: confidence ?? this.confidence,
      note: note ?? this.note,
      shots: shots ?? this.shots,
    );
  }

  @override
  List<Object?> get props => [
        id,
        matchId,
        rackNumber,
        result,
        breakShot,
        breakSuccess,
        ballsPottedOnBreak,
        longestRun,
        totalBallsPotted,
        safetyPlays,
        fouls,
        howWon,
        biggestMistake,
        biggestStrength,
        confidence,
        note,
        shots,
      ];
}
