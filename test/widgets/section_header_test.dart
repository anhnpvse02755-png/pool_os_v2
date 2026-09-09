import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/presentation/widgets/section_header.dart';

Widget _wrap(Widget child, Brightness brightness) => MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: child),
    );

/// Extracts the Text widget rendered color from a Text widget found by key.
Color _extractTextColor(WidgetTester tester, Key key) {
  final text = tester.widget<Text>(find.byKey(key));
  return text.style!.color!;
}

/// Extracts the Container background color from a widget found by key.
Color _extractContainerColor(WidgetTester tester, Key key) {
  final container = tester.widget<Container>(find.byKey(key));
  return (container.decoration as BoxDecoration).color!;
}

void main() {
  // ========================================================================
  // Light mode tests
  // ========================================================================

  testWidgets('hiện tiêu đề', (tester) async {
    await tester.pumpWidget(_wrap(
        const SectionHeader(title: 'Thể thức'), Brightness.light));
    expect(find.text('Thể thức'), findsOneWidget);
  });

  testWidgets('hiện phụ đề khi có', (tester) async {
    await tester.pumpWidget(_wrap(
      const SectionHeader(
          title: 'Ai là người bắn?', subtitle: 'Chạm vào người chơi.'),
      Brightness.light,
    ));

    expect(find.text('Chạm vào người chơi.'), findsOneWidget);
  });

  testWidgets('không có phụ đề thì không chừa chỗ trống', (tester) async {
    await tester.pumpWidget(
        _wrap(const SectionHeader(title: 'Chỉ tiêu đề'), Brightness.light));
    expect(find.byKey(const Key('section-header-subtitle')), findsNothing);
  });

  testWidgets('hiện badge số khi có step', (tester) async {
    await tester.pumpWidget(
        _wrap(const SectionHeader(title: 'Bước', step: 1), Brightness.light));

    expect(find.byKey(const Key('section-header-step')), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('không có step thì không hiện badge', (tester) async {
    await tester.pumpWidget(
        _wrap(const SectionHeader(title: 'Không bước'), Brightness.light));
    expect(find.byKey(const Key('section-header-step')), findsNothing);
  });

  // ========================================================================
  // Dark mode tests — coordinator mandate: every brightness-dependent color
  // must be asserted with its EXACT value in BOTH modes.
  //
  // Colors used by SectionHeader:
  //   AppColors.textPrimary(brightness) — title text color (always rendered)
  //   AppColors.textSecondary(brightness) — subtitle text color (if subtitle != null)
  //   AppColors.primary(brightness) — step badge background (if step != null)
  // ========================================================================

  testWidgets('chế độ sáng: title dùng AppColors.lightTextPrimary',
      (tester) async {
    await tester.pumpWidget(
        _wrap(const SectionHeader(title: 'Tiêu đề'), Brightness.light));

    expect(_extractTextColor(tester, const Key('section-header-title')),
        AppColors.lightTextPrimary);
  });

  testWidgets('chế độ tối: title dùng AppColors.darkTextPrimary',
      (tester) async {
    await tester.pumpWidget(
        _wrap(const SectionHeader(title: 'Tiêu đề'), Brightness.dark));

    expect(_extractTextColor(tester, const Key('section-header-title')),
        AppColors.darkTextPrimary);
  });

  testWidgets('chế độ sáng: subtitle dùng AppColors.lightTextSecondary',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const SectionHeader(title: 'T', subtitle: 'Phụ đề sáng'),
      Brightness.light,
    ));

    expect(_extractTextColor(tester, const Key('section-header-subtitle')),
        AppColors.lightTextSecondary);
  });

  testWidgets('chế độ tối: subtitle dùng AppColors.darkTextSecondary',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const SectionHeader(title: 'T', subtitle: 'Phụ đề tối'),
      Brightness.dark,
    ));

    expect(_extractTextColor(tester, const Key('section-header-subtitle')),
        AppColors.darkTextSecondary);
  });

  testWidgets('chế độ sáng: step badge dùng AppColors.lightPrimary',
      (tester) async {
    await tester.pumpWidget(
        _wrap(const SectionHeader(title: 'T', step: 3), Brightness.light));

    expect(_extractContainerColor(tester, const Key('section-header-step')),
        AppColors.lightPrimary);
  });

  testWidgets('chế độ tối: step badge dùng AppColors.darkPrimary',
      (tester) async {
    await tester.pumpWidget(
        _wrap(const SectionHeader(title: 'T', step: 3), Brightness.dark));

    expect(_extractContainerColor(tester, const Key('section-header-step')),
        AppColors.darkPrimary);
  });
}
