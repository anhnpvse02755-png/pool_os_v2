/// Player Model
class Player {
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

  Player({
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

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'] ?? '',
      email: json['email'],
      avatarUrl: json['avatar_url'],
      phone: json['phone'],
      dominantHand: json['dominant_hand'] ?? 'right',
      currentLevel: json['current_level'] ?? 'beginner',
      targetLevel: json['target_level'],
      playingStyle: List<String>.from(json['playing_style'] ?? []),
      yearsPlaying: json['years_playing'] ?? 0,
      hoursPerWeek: (json['hours_per_week'] ?? 0).toDouble(),
      shortTermGoal: json['short_term_goal'],
      longTermGoal: json['long_term_goal'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'phone': phone,
      'dominant_hand': dominantHand,
      'current_level': currentLevel,
      'target_level': targetLevel,
      'playing_style': playingStyle,
      'years_playing': yearsPlaying,
      'hours_per_week': hoursPerWeek,
      'short_term_goal': shortTermGoal,
      'long_term_goal': longTermGoal,
    };
  }

  Player copyWith({
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
    DateTime? updatedAt,
  }) {
    return Player(
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
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
