import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/presentation/screens/coach/coach_chat_screen.dart'
    show ChatMessage;
import 'package:pool_os_v2/presentation/widgets/coach/coach_chat_bubble.dart';
// Ba lop cung ten `CoachRecommendation` ton tai trong repo; ban ma chuoi chat
// dung la ban khai trong `recommendation_card.dart` — xem
// `coach_provider.dart:23`, no `hide` ban cua coach_service.
import 'package:pool_os_v2/presentation/widgets/coach/recommendation_card.dart';

/// Thay cho `coach_widget_test.dart` — tệp đó có 20 test **rỗng**: mỗi test tự
/// dựng `MaterialApp` với `Text` hằng ngay trong thân test rồi khẳng định tìm
/// thấy đúng chuỗi đó. Chúng kiểm `find.text` của Flutter, không chạm mã ứng
/// dụng nào, nên không bao giờ đỏ được dù màn Coach hỏng thế nào.
///
/// Bộ này pump widget THẬT.
ChatMessage _tin({
  String content = 'Hôm nay nên tập gì?',
  bool isUser = true,
  CoachRecommendation? goiY,
}) =>
    ChatMessage(
      content: content,
      isUser: isUser,
      timestamp: DateTime(2026, 9, 16, 19, 5),
      recommendation: goiY,
    );

CoachRecommendation _goiY() => CoachRecommendation(
      drillCode: 'BT07',
      drillName: 'Cú dừng bi (Stop)',
      reason: 'Nền tảng của mọi kiểm soát vị trí',
      outcomes: ['Bi cái dừng đúng chỗ'],
      estimatedMinutes: 15,
      confidence: 80,
      priority: 1,
    );

Future<void> _pump(
  WidgetTester tester,
  ChatMessage tin, {
  Brightness brightness = Brightness.light,
  VoidCallback? onTapWhy,
  VoidCallback? onTapRecommendation,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(brightness: brightness),
    home: Scaffold(
      body: CoachChatBubble(
        message: tin,
        onTapWhy: onTapWhy,
        onTapRecommendation: onTapRecommendation,
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

/// Nền đặc của bong bóng — Container duy nhất có màu tô.
Color _nenBongBong(WidgetTester tester) {
  final c = tester
      .widgetList<Container>(find.byType(Container))
      .map((w) => w.decoration)
      .whereType<BoxDecoration>()
      .firstWhere((d) => d.color != null && d.color!.a == 1.0);
  return c.color!;
}

void main() {
  group('bong bóng của NGƯỜI DÙNG', () {
    testWidgets('nằm bên phải và hiện đúng nội dung', (tester) async {
      await _pump(tester, _tin(content: 'Tôi yếu ở đâu?'));

      expect(find.text('Tôi yếu ở đâu?'), findsOneWidget);
      expect(tester.widget<Align>(find.byType(Align).first).alignment,
          Alignment.centerRight);
      // Không mang nhãn coach.
      expect(find.text('Huấn luyện viên'), findsNothing);
    });

    for (final b in [Brightness.light, Brightness.dark]) {
      testWidgets('$b: chữ đọc được trên nền bong bóng', (tester) async {
        await _pump(tester, _tin(), brightness: b);

        final chu = tester
            .widget<Text>(find.text('Hôm nay nên tập gì?'))
            .style!
            .color!;
        final nen = _nenBongBong(tester);
        final la = nen.computeLuminance();
        final lb = chu.computeLuminance();
        final hi = la > lb ? la : lb;
        final lo = la > lb ? lb : la;
        expect((hi + 0.05) / (lo + 0.05), greaterThanOrEqualTo(4.5),
            reason: 'Chữ 15px trên nền primary — sàn 4,5:1');
      });
    }
  });

  group('bong bóng của COACH', () {
    testWidgets('nằm bên trái và mang nhãn huấn luyện viên', (tester) async {
      await _pump(tester, _tin(content: 'Tập cú dừng bi.', isUser: false));

      expect(find.text('Huấn luyện viên'), findsOneWidget);
      expect(find.text('Tập cú dừng bi.'), findsOneWidget);
      expect(tester.widget<Align>(find.byType(Align).first).alignment,
          Alignment.centerLeft);
    });

    testWidgets('không có gợi ý thì không hiện thẻ lẫn nút', (tester) async {
      await _pump(tester, _tin(isUser: false),
          onTapWhy: () {}, onTapRecommendation: () {});

      expect(find.text('Tại sao?'), findsNothing);
      expect(find.text('Bắt đầu'), findsNothing);
    });

    testWidgets('có gợi ý thì hiện tên bài và cả hai nút', (tester) async {
      await _pump(tester, _tin(isUser: false, goiY: _goiY()),
          onTapWhy: () {}, onTapRecommendation: () {});

      expect(find.text('Cú dừng bi (Stop)'), findsOneWidget);
      expect(find.text('Tại sao?'), findsOneWidget);
      expect(find.text('Bắt đầu'), findsOneWidget);
    });

    testWidgets('bấm "Bắt đầu" và "Tại sao?" gọi đúng callback',
        (tester) async {
      var batDau = 0;
      var taiSao = 0;
      await _pump(tester, _tin(isUser: false, goiY: _goiY()),
          onTapWhy: () => taiSao++, onTapRecommendation: () => batDau++);

      await tester.tap(find.text('Bắt đầu'));
      await tester.tap(find.text('Tại sao?'));
      await tester.pump();

      expect(batDau, 1);
      expect(taiSao, 1);
    });

    // Nút nào không có callback thì không được vẽ ra: nút bấm không phản hồi
    // tệ hơn nút vắng mặt.
    testWidgets('thiếu callback thì nút tương ứng không xuất hiện',
        (tester) async {
      await _pump(tester, _tin(isUser: false, goiY: _goiY()),
          onTapRecommendation: () {});

      expect(find.text('Tại sao?'), findsNothing);
      expect(find.text('Bắt đầu'), findsOneWidget);
    });
  });
}
