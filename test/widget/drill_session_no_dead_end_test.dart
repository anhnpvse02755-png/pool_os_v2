import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pool_os_v2/presentation/screens/training/drill_session_screen.dart';

/// Lỗi gốc: vào màn tập từ "Bắt đầu buổi tập" thì URL thiếu tham số `level`,
/// nên phiên không tự chạy. Thanh ghi nhận (VÀO BI / TRƯỢT) chỉ hiện khi phiên
/// đang chạy, và màn không có nút bắt đầu nào — người dùng đứng trước một màn
/// trống, không cách nào ghi nhận cú đánh.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpAt(WidgetTester tester, String location) async {
    SharedPreferences.setMockInitialValues({});
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/training/session/new',
          builder: (context, state) => DrillSessionScreen(
            drillCode: state.uri.queryParameters['drill'] ?? 'BT01',
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('Màn tập không được là ngõ cụt', () {
    testWidgets('thiếu tham số level thì vẫn có nút "Bắt đầu"', (tester) async {
      await pumpAt(tester, '/training/session/new?drill=BT01');

      expect(find.text('Bắt đầu'), findsOneWidget,
          reason: 'không có nút này thì người dùng kẹt trong màn trống');
    });

    testWidgets('trạng thái chờ nói rõ phải làm gì', (tester) async {
      await pumpAt(tester, '/training/session/new?drill=BT01');

      expect(find.text('Sẵn sàng bắt đầu!'), findsOneWidget);
      expect(find.textContaining('Bắt đầu'), findsAtLeastNWidgets(1));
    });

    testWidgets('khi phiên chưa chạy thì chưa có nút ghi nhận cú đánh',
        (tester) async {
      await pumpAt(tester, '/training/session/new?drill=BT01');

      // Đây là hành vi đúng — nút ghi nhận chỉ xuất hiện sau khi bắt đầu.
      // Test này khoá cặp "chưa chạy thì không có nút ghi nhận, nhưng PHẢI có
      // nút bắt đầu" lại với nhau.
      expect(find.text('VÀO BI'), findsNothing);
      expect(find.text('TRƯỢT'), findsNothing);
      expect(find.text('Bắt đầu'), findsOneWidget);
    });
  });
}
