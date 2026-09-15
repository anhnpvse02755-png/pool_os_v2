// ============================================================================
// Black Box — test BlackBoxProvider THẬT
//
// Bản trước của file này mang tên "integration" nhưng không tích hợp gì: mỗi
// test tự dựng một Scaffold có sẵn chuỗi rồi assert đúng chuỗi đó. Không
// service nào chạy, không trạng thái nào chuyển.
//
// Bản này gọi thẳng BlackBoxProvider và kiểm máy trạng thái thật của nó.
// Phần giao diện đã có `test/widget/black_box_*_test.dart` phủ.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pool_os_v2/beta/providers/black_box_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Không mock thì mỗi lần khởi tạo in một MissingPluginException ra log;
  // provider nuốt lỗi nên test vẫn xanh, chỉ là chạy trên đường lỗi chứ
  // không phải đường thật.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('BlackBoxProvider — máy trạng thái', () {
    test('khởi điểm là idle, chưa sẵn sàng, chưa có lỗi', () {
      final provider = BlackBoxProvider();

      expect(provider.state, BlackBoxState.idle);
      expect(provider.isInitialized, isFalse);
      expect(provider.error, isNull);
      expect(provider.lastExportPath, isNull);
      expect(provider.preview, isNull);
    });

    test('initialize đưa provider sang ready', () async {
      final provider = BlackBoxProvider();

      await provider.initialize(testerId: 'tester-01');

      expect(provider.state, BlackBoxState.ready);
      expect(provider.isInitialized, isTrue);
      expect(provider.error, isNull);
    });

    test('gọi initialize lần hai không dựng lại services', () async {
      final provider = BlackBoxProvider();

      await provider.initialize(testerId: 'tester-01');
      final recorderSauLan1 = provider.recorder;
      await provider.initialize(testerId: 'tester-02');

      expect(identical(provider.recorder, recorderSauLan1), isTrue,
          reason: 'dựng lại services sẽ mất sạch sự kiện đã ghi');
    });

    test('initialize xong thì có sẵn recorder và feedback collector',
        () async {
      final provider = BlackBoxProvider();

      await provider.initialize(testerId: 'tester-01');

      expect(provider.recorder, isNotNull);
      expect(provider.feedback, isNotNull);
    });

    test('generatePreview trả số liệu và lưu lại vào provider', () async {
      final provider = BlackBoxProvider();
      await provider.initialize(testerId: 'tester-01');

      final preview = provider.generatePreview(testerId: 'tester-01');

      expect(preview.testerId, 'tester-01');
      expect(preview.totalEvents, greaterThanOrEqualTo(0));
      expect(provider.preview, same(preview),
          reason: 'màn hình đọc preview từ provider, không giữ bản riêng');
    });

    test('sizeEstimate luôn là chuỗi đọc được, kể cả khi chưa có sự kiện',
        () async {
      final provider = BlackBoxProvider();
      await provider.initialize(testerId: 'tester-01');

      final preview = provider.generatePreview(testerId: 'tester-01');

      expect(preview.sizeEstimate, isNotEmpty);
    });

    test('clearAll đưa về ready và xoá lỗi lẫn đường dẫn cũ', () async {
      final provider = BlackBoxProvider();
      await provider.initialize(testerId: 'tester-01');

      await provider.clearAll();

      expect(provider.state, BlackBoxState.ready);
      expect(provider.error, isNull);
      expect(provider.lastExportPath, isNull);
    });

    test('provider báo thay đổi cho người nghe', () async {
      final provider = BlackBoxProvider();
      var lanBao = 0;
      provider.addListener(() => lanBao++);

      await provider.initialize(testerId: 'tester-01');

      expect(lanBao, greaterThan(0),
          reason: 'không notifyListeners thì giao diện đứng im ở màn tải');
    });

    test('generatePreview cũng báo thay đổi', () async {
      final provider = BlackBoxProvider();
      await provider.initialize(testerId: 'tester-01');
      var lanBao = 0;
      provider.addListener(() => lanBao++);

      provider.generatePreview(testerId: 'tester-01');

      expect(lanBao, greaterThan(0));
    });
  });

  group('BlackBoxState — các trạng thái phải phân biệt được', () {
    test('có đủ 7 trạng thái của vòng đời xuất gói', () {
      // Màn hình switch trên enum này; thêm/bớt trạng thái mà quên cập nhật
      // màn sẽ ra nhánh không được vẽ.
      expect(BlackBoxState.values, hasLength(7));
      expect(
        BlackBoxState.values,
        containsAll(const [
          BlackBoxState.idle,
          BlackBoxState.initializing,
          BlackBoxState.ready,
          BlackBoxState.exporting,
          BlackBoxState.compressing,
          BlackBoxState.exported,
          BlackBoxState.error,
        ]),
      );
    });
  });
}
