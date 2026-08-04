/// Notification Repository Interface
/// Abstracts data access for notifications
abstract class NotificationRepository {
  /// Get all notifications
  Future<List<AppNotification>> getAllNotifications();

  /// Get unread notifications
  Future<List<AppNotification>> getUnreadNotifications();

  /// Get notification by ID
  Future<AppNotification?> getNotificationById(String id);

  /// Mark notification as read
  Future<void> markAsRead(String id);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Delete notification
  Future<void> delete(String id);

  /// Delete all notifications
  Future<void> deleteAll();

  /// Get unread count
  Future<int> getUnreadCount();

  /// Create notification (for internal use)
  Future<void> createNotification(AppNotification notification);
}

/// App Notification Model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });
}

/// Notification Types
enum NotificationType {
  achievement,
  streakReminder,
  drillRecommendation,
  matchInvite,
  tournamentUpdate,
  communityPost,
  systemUpdate,
}
