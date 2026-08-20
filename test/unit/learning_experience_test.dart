// ============================================================================
// learning_experience_test.dart - Sprint-10B
// Tests for Learning Streak and Daily Notification services
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/services/daily_notification_service.dart';
import 'package:pool_os_v2/data/repositories/cache_repository.dart';

/// Mock cache repository for testing
class MockCacheRepository implements ICacheRepository {
  final Map<String, String> _storage = {};

  @override
  String? getString(String key) => _storage[key];

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Set<String> getKeys() => _storage.keys.toSet();

  @override
  Future<Map<String, dynamic>> getKnowledgeProgress() async => {};
}

void main() {
  group('DailyNotificationService', () {
    late MockCacheRepository mockCache;
    late DailyNotificationService service;
    late MockNotificationScheduler mockScheduler;

    setUp(() {
      mockCache = MockCacheRepository();
      mockScheduler = MockNotificationScheduler();
      service = DailyNotificationService(mockCache);
      service.scheduler = mockScheduler;
    });

    test('isEnabled returns false when not set', () {
      expect(service.isEnabled(), isFalse);
    });

    test('isEnabled returns true when enabled', () async {
      await service.enable();
      expect(service.isEnabled(), isTrue);
    });

    test('enable returns true on success', () async {
      final result = await service.enable();
      expect(result, isTrue);
    });

    test('enable schedules notification', () async {
      await service.enable(hour: 10, minute: 30);
      expect(mockScheduler.scheduledIds, contains(DailyNotificationService.dailyNotificationId));
    });

    test('enable saves hour and minute', () async {
      await service.enable(hour: 14, minute: 45);
      expect(service.getHour(), equals(14));
      expect(service.getMinute(), equals(45));
    });

    test('disable returns false for isEnabled', () async {
      await service.enable();
      await service.disable();
      expect(service.isEnabled(), isFalse);
    });

    test('disable cancels scheduled notification', () async {
      await service.enable();
      await service.disable();
      expect(mockScheduler.scheduledIds, isEmpty);
    });

    test('updateTime returns false when not enabled', () async {
      final result = await service.updateTime(hour: 8, minute: 0);
      expect(result, isFalse);
    });

    test('updateTime updates time when enabled', () async {
      await service.enable();
      await service.updateTime(hour: 20, minute: 15);
      expect(service.getHour(), equals(20));
      expect(service.getMinute(), equals(15));
    });

    test('updateTime reschedules notification', () async {
      await service.enable(hour: 9, minute: 0);
      mockScheduler.scheduledIds.clear();
      await service.updateTime(hour: 10, minute: 0);
      expect(mockScheduler.scheduledIds, contains(DailyNotificationService.dailyNotificationId));
    });

    test('isSupported returns true for mock scheduler', () {
      expect(service.isSupported, isTrue);
    });

    test('default hour is 9', () {
      expect(service.getHour(), equals(9));
    });

    test('default minute is 0', () {
      expect(service.getMinute(), equals(0));
    });

    test('service survives restart - persisted value restored', () async {
      // Enable and save
      await service.enable(hour: 16, minute: 30);

      // Create new service with same cache
      final newService = DailyNotificationService(mockCache);
      newService.scheduler = mockScheduler;

      expect(newService.isEnabled(), isTrue);
      expect(newService.getHour(), equals(16));
      expect(newService.getMinute(), equals(30));
    });
  });

  group('MockNotificationScheduler', () {
    late MockNotificationScheduler scheduler;

    setUp(() {
      scheduler = MockNotificationScheduler();
    });

    test('isSupported returns true by default', () {
      expect(scheduler.isSupported, isTrue);
    });

    test('scheduleDaily adds id to scheduledIds', () async {
      await scheduler.scheduleDaily(
        id: 1,
        title: 'Test',
        body: 'Body',
        hour: 9,
        minute: 0,
      );
      expect(scheduler.scheduledIds, contains(1));
    });

    test('cancel removes id from scheduledIds', () async {
      await scheduler.scheduleDaily(
        id: 1,
        title: 'Test',
        body: 'Body',
        hour: 9,
        minute: 0,
      );
      await scheduler.cancel(1);
      expect(scheduler.scheduledIds, isEmpty);
    });

    test('cancelAll clears all ids', () async {
      await scheduler.scheduleDaily(id: 1, title: 'T', body: 'B', hour: 9, minute: 0);
      await scheduler.scheduleDaily(id: 2, title: 'T', body: 'B', hour: 9, minute: 0);
      await scheduler.cancelAll();
      expect(scheduler.scheduledIds, isEmpty);
    });

    test('areNotificationsEnabled returns true', () async {
      final result = await scheduler.areNotificationsEnabled();
      expect(result, isTrue);
    });
  });
}
