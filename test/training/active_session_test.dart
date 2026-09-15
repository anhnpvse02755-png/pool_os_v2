import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/models/session_item.dart';
import 'package:pool_os_v2/core/providers/active_session_provider.dart';

SessionItem _item(String code, {String? name}) => SessionItem(
      drillCode: code,
      drillName: name ?? 'Bài $code',
      priority: SessionPriority.path,
      estimatedMinutes: 10,
      reason: 'test',
    );

void main() {
  group('ActiveSessionNotifier — chuỗi bài của một buổi tập', () {
    late ActiveSessionNotifier notifier;

    setUp(() => notifier = ActiveSessionNotifier());

    test('khởi đầu là không có buổi nào đang chạy', () {
      expect(notifier.state.isActive, isFalse);
      expect(notifier.state.current, isNull);
    });

    test('start dịch mã knowledge graph sang mã bài tập thật', () {
      // POSITION_CONTROL là mã của knowledge graph; màn tập chỉ hiểu BT09.
      notifier.start([_item('POSITION_CONTROL'), _item('BANK_SHOT')]);

      expect(notifier.state.current!.drillCode, 'BT09');
      expect(notifier.state.items[1].drillCode, 'BT14');
    });

    test('bài không dịch được bị loại khỏi buổi, không làm hỏng cả buổi', () {
      notifier.start([
        _item('KHONG_TON_TAI'),
        _item('BANK_SHOT'),
      ]);

      expect(notifier.state.items, hasLength(1));
      expect(notifier.state.current!.drillCode, 'BT14');
    });

    test('buổi rỗng sau khi lọc thì coi như không có buổi nào chạy', () {
      notifier.start([_item('KHONG_TON_TAI')]);
      expect(notifier.state.isActive, isFalse);
    });

    test('vị trí hiển thị đếm từ 1 và biết đâu là bài cuối', () {
      notifier.start([_item('BT01'), _item('BT03'), _item('BT07')]);

      expect(notifier.state.position, 1);
      expect(notifier.state.total, 3);
      expect(notifier.state.isLast, isFalse);

      notifier.advance();
      expect(notifier.state.position, 2);
      expect(notifier.state.isLast, isFalse);

      notifier.advance();
      expect(notifier.state.position, 3);
      expect(notifier.state.isLast, isTrue);
    });

    test('advance trả về bài kế tiếp, và null khi đã hết bài', () {
      notifier.start([_item('BT01'), _item('BT03')]);

      expect(notifier.advance()?.drillCode, 'BT03');
      expect(notifier.advance(), isNull);
    });

    test('advance quá cuối không đẩy con trỏ ra ngoài danh sách', () {
      notifier.start([_item('BT01')]);

      notifier.advance();
      notifier.advance();

      expect(notifier.state.position, 1);
      expect(notifier.state.current!.drillCode, 'BT01');
    });

    test('ghi nhận kết quả từng bài để tổng kết cuối buổi', () {
      notifier.start([_item('BT01'), _item('BT03')]);

      notifier.recordResult(drillCode: 'BT01', made: 7, missed: 3, minutes: 12);
      notifier.advance();
      notifier.recordResult(drillCode: 'BT03', made: 5, missed: 5, minutes: 8);

      final results = notifier.state.results;
      expect(results, hasLength(2));
      expect(results.first.made, 7);
      expect(notifier.state.totalMade, 12);
      expect(notifier.state.totalMissed, 8);
      expect(notifier.state.totalMinutes, 20);
    });

    test('độ chính xác cả buổi tính trên tổng số cú, không phải trung bình cộng',
        () {
      notifier.start([_item('BT01'), _item('BT03')]);
      // Bài 1: 1/10 = 10%. Bài 2: 2/2 = 100%.
      // Trung bình cộng sẽ ra 55%, nhưng đúng phải là 3/12 = 25%.
      notifier.recordResult(drillCode: 'BT01', made: 1, missed: 9, minutes: 5);
      notifier.recordResult(drillCode: 'BT03', made: 2, missed: 0, minutes: 5);

      expect(notifier.state.accuracy, closeTo(25.0, 0.01));
    });

    test('độ chính xác không chia cho 0 khi chưa có cú nào', () {
      notifier.start([_item('BT01')]);
      expect(notifier.state.accuracy, 0);
    });

    test('kết thúc sớm xoá buổi nhưng giữ lại kết quả đã ghi', () {
      notifier.start([_item('BT01'), _item('BT03')]);
      notifier.recordResult(drillCode: 'BT01', made: 4, missed: 1, minutes: 6);

      final finished = notifier.finish();

      expect(finished.results, hasLength(1));
      expect(finished.completedCount, 1);
      expect(finished.plannedCount, 2);
      expect(notifier.state.isActive, isFalse,
          reason: 'sau khi kết thúc thì không còn buổi nào đang chạy');
    });

    test('ghi trùng một bài thì cập nhật chứ không cộng thêm dòng', () {
      notifier.start([_item('BT01')]);
      notifier.recordResult(drillCode: 'BT01', made: 3, missed: 7, minutes: 5);
      notifier.recordResult(drillCode: 'BT01', made: 6, missed: 4, minutes: 9);

      expect(notifier.state.results, hasLength(1));
      expect(notifier.state.results.single.made, 6);
      expect(notifier.state.totalMinutes, 9);
    });
  });
}
