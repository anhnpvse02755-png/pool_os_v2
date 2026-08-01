class AppConstants {
  // App Info
  static const String appName = 'PoolOS';
  static const String appVersion = '2.0.0';
  static const String appTagline = 'AI Pool Training Platform';

  // ============================================
  // HỆ THỐNG XẾP HẠNG - THEO CHUẨN HÀ NỘI
  // ============================================
  // Tham khảo từ cơ thủ chuyên nghiệp Kiên Magic
  // F là bước đầu tiên của người chơi phong trào
  // Trên F: E, D, C, B, A, Chuyên nghiệp
  // K, I, H, G là các cấp độ nghiệp dư để dễ phân biệt

  static const Map<String, PlayerLevel> playerLevels = {
    'beginner': PlayerLevel(
      code: 'beginner',
      name: 'Chưa từng chơi',
      category: 'newbie',
      description: 'Chưa có kinh nghiệm chơi bi-a',
      isDefaultSelectable: true,
    ),
    'K': PlayerLevel(
      code: 'K',
      name: 'K - Người mới tập',
      category: 'amateur',
      description: 'Mới bắt đầu, đang học các cú đánh cơ bản',
      isDefaultSelectable: true,
    ),
    'I': PlayerLevel(
      code: 'I',
      name: 'I - Người chơi cơ bản',
      category: 'amateur',
      description: 'Biết đánh cơ bản, có thể chơi được một số cú đơn giản',
      isDefaultSelectable: true,
    ),
    'H': PlayerLevel(
      code: 'H',
      name: 'H - Người chơi phong trào',
      category: 'amateur',
      description: 'Chơi đều đặn tại club, có kỹ thuật khá',
      isDefaultSelectable: true,
    ),
    'G': PlayerLevel(
      code: 'G',
      name: 'G - Người chơi phong trào giỏi',
      category: 'amateur',
      description: 'Người chơi phong trào có trình độ cao, có thể thắng giải nhỏ',
      isDefaultSelectable: true,
    ),
    'F': PlayerLevel(
      code: 'F',
      name: 'F - Bước vào chuyên nghiệp',
      category: 'competitive',
      description: 'Bước đầu tiên của người chơi chuyên nghiệp, đủ sức thi đấu giải',
      isDefaultSelectable: false,
    ),
    'E': PlayerLevel(
      code: 'E',
      name: 'E - Người chơi E',
      category: 'competitive',
      description: 'Người chơi chuyên nghiệp cấp thấp, thi đấu thường xuyên',
      isDefaultSelectable: false,
    ),
    'D': PlayerLevel(
      code: 'D',
      name: 'D - Người chơi D',
      category: 'competitive',
      description: 'Người chơi chuyên nghiệp trình độ khá',
      isDefaultSelectable: false,
    ),
    'C': PlayerLevel(
      code: 'C',
      name: 'C - Người chơi C',
      category: 'competitive',
      description: 'Người chơi chuyên nghiệp có kỹ năng tốt',
      isDefaultSelectable: false,
    ),
    'B': PlayerLevel(
      code: 'B',
      name: 'B - Người chơi B',
      category: 'competitive',
      description: 'Người chơi chuyên nghiệp trình độ cao',
      isDefaultSelectable: false,
    ),
    'A': PlayerLevel(
      code: 'A',
      name: 'A - Người chơi A',
      category: 'competitive',
      description: 'Cao thủ, có thể thi đấu ở cấp độ cao nhất',
      isDefaultSelectable: false,
    ),
    'pro': PlayerLevel(
      code: 'pro',
      name: 'Chuyên nghiệp',
      category: 'professional',
      description: 'Cơ thủ chuyên nghiệp, thi đấu quốc tế',
      isDefaultSelectable: false,
    ),
  };

  // Thứ tự xếp hạng (từ thấp đến cao)
  static const List<String> levelOrder = [
    'beginner',
    'K',
    'I',
    'H',
    'G',
    'F',
    'E',
    'D',
    'C',
    'B',
    'A',
    'pro',
  ];

  // Các cấp độ người dùng có thể tự chọn khi onboarding
  static const List<String> selectableLevels = [
    'beginner',
    'K',
    'I',
    'H',
    'G',
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
    'blocking': 'Cần cải cải thiện',
    'improvement': 'Nên cải thiện',
    'knowledge': 'Kiến thức',
    'positive': 'Điểm mạnh',
  };
}

// Model cho cấp độ người chơi
class PlayerLevel {
  final String code;
  final String name;
  final String category; // 'newbie', 'amateur', 'competitive', 'professional'
  final String description;
  final bool isDefaultSelectable; // Người dùng có thể tự chọn khi onboarding

  const PlayerLevel({
    required this.code,
    required this.name,
    required this.category,
    required this.description,
    required this.isDefaultSelectable,
  });

  String get categoryName {
    switch (category) {
      case 'newbie':
        return 'Người mới';
      case 'amateur':
        return 'Nghiệp dư';
      case 'competitive':
        return 'Phong trào → Chuyên nghiệp';
      case 'professional':
        return 'Chuyên nghiệp';
      default:
        return category;
    }
  }
}
