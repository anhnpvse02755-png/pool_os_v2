import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/presentation/widgets/score_bar.dart';

Widget _wrap(Widget child, Brightness brightness) => MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: child),
    );

/// Vạch ngăn mang key có index (`score-bar-divider-1`, `-2`, ...) vì Flutter
/// cấm nhiều widget con cùng một cha dùng chung một Key.
final _dividers = find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key as ValueKey<String>).value.startsWith('score-bar-divider'),
);

void main() {
  const players = [
    ScorePlayer(name: 'Vanh', score: 3),
    ScorePlayer(name: 'Hưng', score: 0),
    ScorePlayer(name: 'Hiệp', score: 5),
  ];

  testWidgets('hiện tên và điểm của mọi người chơi', (tester) async {
    await tester
        .pumpWidget(_wrap(const ScoreBar(players: players), Brightness.light));

    expect(find.text('Vanh'), findsOneWidget);
    expect(find.text('Hưng'), findsOneWidget);
    expect(find.text('Hiệp'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('nền là xanh rêu đậm', (tester) async {
    await tester
        .pumpWidget(_wrap(const ScoreBar(players: players), Brightness.light));

    final container = tester.widget<Container>(
      find.byKey(const Key('score-bar-container')),
    );
    expect((container.decoration as BoxDecoration).color,
        AppColors.primaryContainer(Brightness.light));
  });

  testWidgets('chế độ tối dùng bản primaryContainer tối', (tester) async {
    await tester
        .pumpWidget(_wrap(const ScoreBar(players: players), Brightness.dark));

    final container = tester.widget<Container>(
      find.byKey(const Key('score-bar-container')),
    );
    expect((container.decoration as BoxDecoration).color,
        AppColors.primaryContainer(Brightness.dark));
  });

  testWidgets('có vạch ngăn giữa các người chơi, ít hơn số người 1',
      (tester) async {
    await tester
        .pumpWidget(_wrap(const ScoreBar(players: players), Brightness.light));

    expect(_dividers, findsNWidgets(2));
  });

  testWidgets('một người chơi thì không có vạch ngăn nào', (tester) async {
    await tester.pumpWidget(_wrap(
        const ScoreBar(players: [ScorePlayer(name: 'Một', score: 1)]),
        Brightness.light));

    expect(_dividers, findsNothing);
  });

  testWidgets('danh sách rỗng không làm vỡ', (tester) async {
    await tester
        .pumpWidget(_wrap(const ScoreBar(players: []), Brightness.light));

    expect(tester.takeException(), isNull);
  });

  testWidgets('hiện icon của người chơi khi có', (tester) async {
    await tester.pumpWidget(_wrap(
        const ScoreBar(players: [
          ScorePlayer(name: 'Vanh', score: 2, icon: Icons.sports_bar),
        ]),
        Brightness.light));

    expect(find.byIcon(Icons.sports_bar), findsOneWidget);
  });

  testWidgets('không có icon thì không vẽ Icon nào', (tester) async {
    await tester.pumpWidget(_wrap(
        const ScoreBar(players: [ScorePlayer(name: 'Vanh', score: 2)]),
        Brightness.light));

    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('bo góc theo radiusMd', (tester) async {
    await tester
        .pumpWidget(_wrap(const ScoreBar(players: players), Brightness.light));

    final container = tester.widget<Container>(
      find.byKey(const Key('score-bar-container')),
    );
    final radius =
        (container.decoration as BoxDecoration).borderRadius as BorderRadius;
    expect(radius.topLeft.x, 20.0);
  });
}
