// ============================================================================
// COACH VOICE SERVICE - Phase 7B.1
// Coach Voice Guidelines Implementation
//
// Coach speaks like a real coach, not AI.
// - Short (2-3 sentences max)
// - Natural (no "dựa trên", "hệ thống", "AI")
// - Positive (towards action)
// - Specific (situation, not abstract numbers)
// - Leads (doesn't ask when has data)
// ============================================================================

import '../providers/coach_provider.dart';
import 'coach_types.dart';

/// Coach Voice Service - Implements Coach Voice Guidelines
class CoachVoiceService {
  /// Get reason for recommending a drill (Coach Voice)
  String getReasonForDrill(String drillCode, Map<String, SimpleDrillProgress> progressMap) {
    final progress = progressMap[drillCode];
    if (progress == null) {
      return 'Đây là bài tập cơ bản nhất.';
    }

    // Coach Voice: Talk about situation, not numbers
    if (progress.averageAccuracy < 60) {
      return 'Có vẻ bài này vẫn còn khó nhỉ.';
    } else if (progress.averageAccuracy < 75) {
      return 'Mình thấy bài này đang tiến bộ đấy.';
    } else if (progress.averageAccuracy < 85) {
      return 'Bài này khá ổn rồi. Cần thêm chút nữa.';
    } else {
      return 'Bài này đã thành thạo! Sẵn sàng cho bài khó hơn.';
    }
  }

  /// Get expected outcomes for completing a drill
  List<String> getOutcomesForDrill(String drillCode) {
    switch (drillCode) {
      case 'straight_shot':
        return [
          'Nắm vững căn bản',
          'Chuẩn bị cho các bài nâng cao',
        ];
      case 'stop_ball':
        return [
          'Kiểm soát bóng cái tốt hơn',
          'Giảm overrun',
          'Chuẩn bị cho position play',
        ];
      case 'follow_shot':
        return [
          'Đánh bóng cái đi xa hơn',
          'Kiểm soát tốc độ',
        ];
      case 'draw_shot':
        return [
          'Kéo bóng cái về sau va chạm',
          'Mở rộng khả năng position',
        ];
      case 'speed_control':
        return [
          'Kiểm soát tốc độ đa dạng',
          'Precision trong mọi khoảng cách',
        ];
      case 'position_play':
        return [
          'Đặt bóng cái đúng vị trí',
          'Chuẩn bị cho shot tiếp theo',
        ];
      case 'bank_shot':
        return [
          'Đánh bóng bậc thành công',
          'Mở rộng options trong trận đấu',
        ];
      case 'safety_play':
        return [
          'Chơi an toàn hiệu quả',
          'Gây khó khăn cho đối thủ',
        ];
      case 'break_shot':
        return [
          'Break mạnh và kiểm soát',
          'Tạo cơ hội từ đầu',
        ];
      case 'long_shot':
        return [
          'Đánh xa chính xác',
          'Tự tin hơn với các cú đánh khó',
        ];
      default:
        return [
          'Cải thiện kỹ năng',
          'Thêm tự tin',
        ];
    }
  }

  /// Get greeting based on time of day
  String getGreeting(String? playerName) {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Sáng nay mình tập gì nhỉ?';
    } else if (hour < 17) {
      return 'Chiều rồi, tập thôi!';
    } else {
      return 'Tối nay một chút thôi cũng được.';
    }
  }

  /// Get encouragement message
  String getEncouragementMessage({
    required int previousScore,
    required int currentScore,
    required String drillName,
  }) {
    final diff = currentScore - previousScore;
    if (diff > 5) {
      return 'Tuyệt vời! +$diff% đấy!';
    } else if (diff > 0) {
      return 'Tốt lắm! +$diff%.';
    } else if (diff == 0) {
      return 'Giữ được $currentScore% rồi!';
    } else {
      return 'Không sao. Lần tới sẽ tốt hơn.';
    }
  }

  /// Get recommendation when user has no data
  String getNewUserMessage(String drillName) {
    return 'Bắt đầu với $drillName nhé.\nĐây là bài tập cơ bản nhất.';
  }

  /// Get recommendation when not enough data
  String getNotEnoughDataMessage(int sessionsCount) {
    return 'Hiện tại mình có $sessionsCount buổi.\n'
        'Cần thêm dữ liệu để đưa ra kế hoạch chi tiết.\n'
        'Tiếp tục tập đều đặn nhé!';
  }

  /// Get break recommendation
  String getBreakRecommendation() {
    return 'Nghe có vẻ mệt rồi.\nNghỉ 1 ngày không?';
  }

  /// Get consistency encouragement
  String getConsistencyMessage(int sessionsThisWeek) {
    if (sessionsThisWeek >= 4) {
      return 'Tuyệt vời! $sessionsThisWeek buổi rồi.\n'
          'Nhưng đừng tập quá sức nhé.';
    } else if (sessionsThisWeek >= 2) {
      return 'Tốt lắm! Đều đặn đấy.\n'
          'Tiếp tục duy trì nhé!';
    } else {
      return 'Cố gắng tập đều đặn nhé.\n'
          'Ít nhất 2-3 buổi mỗi tuần.';
    }
  }

  /// Get "why" explanation for a recommendation
  String getWhyExplanation({
    required String drillCode,
    required Map<String, SimpleDrillProgress> progressMap,
  }) {
    final progress = progressMap[drillCode];

    if (progress == null) {
      return 'Mình chưa có dữ liệu cho bài này.\n'
          'Bắt đầu tập để mình hiểu bạn hơn nhé.';
    }

    final parts = <String>[];

    // Data
    parts.add('DỮ LIỆU:');
    parts.add('• ${progress.totalAttempts} buổi đã tập');
    parts.add('• Accuracy trung bình: ${progress.averageAccuracy}%');
    parts.add('• Lần cuối: ${_formatDate(progress.lastAttemptedAt)}');

    // Pattern
    parts.add('\nPATTERN:');
    if (progress.averageAccuracy < 60) {
      parts.add('• Cần nhiều thời gian hơn với bài này');
      parts.add('• Tập trung vào căn bản trước');
    } else if (progress.averageAccuracy < 75) {
      parts.add('• Đang tiến bộ');
      parts.add('• Cần thêm practice để ổn định');
    } else {
      parts.add('• Đã khá thành thạo');
      parts.add('• Có thể chuyển sang bài khó hơn');
    }

    // Next step
    parts.add('\nBƯỚC TIẾP THEO:');
    parts.add('Tiếp tục với bài này để cải thiện.');

    return parts.join('\n');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'chưa bao giờ';
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'hôm nay';
    if (days == 1) return 'hôm qua';
    if (days < 7) return '$days ngày trước';
    return '$days ngày trước';
  }
}
