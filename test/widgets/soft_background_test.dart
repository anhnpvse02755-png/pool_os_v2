import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/presentation/widgets/soft_background.dart';

Widget _wrap(Widget child, Brightness brightness) => MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('dùng nền kem ở chế độ sáng', (tester) async {
    await tester.pumpWidget(
        _wrap(const SoftBackground(child: Text('x')), Brightness.light));

    final container = tester.widget<Container>(
      find.byKey(const Key('soft-background-ground')),
    );
    expect((container.decoration as BoxDecoration).color,
        AppColors.lightBackground);
  });

  testWidgets('dùng nền than ám xanh ở chế độ tối', (tester) async {
    await tester.pumpWidget(
        _wrap(const SoftBackground(child: Text('x')), Brightness.dark));

    final container = tester.widget<Container>(
      find.byKey(const Key('soft-background-ground')),
    );
    expect((container.decoration as BoxDecoration).color,
        AppColors.darkBackground);
  });

  testWidgets('vẽ 3 blob và vẫn hiện child', (tester) async {
    await tester.pumpWidget(
        _wrap(const SoftBackground(child: Text('nội dung')), Brightness.light));

    expect(find.byKey(const Key('soft-background-blobs')), findsOneWidget);
    expect(find.text('nội dung'), findsOneWidget);
  });
}
