import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/presentation/widgets/section_header.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('hiện tiêu đề', (tester) async {
    await tester.pumpWidget(_wrap(const SectionHeader(title: 'Thể thức')));
    expect(find.text('Thể thức'), findsOneWidget);
  });

  testWidgets('hiện phụ đề khi có', (tester) async {
    await tester.pumpWidget(_wrap(const SectionHeader(
        title: 'Ai là người bắn?', subtitle: 'Chạm vào người chơi.')));

    expect(find.text('Chạm vào người chơi.'), findsOneWidget);
  });

  testWidgets('không có phụ đề thì không chừa chỗ trống', (tester) async {
    await tester.pumpWidget(_wrap(const SectionHeader(title: 'Chỉ tiêu đề')));
    expect(find.byKey(const Key('section-header-subtitle')), findsNothing);
  });

  testWidgets('hiện badge số khi có step', (tester) async {
    await tester
        .pumpWidget(_wrap(const SectionHeader(title: 'Bước', step: 1)));

    expect(find.byKey(const Key('section-header-step')), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('không có step thì không hiện badge', (tester) async {
    await tester.pumpWidget(_wrap(const SectionHeader(title: 'Không bước')));
    expect(find.byKey(const Key('section-header-step')), findsNothing);
  });
}
