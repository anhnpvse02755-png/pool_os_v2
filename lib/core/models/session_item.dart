/// Session Item — một bài tập đề xuất trong buổi tập.
/// Dùng chung cho cả logic tạo buổi tự động và hiển thị UI.
enum SessionPriority {
  retest,   // A — cần ôn lại
  weakness, // B — điểm yếu nổi bật
  path,     // C — tiếp theo trong lộ trình
}

class SessionItem {
  final String drillCode;
  final String drillName;
  final SessionPriority priority;
  final int estimatedMinutes;
  final String reason;
  final int? daysSinceLastPractice;
  final String? weaknessCondition; // ví dụ "góc 45°" nếu là điểm yếu
  final double urgencyScore; // càng cao = càng cần ưu tiên

  const SessionItem({
    required this.drillCode,
    required this.drillName,
    required this.priority,
    required this.estimatedMinutes,
    required this.reason,
    this.daysSinceLastPractice,
    this.weaknessCondition,
    this.urgencyScore = 0,
  });

  SessionItem copyWith({String? drillCode, String? drillName}) {
    return SessionItem(
      drillCode: drillCode ?? this.drillCode,
      drillName: drillName ?? this.drillName,
      priority: priority,
      estimatedMinutes: estimatedMinutes,
      reason: reason,
      daysSinceLastPractice: daysSinceLastPractice,
      weaknessCondition: weaknessCondition,
      urgencyScore: urgencyScore,
    );
  }

  String get priorityLabel {
    switch (priority) {
      case SessionPriority.retest:
        return 'Ôn lại';
      case SessionPriority.weakness:
        return 'Điểm yếu';
      case SessionPriority.path:
        return 'Lộ trình';
    }
  }

  String get priorityColor {
    switch (priority) {
      case SessionPriority.retest:
        return 'warning';
      case SessionPriority.weakness:
        return 'error';
      case SessionPriority.path:
        return 'primary';
    }
  }
}

/// Buổi tập đề xuất
class ProposedSession {
  final List<SessionItem> items;
  final int totalMinutes;
  final int retestCount;
  final int weaknessCount;
  final int pathCount;

  const ProposedSession({
    required this.items,
    required this.totalMinutes,
    required this.retestCount,
    required this.weaknessCount,
    required this.pathCount,
  });

  factory ProposedSession.empty() => const ProposedSession(
        items: [],
        totalMinutes: 0,
        retestCount: 0,
        weaknessCount: 0,
        pathCount: 0,
      );

  factory ProposedSession.fromItems(List<SessionItem> items) {
    return ProposedSession(
      items: items,
      totalMinutes: items.fold(0, (sum, i) => sum + i.estimatedMinutes),
      retestCount: items.where((i) => i.priority == SessionPriority.retest).length,
      weaknessCount: items.where((i) => i.priority == SessionPriority.weakness).length,
      pathCount: items.where((i) => i.priority == SessionPriority.path).length,
    );
  }
}
