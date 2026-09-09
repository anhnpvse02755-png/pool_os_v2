import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/core/theme/spacing.dart';
import 'package:pool_os_v2/presentation/widgets/pool_card.dart';

Widget _wrap(Widget child, Brightness brightness) => MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: child),
    );

BoxDecoration _decorationOf(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.byKey(const Key('pool-card-container')),
  );
  return container.decoration as BoxDecoration;
}

void main() {
  testWidgets('bo góc mềm theo radiusMd', (tester) async {
    await tester.pumpWidget(
        _wrap(const PoolCard(child: Text('x')), Brightness.light));

    final radius = _decorationOf(tester).borderRadius as BorderRadius;
    expect(radius.topLeft.x, AppSpacing.radiusMd);
  });

  testWidgets('chưa chọn dùng bề mặt chìm', (tester) async {
    await tester.pumpWidget(_wrap(
        const PoolCard(selected: false, child: Text('x')), Brightness.light));

    expect(_decorationOf(tester).color, AppColors.lightSurfaceRecessed);
  });

  testWidgets('đã chọn dùng bề mặt nổi', (tester) async {
    await tester.pumpWidget(_wrap(
        const PoolCard(selected: true, child: Text('x')), Brightness.light));

    expect(_decorationOf(tester).color, AppColors.lightSurface);
  });

  testWidgets('chế độ tối có viền vì shadow gần như vô hình', (tester) async {
    await tester.pumpWidget(
        _wrap(const PoolCard(child: Text('x')), Brightness.dark));

    expect(_decorationOf(tester).border, isNotNull);
  });

  testWidgets('bấm được khi có onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(
      PoolCard(onTap: () => tapped = true, child: const Text('bấm')),
      Brightness.light,
    ));

    await tester.tap(find.text('bấm'));
    expect(tapped, isTrue);
  });

  testWidgets('không có onTap thì không bọc InkWell', (tester) async {
    await tester.pumpWidget(
        _wrap(const PoolCard(child: Text('x')), Brightness.light));

    expect(find.byType(InkWell), findsNothing);
  });
}
