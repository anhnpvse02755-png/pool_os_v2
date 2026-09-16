import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pool_os_v2/core/theme/app_theme.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/presentation/widgets/buttons/primary_button.dart';

/// Lỗ cuối của đợt "Kem ấm & Xanh rêu": `ThemeData`.
///
/// Mười luật vệ sinh token ĐỌC MÃ NGUỒN — chúng bắt `AppColors.lightFoo`,
/// `Colors.*`, hex thô. Không luật nào bắt được
/// `Theme.of(context).colorScheme.primary`, vì đó là một lời gọi hợp lệ tới
/// một token hợp lệ; cái sai nằm ở GIÁ TRỊ mà `ColorScheme` được nạp.
/// Nên xanh điện #3B82F6 sống sót qua cả sáu lô A–F ngay giữa gốc theme và
/// chảy ra 24 màn qua `PrimaryButton`, 56 `ElevatedButton`, 50 `TextButton`.
///
/// Bộ test này canh GIÁ TRỊ trong `ThemeData`, không canh cách viết.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Mọi sắc xanh điện của họ `accent`. Không màu nào trong số này được phép
/// xuất hiện trong `ThemeData` nữa.
const _electricBlues = <String, Color>{
  'accent': AppColors.accent,
  'accentLight': AppColors.accentLight,
  'accentDark': AppColors.accentDark,
  'accentSubtleLight': AppColors.accentSubtleLight,
  'accentSubtleDark': AppColors.accentSubtleDark,
};

/// Các điểm trong `ThemeData` mà xanh điện từng rò ra giao diện.
Map<String, Color?> _paintedColors(ThemeData t) {
  final selected = <WidgetState>{WidgetState.selected};
  return {
    'colorScheme.primary': t.colorScheme.primary,
    'colorScheme.primaryContainer': t.colorScheme.primaryContainer,
    'colorScheme.onPrimaryContainer': t.colorScheme.onPrimaryContainer,
    'bottomNavigationBar.selectedItemColor':
        t.bottomNavigationBarTheme.selectedItemColor,
    'navigationBar.indicatorColor': t.navigationBarTheme.indicatorColor,
    'navigationBar.labelTextStyle(selected)':
        t.navigationBarTheme.labelTextStyle?.resolve(selected)?.color,
    'navigationBar.iconTheme(selected)':
        t.navigationBarTheme.iconTheme?.resolve(selected)?.color,
    'elevatedButton.backgroundColor': t.elevatedButtonTheme.style?.backgroundColor
        ?.resolve(const <WidgetState>{}),
    'textButton.foregroundColor':
        t.textButtonTheme.style?.foregroundColor?.resolve(const <WidgetState>{}),
    'inputDecoration.focusedBorder':
        t.inputDecorationTheme.focusedBorder?.borderSide.color,
    'chip.selectedColor': t.chipTheme.selectedColor,
    'progressIndicator.color': t.progressIndicatorTheme.color,
    'switch.trackColor(selected)': t.switchTheme.trackColor?.resolve(selected),
    'switch.thumbColor(selected)': t.switchTheme.thumbColor?.resolve(selected),
    'tabBar.labelColor': t.tabBarTheme.labelColor,
    'tabBar.indicator': t.tabBarTheme.indicatorColor,
  };
}

/// `AppTheme.lightTheme` gọi GoogleFonts, vốn cần binding đã khởi tạo — nên
/// theme phải dựng TRONG thân test, không phải ở thân `main()`.
///
/// GoogleFonts nạp font BẤT ĐỒNG BỘ và trong test thì việc nạp luôn hỏng. Lỗi
/// ấy nổ sau khi test gọi nó đã kết thúc, nên nó làm đỏ test KẾ TIẾP với dòng
/// "This test failed after it had already completed" — mọi assertion vẫn đúng.
/// Bọc trong zone riêng để lỗi font ở lại đúng chỗ nó sinh ra.
ThemeData _themeFor(Brightness b) {
  late ThemeData theme;
  runZonedGuarded(
    () => theme = b == Brightness.light ? AppTheme.lightTheme : AppTheme.darkTheme,
    (_, _) {},
  );
  return theme;
}

const _brightnesses = [Brightness.light, Brightness.dark];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // `_buildTextTheme` gọi GoogleFonts, vốn tải font qua HTTP. Trong test không
  // có mạng nên nó ném lỗi BẤT ĐỒNG BỘ, và lỗi đó rơi vào bất kỳ test nào
  // đang chạy dở — 22 test đỏ dù mọi assertion đều đúng. Tắt tải lúc chạy thì
  // google_fonts quay về nhánh bắt lỗi của chính nó và chỉ in cảnh báo.
  GoogleFonts.config.allowRuntimeFetching = false;

  group('gốc ThemeData không còn xanh điện', () {
    for (final b in _brightnesses) {
      test('$b: colorScheme.primary là xanh rêu', () {
        expect(_themeFor(b).colorScheme.primary, AppColors.primary(b));
      });

      test('$b: không điểm sơn nào mang màu họ accent', () {
        final painted = _paintedColors(_themeFor(b));
        for (final p in painted.entries) {
          for (final blue in _electricBlues.entries) {
            expect(p.value, isNot(blue.value),
                reason: '${p.key} vẫn là ${blue.key} — xanh điện rò ra giao diện');
          }
        }
      });
    }
  });

  group('tương phản tại các điểm vừa đổi — kiểm CẢ HAI chiều', () {
    for (final b in _brightnesses) {
      test('$b: chữ onPrimary đọc được trên nền primary', () {
        final cs = _themeFor(b).colorScheme;
        expect(_contrast(cs.primary, cs.onPrimary),
            greaterThanOrEqualTo(4.5),
            reason: 'Nhãn nút CTA nằm trên nền primary');
      });

      test('$b: chữ onPrimaryContainer đọc được trên primaryContainer', () {
        final cs = _themeFor(b).colorScheme;
        expect(_contrast(cs.primaryContainer, cs.onPrimaryContainer),
            greaterThanOrEqualTo(4.5));
      });

      test('$b: chữ onSecondary đọc được trên nền secondary', () {
        final cs = _themeFor(b).colorScheme;
        expect(_contrast(cs.secondary, cs.onSecondary),
            greaterThanOrEqualTo(4.5),
            reason: 'secondary là gold #A67C00 — chữ trắng chỉ đạt 3,82');
      });

      test('$b: nhãn ElevatedButton đọc được trên nền của chính nó', () {
        final theme = _themeFor(b);
        final style = theme.elevatedButtonTheme.style!;
        const empty = <WidgetState>{};
        expect(
          _contrast(style.backgroundColor!.resolve(empty)!,
              style.foregroundColor!.resolve(empty)!),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('$b: nhãn TextButton đọc được trên nền nút bấm nằm', () {
        final theme = _themeFor(b);
        final fg = theme.textButtonTheme.style!.foregroundColor!
            .resolve(const <WidgetState>{})!;
        expect(_contrast(theme.scaffoldBackgroundColor, fg),
            greaterThanOrEqualTo(4.5));
        expect(_contrast(theme.colorScheme.surface, fg),
            greaterThanOrEqualTo(4.5));
      });

      test('$b: nhãn NavigationBar đã chọn đọc được trên indicator', () {
        final nav = _themeFor(b).navigationBarTheme;
        const selected = <WidgetState>{WidgetState.selected};
        final label = nav.labelTextStyle!.resolve(selected)!.color!;
        final icon = nav.iconTheme!.resolve(selected)!.color!;
        expect(_contrast(nav.indicatorColor!, label),
            greaterThanOrEqualTo(4.5));
        expect(_contrast(nav.indicatorColor!, icon),
            greaterThanOrEqualTo(4.5));
      });

      test('$b: nhãn chip đã chọn đọc được trên nền chip đã chọn', () {
        final theme = _themeFor(b);
        // `labelStyle` không đặt màu nên Material lấy `onSurface`.
        final label =
            theme.chipTheme.labelStyle?.color ?? theme.colorScheme.onSurface;
        expect(_contrast(theme.chipTheme.selectedColor!, label),
            greaterThanOrEqualTo(4.5));
      });

      test('$b: mục đã chọn ở bottom nav đọc được trên thanh nav', () {
        final nav = _themeFor(b).bottomNavigationBarTheme;
        expect(_contrast(nav.backgroundColor!, nav.selectedItemColor!),
            greaterThanOrEqualTo(4.5));
      });

      test('$b: núm switch đã bật đọc được trên rãnh đã bật', () {
        final theme = _themeFor(b);
        const selected = <WidgetState>{WidgetState.selected};
        expect(
          _contrast(theme.switchTheme.trackColor!.resolve(selected)!,
              theme.switchTheme.thumbColor!.resolve(selected)!),
          greaterThanOrEqualTo(3.0),
          reason: 'Núm/rãnh là thành phần giao diện — sàn 3:1',
        );
      });
    }
  });

  group('PrimaryButton — nút CTA của 24 màn', () {
    for (final b in _brightnesses) {
      testWidgets('$b: tô nền bằng xanh rêu', (tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: _themeFor(b),
          home: Scaffold(
            body: PrimaryButton(label: 'Bắt đầu', onPressed: () {}),
          ),
        ));

        final filled = tester
            .widgetList<Container>(find.descendant(
              of: find.byType(PrimaryButton),
              matching: find.byType(Container),
            ))
            .where((c) => c.decoration is BoxDecoration)
            .map((c) => (c.decoration as BoxDecoration).color)
            .whereType<Color>()
            .toList();

        expect(filled, isNotEmpty, reason: 'Không tìm thấy nền của nút');
        expect(filled.first, AppColors.primary(b));
      });
    }
  });
}
