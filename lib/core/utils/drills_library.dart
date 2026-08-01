import '../constants/app_constants.dart';

/// Drill Library for Training Center
/// Based on RFC-014 Training Drill Library
class DrillLibrary {
  // Categories of drills
  static const List<DrillCategory> categories = [
    DrillCategory(
      id: 'shots',
      name: 'Cú đánh cơ bản',
      icon: 'sports',
      drills: [
        Drill(
          code: 'STRAIGHT_POT',
          name: 'Đánh thẳng',
          nameVi: 'Đánh thẳng',
          category: 'shots',
          difficulty: 'beginner',
          description: 'Đánh bi vào lỗ theo đường thẳng',
          instructions: [
            'Đặt bi mục tiêu cách lỗ khoảng 30cm',
            'Ngắm thẳng từ bi đến lỗ',
            'Đánh thẳng, không xoáy',
            'Giữ tốc độ đều',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'THIN_CUT',
          name: 'Cắt mỏng',
          nameVi: 'Cắt mỏng',
          category: 'shots',
          difficulty: 'intermediate',
          description: 'Đánh bi với góc cắt mỏng (< 30°)',
          instructions: [
            'Đặt bi ở góc bàn',
            'Ngắm điểm ngắm chính xác',
            'Kiểm soát lực vừa phải',
            'Follow through thẳng',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'THICK_CUT',
          name: 'Cắt dày',
          nameVi: 'Cắt dày',
          category: 'shots',
          difficulty: 'beginner',
          description: 'Đánh bi với góc cắt dày (> 45°)',
          instructions: [
            'Đặt bi gần lỗ',
            'Ngắm góc rộng',
            'Điều khiển lực tốt',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'FOLLOW_SHOT',
          name: 'Follow',
          nameVi: 'Follow',
          category: 'shots',
          difficulty: 'intermediate',
          description: 'Đánh bi đi tới sau khi chạm bi mục tiêu',
          instructions: [
            'Sử dụng xoáy trên (top spin)',
            'Đánh mạnh hơn bình thường 20%',
            'Bi cái đi cùng hướng bi mục tiêu',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'DRAW_SHOT',
          name: 'Draw',
          nameVi: 'Draw',
          category: 'shots',
          difficulty: 'intermediate',
          description: 'Đánh bi quay ngược lại',
          instructions: [
            'Sử dụng xoáy dưới (back spin)',
            'Đánh từ dưới bi cái',
            'Bi cái quay về sau khi chạm',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'STUN_SHOT',
          name: 'Stun',
          nameVi: 'Stun',
          category: 'shots',
          difficulty: 'intermediate',
          description: 'Bi cái đi thẳng sau khi chạm, không xoáy',
          instructions: [
            'Đánh vào tâm bi cái',
            'Không có xoáy trên/dưới',
            'Bi cái đi thẳng về hướng ngắm',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'BANK_SHOT',
          name: 'Bank',
          nameVi: 'Bank',
          category: 'shots',
          difficulty: 'advanced',
          description: 'Đánh bi chạm băng trước khi vào lỗ',
          instructions: [
            'Tính góc phản xạ',
            'Đánh chạm băng vuông góc',
            'Kiểm soát lực để bi không dội ra',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'KICK_SHOT',
          name: 'Kick',
          nameVi: 'Kick',
          category: 'shots',
          difficulty: 'advanced',
          description: 'Đánh từ băng vào bi mục tiêu',
          instructions: [
            'Đá từ băng đến bi',
            'Tính toán góc đá',
            'Kiểm soát lực chính xác',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'JUMP_SHOT',
          name: 'Jump',
          nameVi: 'Jump',
          category: 'shots',
          difficulty: 'advanced',
          description: 'Nhảy bi cái qua chướng ngại vật',
          instructions: [
            'Đánh mạnh từ dưới lên',
            'Bi cái nhảy lên cao',
            'Hạ cánh chính xác',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'MASSE_SHOT',
          name: 'Masse',
          nameVi: 'Masse',
          category: 'shots',
          difficulty: 'expert',
          description: 'Đánh xoáy ngược với độ cong lớn',
          instructions: [
            'Nâng đầu cơ lên cao',
            'Đánh mạnh theo hướng mong muốn',
            'Tạo đường cong cho bi cái',
          ],
          targetReps: 5,
        ),
      ],
    ),
    DrillCategory(
      id: 'position',
      name: 'Kiểm soát vị trí',
      icon: 'gps_fixed',
      drills: [
        Drill(
          code: 'POSITION_STOP',
          name: 'Stop Ball',
          nameVi: 'Dừng bi',
          category: 'position',
          difficulty: 'beginner',
          description: 'Dừng bi cái tại vị trí chỉ định sau cú đánh',
          instructions: [
            'Đánh draw để dừng',
            'Tính toán lực và xoáy',
            'Practice nhiều lần',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'POSITION_FOLLOW',
          name: 'Position Follow',
          nameVi: 'Vị trí Follow',
          category: 'position',
          difficulty: 'intermediate',
          description: 'Điều bi cái đến vị trí mong muốn sau cú follow',
          instructions: [
            'Đánh follow với xoáy trên',
            'Tính toán vị trí dừng',
            'Practice với nhiều khoảng cách',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'POSITION_DRAW',
          name: 'Position Draw',
          nameVi: 'Vị trí Draw',
          category: 'position',
          difficulty: 'intermediate',
          description: 'Điều bi cái quay về vị trí mong muốn',
          instructions: [
            'Sử dụng draw shot',
            'Tính toán điểm dừng',
            'Kiểm soát lực chính xác',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'PATTERN_3BALL',
          name: 'Pattern 3 Balls',
          nameVi: 'Pattern 3 bi',
          category: 'position',
          difficulty: 'intermediate',
          description: 'Đánh 3 bi theo thứ tự và kết thúc ở vị trí chỉ định',
          instructions: [
            'Quan sát toàn bộ bàn',
            'Lên kế hoạch đường đi',
            'Thực hiện từng cú',
          ],
          targetReps: 5,
        ),
        Drill(
          code: 'PATTERN_5BALL',
          name: 'Pattern 5 Balls',
          nameVi: 'Pattern 5 bi',
          category: 'position',
          difficulty: 'advanced',
          description: 'Đánh 5 bi theo thứ tự với kiểm soát vị trí',
          instructions: [
            'Lên pattern hoàn chỉnh',
            'Tính toán mọi cú đánh',
            'Position chính xác cho cú tiếp theo',
          ],
          targetReps: 3,
        ),
      ],
    ),
    DrillCategory(
      id: 'safety',
      name: 'An toàn',
      icon: 'shield',
      drills: [
        Drill(
          code: 'SAFETY_BASIC',
          name: 'Safety cơ bản',
          nameVi: 'An toàn cơ bản',
          category: 'safety',
          difficulty: 'beginner',
          description: 'Đánh an toàn không để đối thủ dễ đánh',
          instructions: [
            'Đánh bi cái chạm băng',
            'Để bi đối thủ ở vị trí khó',
            'Không tạo cơ hội cho đối thủ',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'SAFETY_FORCE',
          name: 'Force Safety',
          nameVi: 'Ép lực an toàn',
          category: 'safety',
          difficulty: 'intermediate',
          description: 'Buộc đối thủ đánh cú khó',
          instructions: [
            'Để bi đối thủ sát băng',
            'Tạo khoảng cách xa đến bi mục tiêu',
            'Ép đối thủ vào thế bất lợi',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'SAFETY_PINCH',
          name: 'Pinch Safety',
          nameVi: 'Kẹp an toàn',
          category: 'safety',
          difficulty: 'advanced',
          description: 'Kẹp bi đối thủ vào băng và khoá bi mục tiêu',
          instructions: [
            'Đánh bi cái chạm 2 băng',
            'Kẹp bi đối thủ vào góc',
            'Tạo thế bất khả thi',
          ],
          targetReps: 5,
        ),
        Drill(
          code: 'SAFETY_JAWS',
          name: 'Jaws Safety',
          nameVi: 'Kẹp hàm',
          category: 'safety',
          difficulty: 'advanced',
          description: 'Tạo thế kẹp bi đối thủ giữa băng và bi mục tiêu',
          instructions: [
            'Tính toán vị trí kẹp',
            'Điều khiển lực chính xác',
            'Tạo khoảng cách bất lợi',
          ],
          targetReps: 5,
        ),
      ],
    ),
    DrillCategory(
      id: 'break',
      name: 'Khai cuộc',
      icon: 'flash_on',
      drills: [
        Drill(
          code: 'BREAK_POWER',
          name: 'Power Break',
          nameVi: 'Khai cuộc lực mạnh',
          category: 'break',
          difficulty: 'intermediate',
          description: 'Phá bi với lực mạnh để phết bóng',
          instructions: [
            'Đặt cơ ở góc thấp',
            'Đánh mạnh vào điểm 1/4 dưới bi',
            'Theo dõi sự phân tán của bóng',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'BREAK_CONTROL',
          name: 'Control Break',
          nameVi: 'Khai cuộc kiểm soát',
          category: 'break',
          difficulty: 'intermediate',
          description: 'Phá bi với kiểm soát để tạo cơ hội',
          instructions: [
            'Điều khiển lực vừa phải',
            'Nhắm vào vị trí tối ưu',
            'Tạo layout thuận lợi cho cú tiếp theo',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'BREAK_SPREAD',
          name: 'Spread Break',
          nameVi: 'Khai cuộc phết',
          category: 'break',
          difficulty: 'advanced',
          description: 'Phá bi để bóng phân tán đều khắp bàn',
          instructions: [
            'Tính toán góc và lực',
            'Điểm đánh chính xác',
            'Follow through đầy đủ',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'BREAK_9BALL',
          name: '9-Ball Break',
          nameVi: 'Khai cuộc 9-ball',
          category: 'break',
          difficulty: 'advanced',
          description: 'Khai cuộc 9-ball để đánh bi số thấp',
          instructions: [
            'Nhắm vào bóng 1',
            'Lực mạnh vừa phải',
            'Tạo cơ hội cho bi tiếp theo',
          ],
          targetReps: 10,
        ),
      ],
    ),
    DrillCategory(
      id: 'special',
      name: 'Kỹ năng đặc biệt',
      icon: 'star',
      drills: [
        Drill(
          code: 'COMBO_SHOT',
          name: 'Combo',
          nameVi: 'Combo',
          category: 'special',
          difficulty: 'intermediate',
          description: 'Đánh bi mục tiêu chạm bi khác vào lỗ',
          instructions: [
            'Ngắm điểm trên bi trung gian',
            'Tính toán góc phản xạ',
            'Kiểm soát lực để bi không dừng sớm',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'CAROM_SHOT',
          name: 'Carom',
          nameVi: 'Carom',
          category: 'special',
          difficulty: 'advanced',
          description: 'Bi cái chạm 2 bi khác mà không có bi nào vào lỗ',
          instructions: [
            'Ngắm điểm trên bi trung gian',
            'Tính toán góc chạm',
            'Không đẩy bi vào lỗ',
          ],
          targetReps: 10,
        ),
        Drill(
          code: 'RUNOUT_8BALL',
          name: '8-Ball Runout',
          nameVi: 'Chấm 8-ball',
          category: 'special',
          difficulty: 'advanced',
          description: 'Đi tất cả bi của mình vào lỗ liên tiếp',
          instructions: [
            'Quan sát toàn bộ bàn',
            'Lên kế hoạch thứ tự',
            'Kiểm soát position cho từng cú',
          ],
          targetReps: 3,
        ),
        Drill(
          code: 'RUNOUT_9BALL',
          name: '9-Ball Runout',
          nameVi: 'Chấm 9-ball',
          category: 'special',
          difficulty: 'advanced',
          description: 'Đánh bi số thấp nhất trên bàn',
          instructions: [
            'Luôn nhắm bi số thấp nhất',
            'Nhanh chóng kết thúc',
            'Position cho cú tiếp theo',
          ],
          targetReps: 5,
        ),
      ],
    ),
  ];

  /// Get drill by code
  static Drill? getDrill(String code) {
    for (final category in categories) {
      for (final drill in category.drills) {
        if (drill.code == code) return drill;
      }
    }
    return null;
  }

  /// Get drills by category
  static List<Drill> getDrillsByCategory(String categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) {
        return category.drills;
      }
    }
    return [];
  }

  /// Get drill difficulty color
  static String getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 'green';
      case 'intermediate':
        return 'orange';
      case 'advanced':
        return 'red';
      case 'expert':
        return 'purple';
      default:
        return 'grey';
    }
  }
}

/// Drill Category
class DrillCategory {
  final String id;
  final String name;
  final String icon;
  final List<Drill> drills;

  const DrillCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.drills,
  });
}

/// Drill Definition
class Drill {
  final String code;
  final String name;
  final String nameVi;
  final String category;
  final String difficulty;
  final String description;
  final List<String> instructions;
  final int targetReps;

  const Drill({
    required this.code,
    required this.name,
    required this.nameVi,
    required this.category,
    required this.difficulty,
    required this.description,
    required this.instructions,
    required this.targetReps,
  });
}
