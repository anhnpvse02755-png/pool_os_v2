/// Player Interests Model
/// Stores user's interests selected during onboarding
class PlayerInterests {
  final String id;
  final String playerId;
  final List<String> interests; // e.g., ['draw', 'position', 'bank', 'kick', 'jump']
  final DateTime updatedAt;

  PlayerInterests({
    required this.id,
    required this.playerId,
    required this.interests,
    required this.updatedAt,
  });

  factory PlayerInterests.fromJson(Map<String, dynamic> json) {
    return PlayerInterests(
      id: json['id'],
      playerId: json['player_id'],
      interests: List<String>.from(json['interests'] ?? []),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'interests': interests,
    };
  }

  PlayerInterests copyWith({
    List<String>? interests,
  }) {
    return PlayerInterests(
      id: id,
      playerId: playerId,
      interests: interests ?? this.interests,
      updatedAt: DateTime.now(),
    );
  }
}

/// Available interests with metadata
class InterestOption {
  final String id;
  final String name;
  final String nameVi;
  final String icon;
  final String color;

  const InterestOption({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.icon,
    required this.color,
  });

  static const List<InterestOption> all = [
    InterestOption(
      id: 'draw',
      name: 'Draw Shot',
      nameVi: 'Draw Shot',
      icon: 'arrow_back',
      color: 'orange',
    ),
    InterestOption(
      id: 'position',
      name: 'Position Control',
      nameVi: 'Kiểm soát vị trí',
      icon: 'gps_fixed',
      color: 'blue',
    ),
    InterestOption(
      id: 'bank',
      name: 'Bank Shot',
      nameVi: 'Bank',
      icon: 'change_history',
      color: 'purple',
    ),
    InterestOption(
      id: 'kick',
      name: 'Kick Shot',
      nameVi: 'Kick',
      icon: 'turn_right',
      color: 'teal',
    ),
    InterestOption(
      id: 'jump',
      name: 'Jump Shot',
      nameVi: 'Jump',
      icon: 'arrow_upward',
      color: 'red',
    ),
    InterestOption(
      id: 'masse',
      name: 'Masse',
      nameVi: 'Masse',
      icon: 'rotate_right',
      color: 'pink',
    ),
    InterestOption(
      id: 'safety',
      name: 'Safety Play',
      nameVi: 'An toàn',
      icon: 'shield',
      color: 'green',
    ),
    InterestOption(
      id: '3cushion',
      name: '3 Cushion',
      nameVi: '3 Băng',
      icon: 'view_in_ar',
      color: 'indigo',
    ),
    InterestOption(
      id: 'trickshot',
      name: 'Trickshot',
      nameVi: 'Trickshot',
      icon: 'auto_awesome',
      color: 'amber',
    ),
    InterestOption(
      id: 'break',
      name: 'Break Shot',
      nameVi: 'Khai cuộc',
      icon: 'flash_on',
      color: 'deepOrange',
    ),
  ];
}
