import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/data/models/training_session.dart';

void main() {
  group('TrainingSession — shotsAttempted la du lieu dan xuat', () {
    test('shotsAttempted bang tong made va missed', () {
      final s = TrainingSession(
        id: 'a',
        drillCode: 'BT01',
        drillName: 'Bai 1',
        level: 1,
        score: 70,
        shotsMade: 7,
        shotsMissed: 3,
        duration: 10,
        completedAt: DateTime(2026, 9, 17),
      );

      expect(s.shotsAttempted, equals(10));
    });
  });

  group('TrainingSession.fromJson — khoan dung voi khoa cu', () {
    test('suy ra shotsMissed tu shotsAttempted khi thieu shotsMissed', () {
      final s = TrainingSession.fromJson({
        'id': 'a',
        'drillCode': 'BT01',
        'drillName': 'Bai 1',
        'level': 1,
        'score': 70,
        'shotsAttempted': 10,
        'shotsMade': 7,
        'duration': 10,
        'date': '2026-09-17T08:00:00.000',
      });

      expect(s.shotsMissed, equals(3), reason: '10 danh - 7 vao = 3 truot');
      expect(s.shotsAttempted, equals(10));
    });

    test('doc khoa cu `date` khi thieu `completedAt`', () {
      final s = TrainingSession.fromJson({
        'id': 'a',
        'drillCode': 'BT01',
        'drillName': 'Bai 1',
        'date': '2026-09-17T08:00:00.000',
      });

      expect(s.completedAt, equals(DateTime.parse('2026-09-17T08:00:00.000')),
          reason: 'thieu cho nay thi moi buoi tap deu mang gio doc, khong phai gio tap');
    });

    test('uu tien khoa moi khi co ca hai', () {
      final s = TrainingSession.fromJson({
        'id': 'a',
        'drillCode': 'BT01',
        'drillName': 'Bai 1',
        'shotsAttempted': 10,
        'shotsMade': 7,
        'shotsMissed': 2,
        'completedAt': '2026-09-18T08:00:00.000',
        'date': '2026-09-17T08:00:00.000',
      });

      expect(s.shotsMissed, equals(2));
      expect(s.completedAt, equals(DateTime.parse('2026-09-18T08:00:00.000')));
    });

    test('shotsMissed khong bao gio am', () {
      final s = TrainingSession.fromJson({
        'id': 'a',
        'drillCode': 'BT01',
        'drillName': 'Bai 1',
        'shotsAttempted': 3,
        'shotsMade': 7,
      });

      expect(s.shotsMissed, equals(0), reason: 'du lieu ban khong duoc sinh so am');
    });
  });
}
