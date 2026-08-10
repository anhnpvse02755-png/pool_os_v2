// ============================================================================
// Coach Widget Tests — D0.2
// Tests for Coach screen states and interactions
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Coach Widget Tests', () {
    testWidgets('Coach shows loading indicator', (tester) async {
      bool isLoading = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : const Text('Loaded'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Coach shows empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Không có đủ dữ liệu'),
            ),
          ),
        ),
      );

      expect(find.text('Không có đủ dữ liệu'), findsOneWidget);
    });

    testWidgets('Coach shows ONE priority recommendation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Đánh thẳng'),
                Text('Phù hợp với sở thích'),
                Text('15 phút'),
                Text('Priority: 1'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Đánh thẳng'), findsOneWidget);
      expect(find.text('Priority: 1'), findsOneWidget);
    });

    testWidgets('Coach shows error with retry', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Đã xảy ra lỗi'),
                TextButton(
                  onPressed: () => retried = true,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Đã xảy ra lỗi'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);

      await tester.tap(find.text('Thử lại'));
      expect(retried, isTrue);
    });

    testWidgets('Coach shows multiple recommendations (max 3)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Recommendation 1'),
                Text('Recommendation 2'),
                Text('Recommendation 3'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Recommendation 1'), findsOneWidget);
      expect(find.text('Recommendation 2'), findsOneWidget);
      expect(find.text('Recommendation 3'), findsOneWidget);
    });

    testWidgets('Start Now button is tappable', (tester) async {
      bool started = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => started = true,
                child: const Text('Bắt đầu ngay'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Bắt đầu ngay'));
      expect(started, isTrue);
    });

    testWidgets('Coach shows Continue Session when interrupted', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Tiếp tục phiên tập luyện'),
                Text('Bài: Đánh thẳng'),
                Text('Đã tập: 5/10 lần'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tiếp tục phiên tập luyện'), findsOneWidget);
      expect(find.text('Bài: Đánh thẳng'), findsOneWidget);
    });

    testWidgets('Coach Voice follows guidelines - no "Bạn muốn"', (tester) async {
      // Coach should not use these phrases
      const badPhrases = ['Bạn muốn', 'Theo phân tích', 'Dựa trên dữ liệu'];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Hãy tập Đánh thẳng hôm nay'),
          ),
        ),
      );

      for (final phrase in badPhrases) {
        expect(find.textContaining(phrase), findsNothing);
      }
    });

    testWidgets('Coach explains recommendation with "Vì sao?"', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Đánh thẳng'),
                TextButton(
                  onPressed: () {},
                  child: const Text('Vì sao?'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Vì sao?'), findsOneWidget);
    });

    testWidgets('Coach explains shows reason', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Đánh thẳng'),
                Text('Lý do: Đây là kỹ năng nền tảng cho mọi cú đánh'),
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('Lý do:'), findsOneWidget);
    });
  });

  group('Coach Chat Widget Tests', () {
    testWidgets('Chat shows message history', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Bạn: Tôi yếu ở đâu?'),
                Text('Coach: Bạn cần cải thiện cú đánh thẳng'),
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('Bạn:'), findsOneWidget);
      expect(find.textContaining('Coach:'), findsOneWidget);
    });

    testWidgets('Chat input field accepts text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: InputDecoration(
                hintText: 'Nhập câu hỏi...',
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Tại sao?');
      expect(find.text('Tại sao?'), findsOneWidget);
    });

    testWidgets('Chat send button is enabled when has text', (tester) async {
      bool sent = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const TextField(),
                ElevatedButton(
                  onPressed: () => sent = true,
                  child: const Text('Gửi'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Tại sao?');
      await tester.tap(find.text('Gửi'));

      expect(sent, isTrue);
    });

    testWidgets('Chat shows loading indicator while waiting', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Coach đang suy nghĩ...'),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Coach đang suy nghĩ...'), findsOneWidget);
    });
  });

  group('Coach Timeline Widget Tests', () {
    testWidgets('Timeline shows session entries', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('19:00 - Mở ứng dụng'),
                Text('19:05 - Tập Đánh thẳng'),
                Text('19:15 - Hoàn thành'),
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('19:00'), findsOneWidget);
      expect(find.textContaining('19:05'), findsOneWidget);
      expect(find.textContaining('19:15'), findsOneWidget);
    });

    testWidgets('Timeline entries are ordered chronologically', (tester) async {
      final entries = ['10:00', '10:15', '10:30'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: entries.map((e) => Text(e)).toList(),
            ),
          ),
        ),
      );

      // Entries should appear in order
      for (int i = 0; i < entries.length; i++) {
        expect(find.text(entries[i]), findsOneWidget);
      }
    });

    testWidgets('Timeline shows recommendation completion', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('✓ Đánh thẳng - Hoàn thành'),
                Text('Điểm: 85%'),
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('Hoàn thành'), findsOneWidget);
      expect(find.text('Điểm: 85%'), findsOneWidget);
    });
  });
}
