import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final String dominantHand;
  final String currentLevel;
  final String? targetLevel;
  final List<String> playingStyle;
  final int? yearsPlaying;
  final double? hoursPerWeek;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Player({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.dominantHand = 'right',
    this.currentLevel = 'beginner',
    this.targetLevel,
    this.playingStyle = const [],
    this.yearsPlaying,
    this.hoursPerWeek,
    required this.createdAt,
    required this.updatedAt,
  });

  Player copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? dominantHand,
    String? currentLevel,
    String? targetLevel,
    List<String>? playingStyle,
    int? yearsPlaying,
    double? hoursPerWeek,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dominantHand: dominantHand ?? this.dominantHand,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      playingStyle: playingStyle ?? this.playingStyle,
      yearsPlaying: yearsPlaying ?? this.yearsPlaying,
      hoursPerWeek: hoursPerWeek ?? this.hoursPerWeek,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        dominantHand,
        currentLevel,
        targetLevel,
        playingStyle,
        yearsPlaying,
        hoursPerWeek,
        createdAt,
        updatedAt,
      ];
}
