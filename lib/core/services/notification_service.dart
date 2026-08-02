/// Notification Model - Chỉ hiện khi thật sự cần
class PoolNotification {
  final String id;
  final String type; // streak_warning, drill_ready, level_up, test_available
  final String title;
  final String body;
  final String? actionRoute;
  final String? actionLabel;
  final DateTime createdAt;
  final bool isRead;

  PoolNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.actionRoute,
    this.actionLabel,
    required this.createdAt,
    this.isRead = false,
  });

  factory PoolNotification.fromJson(Map<String, dynamic> json) {
    return PoolNotification(
      id: json['id'],
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      actionRoute: json['action_route'],
      actionLabel: json['action_label'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'action_route': actionRoute,
      'action_label': actionLabel,
      'is_read': isRead,
    };
  }

  PoolNotification copyWith({bool? isRead}) {
    return PoolNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      actionRoute: actionRoute,
      actionLabel: actionLabel,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Notification Templates
class NotificationTemplates {
  /// Cảnh báo streak sắp mất
  static PoolNotification streakWarning({
    required int daysInactive,
    String? drillName,
  }) {
    return PoolNotification(
      id: 'streak_warning_${DateTime.now().millisecondsSinceEpoch}',
      type: 'streak_warning',
      title: 'Cảnh báo Streak',
      body: daysInactive >= 4
          ? 'Bạn đã bỏ tập $daysInactive ngày. Hãy quay lại ngay!'
          : 'Bạn đã bỏ tập $daysInactive ngày. Đừng để mất streak!',
      actionRoute: drillName != null ? '/training/session/new?drill=$drillName' : '/training',
      actionLabel: 'Quay lại tập',
      createdAt: DateTime.now(),
    );
  }

  /// Drill đã sẵn sàng để test
  static PoolNotification drillReady({
    required String drillName,
    required int level,
  }) {
    return PoolNotification(
      id: 'drill_ready_${DateTime.now().millisecondsSinceEpoch}',
      type: 'drill_ready',
      title: 'Drill sẵn sàng',
      body: '$drillName Lv$level đã đạt yêu cầu. Bạn có thể test ngay!',
      actionRoute: '/training/certification',
      actionLabel: 'Đi test',
      createdAt: DateTime.now(),
    );
  }

  /// Level up thông báo
  static PoolNotification levelUp({
    required String drillName,
    required int newLevel,
  }) {
    return PoolNotification(
      id: 'level_up_${DateTime.now().millisecondsSinceEpoch}',
      type: 'level_up',
      title: 'Level Up! 🎉',
      body: 'Bạn đã hoàn thành $drillName Lv${newLevel - 1}. Tiếp tục với Lv$newLevel!',
      actionRoute: '/training/session/new?drill=$drillName&level=$newLevel',
      actionLabel: 'Tiếp tục Lv$newLevel',
      createdAt: DateTime.now(),
    );
  }

  /// Test có sẵn để pass
  static PoolNotification testAvailable({
    required String testName,
  }) {
    return PoolNotification(
      id: 'test_available_${DateTime.now().millisecondsSinceEpoch}',
      type: 'test_available',
      title: 'Có thể thi ngay!',
      body: 'Bạn đã đạt yêu cầu cho $testName. Hãy thi để nhận chứng nhận.',
      actionRoute: '/training/certification',
      actionLabel: 'Đi thi',
      createdAt: DateTime.now(),
    );
  }

  /// Sau match - phân tích
  static PoolNotification matchAnalysis({
    required int totalMisses,
    required String weakestArea,
  }) {
    return PoolNotification(
      id: 'match_analysis_${DateTime.now().millisecondsSinceEpoch}',
      type: 'match_analysis',
      title: 'Phân tích sau trận',
      body: 'Bạn miss $totalMisses cú. Điểm yếu nhất: $weakestArea. AI đã chọn bài tập phù hợp.',
      actionRoute: '/training',
      actionLabel: 'Xem đề xuất',
      createdAt: DateTime.now(),
    );
  }

  /// Streak milestone
  static PoolNotification streakMilestone({
    required int days,
  }) {
    return PoolNotification(
      id: 'streak_milestone_${DateTime.now().millisecondsSinceEpoch}',
      type: 'streak_milestone',
      title: 'Kỷ lục mới! 🔥',
      body: 'Bạn đã tập liên tiếp $days ngày. Tiếp tục phát huy!',
      createdAt: DateTime.now(),
    );
  }
}
