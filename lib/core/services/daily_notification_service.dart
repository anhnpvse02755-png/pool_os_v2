// ============================================================================
// DAILY NOTIFICATION SERVICE - Sprint-10B
// Handles daily learning notifications with persistence
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../data/repositories/cache_repository.dart';

/// Abstract interface for notification scheduling (testable without real OS)
abstract class NotificationScheduler {
  /// Schedule a daily notification at the specified hour
  Future<bool> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  });

  /// Cancel a scheduled notification
  Future<void> cancel(int id);

  /// Cancel all scheduled notifications
  Future<void> cancelAll();

  /// Check if notifications are supported on this platform
  bool get isSupported;

  /// Check if notifications are enabled by user
  Future<bool> areNotificationsEnabled();
}

/// Mock scheduler for testing
class MockNotificationScheduler implements NotificationScheduler {
  final List<int> scheduledIds = [];
  bool _isSupported = true;

  @override
  bool get isSupported => _isSupported;

  @override
  Future<bool> areNotificationsEnabled() async => true;

  @override
  Future<bool> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    scheduledIds.add(id);
    return true;
  }

  @override
  Future<void> cancel(int id) async {
    scheduledIds.remove(id);
  }

  @override
  Future<void> cancelAll() async {
    scheduledIds.clear();
  }
}

/// Platform notification scheduler
class PlatformNotificationScheduler implements NotificationScheduler {
  PlatformNotificationScheduler() {
    _init();
  }

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  @override
  bool get isSupported => defaultTargetPlatform != TargetPlatform.fuchsia;

  @override
  Future<bool> areNotificationsEnabled() async {
    if (!_initialized) await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.areNotificationsEnabled() ?? false;
  }

  @override
  Future<bool> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await _init();

    // Check permission on Android
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final enabled = await android?.requestNotificationsPermission();
      if (enabled != true) return false;
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_learning',
          'Daily Learning',
          channelDescription: 'Daily learning reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    return true;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  @override
  Future<void> cancel(int id) async {
    if (!_initialized) await _init();
    await _plugin.cancel(id);
  }

  @override
  Future<void> cancelAll() async {
    if (!_initialized) await _init();
    await _plugin.cancelAll();
  }
}

/// Daily notification service - coordinates notification scheduling and preferences
class DailyNotificationService {
  DailyNotificationService(this._cache);

  final ICacheRepository _cache;
  static const _kDailyNotificationEnabled = 'poolos_v2.daily_notification_enabled';
  static const _kDailyNotificationHour = 'poolos_v2.daily_notification_hour';
  static const _kDailyNotificationMinute = 'poolos_v2.daily_notification_minute';

  // Notification ID for daily learning reminder
  static const int dailyNotificationId = 1001;

  NotificationScheduler _scheduler = MockNotificationScheduler();

  /// Set custom scheduler (for testing)
  set scheduler(NotificationScheduler s) => _scheduler = s;

  /// Get scheduler (for testing)
  NotificationScheduler get scheduler => _scheduler;

  /// Check if daily notifications are enabled
  bool isEnabled() {
    final value = _cache.getString(_kDailyNotificationEnabled);
    return value == 'true';
  }

  /// Get scheduled hour (default 9 AM)
  int getHour() {
    final value = _cache.getString(_kDailyNotificationHour);
    return int.tryParse(value ?? '9') ?? 9;
  }

  /// Get scheduled minute (default 0)
  int getMinute() {
    final value = _cache.getString(_kDailyNotificationMinute);
    return int.tryParse(value ?? '0') ?? 0;
  }

  /// Enable daily notifications
  Future<bool> enable({
    int hour = 9,
    int minute = 0,
  }) async {
    // Save preference using string storage
    await _cache.setString(_kDailyNotificationEnabled, 'true');
    await _cache.setString(_kDailyNotificationHour, hour.toString());
    await _cache.setString(_kDailyNotificationMinute, minute.toString());

    // Schedule notification
    final success = await _scheduler.scheduleDaily(
      id: dailyNotificationId,
      title: 'Tập luyện hôm nay! 🏆',
      body: 'Đừng quên streak của bạn. Vào luyện tập ngay!',
      hour: hour,
      minute: minute,
    );

    return success;
  }

  /// Disable daily notifications
  Future<void> disable() async {
    await _cache.setString(_kDailyNotificationEnabled, 'false');
    await _scheduler.cancel(dailyNotificationId);
  }

  /// Update notification time
  Future<bool> updateTime({
    required int hour,
    required int minute,
  }) async {
    if (!isEnabled()) return false;

    await _cache.setString(_kDailyNotificationHour, hour.toString());
    await _cache.setString(_kDailyNotificationMinute, minute.toString());

    // Cancel and reschedule
    await _scheduler.cancel(dailyNotificationId);

    return await _scheduler.scheduleDaily(
      id: dailyNotificationId,
      title: 'Tập luyện hôm nay! 🏆',
      body: 'Đừng quên streak của bạn. Vào luyện tập ngay!',
      hour: hour,
      minute: minute,
    );
  }

  /// Check if platform supports notifications
  bool get isSupported => _scheduler.isSupported;

  /// Check if notifications are enabled in system settings
  Future<bool> checkSystemPermission() async {
    return await _scheduler.areNotificationsEnabled();
  }
}
