import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

/// Notification State
class NotificationState {
  final List<PoolNotification> notifications;
  final int unreadCount;

  NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<PoolNotification>? notifications,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Notification Notifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState());

  /// Add notification
  void addNotification(PoolNotification notification) {
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
      unreadCount: state.unreadCount + 1,
    );
  }

  /// Mark as read
  void markAsRead(String notificationId) {
    final notifications = state.notifications.map((n) {
      if (n.id == notificationId && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final unreadCount = notifications.where((n) => !n.isRead).length;

    state = state.copyWith(
      notifications: notifications,
      unreadCount: unreadCount,
    );
  }

  /// Mark all as read
  void markAllAsRead() {
    final notifications = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();

    state = state.copyWith(
      notifications: notifications,
      unreadCount: 0,
    );
  }

  /// Remove notification
  void removeNotification(String notificationId) {
    final notifications = state.notifications
        .where((n) => n.id != notificationId)
        .toList();

    final unreadCount = notifications.where((n) => !n.isRead).length;

    state = state.copyWith(
      notifications: notifications,
      unreadCount: unreadCount,
    );
  }

  /// Clear all
  void clearAll() {
    state = NotificationState();
  }

  /// Generate streak warning
  void generateStreakWarning(int daysInactive, {String? drillCode}) {
    final notification = NotificationTemplates.streakWarning(
      daysInactive: daysInactive,
      drillName: drillCode,
    );
    addNotification(notification);
  }

  /// Generate drill ready
  void generateDrillReady(String drillName, int level) {
    final notification = NotificationTemplates.drillReady(
      drillName: drillName,
      level: level,
    );
    addNotification(notification);
  }

  /// Generate level up
  void generateLevelUp(String drillName, int newLevel) {
    final notification = NotificationTemplates.levelUp(
      drillName: drillName,
      newLevel: newLevel,
    );
    addNotification(notification);
  }
}

/// Notification Provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

/// Unread count provider (for badge)
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});

/// Has notifications provider
final hasNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).unreadCount > 0;
});
