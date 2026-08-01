import 'package:json_annotation/json_annotation.dart';

part 'player_model.g.dart';

@JsonSerializable()
class PlayerModel {
  final String id;
  final String? userId;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String? phone;
  final String dominantHand;
  final String currentLevel;
  final String? targetLevel;
  final List<String> playingStyle;
  final int yearsPlaying;
  final double hoursPerWeek;
  final String? shortTermGoal;
  final String? longTermGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlayerModel({
    required this.id,
    this.userId,
    required this.name,
    this.email,
    this.avatarUrl,
    this.phone,
    this.dominantHand = 'right',
    this.currentLevel = 'beginner',
    this.targetLevel,
    this.playingStyle = const [],
    this.yearsPlaying = 0,
    this.hoursPerWeek = 0,
    this.shortTermGoal,
    this.longTermGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerModelToJson(this);

  PlayerModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? avatarUrl,
    String? phone,
    String? dominantHand,
    String? currentLevel,
    String? targetLevel,
    List<String>? playingStyle,
    int? yearsPlaying,
    double? hoursPerWeek,
    String? shortTermGoal,
    String? longTermGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      dominantHand: dominantHand ?? this.dominantHand,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      playingStyle: playingStyle ?? this.playingStyle,
      yearsPlaying: yearsPlaying ?? this.yearsPlaying,
      hoursPerWeek: hoursPerWeek ?? this.hoursPerWeek,
      shortTermGoal: shortTermGoal ?? this.shortTermGoal,
      longTermGoal: longTermGoal ?? this.longTermGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
