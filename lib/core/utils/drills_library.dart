import '../constants/app_constants.dart';

/// Drill Library for Training Center
/// Based on FINAL Training Center Specification v2
class DrillLibrary {
  static const List<DrillCategory> categories = [
    DrillCategory(
      id: 'potting',
      name: 'Potting',
      nameVi: 'Đánh bóng',
      icon: 'center_focus_strong',
      drills: [
        Drill(
          code: 'STRAIGHT_POT',
          name: 'Straight Shot',
          nameVi: 'Đánh thẳng',
          category: 'potting',
          difficulty: 'easy',
          description: 'Đánh bi vào lỗ theo đường thẳng',
          setup: 'Đặt bi mục tiêu cách lỗ 30cm',
          steps: [
            'Ngắm thẳng từ bi đến lỗ',
            'Tư thế vững vàng',
            'Đánh thẳng, nhắm điểm chính xác',
            'Follow through đầy đủ',
          ],
          goal: 'Đánh trúng 10 lần trong 12 lần thử',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 8, distance: '20cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 8, distance: '30cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, distance: '50cm'),
            DrillLevel(level: 4, attempts: 10, passCount: 8, distance: '70cm'),
            DrillLevel(level: 5, attempts: 10, passCount: 9, distance: 'Full table'),
          ],
          knowledgeIds: ['aiming', 'bridge', 'stroke'],
        ),
        Drill(
          code: 'THIN_CUT',
          name: 'Thin Cut',
          nameVi: 'Cắt mỏng',
          category: 'potting',
          difficulty: 'medium',
          description: 'Đánh bi với góc cắt mỏng (< 30°)',
          setup: 'Đặt bi ở góc bàn',
          steps: [
            'Xác định góc cắt',
            'Ngắm điểm ngắm chính xác',
            'Kiểm soát lực vừa phải',
            'Follow through thẳng',
          ],
          goal: 'Đánh trúng 8 lần trong 10 lần thử',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, angle: '15°'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, angle: '20°'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, angle: '25°'),
            DrillLevel(level: 4, attempts: 10, passCount: 8, angle: '30°'),
            DrillLevel(level: 5, attempts: 10, passCount: 9, angle: '35°'),
          ],
          knowledgeIds: ['cut_shots', 'aiming', 'english'],
        ),
        Drill(
          code: 'THICK_CUT',
          name: 'Thick Cut',
          nameVi: 'Cắt dày',
          category: 'potting',
          difficulty: 'easy',
          description: 'Đánh bi với góc cắt dày (> 45°)',
          setup: 'Đặt bi gần lỗ',
          steps: [
            'Xác định góc cắt',
            'Ngắm điểm ngắm',
            'Điều khiển lực phù hợp',
          ],
          goal: 'Đánh trúng 8 lần trong 10 lần thử',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, angle: '45°'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, angle: '50°'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, angle: '55°'),
            DrillLevel(level: 4, attempts: 10, passCount: 8, angle: '60°'),
            DrillLevel(level: 5, attempts: 10, passCount: 9, angle: '65°'),
          ],
          knowledgeIds: ['cut_shots', 'aiming'],
        ),
      ],
    ),
    DrillCategory(
      id: 'cueball',
      name: 'Cue Ball',
      nameVi: 'Kiểm soát bi cái',
      icon: 'circle',
      drills: [
        Drill(
          code: 'STOP_BALL',
          name: 'Stop Ball',
          nameVi: 'Dừng bi',
          category: 'cueball',
          difficulty: 'medium',
          description: 'Dừng bi cái tại vị trí chỉ định sau cú đánh',
          setup: 'Đánh draw để dừng',
          steps: [
            'Điểm đánh dưới tâm bi cái',
            'Đánh mạnh vừa phải',
            'Giữ cổ tay cố định',
            'Follow through đầy đủ',
          ],
          goal: 'Dừng trong vòng 10cm 8 lần trong 10 lần thử',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, distance: '20cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, distance: '15cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, distance: '10cm'),
            DrillLevel(level: 4, attempts: 10, passCount: 8, distance: '5cm'),
            DrillLevel(level: 5, attempts: 10, passCount: 9, distance: '2cm'),
          ],
          knowledgeIds: ['draw', 'tip_placement', 'acceleration'],
        ),
        Drill(
          code: 'FOLLOW_SHOT',
          name: 'Follow Shot',
          nameVi: 'Follow',
          category: 'cueball',
          difficulty: 'medium',
          description: 'Bi cái đi tới sau khi chạm bi mục tiêu',
          setup: 'Sử dụng xoáy trên (top spin)',
          steps: [
            'Điểm đánh trên tâm bi cái',
            'Đánh mạnh hơn bình thường 20%',
            'Bi cái đi cùng hướng bi mục tiêu',
          ],
          goal: 'Follow đến vị trí trong 10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, distance: '30cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, distance: '50cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, distance: '80cm'),
            DrillLevel(level: 4, attempts: 10, passCount: 8, distance: '1m'),
            DrillLevel(level: 5, attempts: 10, passCount: 9, distance: 'Full table'),
          ],
          knowledgeIds: ['follow', 'top_spin', 'tip_placement'],
        ),
        Drill(
          code: 'DRAW_SHOT',
          name: 'Draw Shot',
          nameVi: 'Draw',
          category: 'cueball',
          difficulty: 'medium',
          description: 'Bi cái quay ngược lại sau khi chạm bi mục tiêu',
          setup: 'Sử dụng xoáy dưới (back spin)',
          steps: [
            'Điểm đánh dưới tâm bi cái',
            'Đánh mạnh vừa phải',
            'Bi cái quay về sau khi chạm',
          ],
          goal: 'Draw về vị trí trong 10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, distance: '20cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, distance: '40cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, distance: '60cm'),
            DrillLevel(level: 4, attempts: 10, passCount: 8, distance: '80cm'),
            DrillLevel(level: 5, attempts: 10, passCount: 9, distance: '1m+'),
          ],
          knowledgeIds: ['draw', 'back_spin', 'tip_placement'],
        ),
        Drill(
          code: 'STUN_SHOT',
          name: 'Stun Shot',
          nameVi: 'Stun',
          category: 'cueball',
          difficulty: 'medium',
          description: 'Bi cái đi thẳng sau khi chạm, không xoáy',
          setup: 'Đánh vào tâm bi cái, không xoáy',
          steps: [
            'Đánh vào tâm bi cái',
            'Không có xoáy trên/dưới',
            'Bi cái đi thẳng về hướng ngắm',
          ],
          goal: 'Stun chính xác 8 lần trong 10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, accuracy: '10cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, accuracy: '7cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, accuracy: '5cm'),
            DrillLevel(level: 4, attempts: 10, passCount: 8, accuracy: '3cm'),
            DrillLevel(level: 5, attempts: 10, passCount: 9, accuracy: '1cm'),
          ],
          knowledgeIds: ['stun', 'tip_placement', 'stroke'],
        ),
      ],
    ),
    DrillCategory(
      id: 'position',
      name: 'Position',
      nameVi: 'Vị trí',
      icon: 'gps_fixed',
      drills: [
        Drill(
          code: 'POSITION_BASIC',
          name: 'Basic Position',
          nameVi: 'Vị trí cơ bản',
          category: 'position',
          difficulty: 'medium',
          description: 'Điều bi cái đến vị trí chỉ định',
          setup: 'Đặt bi mục tiêu, đánh đến vùng chỉ định',
          steps: [
            'Quan sát khoảng cách',
            'Tính toán lực và xoáy',
            'Thực hiện cú đánh',
          ],
          goal: 'Bi cái dừng trong vùng chỉ định 8/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, zone: '30cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, zone: '20cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, zone: '15cm'),
            DrillLevel(level: 4, attempts: 10, passCount: 8, zone: '10cm'),
            DrillLevel(level: 5, attempts: 10, passCount: 9, zone: '5cm'),
          ],
          knowledgeIds: ['position_play', 'speed_control', 'spin_control'],
        ),
        Drill(
          code: 'POSITION_3BALL',
          name: '3-Ball Position',
          nameVi: 'Position 3 bi',
          category: 'position',
          difficulty: 'hard',
          description: 'Đánh 3 bi theo thứ tự, kết thúc ở vị trí chỉ định',
          setup: 'Đặt 3 bi, đánh lần lượt',
          steps: [
            'Quan sát toàn bộ bàn',
            'Lên kế hoạch đường đi',
            'Position cho từng cú',
          ],
          goal: 'Hoàn thành pattern 3 bi 5/5 lần',
          levels: [
            DrillLevel(level: 1, attempts: 5, passCount: 3, balls: 3),
            DrillLevel(level: 2, attempts: 5, passCount: 4, balls: 3),
            DrillLevel(level: 3, attempts: 5, passCount: 4, balls: 3),
            DrillLevel(level: 4, attempts: 5, passCount: 5, balls: 3),
            DrillLevel(level: 5, attempts: 5, passCount: 5, balls: 3),
          ],
          knowledgeIds: ['pattern', 'position_play', 'speed_control'],
        ),
      ],
    ),
    DrillCategory(
      id: 'safety',
      name: 'Safety',
      nameVi: 'An toàn',
      icon: 'shield',
      drills: [
        Drill(
          code: 'SAFETY_BASIC',
          name: 'Basic Safety',
          nameVi: 'An toàn cơ bản',
          category: 'safety',
          difficulty: 'easy',
          description: 'Đánh an toàn không để đối thủ dễ đánh',
          setup: 'Đặt bi đối thủ, đánh safety',
          steps: [
            'Đánh bi cái chạm băng',
            'Để bi đối thủ ở vị trí khó',
            'Không tạo cơ hội cho đối thủ',
          ],
          goal: 'Tạo thế an toàn 8/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6),
            DrillLevel(level: 2, attempts: 10, passCount: 7),
            DrillLevel(level: 3, attempts: 10, passCount: 8),
            DrillLevel(level: 4, attempts: 10, passCount: 8),
            DrillLevel(level: 5, attempts: 10, passCount: 9),
          ],
          knowledgeIds: ['safety', 'angles', 'position_play'],
        ),
        Drill(
          code: 'SAFETY_FORCE',
          name: 'Force Safety',
          nameVi: 'Ép lực an toàn',
          category: 'safety',
          difficulty: 'hard',
          description: 'Buộc đối thủ đánh cú khó',
          setup: 'Để bi đối thủ sát băng',
          steps: [
            'Tính toán góc đánh',
            'Điều khiển lực chính xác',
            'Tạo khoảng cách bất lợi',
          ],
          goal: 'Ép đối thủ vào thế khó 6/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 4),
            DrillLevel(level: 2, attempts: 10, passCount: 5),
            DrillLevel(level: 3, attempts: 10, passCount: 6),
            DrillLevel(level: 4, attempts: 10, passCount: 7),
            DrillLevel(level: 5, attempts: 10, passCount: 8),
          ],
          knowledgeIds: ['safety', 'angles', 'english'],
        ),
      ],
    ),
    DrillCategory(
      id: 'special',
      name: 'Special',
      nameVi: 'Kỹ năng đặc biệt',
      icon: 'star',
      drills: [
        Drill(
          code: 'BANK_SHOT',
          name: 'Bank Shot',
          nameVi: 'Bank',
          category: 'special',
          difficulty: 'hard',
          description: 'Đánh bi chạm băng trước khi vào lỗ',
          setup: 'Đặt bi cách băng, nhắm vào lỗ đối diện',
          steps: [
            'Tính góc phản xạ',
            'Đánh chạm băng vuông góc',
            'Kiểm soát lực',
          ],
          goal: 'Bank thành công 6/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 4),
            DrillLevel(level: 2, attempts: 10, passCount: 5),
            DrillLevel(level: 3, attempts: 10, passCount: 6),
            DrillLevel(level: 4, attempts: 10, passCount: 7),
            DrillLevel(level: 5, attempts: 10, passCount: 8),
          ],
          knowledgeIds: ['bank', 'angles', 'speed_control'],
        ),
        Drill(
          code: 'KICK_SHOT',
          name: 'Kick Shot',
          nameVi: 'Kick',
          category: 'special',
          difficulty: 'expert',
          description: 'Đánh từ băng vào bi mục tiêu',
          setup: 'Đá từ băng đến bi',
          steps: [
            'Tính toán góc đá',
            'Điểm đánh chính xác',
            'Kiểm soát lực',
          ],
          goal: 'Kick thành công 4/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 2),
            DrillLevel(level: 2, attempts: 10, passCount: 3),
            DrillLevel(level: 3, attempts: 10, passCount: 4),
            DrillLevel(level: 4, attempts: 10, passCount: 5),
            DrillLevel(level: 5, attempts: 10, passCount: 6),
          ],
          knowledgeIds: ['kick', 'angles', 'math'],
        ),
        Drill(
          code: 'JUMP_SHOT',
          name: 'Jump Shot',
          nameVi: 'Jump',
          category: 'special',
          difficulty: 'expert',
          description: 'Bi cái nhảy qua chướng ngại vật',
          setup: 'Đặt bi cách bi khác',
          steps: [
            'Nâng đầu cơ cao',
            'Đánh mạnh từ dưới lên',
            'Hạ cánh chính xác',
          ],
          goal: 'Jump thành công 3/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 2),
            DrillLevel(level: 2, attempts: 10, passCount: 2),
            DrillLevel(level: 3, attempts: 10, passCount: 3),
            DrillLevel(level: 4, attempts: 10, passCount: 4),
            DrillLevel(level: 5, attempts: 10, passCount: 5),
          ],
          knowledgeIds: ['jump', 'bridging', 'power'],
        ),
        Drill(
          code: 'MASSE',
          name: 'Masse',
          nameVi: 'Masse',
          category: 'special',
          difficulty: 'expert',
          description: 'Đánh xoáy ngược với độ cong lớn',
          setup: 'Nâng đầu cơ, đánh mạnh',
          steps: [
            'Xác định điểm đánh',
            'Nâng đầu cơ cao',
            'Đánh mạnh theo hướng',
          ],
          goal: 'Masse thành công 2/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 1),
            DrillLevel(level: 2, attempts: 10, passCount: 1),
            DrillLevel(level: 3, attempts: 10, passCount: 2),
            DrillLevel(level: 4, attempts: 10, passCount: 2),
            DrillLevel(level: 5, attempts: 10, passCount: 3),
          ],
          knowledgeIds: ['masse', 'english', 'power'],
        ),
      ],
    ),
    DrillCategory(
      id: 'break',
      name: 'Break',
      nameVi: 'Khai cuộc',
      icon: 'flash_on',
      drills: [
        Drill(
          code: 'BREAK_POWER',
          name: 'Power Break',
          nameVi: 'Khai cuộc lực mạnh',
          category: 'break',
          difficulty: 'medium',
          description: 'Phá bi với lực mạnh để phết bóng',
          setup: 'Đặt cơ ở góc thấp',
          steps: [
            'Điểm đánh 1/4 dưới bi',
            'Đánh mạnh và nhanh',
            'Follow through đầy đủ',
          ],
          goal: 'Phết được 4+ bi 6/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 4),
            DrillLevel(level: 2, attempts: 10, passCount: 5),
            DrillLevel(level: 3, attempts: 10, passCount: 6),
            DrillLevel(level: 4, attempts: 10, passCount: 7),
            DrillLevel(level: 5, attempts: 10, passCount: 8),
          ],
          knowledgeIds: ['break', 'tip_placement', 'power'],
        ),
        Drill(
          code: 'BREAK_CONTROL',
          name: 'Control Break',
          nameVi: 'Khai cuộc kiểm soát',
          category: 'break',
          difficulty: 'hard',
          description: 'Phá bi với kiểm soát để tạo cơ hội',
          setup: 'Nhắm vào vị trí tối ưu',
          steps: [
            'Xác định điểm ngắm',
            'Điều khiển lực vừa phải',
            'Follow through kiểm soát',
          ],
          goal: 'Tạo cơ hội đánh 5/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 3),
            DrillLevel(level: 2, attempts: 10, passCount: 4),
            DrillLevel(level: 3, attempts: 10, passCount: 5),
            DrillLevel(level: 4, attempts: 10, passCount: 6),
            DrillLevel(level: 5, attempts: 10, passCount: 7),
          ],
          knowledgeIds: ['break', 'position', 'control'],
        ),
      ],
    ),
  ];

  static List<Drill> getAllDrills() {
    final List<Drill> all = [];
    for (final category in categories) {
      all.addAll(category.drills);
    }
    return all;
  }

  static Drill? getDrill(String code) {
    for (final category in categories) {
      for (final drill in category.drills) {
        if (drill.code == code) return drill;
      }
    }
    return null;
  }

  static List<Drill> getDrillsByCategory(String categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) {
        return category.drills;
      }
    }
    return [];
  }

  static List<Drill> getDrillsByDifficulty(String difficulty) {
    return getAllDrills().where((d) => d.difficulty == difficulty).toList();
  }

  static List<Drill> searchDrills(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllDrills().where((d) {
      return d.name.toLowerCase().contains(lowerQuery) ||
          d.nameVi.toLowerCase().contains(lowerQuery) ||
          d.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static List<Drill> getRecommendedDrills() {
    // Placeholder - AI sẽ generate sau
    return [
      getDrill('DRAW_SHOT')!,
      getDrill('FOLLOW_SHOT')!,
      getDrill('STOP_BALL')!,
      getDrill('STRAIGHT_POT')!,
      getDrill('POSITION_BASIC')!,
    ];
  }
}

class DrillCategory {
  final String id;
  final String name;
  final String nameVi;
  final String icon;
  final List<Drill> drills;

  const DrillCategory({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.icon,
    required this.drills,
  });
}

class Drill {
  final String code;
  final String name;
  final String nameVi;
  final String category;
  final String difficulty;
  final String description;
  final String setup;
  final List<String> steps;
  final String goal;
  final List<DrillLevel> levels;
  final List<String> knowledgeIds;

  const Drill({
    required this.code,
    required this.name,
    required this.nameVi,
    required this.category,
    required this.difficulty,
    required this.description,
    required this.setup,
    required this.steps,
    required this.goal,
    required this.levels,
    required this.knowledgeIds,
  });

  int get currentLevel {
    // Placeholder - sẽ lấy từ user progress
    return 1;
  }

  bool isLevelUnlocked(int level) {
    if (level == 1) return true;
    // Level unlocked if previous level passed
    // Placeholder logic
    return true;
  }

  DrillLevel? getLevel(int level) {
    return levels.firstWhere(
      (l) => l.level == level,
      orElse: () => levels.first,
    );
  }
}

class DrillLevel {
  final int level;
  final int attempts;
  final int passCount;
  // Optional difficulty parameters
  final String? distance;
  final String? angle;
  final String? accuracy;
  final String? zone;
  final int? balls;

  const DrillLevel({
    required this.level,
    required this.attempts,
    required this.passCount,
    this.distance,
    this.angle,
    this.accuracy,
    this.zone,
    this.balls,
  });

  String get criteriaText {
    if (distance != null) return '$attempts attempts → $passCount success ($distance)';
    if (angle != null) return '$attempts attempts → $passCount success ($angle)';
    if (accuracy != null) return '$attempts attempts → $passCount success ($accuracy)';
    if (zone != null) return '$attempts attempts → $passCount success (zone: $zone)';
    return '$attempts attempts → $passCount success';
  }
}
