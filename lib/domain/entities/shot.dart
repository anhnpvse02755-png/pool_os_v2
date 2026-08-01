import 'package:equatable/equatable.dart';

class Shot extends Equatable {
  final String id;
  final String rackId;

  // What player tried to do
  final String shotType; // 'pot' | 'safety' | 'break' | 'jump' | 'kick' | 'bank' | 'combo' | 'push_out' | 'masse'
  final String difficulty; // 'easy' | 'medium' | 'hard'

  // Spin
  final List<String> spinUsed; // 'top' | 'back' | 'left' | 'right' | 'follow' | 'draw'

  // Result
  final String result; // 'made' | 'missed'

  // Events (what went wrong, if any)
  final List<String> events; // 'scratch' | 'foul' | 'double_kiss' | 'jumped_cue' | 'easy_miss' | etc.

  // Confidence before shot (1-10)
  final int confidence;

  // Challenge/Goal (Practice mode)
  final String? challenge;

  const Shot({
    required this.id,
    required this.rackId,
    required this.shotType,
    this.difficulty = 'medium',
    this.spinUsed = const [],
    required this.result,
    this.events = const [],
    this.confidence = 5,
    this.challenge,
  });

  Shot copyWith({
    String? id,
    String? rackId,
    String? shotType,
    String? difficulty,
    List<String>? spinUsed,
    String? result,
    List<String>? events,
    int? confidence,
    String? challenge,
  }) {
    return Shot(
      id: id ?? this.id,
      rackId: rackId ?? this.rackId,
      shotType: shotType ?? this.shotType,
      difficulty: difficulty ?? this.difficulty,
      spinUsed: spinUsed ?? this.spinUsed,
      result: result ?? this.result,
      events: events ?? this.events,
      confidence: confidence ?? this.confidence,
      challenge: challenge ?? this.challenge,
    );
  }

  @override
  List<Object?> get props => [
        id,
        rackId,
        shotType,
        difficulty,
        spinUsed,
        result,
        events,
        confidence,
        challenge,
      ];
}
