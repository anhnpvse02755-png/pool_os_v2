import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/presentation/widgets/bottom_action_bar.dart';

Widget _wrap(Widget child, [Brightness brightness = Brightness.light]) =>
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('hiện đủ nhãn và icon', (tester) async {
    await tester.pumpWidget(_wrap(BottomActionBar(actions: [
      BarAction(icon: Icons.refresh, label: 'Xóa chọn', onTap: () {}),
      BarAction(icon: Icons.undo, label: 'Hoàn tác', onTap: () {}),
    ])));

    expect(find.text('Xóa chọn'), findsOneWidget);
    expect(find.text('Hoàn tác'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('bấm gọi đúng callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(BottomActionBar(actions: [
      BarAction(icon: Icons.flag, label: 'Kết thúc', onTap: () => tapped = true),
    ])));

    await tester.tap(find.text('Kết thúc'));
    expect(tapped, isTrue);
  });

  testWidgets('onTap null thì hiển thị mờ', (tester) async {
    await tester.pumpWidget(_wrap(BottomActionBar(actions: [
      const BarAction(icon: Icons.undo, label: 'Hoàn tác'),
    ])));

    final opacity = tester.widget<Opacity>(
      find.byKey(const Key('bar-action-Hoàn tác')),
    );
    expect(opacity.opacity, lessThan(1.0));
  });

  testWidgets('onTap null thì bấm không nổ và không gọi gì', (tester) async {
    await tester.pumpWidget(_wrap(BottomActionBar(actions: [
      const BarAction(icon: Icons.undo, label: 'Hoàn tác'),
    ])));

    await tester.tap(find.text('Hoàn tác'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('có onTap thì hiển thị rõ, không mờ', (tester) async {
    await tester.pumpWidget(_wrap(BottomActionBar(actions: [
      BarAction(icon: Icons.undo, label: 'Hoàn tác', onTap: () {}),
    ])));

    final opacity = tester.widget<Opacity>(
      find.byKey(const Key('bar-action-Hoàn tác')),
    );
    expect(opacity.opacity, 1.0);
  });

  testWidgets('nền và viền theo chế độ sáng', (tester) async {
    await tester.pumpWidget(_wrap(BottomActionBar(actions: [
      BarAction(icon: Icons.undo, label: 'Hoàn tác', onTap: () {}),
    ])));

    final container = tester.widget<Container>(
      find.byKey(const Key('bottom-action-bar-container')),
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColors.surface(Brightness.light));
    expect(decoration.border, isNotNull);
  });

  testWidgets('nền và viền theo chế độ tối', (tester) async {
    await tester.pumpWidget(_wrap(
      BottomActionBar(actions: [
        BarAction(icon: Icons.undo, label: 'Hoàn tác', onTap: () {}),
      ]),
      Brightness.dark,
    ));

    final container = tester.widget<Container>(
      find.byKey(const Key('bottom-action-bar-container')),
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColors.surface(Brightness.dark));
    expect(
      (decoration.border as Border).top.color,
      AppColors.border(Brightness.dark),
    );
  });

  testWidgets('icon và nhãn dùng màu chính theo chế độ tối', (tester) async {
    await tester.pumpWidget(_wrap(
      BottomActionBar(actions: [
        BarAction(icon: Icons.undo, label: 'Hoàn tác', onTap: () {}),
      ]),
      Brightness.dark,
    ));

    final icon = tester.widget<Icon>(find.byIcon(Icons.undo));
    expect(icon.color, AppColors.primary(Brightness.dark));

    final text = tester.widget<Text>(find.text('Hoàn tác'));
    expect(text.style?.color, AppColors.primary(Brightness.dark));
  });

  testWidgets('danh sách rỗng không làm vỡ', (tester) async {
    await tester.pumpWidget(_wrap(const BottomActionBar(actions: [])));

    expect(tester.takeException(), isNull);
  });
}
