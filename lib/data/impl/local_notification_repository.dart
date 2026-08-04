import '../../data/datasources/local/local_storage_datasource.dart';
import '../../data/repositories/notification_repository.dart';

/// Local Notification Repository Implementation
class LocalNotificationRepository implements NotificationRepository {
  @override
  Future<List<AppNotification>> getAllNotifications() async {
    final data = await LocalStorageDataSource.getNotifications();
    return data.map((json) => _notificationFromJson(json)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<AppNotification>> getUnreadNotifications() async {
    final notifications = await getAllNotifications();
    return notifications.where((n) => !n.isRead).toList();
  }

  @override
  Future<AppNotification?> getNotificationById(String id) async {
    final notifications = await getAllNotifications();
    try {
      return notifications.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    final notifications = await LocalStorageDataSource.getNotifications();
    final index = notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      notifications[index]['isRead'] = true;
      await LocalStorageDataSource.saveNotifications(notifications);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final notifications = await LocalStorageDataSource.getNotifications();
    for (var i = 0; i < notifications.length; i++) {
      notifications[i]['isRead'] = true;
    }
    await LocalStorageDataSource.saveNotifications(notifications);
  }

  @override
  Future<void> delete(String id) async {
    final notifications = await LocalStorageDataSource.getNotifications();
    notifications.removeWhere((n) => n['id'] == id);
    await LocalStorageDataSource.saveNotifications(notifications);
  }

  @override
  Future<void> deleteAll() async {
    await LocalStorageDataSource.saveNotifications([]);
  }

  @override
  Future<int> getUnreadCount() async {
    final notifications = await getUnreadNotifications();
    return notifications.length;
  }

  @override
  Future<void> createNotification(AppNotification notification) async {
    final notifications = await LocalStorageDataSource.getNotifications();
    notifications.insert(0, _notificationToJson(notification));
    await LocalStorageDataSource.saveNotifications(notifications);
  }

  AppNotification _notificationFromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NotificationType.systemUpdate,
      ),
      data: json['data'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> _notificationToJson(AppNotification notification) {
    return {
      'id': notification.id,
      'title': notification.title,
      'body': notification.body,
      'type': notification.type.name,
      'data': notification.data,
      'isRead': notification.isRead,
      'createdAt': notification.createdAt.toIso8601String(),
    };
  }
}
