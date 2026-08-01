class AppConstants {
  // App Info
  static const String appName = 'PoolOS';
  static const String appVersion = '2.0.0';
  static const String appTagline = 'AI Pool Training Platform';

  // Player Levels
  static const Map<String, String> playerLevels = {
    'beginner': 'Chưa từng chơi',
    'K': 'K - Mới chơi',
    'I': 'I - Cơ bản',
    'H': 'H - Club Player',
    'G': 'G - Giỏi',
    'F': 'F - Chuyên nghiệp',
  };

  static const List<String> levelOrder = [
    'beginner',
    'K',
    'I',
    'H',
    'G',
    'F',
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
