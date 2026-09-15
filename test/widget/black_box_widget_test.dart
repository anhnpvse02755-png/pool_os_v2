// ============================================================================
// Black Box — test các widget THẬT ngoài màn export
//
// Bản trước của file này tự dựng Scaffold giả trong từng test rồi assert
// chính chuỗi vừa dựng, nên luôn xanh kể cả khi mã sản phẩm sai.
//
// Phần trạng thái của màn export đã được phủ ở
// `black_box_export_widget_test.dart`. File này phủ những thứ file đó không
// chạm tới: ô cài đặt, thẻ giới thiệu, và phiếu góp ý.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/beta/presentation/screens/black_box_export_screen.dart';
import 'package:pool_os_v2/beta/presentation/screens/black_box_settings_tile.dart';
import 'package:pool_os_v2/beta/providers/black_box_provider.dart';
import 'package:pool_os_v2/beta/providers/providers.dart';

import 'black_box_export_widget_test.dart' show FakeBlackBoxProvider;

Future<void> pumpWidgetUnderTest(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(child: MaterialApp(home: Scaffold(body: child))),
  );
  await tester.pump();
}

void main() {
  group('BlackBoxSettingsTile — ô mở Black Box trong Cài đặt', () {
    testWidgets('hiện tên và mô tả, không phải ô trống', (tester) async {
      await pumpWidgetUnderTest(tester, const BlackBoxSettingsTile());

      expect(find.text('Hộp đen (Black Box) PoolOS'), findsOneWidget);
      expect(find.text('Xuất gói dữ liệu Coach'), findsOneWidget);
    });

    testWidgets('có huy hiệu phiên bản', (tester) async {
      await pumpWidgetUnderTest(tester, const BlackBoxSettingsTile());

      expect(find.text('v2.0'), findsOneWidget,
          reason: 'người thử beta cần biết đang dùng bản nào');
    });

    testWidgets('bấm được — là lối vào màn Black Box', (tester) async {
      await pumpWidgetUnderTest(tester, const BlackBoxSettingsTile());

      expect(find.byType(InkWell), findsAtLeastNWidgets(1));
    });
  });

  group('BlackBoxInfoCard — thẻ giải thích', () {
    testWidgets('nói rõ hộp đen là gì', (tester) async {
      await pumpWidgetUnderTest(tester, const BlackBoxInfoCard());

      expect(find.text('Về hộp đen'), findsOneWidget);
      expect(
        find.textContaining('ảnh chụp đầy đủ trạng thái Coach AI'),
        findsOneWidget,
      );
    });

    testWidgets('cam kết riêng tư phải hiện ra', (tester) async {
      await pumpWidgetUnderTest(tester, const BlackBoxInfoCard());

      // Đây là lời hứa với người dùng beta, không được lặng lẽ biến mất.
      expect(find.textContaining('Không cần tài khoản'), findsOneWidget);
      expect(find.textContaining('Ẩn danh'), findsOneWidget);
    });

    testWidgets('liệt kê các phần dữ liệu', (tester) async {
      await pumpWidgetUnderTest(tester, const BlackBoxInfoCard());

      for (final chip in const ['Buổi tập', 'Đề xuất', 'Dòng thời gian']) {
        expect(find.text(chip), findsOneWidget, reason: 'thiếu chip "$chip"');
      }
    });
  });

  group('Phiếu góp ý mở từ nút xuất', () {
    Future<void> openFeedback(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            blackBoxProvider.overrideWith(
              (ref) => FakeBlackBoxProvider(BlackBoxState.ready),
            ),
          ],
          child: const MaterialApp(home: BlackBoxExportScreen()),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Xuất gói dữ liệu Coach'));
      await tester.pump();
      await tester.tap(find.text('Xuất gói dữ liệu Coach'));
      await tester.pumpAndSettle();
    }

    testWidgets('bấm nút xuất thì hiện phiếu góp ý trước', (tester) async {
      await openFeedback(tester);

      expect(find.text('Góp ý của bạn'), findsAtLeastNWidgets(1));
    });

    testWidgets('phiếu có cả đường bỏ qua lẫn đường gửi', (tester) async {
      await openFeedback(tester);

      // Bắt buộc góp ý mới được xuất thì người thử sẽ bỏ cuộc giữa chừng.
      expect(find.text('Bỏ qua'), findsOneWidget);
      expect(find.text('Gửi và xuất'), findsOneWidget);
    });

    testWidgets('có thang sao để chấm điểm', (tester) async {
      await openFeedback(tester);

      expect(
        find.byWidgetPredicate((w) =>
            w is Icon &&
            (w.icon == Icons.star || w.icon == Icons.star_border)),
        findsAtLeastNWidgets(5),
        reason: 'phiếu cần ít nhất một thang 5 sao',
      );
    });
  });
}
