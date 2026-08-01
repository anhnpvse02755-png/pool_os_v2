class AppConstants {
  // App Info
  static const String appName = 'PoolOS';
  static const String appVersion = '2.0.0';
  static const String appTagline = 'AI Pool Training Platform';

  // ============================================
  // HỆ THỐNG XẾP HẠNG - THEO CHUẨN HÀ NỘI
  // ============================================
  // Tham khảo từ cộng đồng Pool Hà Nội
  // Pool OS chỉ thu thập năng lực thực tế và tính Pool Rating

  static const Map<String, PlayerLevel> playerLevels = {
    'K': PlayerLevel(
      code: 'K',
      name: 'K',
      category: 'amateur',
      description: 'Người mới làm quen với Pool',
    ),
    'I': PlayerLevel(
      code: 'I',
      name: 'I',
      category: 'amateur',
      description: 'Đã biết luật chơi, kỹ thuật cơ bản',
    ),
    'H': PlayerLevel(
      code: 'H',
      name: 'H',
      category: 'amateur',
      description: 'Người chơi phong trào phổ biến, bắt đầu có khả năng điều bi',
    ),
    'G': PlayerLevel(
      code: 'G',
      name: 'G',
      category: 'amateur',
      description: 'Người chơi phong trào khá, có thể thi đấu ổn định với đa số CLB',
    ),
    'F': PlayerLevel(
      code: 'F',
      name: 'F',
      category: 'competitive',
      description: 'Bước đầu tham gia sân chơi thi đấu, trình độ cao trong nhóm phong trào',
    ),
    'E': PlayerLevel(
      code: 'E',
      name: 'E',
      category: 'competitive',
      description: 'Người chơi bán chuyên',
    ),
    'D': PlayerLevel(
      code: 'D',
      name: 'D',
      category: 'competitive',
      description: 'Người chơi mạnh, thường xuyên thi đấu',
    ),
    'C': PlayerLevel(
      code: 'C',
      name: 'C',
      category: 'competitive',
      description: 'Vận động viên trình độ cao',
    ),
    'B': PlayerLevel(
      code: 'B',
      name: 'B',
      category: 'competitive',
      description: 'Vận động viên rất mạnh',
    ),
    'A': PlayerLevel(
      code: 'A',
      name: 'A',
      category: 'competitive',
      description: 'Top đầu trong nước',
    ),
    'pro': PlayerLevel(
      code: 'pro',
      name: 'Chuyên nghiệp',
      category: 'professional',
      description: 'Thi đấu chuyên nghiệp',
    ),
  };

  // Thứ tự xếp hạng (từ thấp đến cao)
  static const List<String> levelOrder = [
    'K', 'I', 'H', 'G', 'F', 'E', 'D', 'C', 'B', 'A', 'pro',
  ];

  // ============================================
  // POOL RATING SYSTEM
  // ============================================
  // Pool Rating: 0-1000 scale
  // Calculated from 5 skill groups

  static const List<RatingRange> ratingRanges = [
    RatingRange(min: 0, max: 120, level: 'K'),
    RatingRange(min: 121, max: 220, level: 'I'),
    RatingRange(min: 221, max: 380, level: 'H'),
    RatingRange(min: 381, max: 560, level: 'G'),
    RatingRange(min: 561, max: 700, level: 'F'),
    RatingRange(min: 701, max: 800, level: 'E'),
    RatingRange(min: 801, max: 880, level: 'D'),
    RatingRange(min: 881, max: 940, level: 'C'),
    RatingRange(min: 941, max: 980, level: 'B'),
    RatingRange(min: 981, max: 995, level: 'A'),
    RatingRange(min: 996, max: 1000, level: 'pro'),
  ];

  // Skill weights for Pool Rating calculation
  static const double weightAverageRun = 0.35;     // 35%
  static const double weightRunoutFreq = 0.25;     // 25%
  static const double weightPositionPlay = 0.20;    // 20%
  static const double weightBreakQuality = 0.10;   // 10%
  static const double weightPeakRun = 0.10;        // 10%

  // ============================================
  // ASSESSMENT QUESTIONS
  // ============================================
  // 8 questions for initial skill assessment
  // Used as confidence factor, NOT for grading directly

  static const List<AssessmentQuestion> assessmentQuestions = [
    AssessmentQuestion(
      id: 1,
      title: 'Bạn đã chơi Pool được bao lâu?',
      subtitle: 'Không dùng để chấm điểm. Chỉ dùng làm hệ số tin cậy.',
      type: QuestionType.singleChoice,
      options: [
        AssessmentOption(value: 0, label: 'Chưa từng chơi'),
        AssessmentOption(value: 1, label: 'Dưới 3 tháng'),
        AssessmentOption(value: 2, label: '3 – 6 tháng'),
        AssessmentOption(value: 3, label: '6 tháng – 1 năm'),
        AssessmentOption(value: 4, label: '1 – 2 năm'),
        AssessmentOption(value: 5, label: '2 – 5 năm'),
        AssessmentOption(value: 6, label: 'Trên 5 năm'),
      ],
    ),
    AssessmentQuestion(
      id: 2,
      title: 'Trung bình bạn chơi Pool bao nhiêu?',
      subtitle: 'Không quyết định hạng. Chỉ dùng để AI đánh giá tốc độ tiến bộ.',
      type: QuestionType.singleChoice,
      options: [
        AssessmentOption(value: 1, label: 'Dưới 2 giờ / tuần'),
        AssessmentOption(value: 2, label: '2 – 5 giờ / tuần'),
        AssessmentOption(value: 3, label: '5 – 10 giờ / tuần'),
        AssessmentOption(value: 4, label: '10 – 20 giờ / tuần'),
        AssessmentOption(value: 5, label: 'Trên 20 giờ / tuần'),
      ],
    ),
    AssessmentQuestion(
      id: 3,
      title: 'Trong một lượt cơ, bạn đã từng đi được nhiều nhất bao nhiêu bi?',
      subtitle: 'Đây là Peak Performance (thành tích tốt nhất từng đạt được).',
      type: QuestionType.singleChoice,
      options: [
        AssessmentOption(value: 1, label: '1'),
        AssessmentOption(value: 2, label: '2'),
        AssessmentOption(value: 3, label: '3'),
        AssessmentOption(value: 4, label: '4'),
        AssessmentOption(value: 5, label: '5'),
        AssessmentOption(value: 6, label: '6'),
        AssessmentOption(value: 7, label: '7'),
        AssessmentOption(value: 8, label: '8'),
        AssessmentOption(value: 9, label: 'Runout'),
      ],
      skillGroup: 'peak_run',
    ),
    AssessmentQuestion(
      id: 4,
      title: 'Trong những thế bi bình thường, bạn thường đi được bao nhiêu bi?',
      subtitle: 'Hãy nghĩ đến số bi bạn thường xuyên làm được, không phải lượt tốt nhất.',
      type: QuestionType.singleChoice,
      isImportant: true,
      options: [
        AssessmentOption(value: 1, label: '1'),
        AssessmentOption(value: 2, label: '2'),
        AssessmentOption(value: 3, label: '3'),
        AssessmentOption(value: 4, label: '4'),
        AssessmentOption(value: 5, label: '5'),
        AssessmentOption(value: 6, label: '6+'),
        AssessmentOption(value: 7, label: 'Thường xuyên Runout'),
      ],
      skillGroup: 'average_run',
    ),
    AssessmentQuestion(
      id: 5,
      title: 'Bạn đã từng Runout (đi chấm) chưa?',
      subtitle: 'Tần suất bạn có thể hoàn thành một rack.',
      type: QuestionType.singleChoice,
      options: [
        AssessmentOption(value: 0, label: 'Chưa bao giờ'),
        AssessmentOption(value: 1, label: 'Đã từng 1–2 lần'),
        AssessmentOption(value: 2, label: 'Thỉnh thoảng'),
        AssessmentOption(value: 3, label: 'Khá thường xuyên'),
        AssessmentOption(value: 4, label: 'Rất thường xuyên'),
      ],
      skillGroup: 'runout_frequency',
    ),
    AssessmentQuestion(
      id: 6,
      title: 'Trung bình bao nhiêu rack bạn có thể đi được một chấm?',
      subtitle: 'Khả năng hoàn thành một rack trong điều kiện bình thường.',
      type: QuestionType.singleChoice,
      options: [
        AssessmentOption(value: 0, label: 'Chưa từng'),
        AssessmentOption(value: 6, label: 'Hơn 100 rack'),
        AssessmentOption(value: 5, label: 'Khoảng 50 rack'),
        AssessmentOption(value: 4, label: 'Khoảng 20 rack'),
        AssessmentOption(value: 3, label: 'Khoảng 10 rack'),
        AssessmentOption(value: 2, label: 'Khoảng 5 rack'),
        AssessmentOption(value: 1, label: 'Khoảng 2–3 rack'),
        AssessmentOption(value: 7, label: 'Gần như rack nào cũng có thể'),
      ],
      skillGroup: 'runout_frequency',
    ),
    AssessmentQuestion(
      id: 7,
      title: 'Sau cú phá bi, bạn thường còn thế bi như thế nào?',
      subtitle: 'Chất lượng cú phá bi ảnh hưởng đến cơ hội ghi điểm.',
      type: QuestionType.singleChoice,
      options: [
        AssessmentOption(value: 1, label: 'Thường không có bi đánh tiếp'),
        AssessmentOption(value: 2, label: 'Thường chỉ có 1 bi'),
        AssessmentOption(value: 3, label: 'Có thể đi tiếp 2–3 bi'),
        AssessmentOption(value: 4, label: 'Thường có layout thuận lợi'),
        AssessmentOption(value: 5, label: 'Thường có cơ hội đi chấm'),
      ],
      skillGroup: 'break_quality',
    ),
    AssessmentQuestion(
      id: 8,
      title: 'Sau khi ăn một bi, bạn thường điều bi cái ở mức nào?',
      subtitle: 'Khả năng kiểm soát vị trí bi cái.',
      type: QuestionType.singleChoice,
      isImportant: true,
      options: [
        AssessmentOption(value: 1, label: 'Thường xuyên bị khó'),
        AssessmentOption(value: 2, label: 'Có lúc dễ, có lúc khó'),
        AssessmentOption(value: 3, label: 'Phần lớn còn bi đánh tiếp'),
        AssessmentOption(value: 4, label: 'Thường chủ động điều được bi cái'),
        AssessmentOption(value: 5, label: 'Có thể điều bi chính xác theo ý muốn'),
      ],
      skillGroup: 'position_play',
    ),
  ];

  // Session Types
  static const Map<String, String> sessionTypes = {
    'practice': 'Luyện tập',
    'tournament': 'Giải đấu',
    'casual': 'Chơi vui',
  };

  // Match Results
  static const Map<String, String> matchResults = {
    'win': 'Thắng',
    'lose': 'Thua',
    'draw': 'Hòa',
  };

  // Shot Types
  static const Map<String, String> shotTypes = {
    'pot': 'Đánh bóng',
    'safety': 'An toàn',
    'break': 'Khai cuộc',
    'jump': 'Nhảy',
    'kick': 'Đá',
    'bank': 'Bank',
    'combo': 'Combo',
    'push_out': 'Push Out',
    'masse': 'Masse',
  };

  // Shot Events (Mistakes)
  static const Map<String, String> shotEvents = {
    'scratch': 'Gậy chạm biên',
    'foul': 'Phạm lỗi',
    'double_kiss': 'Dính 2 bi',
    'jumped_cue': 'Bi nhảy',
    'easy_miss': 'Đánh trượt dễ',
    'wrong_angle': 'Sai góc',
    'wrong_speed': 'Sai lực',
    'wrong_spin': 'Sai xoáy',
    'bridge_unstable': 'Tay kê không vững',
    'aim_error': 'Ngắm sai',
    'deceleration': 'Giảm tốc độ',
    'kick': 'Bi đá',
    'bad_roll': 'Bi lăn không đúng',
  };

  // Spin Types
  static const Map<String, String> spinTypes = {
    'top': 'Xoáy trên',
    'back': 'Xoáy dưới',
    'left': 'Trái',
    'right': 'Phải',
    'follow': 'Follow',
    'draw': 'Draw',
  };

  // Fatigue Levels
  static const Map<String, String> fatigueLevels = {
    'none': 'Không mệt',
    'light': 'Hơi mệt',
    'moderate': 'Mệt',
    'heavy': 'Rất mệt',
  };

  // Mental States
  static const Map<String, String> mentalStates = {
    'very_confident': 'Rất tự tin',
    'confident': 'Tự tin',
    'normal': 'Bình thường',
    'uncertain': 'Không chắc',
    'pressured': 'Bị áp lực',
  };

  // Coach Recommendation Priorities
  static const Map<String, String> priorities = {
    'critical': 'Nghiêm trọng',
    'blocking': 'Cần cải thiện',
    'improvement': 'Nên cải thiện',
    'knowledge': 'Kiến thức',
    'positive': 'Điểm mạnh',
  };
}

// Model cho cấp độ người chơi
class PlayerLevel {
  final String code;
  final String name;
  final String category;
  final String description;

  const PlayerLevel({
    required this.code,
    required this.name,
    required this.category,
    required this.description,
  });
}

// Rating range model
class RatingRange {
  final int min;
  final int max;
  final String level;

  const RatingRange({
    required this.min,
    required this.max,
    required this.level,
  });
}

// Assessment question model
class AssessmentQuestion {
  final int id;
  final String title;
  final String subtitle;
  final QuestionType type;
  final List<AssessmentOption> options;
  final bool isImportant;
  final String? skillGroup;

  const AssessmentQuestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.options,
    this.isImportant = false,
    this.skillGroup,
  });
}

enum QuestionType { singleChoice, multipleChoice }

// Assessment option model
class AssessmentOption {
  final int value;
  final String label;

  const AssessmentOption({
    required this.value,
    required this.label,
  });
}
