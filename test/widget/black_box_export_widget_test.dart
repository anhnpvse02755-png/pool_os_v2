// ============================================================================
// Black Box Export — test màn hình THẬT
//
// Bản trước của file này không kiểm gì cả: mỗi test tự dựng
// `Text('PoolOS Black Box')` ngay trong test rồi assert đúng chuỗi vừa dựng.
// Nó xanh kể cả khi màn hình thật bị xoá sạch. Phát hiện ra vì đợt việt hoá
// đổi toàn bộ chuỗi của màn mà không test nào đỏ.
//
// Bản này dựng `BlackBoxExportScreen` thật và điều khiển trạng thái qua một
// BlackBoxProvider giả, nên nó thực sự bám vào mã sản phẩm.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/beta/services/package_builder_service.dart';
import 'package:pool_os_v2/beta/services/replay_builder_service.dart';
import 'package:pool_os_v2/beta/presentation/screens/black_box_export_screen.dart';
import 'package:pool_os_v2/beta/providers/black_box_provider.dart';
import 'package:pool_os_v2/beta/providers/providers.dart';

/// Provider giả: chặn `initialize()` (bản thật đụng file system và
/// path_provider) và cho phép đặt thẳng trạng thái cần kiểm.
class FakeBlackBoxProvider extends BlackBoxProvider {
  FakeBlackBoxProvider(
    this._state, {
    String? error,
    String? exportPath,
    PackagePreview? preview,
  })  : _fakeError = error,
        _fakeExportPath = exportPath,
        _fakePreview = preview;

  final BlackBoxState _state;
  final String? _fakeError;
  final String? _fakeExportPath;
  final PackagePreview? _fakePreview;

  int clearAllCalls = 0;

  @override
  BlackBoxState get state => _state;
  @override
  String? get error => _fakeError;
  @override
  String? get lastExportPath => _fakeExportPath;
  @override
  PackagePreview? get preview => _fakePreview;
  @override
  bool get isInitialized => true;

  @override
  Future<void> initialize({String? testerId}) async {}

  /// Bản thật đọc `packageBuilder` — một `late final` chỉ được gán trong
  /// `initialize()`, mà ở đây ta cố tình không chạy. Không override thì mọi
  /// test chạm nút xuất sẽ chết vì LateInitializationError.
  @override
  PackagePreview generatePreview({required String testerId}) =>
      fakePreview(testerId);

  @override
  Future<void> clearAll() async {
    clearAllCalls++;
  }
}

PackagePreview fakePreview(String testerId) => PackagePreview(
      testerId: testerId,
      totalEvents: 42,
      totalSessions: 3,
      totalMatches: 1,
      totalRecommendations: 5,
      totalConversations: 2,
      totalErrors: 0,
      validation: ReplayValidation(
        isValid: true,
        issues: const [],
        totalEvents: 42,
      ),
      replaySummary: ReplaySummary(
        totalEvents: 42,
        sessionStart: DateTime(2026, 9, 15, 9),
        sessionEnd: DateTime(2026, 9, 15, 10),
        drillStarts: 3,
        drillCompletions: 3,
        drillAbandons: 0,
        matchesStarted: 1,
        matchesCompleted: 1,
        coachChats: 2,
        recommendations: 5,
        errors: 0,
      ),
    );

Future<FakeBlackBoxProvider> pumpScreen(
  WidgetTester tester,
  BlackBoxState state, {
  String? error,
  String? exportPath,
}) async {
  final fake = FakeBlackBoxProvider(
    state,
    error: error,
    exportPath: exportPath,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [blackBoxProvider.overrideWith((ref) => fake)],
      child: const MaterialApp(home: BlackBoxExportScreen()),
    ),
  );
  await tester.pump();
  return fake;
}

void main() {
  group('BlackBoxExportScreen — mỗi trạng thái hiện đúng thứ cần hiện', () {
    testWidgets('idle: đang tải, chưa có nút xuất', (tester) async {
      await pumpScreen(tester, BlackBoxState.idle);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Xuất gói dữ liệu Coach'), findsNothing);
    });

    testWidgets('initializing: vẫn là màn tải', (tester) async {
      await pumpScreen(tester, BlackBoxState.initializing);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ready: có nút xuất và phần giải thích', (tester) async {
      await pumpScreen(tester, BlackBoxState.ready);

      expect(find.text('Xuất gói dữ liệu Coach'), findsOneWidget);
      expect(find.text('Đây là gì?'), findsOneWidget);
      expect(find.text('Không cần tài khoản. Không cần mạng. Ẩn danh.'),
          findsOneWidget);
    });

    testWidgets('ready: liệt kê đủ 5 thứ sẽ được xuất', (tester) async {
      await pumpScreen(tester, BlackBoxState.ready);

      for (final item in const [
        'Hồ sơ & kỹ năng của bạn',
        'Đề xuất và lập luận của Coach',
        'Toàn bộ hội thoại',
        'Dòng thời gian đầy đủ',
        'Góp ý của bạn',
      ]) {
        expect(find.text(item), findsOneWidget, reason: 'thiếu mục "$item"');
      }
    });

    testWidgets('exporting: hiện tiến trình, không cho bấm xuất lần nữa',
        (tester) async {
      await pumpScreen(tester, BlackBoxState.exporting);

      expect(find.text('Đang dựng hộp đen...'), findsOneWidget);
      expect(find.text('Xuất gói dữ liệu Coach'), findsNothing,
          reason: 'đang xuất mà vẫn bấm xuất được thì sinh hai tiến trình');
    });

    testWidgets('exporting: liệt kê các bước', (tester) async {
      await pumpScreen(tester, BlackBoxState.exporting);

      for (final step in const [
        'Ghi lại sự kiện',
        'Dựng bản phát lại',
        'Tạo ảnh chụp',
        'Đóng gói',
        'Nén ZIP',
      ]) {
        expect(find.text(step), findsOneWidget, reason: 'thiếu bước "$step"');
      }
    });

    testWidgets('compressing: là bước riêng, không lẫn với exporting',
        (tester) async {
      await pumpScreen(tester, BlackBoxState.compressing);

      expect(find.text('Đang nén...'), findsOneWidget);
      expect(find.text('Đang dựng hộp đen...'), findsNothing);
    });

    testWidgets('exported: báo xong và cho chia sẻ / lưu / xuất tiếp',
        (tester) async {
      await pumpScreen(
        tester,
        BlackBoxState.exported,
        exportPath: '/tmp/PoolOS_Coach_001.zip',
      );

      expect(find.text('Hộp đen đã sẵn sàng!'), findsOneWidget);
      expect(find.text('Chia sẻ qua...'), findsOneWidget);
      expect(find.text('Lưu vào thư mục Tải về'), findsOneWidget);
      expect(find.text('Xuất gói khác'), findsOneWidget);
    });

    testWidgets('exported: hiện tên file thật đã xuất', (tester) async {
      await pumpScreen(
        tester,
        BlackBoxState.exported,
        exportPath: '/tmp/PoolOS_Coach_042.zip',
      );

      expect(find.text('PoolOS_Coach_042.zip'), findsOneWidget,
          reason: 'người dùng cần biết file nào vừa được tạo');
    });

    testWidgets('error: nói rõ lý do chứ không chỉ "thất bại"',
        (tester) async {
      await pumpScreen(
        tester,
        BlackBoxState.error,
        error: 'Hết dung lượng đĩa',
      );

      expect(find.text('Xuất thất bại'), findsOneWidget);
      expect(find.textContaining('Hết dung lượng đĩa'), findsAtLeastNWidgets(1),
          reason: 'lý do lỗi phải tới được người dùng');
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('error: bấm "Thử lại" thì dọn trạng thái lỗi', (tester) async {
      final fake = await pumpScreen(
        tester,
        BlackBoxState.error,
        error: 'Lỗi gì đó',
      );

      // Nut nam trong vung cuon: khong ensureVisible thi tap() ban ra ngoai
      // viewport va IM LANG khong lam gi.
      await tester.ensureVisible(find.text('Thử lại'));
      await tester.pump();
      await tester.tap(find.text('Thử lại'));
      await tester.pump();

      expect(fake.clearAllCalls, 1,
          reason: 'không dọn trạng thái thì màn kẹt ở lỗi cũ');
    });

    testWidgets('error: có nút Huỷ để thoát khỏi màn', (tester) async {
      // "Huỷ" rời màn bằng context.pop() chứ không dọn trạng thái — dọn là
      // việc của "Thử lại". Hai nút không được làm cùng một chuyện.
      await pumpScreen(tester, BlackBoxState.error, error: 'Lỗi gì đó');

      expect(find.text('Huỷ'), findsOneWidget);
    });

    testWidgets('exported: bấm "Xuất gói khác" thì gọi clearAll',
        (tester) async {
      final fake = await pumpScreen(
        tester,
        BlackBoxState.exported,
        exportPath: '/tmp/a.zip',
      );

      await tester.ensureVisible(find.text('Xuất gói khác'));
      await tester.pump();
      await tester.tap(find.text('Xuất gói khác'));
      await tester.pump();

      expect(fake.clearAllCalls, 1);
    });

    testWidgets('tiêu đề giữ nguyên ở mọi trạng thái', (tester) async {
      for (final state in const [
        BlackBoxState.ready,
        BlackBoxState.exporting,
        BlackBoxState.exported,
        BlackBoxState.error,
      ]) {
        await pumpScreen(tester, state, exportPath: '/tmp/a.zip', error: 'x');
        // Trang thai `ready` lap lai ten nay trong than man, nen chi kiem
        // rieng tieu de tren AppBar.
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Hộp đen (Black Box) PoolOS'),
          ),
          findsOneWidget,
          reason: 'mất tiêu đề ở trạng thái $state',
        );
      }
    });
  });
}
