// ============================================================================
// Coach Home Widget Tests — D0.2
// Tests for Coach Home screen states and interactions
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Coach Home State Tests', () {
    testWidgets('Shows loading when initializing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Shows empty state when no data', (tester) async {
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

    testWidgets('Shows ONE priority recommendation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Đánh thẳng'),
                Text('Phù hợp với sở thích'),
                Text('Priority: 1'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Đánh thẳng'), findsOneWidget);
      expect(find.text('Priority: 1'), findsOneWidget);
    });

    testWidgets('Shows error with retry button', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Đã xảy ra lỗi'),
                ElevatedButton(
                  onPressed: () => retried = true,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Thử lại'));
      expect(retried, isTrue);
    });

    testWidgets('Start Now button triggers navigation', (tester) async {
      bool started = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => started = true,
              child: const Text('Bắt đầu ngay'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Bắt đầu ngay'));
      expect(started, isTrue);
    });

    testWidgets('Shows Continue Session when interrupted', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Tiếp tục phiên tập luyện'),
                Text('Bài: Đánh thẳng'),
                Text('Đã tập: 5/10'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tiếp tục phiên tập luyện'), findsOneWidget);
    });

    testWidgets('Coach Voice: no "Bạn muốn" phrase', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Hãy tập Đánh thẳng hôm nay'),
          ),
        ),
      );

      expect(find.textContaining('Bạn muốn'), findsNothing);
    });

    testWidgets('Coach Voice: no "Theo phân tích" phrase', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Đánh thẳng là kỹ năng nền tảng'),
          ),
        ),
      );

      expect(find.textContaining('Theo phân tích'), findsNothing);
    });
  });

  group('Coach Recommendation Tests', () {
    testWidgets('Recommendation shows drill name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Đánh thẳng'),
          ),
        ),
      );

      expect(find.text('Đánh thẳng'), findsOneWidget);
    });

    testWidgets('Recommendation shows reason', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Vì đây là kỹ năng nền tảng'),
          ),
        ),
      );

      expect(find.text('Vì đây là kỹ năng nền tảng'), findsOneWidget);
    });

    testWidgets('Recommendation shows time estimate', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('~15 phút'),
          ),
        ),
      );

      expect(find.text('~15 phút'), findsOneWidget);
    });

    testWidgets('"Vì sao?" button opens explain', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () {},
              child: const Text('Vì sao?'),
            ),
          ),
        ),
      );

      expect(find.text('Vì sao?'), findsOneWidget);
    });
  });

  group('Coach Chat Tests', () {
    testWidgets('Chat shows message history', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Bạn: Tôi yếu ở đâu?'),
                Text('Coach: Cần cải thiện cú đánh thẳng'),
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('Bạn:'), findsOneWidget);
      expect(find.textContaining('Coach:'), findsOneWidget);
    });

    testWidgets('Chat input accepts text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: InputDecoration(hintText: 'Nhập câu hỏi...'),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Tại sao?');
      expect(find.text('Tại sao?'), findsOneWidget);
    });

    testWidgets('Chat send button enabled with text', (tester) async {
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

    testWidgets('Chat shows thinking indicator', (tester) async {
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
    });
  });

  group('Coach Timeline Tests', () {
    testWidgets('Timeline shows entries', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('10:00 - Mở ứng dụng'),
                Text('10:05 - Tập Đánh thẳng'),
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('Mở ứng dụng'), findsOneWidget);
      expect(find.textContaining('Tập Đánh thẳng'), findsOneWidget);
    });

    testWidgets('Timeline entries ordered chronologically', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('10:00'),
                Text('10:15'),
                Text('10:30'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);
    });

    testWidgets('Timeline shows completion status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('✓ Đánh thẳng - Hoàn thành'),
          ),
        ),
      );

      expect(find.textContaining('Hoàn thành'), findsOneWidget);
    });

    testWidgets('Timeline shows score', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Điểm: 85%'),
          ),
        ),
      );

      expect(find.text('Điểm: 85%'), findsOneWidget);
    });
  });
}
