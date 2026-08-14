/// Drill Content — Vietnamese instructional content for each drill.
///
/// Each drill can have detailed content covering:
/// - Equipment needed
/// - Stance (tư thế)
/// - Bridge (cầu tay)
/// - Stroke mechanics (kỹ thuật ra cơ)
/// - Aiming system (hệ thống ngắm)
/// - Key points (điểm quan trọng)
/// - Common mistakes (lỗi thường gặp)
/// - Pro tips (mẹo pro)
/// - Safety notes (lưu ý an toàn)
///
/// All content is written in Vietnamese, based on Dr. Dave Alciatore's
/// "The Illustrated Principles of Pool and Billiards" and BCA/APA standards.
library;

class DrillContent {
  final String drillCode;

  /// Dụng cụ cần thiết
  final List<String> equipment;

  /// Tư thế đứng
  final String stance;

  /// Cách đặt cầu tay
  final String bridge;

  /// Kỹ thuật ra cơ
  final String stroke;

  /// Hệ thống ngắm
  final String aiming;

  /// Các điểm cần nhớ
  final List<String> keyPoints;

  /// Lỗi thường gặp
  final List<String> commonMistakes;

  /// Mẹo từ pro
  final List<String> proTips;

  /// Lưu ý an toàn
  final String? safetyNotes;

  const DrillContent({
    required this.drillCode,
    this.equipment = const [],
    required this.stance,
    required this.bridge,
    required this.stroke,
    required this.aiming,
    this.keyPoints = const [],
    this.commonMistakes = const [],
    this.proTips = const [],
    this.safetyNotes,
  });
}
