import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/presentation/widgets/icon_tile.dart';

Widget _wrap(Widget child, Brightness brightness) => MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('dùng Material icon, KHÔNG dùng emoji', (tester) async {
    await tester.pumpWidget(_wrap(
        const IconTile(icon: Icons.sports_bar, toneIndex: 0),
        Brightness.light));

    expect(find.byIcon(Icons.sports_bar), findsOneWidget);
    // Nếu có ai thay bằng emoji thì đây là chỗ chặn lại.
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('nền lấy đúng tông pastel theo toneIndex', (tester) async {
    await tester.pumpWidget(_wrap(
        const IconTile(icon: Icons.star, toneIndex: 2), Brightness.light));

    final container = tester.widget<Container>(
      find.byKey(const Key('icon-tile-container')),
    );
    expect((container.decoration as BoxDecoration).color,
        AppColors.pastelFor(2, Brightness.light));
  });

  testWidgets('cùng toneIndex cho màu khác nhau giữa sáng và tối',
      (tester) async {
    await tester.pumpWidget(_wrap(
        const IconTile(icon: Icons.star, toneIndex: 1), Brightness.dark));

    final container = tester.widget<Container>(
      find.byKey(const Key('icon-tile-container')),
    );
    expect((container.decoration as BoxDecoration).color,
        AppColors.pastelFor(1, Brightness.dark));
  });

  testWidgets('toneIndex vượt 5 thì lặp vòng, không lỗi', (tester) async {
    await tester.pumpWidget(_wrap(
        const IconTile(icon: Icons.star, toneIndex: 7), Brightness.light));

    expect(tester.takeException(), isNull);
  });
}
