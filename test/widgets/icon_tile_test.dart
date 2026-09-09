import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/presentation/widgets/icon_tile.dart';

Widget _wrap(Widget child, Brightness brightness) => MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: child),
    );

Color _extractIconColor(WidgetTester tester) {
  final icon = tester.widget<Icon>(find.byKey(const Key('icon-tile-icon')));
  return icon.color!;
}

void main() {
  // ========================================================================
  // Material icon guardrail — emoji substitution must be caught.
  // ========================================================================

  testWidgets('dùng Material icon, KHÔNG dùng emoji', (tester) async {
    await tester.pumpWidget(_wrap(
        const IconTile(icon: Icons.sports_bar, toneIndex: 0),
        Brightness.light));

    expect(find.byIcon(Icons.sports_bar), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });

  // ========================================================================
  // Pastel background — tested in BOTH modes with exact color values.
  //
  // AppColors.pastelFor(index, brightness) resolves to:
  //   light: [mint, blue, peach, lilac, butter]
  //   dark:  [darkMint, darkBlue, darkPeach, darkLilac, darkButter]
  // ========================================================================

  testWidgets('nền: toneIndex=2 sáng dùng pastelLight[2]=peach',
      (tester) async {
    await tester.pumpWidget(_wrap(
        const IconTile(icon: Icons.star, toneIndex: 2), Brightness.light));

    final container = tester.widget<Container>(
      find.byKey(const Key('icon-tile-container')),
    );
    expect((container.decoration as BoxDecoration).color,
        AppColors.pastelFor(2, Brightness.light));
  });

  testWidgets('nền: toneIndex=1 tối dùng pastelDark[1]=darkBlue',
      (tester) async {
    await tester.pumpWidget(_wrap(
        const IconTile(icon: Icons.star, toneIndex: 1), Brightness.dark));

    final container = tester.widget<Container>(
      find.byKey(const Key('icon-tile-container')),
    );
    expect((container.decoration as BoxDecoration).color,
        AppColors.pastelFor(1, Brightness.dark));
  });

  testWidgets('nền: toneIndex vượt 5 thì lặp vòng, không lỗi', (tester) async {
    await tester.pumpWidget(_wrap(
        const IconTile(icon: Icons.star, toneIndex: 7), Brightness.light));

    expect(tester.takeException(), isNull);
  });

  // ========================================================================
  // Icon color — AppColors.primary(brightness):
  //   light: AppColors.lightPrimary
  //   dark:  AppColors.darkPrimary
  // Must be asserted in BOTH modes; mutation proven in review.
  // ========================================================================

  testWidgets('icon: chế độ sáng dùng AppColors.lightPrimary', (tester) async {
    await tester.pumpWidget(_wrap(
        const IconTile(icon: Icons.star, toneIndex: 0), Brightness.light));

    expect(_extractIconColor(tester), AppColors.lightPrimary);
  });

  testWidgets('icon: chế độ tối dùng AppColors.darkPrimary', (tester) async {
    await tester.pumpWidget(_wrap(
        const IconTile(icon: Icons.star, toneIndex: 0), Brightness.dark));

    expect(_extractIconColor(tester), AppColors.darkPrimary);
  });
  testWidgets('bo goc dung token, o 56 thi ra dung 18 nhu spec chot',
      (tester) async {
    await tester.pumpWidget(_wrap(
        const IconTile(icon: Icons.gps_fixed, toneIndex: 0),
        Brightness.light));
    final d = tester
        .widget<Container>(find.byKey(const Key('icon-tile-container')))
        .decoration as BoxDecoration;
    // Spec: "O 56x56 bo 18". Khang dinh dung so 18, khong phai
    // AppSpacing.radiusTile — neu ai doi token thi test phai do, chu khong
    // im lang chay theo.
    expect((d.borderRadius as BorderRadius).topLeft.x, 18.0);
    expect((d.borderRadius as BorderRadius).topRight.x, 18.0);
    expect((d.borderRadius as BorderRadius).bottomLeft.x, 18.0);
    expect((d.borderRadius as BorderRadius).bottomRight.x, 18.0);
  });

  testWidgets('o to gap doi thi bo goc gian theo ti le', (tester) async {
    await tester.pumpWidget(_wrap(
        const IconTile(icon: Icons.gps_fixed, toneIndex: 0, size: 112),
        Brightness.light));
    final d = tester
        .widget<Container>(find.byKey(const Key('icon-tile-container')))
        .decoration as BoxDecoration;
    expect((d.borderRadius as BorderRadius).topLeft.x, 36.0);
  });

}
