# Redesign "Kem ấm & Xanh rêu" — Kế hoạch giai đoạn 1

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Đổi tầng token màu/hình khối sang ngôn ngữ kem ấm + xanh rêu, dựng 6 component dùng chung, và quét lô màn đầu tiên (onboarding + auth) làm khuôn mẫu cho 7 lô sau.

**Architecture:** Ba lớp xếp chồng. Lớp token đổi hex tại chỗ trong `AppColors` — vì file này dùng cặp `lightX`/`darkX` cộng accessor `X(Brightness)`, đổi giá trị sẽ lan tự động tới mọi màn KHÔNG hardcode. Lớp component gom 6 widget dùng chung để việc quét 68 màn thành cơ học. Lớp quét sửa từng lô màn, đồng thời chuyển `AppColors.lightFoo` → `AppColors.foo(brightness)` — việc bắt buộc cho dark mode.

**Tech Stack:** Flutter 3.47.0 · Dart 3.12.2 · flutter_riverpod · google_fonts (Plus Jakarta Sans) · flutter_test

**Spec:** `docs/superpowers/specs/2026-09-09-warm-green-redesign-design.md`

## Global Constraints

- **KHÔNG dùng emoji làm icon.** Dùng Material icon đặt trong ô pastel.
- **KHÔNG đổi font.** Giữ `GoogleFonts.plusJakartaSans()`.
- **KHÔNG bật `ThemeMode.system`** cho tới khi lô 8 xong. `main.dart:137` giữ nguyên `ThemeMode.light` trong suốt giai đoạn này.
- **Mọi màn đã quét phải dùng `AppColors.foo(brightness)`**, không được để lại `AppColors.lightFoo`.
- Thang bo góc mới: `radiusSm = 12`, `radiusMd = 20`, `radiusLg = 28`, `radiusFull = 9999`.
- Màu chính sáng `#0F4032`, tối `#34A97C`.
- Nền sáng `#F7F4EC`, tối `#121715`.
- Sau mỗi task: `flutter test` phải xanh toàn bộ (hiện 488 test).
- E2E dựa vào nhãn `"Bắt đầu ngay"`, `"Tôi đã có tài khoản"`, `"Tiếp tục"`, `"Bắt đầu"` — **không đổi các chuỗi này**; nếu buộc phải đổi thì sửa `pages/*.ts` trong cùng task.

---

## Cấu trúc file

| File | Trách nhiệm |
|---|---|
| `lib/core/theme/colors.dart` | Sửa: bảng màu sáng/tối mới + bảng pastel |
| `lib/core/theme/spacing.dart` | Sửa: thang bo góc |
| `lib/core/theme/shadows.dart` | Sửa: shadow mềm hơn |
| `lib/core/theme/typography.dart` | Sửa: cỡ + độ đậm tiêu đề |
| `lib/presentation/widgets/soft_background.dart` | Tạo: nền + blob |
| `lib/presentation/widgets/pool_card.dart` | Tạo: thẻ bo lớn |
| `lib/presentation/widgets/icon_tile.dart` | Tạo: ô pastel chứa icon |
| `lib/presentation/widgets/section_header.dart` | Tạo: tiêu đề mục |
| `lib/presentation/widgets/score_bar.dart` | Tạo: thanh điểm nhiều người |
| `lib/presentation/widgets/bottom_action_bar.dart` | Tạo: thanh hành động dưới |
| `test/theme/design_tokens_test.dart` | Tạo: khoá giá trị token |
| `test/widgets/*_test.dart` | Tạo: 6 widget test |

---

### Task 1: Token màu

**Files:**
- Modify: `lib/core/theme/colors.dart`
- Test: `test/theme/design_tokens_test.dart`

**Interfaces:**
- Consumes: không
- Produces: `AppColors.lightBackground`, `AppColors.darkBackground`, `AppColors.primary(Brightness)`, `AppColors.pastelFor(int index, Brightness)` — các accessor `background/surface/textPrimary/...(Brightness)` đã có sẵn, giữ nguyên chữ ký.

- [ ] **Step 1: Viết test khoá giá trị token**

Tạo `test/theme/design_tokens_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';

void main() {
  group('Bảng màu sáng', () {
    test('nền là kem ấm, không phải trắng xám', () {
      expect(AppColors.lightBackground, const Color(0xFFF7F4EC));
    });

    test('màu chính là xanh rêu đậm', () {
      expect(AppColors.primary(Brightness.light), const Color(0xFF0F4032));
    });

    test('có bề mặt chìm cho thẻ chưa chọn', () {
      expect(AppColors.lightSurfaceRecessed, const Color(0xFFF1EFEA));
    });
  });

  group('Bảng màu tối', () {
    test('nền là than ám xanh, KHÔNG phải đen thuần', () {
      expect(AppColors.darkBackground, const Color(0xFF121715));
      expect(AppColors.darkBackground, isNot(const Color(0xFF000000)));
    });

    test('xanh chính sáng hơn bản sáng để đọc được trên nền tối', () {
      final light = AppColors.primary(Brightness.light);
      final dark = AppColors.primary(Brightness.dark);
      expect(dark, const Color(0xFF34A97C));
      expect(dark.computeLuminance(), greaterThan(light.computeLuminance()));
    });
  });

  group('Ô pastel', () {
    test('có đúng 5 tông cho mỗi chế độ', () {
      expect(AppColors.pastelLight, hasLength(5));
      expect(AppColors.pastelDark, hasLength(5));
    });

    test('pastelFor lặp vòng, không bao giờ vượt mảng', () {
      for (var i = 0; i < 12; i++) {
        expect(AppColors.pastelFor(i, Brightness.light), isA<Color>());
      }
      expect(AppColors.pastelFor(0, Brightness.light),
          AppColors.pastelFor(5, Brightness.light));
    });

    test('tông tối sẫm hơn tông sáng tương ứng', () {
      for (var i = 0; i < 5; i++) {
        expect(
          AppColors.pastelFor(i, Brightness.dark).computeLuminance(),
          lessThan(AppColors.pastelFor(i, Brightness.light).computeLuminance()),
        );
      }
    });
  });

  group('Tương phản chữ', () {
    double contrast(Color a, Color b) {
      final l1 = a.computeLuminance(), l2 = b.computeLuminance();
      final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
      return (hi + 0.05) / (lo + 0.05);
    }

    test('chữ chính trên nền đạt tối thiểu 7:1 ở cả hai chế độ', () {
      expect(
        contrast(AppColors.lightTextPrimary, AppColors.lightBackground),
        greaterThanOrEqualTo(7.0),
      );
      expect(
        contrast(AppColors.darkTextPrimary, AppColors.darkBackground),
        greaterThanOrEqualTo(7.0),
      );
    });

    test('chữ phụ trên nền đạt tối thiểu 4.5:1', () {
      expect(
        contrast(AppColors.lightTextSecondary, AppColors.lightBackground),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(AppColors.darkTextSecondary, AppColors.darkBackground),
        greaterThanOrEqualTo(4.5),
      );
    });
  });
}
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

Run: `flutter test test/theme/design_tokens_test.dart`
Expected: FAIL — `lightSurfaceRecessed`, `pastelLight`, `pastelDark`, `pastelFor`, `primary` chưa tồn tại.

- [ ] **Step 3: Sửa giá trị màu trong `colors.dart`**

Đổi các hằng có sẵn (giữ nguyên tên để không vỡ call site):

```dart
  // ---- SÁNG ----
  static const Color lightBackground = Color(0xFFF7F4EC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightSurfaceRecessed = Color(0xFFF1EFEA);
  static const Color lightTextPrimary = Color(0xFF12352B);
  static const Color lightTextSecondary = Color(0xFF5E6661);
  static const Color lightTextTertiary = Color(0xFF9AA39D);
  static const Color lightBorder = Color(0xFFE7E3DA);
  static const Color lightBorderSubtle = Color(0xFFF0EDE5);

  // ---- TỐI ----
  static const Color darkBackground = Color(0xFF121715);
  static const Color darkSurface = Color(0xFF1B221F);
  static const Color darkSurfaceElevated = Color(0xFF232B27);
  static const Color darkSurfaceRecessed = Color(0xFF171D1A);
  static const Color darkTextPrimary = Color(0xFFECF1EE);
  static const Color darkTextSecondary = Color(0xFF9AA6A0);
  static const Color darkTextTertiary = Color(0xFF6F7B75);
  static const Color darkBorder = Color(0xFF2C3531);
  static const Color darkBorderSubtle = Color(0xFF242C29);
```

Thêm mới vào cuối phần hằng:

```dart
  // ========================================================================
  // XANH RÊU — MÀU CHÍNH
  // ========================================================================

  static const Color lightPrimary = Color(0xFF0F4032);
  static const Color lightPrimaryDeep = Color(0xFF08291F);
  static const Color lightPrimaryContainer = Color(0xFF0F4032);
  static const Color lightAccentLabel = Color(0xFF0F7A55);

  static const Color darkPrimary = Color(0xFF34A97C);
  static const Color darkPrimaryDeep = Color(0xFF2A8A65);
  static const Color darkPrimaryContainer = Color(0xFF16382C);
  static const Color darkAccentLabel = Color(0xFF4FC79A);

  // ========================================================================
  // BLOB NỀN — đặt sau lớp nền, opacity thấp
  // ========================================================================

  static const Color lightBlobPeach = Color(0xFFFBE9DC);
  static const Color lightBlobMint = Color(0xFFDFEFE4);
  static const Color lightBlobButter = Color(0xFFFDF6E3);

  static const Color darkBlobPeach = Color(0xFF2A1E18);
  static const Color darkBlobMint = Color(0xFF16241E);
  static const Color darkBlobButter = Color(0xFF262214);

  // ========================================================================
  // Ô PASTEL — gán theo danh mục ỔN ĐỊNH, không ngẫu nhiên.
  // Người dùng học được màu, nên cùng một danh mục phải luôn cùng tông.
  // ========================================================================

  static const List<Color> pastelLight = [
    Color(0xFFDCEFE5), // mint
    Color(0xFFDCE7F7), // blue
    Color(0xFFFBE7DA), // peach
    Color(0xFFEAE3F7), // lilac
    Color(0xFFFBF0D5), // butter
  ];

  static const List<Color> pastelDark = [
    Color(0xFF1C3830),
    Color(0xFF1B2A3C),
    Color(0xFF38281F),
    Color(0xFF2A2438),
    Color(0xFF33301F),
  ];
```

Thêm accessor cạnh các accessor sẵn có:

```dart
  static Color primary(Brightness brightness) =>
      brightness == Brightness.light ? lightPrimary : darkPrimary;

  static Color primaryDeep(Brightness brightness) =>
      brightness == Brightness.light ? lightPrimaryDeep : darkPrimaryDeep;

  static Color primaryContainer(Brightness brightness) =>
      brightness == Brightness.light
          ? lightPrimaryContainer
          : darkPrimaryContainer;

  static Color accentLabel(Brightness brightness) =>
      brightness == Brightness.light ? lightAccentLabel : darkAccentLabel;

  static Color surfaceRecessed(Brightness brightness) =>
      brightness == Brightness.light
          ? lightSurfaceRecessed
          : darkSurfaceRecessed;

  /// Tông pastel thứ [index], lặp vòng khi vượt quá 5.
  static Color pastelFor(int index, Brightness brightness) {
    final palette = brightness == Brightness.light ? pastelLight : pastelDark;
    return palette[index % palette.length];
  }
```

- [ ] **Step 4: Chạy test, xác nhận PASS**

Run: `flutter test test/theme/design_tokens_test.dart`
Expected: PASS toàn bộ.

Tỉ lệ tương phản đã tính trước khi viết plan: chữ chính sáng 12.17:1, chữ phụ sáng 5.38:1, chữ chính tối 15.86:1, chữ phụ tối 7.19:1 — đều đạt. `#6E7671` (giá trị đọc từ ảnh mẫu) chỉ đạt 4.25:1 nên đã thay bằng `#5E6661`. Nếu vẫn FAIL: sẫm thêm chữ phụ, **không hạ ngưỡng trong test**.

- [ ] **Step 5: Chạy toàn bộ suite**

Run: `flutter test`
Expected: 488 test + test mới, tất cả PASS. Nếu có test màn hình khẳng định mã màu cũ, sửa test đó theo giá trị mới.

- [ ] **Step 6: Commit**

```bash
git add lib/core/theme/colors.dart test/theme/design_tokens_test.dart
git commit -m "feat(theme): Bảng màu kem ấm + xanh rêu, có cả bản tối

Đổi hex tại chỗ nên mọi màn KHÔNG hardcode tự đổi theo, không sửa call site.
Thêm bảng pastel 5 tông cho ô icon, blob nền, và accessor primary/accentLabel/
surfaceRecessed theo Brightness.

Bản tối là thiết kế mới: nền than ám xanh #121715 chứ không đen thuần, xanh
chính đẩy lên #34A97C cho đủ tương phản.

Test khoá giá trị token và kiểm tỉ lệ tương phản 7:1 (chữ chính) và 4.5:1
(chữ phụ) ở cả hai chế độ."
```

---

### Task 2: Thang bo góc và shadow

**Files:**
- Modify: `lib/core/theme/spacing.dart:38-47`
- Modify: `lib/core/theme/shadows.dart`
- Test: `test/theme/design_tokens_test.dart` (bổ sung)

**Interfaces:**
- Consumes: không
- Produces: `AppSpacing.radiusSm/Md/Lg/Full`, `AppShadows.soft(Brightness)`, `AppShadows.softLg(Brightness)`

- [ ] **Step 1: Viết test bổ sung**

Thêm vào cuối `test/theme/design_tokens_test.dart`, TRƯỚC dấu `}` đóng `main()`:

```dart
  group('Thang bo góc', () {
    test('mềm hơn hẳn thang cũ 6/8/12', () {
      expect(AppSpacing.radiusSm, 12.0);
      expect(AppSpacing.radiusMd, 20.0);
      expect(AppSpacing.radiusLg, 28.0);
    });

    test('tăng dần', () {
      expect(AppSpacing.radiusSm, lessThan(AppSpacing.radiusMd));
      expect(AppSpacing.radiusMd, lessThan(AppSpacing.radiusLg));
    });
  });

  group('Shadow', () {
    test('mềm và loang — blur lớn, opacity thấp', () {
      final s = AppShadows.soft(Brightness.light);
      expect(s, isNotEmpty);
      expect(s.first.blurRadius, greaterThanOrEqualTo(16));
      expect(s.first.color.a, lessThan(0.12));
    });

    test('bản tối có shadow riêng, đậm hơn', () {
      final light = AppShadows.soft(Brightness.light);
      final dark = AppShadows.soft(Brightness.dark);
      expect(dark.first.color.a, greaterThan(light.first.color.a));
    });
  });
```

Thêm import ở đầu file:

```dart
import 'package:pool_os_v2/core/theme/spacing.dart';
import 'package:pool_os_v2/core/theme/shadows.dart';
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

Run: `flutter test test/theme/design_tokens_test.dart`
Expected: FAIL — `radiusSm` vẫn là 6.0, `AppShadows.soft` chưa tồn tại.

- [ ] **Step 3: Sửa thang bo góc**

Trong `lib/core/theme/spacing.dart`, thay 4 hằng radius:

```dart
  /// Small radius - buttons, inputs
  static const double radiusSm = 12.0;

  /// Medium radius - cards, modals
  static const double radiusMd = 20.0;

  /// Large radius - large cards, sheets
  static const double radiusLg = 28.0;

  /// Full radius - pills, avatars
  static const double radiusFull = 9999.0;
```

- [ ] **Step 4: Thêm shadow mềm**

Thêm vào cuối `class AppShadows` trong `lib/core/theme/shadows.dart`:

```dart
  // ========================================================================
  // SHADOW MỀM — ngôn ngữ "Kem ấm & Xanh rêu"
  //
  // Loang rộng, opacity thấp. Bản tối đậm hơn vì shadow gần như vô hình
  // trên nền tối; màn dùng bản tối nên kèm viền 1px `AppColors.border`.
  // ========================================================================

  static List<BoxShadow> soft(Brightness brightness) =>
      brightness == Brightness.light
          ? const [
              BoxShadow(
                color: Color(0x0F11221C),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x59000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ];

  static List<BoxShadow> softLg(Brightness brightness) =>
      brightness == Brightness.light
          ? const [
              BoxShadow(
                color: Color(0x1411221C),
                blurRadius: 40,
                offset: Offset(0, 16),
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 40,
                offset: Offset(0, 16),
              ),
            ];
```

- [ ] **Step 5: Chạy test, xác nhận PASS**

Run: `flutter test test/theme/design_tokens_test.dart`
Expected: PASS.

- [ ] **Step 6: Chạy toàn bộ suite**

Run: `flutter test`
Expected: tất cả PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/core/theme/spacing.dart lib/core/theme/shadows.dart test/theme/design_tokens_test.dart
git commit -m "feat(theme): Thang bo góc 12/20/28 và shadow mềm

Bo góc là thứ tạo cảm giác mềm của thiết kế tham chiếu, nhiều hơn cả màu:
6/8/12 -> 12/20/28. Mọi màn dùng AppSpacing.radius* tự mềm theo.

AppShadows.soft/softLg loang rộng opacity thấp, có biến thể tối riêng vì
shadow gần như vô hình trên nền tối."
```

---

### Task 3: Typography

**Files:**
- Modify: `lib/core/theme/typography.dart`
- Test: `test/theme/design_tokens_test.dart` (bổ sung)

**Interfaces:**
- Consumes: không
- Produces: `AppTypography.displayLg`, `AppTypography.cardTitle` — các style sẵn có giữ nguyên tên.

- [ ] **Step 1: Viết test bổ sung**

Thêm vào `test/theme/design_tokens_test.dart` trước `}` đóng `main()`:

```dart
  group('Typography', () {
    test('vẫn dùng Plus Jakarta Sans', () {
      expect(AppTypography.displayLg.fontFamily, contains('Jakarta'));
    });

    test('tiêu đề trang to và rất đậm', () {
      expect(AppTypography.displayLg.fontSize, greaterThanOrEqualTo(28));
      expect(AppTypography.displayLg.fontWeight, FontWeight.w800);
    });

    test('tiêu đề thẻ to gần bằng tiêu đề trang', () {
      expect(AppTypography.cardTitle.fontSize, greaterThanOrEqualTo(22));
      expect(AppTypography.cardTitle.fontWeight, FontWeight.w700);
    });
  });
```

Thêm import:

```dart
import 'package:pool_os_v2/core/theme/typography.dart';
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

Run: `flutter test test/theme/design_tokens_test.dart`
Expected: FAIL — `displayLg` / `cardTitle` chưa tồn tại.

- [ ] **Step 3: Thêm style**

Thêm vào `class AppTypography` trong `lib/core/theme/typography.dart`:

```dart
  /// Tiêu đề trang — "Thể thức thi đấu"
  static TextStyle get displayLg => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
      );

  /// Tiêu đề thẻ / tên người chơi — trong thiết kế tham chiếu, tên người
  /// chơi to gần bằng tiêu đề trang.
  static TextStyle get cardTitle => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  /// Nhãn hành động — "Chọn làm người bắn"
  static TextStyle get actionLabel => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );
```

- [ ] **Step 4: Chạy test, xác nhận PASS**

Run: `flutter test test/theme/design_tokens_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/theme/typography.dart test/theme/design_tokens_test.dart
git commit -m "feat(theme): Thêm displayLg, cardTitle, actionLabel

Giữ Plus Jakarta Sans, chỉ tăng cỡ và độ đậm ở tiêu đề. cardTitle 24/w700
vì trong thiết kế tham chiếu tên người chơi to gần bằng tiêu đề trang."
```

---

### Task 4: `SoftBackground` và `PoolCard`

**Files:**
- Create: `lib/presentation/widgets/soft_background.dart`
- Create: `lib/presentation/widgets/pool_card.dart`
- Test: `test/widgets/soft_background_test.dart`
- Test: `test/widgets/pool_card_test.dart`

**Interfaces:**
- Consumes: `AppColors.background/surface/surfaceRecessed/border(Brightness)`, `AppColors.lightBlobPeach/Mint/Butter`, `AppColors.darkBlob*`, `AppSpacing.radiusMd/Lg`, `AppShadows.soft(Brightness)`
- Produces:
  - `SoftBackground({required Widget child})`
  - `PoolCard({required Widget child, VoidCallback? onTap, bool selected = false, EdgeInsets? padding, double? radius})`

- [ ] **Step 1: Viết test cho `SoftBackground`**

Tạo `test/widgets/soft_background_test.dart`:

```dart
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
```

- [ ] **Step 2: Viết test cho `PoolCard`**

Tạo `test/widgets/pool_card_test.dart`:

```dart
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
```

- [ ] **Step 3: Chạy cả hai test, xác nhận FAIL**

Run: `flutter test test/widgets/soft_background_test.dart test/widgets/pool_card_test.dart`
Expected: FAIL — hai file widget chưa tồn tại.

- [ ] **Step 4: Viết `SoftBackground`**

Tạo `lib/presentation/widgets/soft_background.dart`:

```dart
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// Nền kem ấm (hoặc than ám xanh) kèm vài mảng màu mờ.
///
/// Blob đặt cố định và làm mờ mạnh — chúng là kết cấu nền, không phải hình
/// trang trí cần chú ý. Đặt widget này dưới cùng của body màn hình.
class SoftBackground extends StatelessWidget {
  const SoftBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;

    final peach = isLight ? AppColors.lightBlobPeach : AppColors.darkBlobPeach;
    final mint = isLight ? AppColors.lightBlobMint : AppColors.darkBlobMint;
    final butter =
        isLight ? AppColors.lightBlobButter : AppColors.darkBlobButter;

    return Container(
      key: const Key('soft-background-ground'),
      decoration: BoxDecoration(color: AppColors.background(brightness)),
      child: Stack(
        children: [
          Positioned.fill(
            key: const Key('soft-background-blobs'),
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Stack(
                  children: [
                    Positioned(
                      top: -80,
                      right: -60,
                      child: _Blob(color: peach, size: 260),
                    ),
                    Positioned(
                      top: 220,
                      left: -90,
                      child: _Blob(color: mint, size: 220),
                    ),
                    Positioned(
                      bottom: -70,
                      right: -40,
                      child: _Blob(color: butter, size: 240),
                    ),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
```

- [ ] **Step 5: Viết `PoolCard`**

Tạo `lib/presentation/widgets/pool_card.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/spacing.dart';

/// Thẻ bo góc lớn, shadow mềm — khối xây dựng chính của giao diện.
///
/// [selected] = false dùng bề mặt chìm, đúng như trạng thái xám của thẻ chưa
/// chọn trong thiết kế tham chiếu.
class PoolCard extends StatelessWidget {
  const PoolCard({
    super.key,
    required this.child,
    this.onTap,
    this.selected = true,
    this.padding,
    this.radius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsets? padding;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final r = radius ?? AppSpacing.radiusMd;

    final content = Container(
      key: const Key('pool-card-container'),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.surface(brightness)
            : AppColors.surfaceRecessed(brightness),
        borderRadius: BorderRadius.circular(r),
        boxShadow: AppShadows.soft(brightness),
        // Nền tối nuốt shadow, nên phải có viền mới thấy được mép thẻ.
        border: brightness == Brightness.dark
            ? Border.all(color: AppColors.darkBorder)
            : null,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r),
        child: content,
      ),
    );
  }
}
```

- [ ] **Step 6: Chạy test, xác nhận PASS**

Run: `flutter test test/widgets/soft_background_test.dart test/widgets/pool_card_test.dart`
Expected: PASS toàn bộ.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/widgets/soft_background.dart lib/presentation/widgets/pool_card.dart test/widgets/soft_background_test.dart test/widgets/pool_card_test.dart
git commit -m "feat(ui): SoftBackground và PoolCard

SoftBackground: nền kem/tối + 3 blob làm mờ mạnh, IgnorePointer để không
chắn thao tác. PoolCard: bo radiusMd, shadow mềm, trạng thái selected dùng
bề mặt nổi còn chưa chọn dùng bề mặt chìm.

Chế độ tối thêm viền 1px vì nền tối nuốt shadow, không có viền thì không
thấy mép thẻ."
```

---

### Task 5: `IconTile` và `SectionHeader`

**Files:**
- Create: `lib/presentation/widgets/icon_tile.dart`
- Create: `lib/presentation/widgets/section_header.dart`
- Test: `test/widgets/icon_tile_test.dart`
- Test: `test/widgets/section_header_test.dart`

**Interfaces:**
- Consumes: `AppColors.pastelFor(int, Brightness)`, `AppColors.primary/textPrimary/textSecondary(Brightness)`, `AppTypography.displayLg`, `AppSpacing.radiusSm`
- Produces:
  - `IconTile({required IconData icon, required int toneIndex, double size = 56})`
  - `SectionHeader({required String title, String? subtitle, int? step})`

- [ ] **Step 1: Viết test cho `IconTile`**

Tạo `test/widgets/icon_tile_test.dart`:

```dart
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
```

- [ ] **Step 2: Viết test cho `SectionHeader`**

Tạo `test/widgets/section_header_test.dart`:

```dart
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
```

- [ ] **Step 3: Chạy test, xác nhận FAIL**

Run: `flutter test test/widgets/icon_tile_test.dart test/widgets/section_header_test.dart`
Expected: FAIL — hai widget chưa tồn tại.

- [ ] **Step 4: Viết `IconTile`**

Tạo `lib/presentation/widgets/icon_tile.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// Ô bo tròn nền pastel chứa một Material icon.
///
/// CỐ Ý dùng icon chứ không dùng emoji: emoji hiển thị khác nhau giữa các hệ
/// điều hành và trình đọc màn hình đọc tên emoji nghe lạc lõng. Vẻ ấm áp đến
/// từ ô pastel, không từ bản thân emoji.
///
/// [toneIndex] phải gán theo danh mục ỔN ĐỊNH — cùng một danh mục luôn cùng
/// tông, để người dùng học được màu.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.toneIndex,
    this.size = 56,
  });

  final IconData icon;
  final int toneIndex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      key: const Key('icon-tile-container'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.pastelFor(toneIndex, brightness),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        icon,
        size: size * 0.46,
        color: AppColors.primary(brightness),
      ),
    );
  }
}
```

- [ ] **Step 5: Viết `SectionHeader`**

Tạo `lib/presentation/widgets/section_header.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

/// Tiêu đề mục, có biến thể kèm số thứ tự bước.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.step,
  });

  final String title;
  final String? subtitle;

  /// Số thứ tự bước; có giá trị thì hiện badge tròn bên trái.
  final int? step;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.displayLg
              .copyWith(color: AppColors.textPrimary(brightness)),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            key: const Key('section-header-subtitle'),
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textSecondary(brightness),
            ),
          ),
        ],
      ],
    );

    if (step == null) return texts;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: const Key('section-header-step'),
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary(brightness),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$step',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: texts),
      ],
    );
  }
}
```

- [ ] **Step 6: Chạy test, xác nhận PASS**

Run: `flutter test test/widgets/icon_tile_test.dart test/widgets/section_header_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/widgets/icon_tile.dart lib/presentation/widgets/section_header.dart test/widgets/icon_tile_test.dart test/widgets/section_header_test.dart
git commit -m "feat(ui): IconTile và SectionHeader

IconTile bọc Material icon trong ô pastel. Test có khẳng định KHÔNG có
widget Text bên trong — chặn việc ai đó thay bằng emoji sau này.

SectionHeader có biến thể kèm badge số thứ tự bước, dùng cho các luồng
nhiều bước như ghi điểm trận."
```

---

### Task 6: `ScoreBar` và `BottomActionBar`

**Files:**
- Create: `lib/presentation/widgets/score_bar.dart`
- Create: `lib/presentation/widgets/bottom_action_bar.dart`
- Test: `test/widgets/score_bar_test.dart`
- Test: `test/widgets/bottom_action_bar_test.dart`

**Interfaces:**
- Consumes: `AppColors.primaryContainer/textSecondary(Brightness)`, `AppSpacing.radiusMd`
- Produces:
  - `ScorePlayer({required String name, required int score, IconData? icon})`
  - `ScoreBar({required List<ScorePlayer> players})`
  - `BarAction({required IconData icon, required String label, VoidCallback? onTap})`
  - `BottomActionBar({required List<BarAction> actions})`

- [ ] **Step 1: Viết test cho `ScoreBar`**

Tạo `test/widgets/score_bar_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/presentation/widgets/score_bar.dart';

Widget _wrap(Widget child, Brightness brightness) => MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: child),
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

  testWidgets('có vạch ngăn giữa các người chơi, ít hơn số người 1',
      (tester) async {
    await tester
        .pumpWidget(_wrap(const ScoreBar(players: players), Brightness.light));

    expect(find.byKey(const Key('score-bar-divider')), findsNWidgets(2));
  });

  testWidgets('một người chơi thì không có vạch ngăn nào', (tester) async {
    await tester.pumpWidget(_wrap(
        const ScoreBar(players: [ScorePlayer(name: 'Một', score: 1)]),
        Brightness.light));

    expect(find.byKey(const Key('score-bar-divider')), findsNothing);
  });

  testWidgets('danh sách rỗng không làm vỡ', (tester) async {
    await tester
        .pumpWidget(_wrap(const ScoreBar(players: []), Brightness.light));

    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Viết test cho `BottomActionBar`**

Tạo `test/widgets/bottom_action_bar_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/presentation/widgets/bottom_action_bar.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
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

  testWidgets('onTap null thì hiển thị mờ và không bấm được', (tester) async {
    await tester.pumpWidget(_wrap(BottomActionBar(actions: [
      const BarAction(icon: Icons.undo, label: 'Hoàn tác'),
    ])));

    final opacity = tester.widget<Opacity>(
      find.byKey(const Key('bar-action-Hoàn tác')),
    );
    expect(opacity.opacity, lessThan(1.0));
  });
}
```

- [ ] **Step 3: Chạy test, xác nhận FAIL**

Run: `flutter test test/widgets/score_bar_test.dart test/widgets/bottom_action_bar_test.dart`
Expected: FAIL — hai widget chưa tồn tại.

- [ ] **Step 4: Viết `ScoreBar`**

Tạo `lib/presentation/widgets/score_bar.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';

class ScorePlayer {
  const ScorePlayer({required this.name, required this.score, this.icon});

  final String name;
  final int score;
  final IconData? icon;
}

/// Thanh điểm nền xanh rêu, chia đều cho N người chơi.
class ScoreBar extends StatelessWidget {
  const ScoreBar({super.key, required this.players});

  final List<ScorePlayer> players;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      key: const Key('score-bar-container'),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          for (var i = 0; i < players.length; i++) ...[
            if (i > 0)
              Container(
                key: const Key('score-bar-divider'),
                width: 1,
                height: 34,
                color: Colors.white24,
              ),
            Expanded(child: _PlayerCell(player: players[i])),
          ],
        ],
      ),
    );
  }
}

class _PlayerCell extends StatelessWidget {
  const _PlayerCell({required this.player});

  final ScorePlayer player;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (player.icon != null) ...[
              Icon(player.icon, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                player.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${player.score}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 5: Viết `BottomActionBar`**

Tạo `lib/presentation/widgets/bottom_action_bar.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

class BarAction {
  const BarAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;

  /// null = vô hiệu, hiển thị mờ.
  final VoidCallback? onTap;
}

/// Thanh hành động dưới cùng, 3-5 mục chia đều.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.actions});

  final List<BarAction> actions;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        border: Border(top: BorderSide(color: AppColors.border(brightness))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (final a in actions)
              Expanded(
                child: Opacity(
                  key: Key('bar-action-${a.label}'),
                  opacity: a.onTap == null ? 0.38 : 1.0,
                  child: InkWell(
                    onTap: a.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(a.icon,
                              size: 22,
                              color: AppColors.primary(brightness)),
                          const SizedBox(height: 4),
                          Text(
                            a.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary(brightness),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Chạy test, xác nhận PASS**

Run: `flutter test test/widgets/score_bar_test.dart test/widgets/bottom_action_bar_test.dart`
Expected: PASS.

- [ ] **Step 7: Chạy toàn bộ suite**

Run: `flutter test`
Expected: tất cả PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/presentation/widgets/score_bar.dart lib/presentation/widgets/bottom_action_bar.dart test/widgets/score_bar_test.dart test/widgets/bottom_action_bar_test.dart
git commit -m "feat(ui): ScoreBar và BottomActionBar

ScoreBar: nền xanh rêu, chia đều N người chơi, vạch ngăn chỉ chèn giữa các
ô nên số vạch luôn ít hơn số người 1. Có test cho danh sách rỗng và 1 người.

BottomActionBar: onTap null nghĩa là vô hiệu và hiển thị mờ — trạng thái
này có trong thiết kế tham chiếu (nút Hoàn tác lúc chưa có gì để hoàn tác)."
```

---

### Task 7: Lô 1 — quét màn onboarding và auth

**Files:**
- Modify: `lib/presentation/screens/onboarding/welcome_screen.dart`
- Modify: `lib/presentation/screens/onboarding/onboarding_screen.dart`
- Modify: `lib/presentation/screens/onboarding/interest_selection_screen.dart`
- Modify: `lib/presentation/screens/auth/login_screen.dart`
- Modify: `lib/presentation/screens/auth/register_screen.dart`
- Modify: `lib/presentation/screens/auth/reset_password_screen.dart`
- Test: `test/screens/batch1_dark_mode_test.dart`

**Interfaces:**
- Consumes: `SoftBackground`, `PoolCard`, `IconTile`, `SectionHeader`, `AppColors.*(Brightness)`
- Produces: không có API mới — đây là task sửa giao diện.

- [ ] **Step 1: Viết test chặn hardcode**

Tạo `test/screens/batch1_dark_mode_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Lô 1 phải sạch token cứng thì dark mode mới đúng. Test này đọc mã nguồn
/// thay vì render, vì mục tiêu là chặn `AppColors.lightFoo` quay lại.
void main() {
  const batch1 = [
    'lib/presentation/screens/onboarding/welcome_screen.dart',
    'lib/presentation/screens/onboarding/onboarding_screen.dart',
    'lib/presentation/screens/onboarding/interest_selection_screen.dart',
    'lib/presentation/screens/auth/login_screen.dart',
    'lib/presentation/screens/auth/register_screen.dart',
    'lib/presentation/screens/auth/reset_password_screen.dart',
  ];

  test('lô 1 không còn màn nào hardcode AppColors.light*', () {
    final offenders = <String>[];

    for (final path in batch1) {
      final source = File(path).readAsStringSync();
      final matches =
          RegExp(r'AppColors\.light[A-Z]\w*').allMatches(source).toList();
      if (matches.isNotEmpty) {
        offenders.add('$path: ${matches.map((m) => m.group(0)).toSet().join(", ")}');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Phải dùng AppColors.foo(brightness) thay vì token sáng cứng:\n'
          '${offenders.join("\n")}',
    );
  });

  test('lô 1 không dùng emoji làm icon', () {
    // Dải emoji thường gặp; nhãn tiếng Việt có dấu KHÔNG nằm trong dải này.
    final emoji = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{27BF}]',
        unicode: true);
    final offenders = <String>[];

    for (final path in batch1) {
      if (emoji.hasMatch(File(path).readAsStringSync())) offenders.add(path);
    }

    expect(offenders, isEmpty,
        reason: 'Quyết định thiết kế: dùng Material icon trong ô pastel.');
  });
}
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

Run: `flutter test test/screens/batch1_dark_mode_test.dart`
Expected: FAIL — liệt kê các màn đang hardcode `AppColors.light*`.

- [ ] **Step 3: Sửa từng màn trong lô**

Với **mỗi** file trong danh sách:

1. Thêm `final brightness = Theme.of(context).brightness;` ở đầu `build()` nếu chưa có.
2. Thay mọi `AppColors.lightBackground` → `AppColors.background(brightness)`; tương tự cho `lightSurface`→`surface`, `lightTextPrimary`→`textPrimary`, `lightTextSecondary`→`textSecondary`, `lightBorder`→`border`, `lightBorderSubtle`→`borderSubtle`.
3. Bọc `body:` bằng `SoftBackground(child: ...)`.
4. Thay `Container` đóng vai thẻ bằng `PoolCard`.
5. Thay tiêu đề màn bằng `SectionHeader`.
6. Icon đứng một mình trong ô màu → `IconTile`.

Mẫu biến đổi cụ thể — TRƯỚC:

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Column(
            children: [
              Text('Chọn sở thích',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightTextPrimary)),
              Text('Giúp AI gợi ý bài tập hợp với bạn.',
                  style: TextStyle(color: AppColors.lightTextSecondary)),
            ],
          ),
        ),
      ),
    );
  }
```

SAU:

```dart
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SoftBackground(
        child: SafeArea(
          child: PoolCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SectionHeader(
                  title: 'Chọn sở thích',
                  subtitle: 'Giúp AI gợi ý bài tập hợp với bạn.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
```

Bốn điều thay đổi trong ví dụ trên: `lightBackground` → `background(brightness)`;
`Container` trang trí tay → `PoolCard` (bo góc, shadow, viền chế độ tối đã nằm
trong widget); hai `Text` tiêu đề + phụ đề → `SectionHeader`; `body` bọc thêm
`SoftBackground`.

**KHÔNG đổi bất kỳ chuỗi hiển thị nào**, đặc biệt: `'Bắt đầu ngay'`, `'Tôi đã có tài khoản'`, `'Tiếp tục'`, `'Bắt đầu'`, `'Quay lại'`. E2E bám vào chúng.

- [ ] **Step 4: Chạy test lô, xác nhận PASS**

Run: `flutter test test/screens/batch1_dark_mode_test.dart`
Expected: PASS cả hai test.

- [ ] **Step 5: Chạy toàn bộ suite Flutter**

Run: `flutter test`
Expected: tất cả PASS. Test widget nào khẳng định màu cũ thì cập nhật theo token mới.

- [ ] **Step 6: Chạy E2E**

Run: `flutter build web --release --base-href /` rồi `npx playwright test --project=chromium`

Expected: 22 PASS, 4 skip. Nếu có test đỏ vì không tìm thấy nhãn, nghĩa là Step 3 đã đổi chuỗi — hoàn lại chuỗi đó.

**Lưu ý build:** dùng PowerShell cho lệnh có `--base-href /`; Git Bash biến `/` thành đường dẫn Windows.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/screens/onboarding lib/presentation/screens/auth test/screens/batch1_dark_mode_test.dart
git commit -m "feat(ui): Lô 1 — onboarding và auth theo ngôn ngữ mới

6 màn dùng SoftBackground/PoolCard/SectionHeader/IconTile, và chuyển hết
AppColors.lightFoo sang AppColors.foo(brightness) — việc bắt buộc cho dark
mode, làm gộp luôn thay vì hai lượt.

Thêm test đọc mã nguồn chặn hai thứ quay lại: token sáng cứng, và emoji.

Giữ nguyên mọi chuỗi hiển thị vì E2E bám vào 'Bắt đầu ngay', 'Tôi đã có tài
khoản', 'Tiếp tục', 'Bắt đầu'."
```

---

## Sau kế hoạch này

Lô 2-8 (62 màn còn lại) mỗi lô một kế hoạch riêng, viết khi tới lượt. Chúng sẽ
lặp đúng khuôn Task 7 — cùng bộ 6 bước, chỉ đổi danh sách file — nên viết sẵn
bây giờ là đoán mò về những màn chưa đọc.

Thứ tự đã chốt trong spec: 2. shell+home (3) · 3. training (19) · 4. play+match
(13) · 5. coach (8) · 6. profile (10) · 7. knowledge (4) · 8. community+reports+
session (5).

**Chỉ bật `ThemeMode.system` ở `main.dart:137` sau khi lô 8 xong**, và trước đó
chạy một lượt kiểm tra không còn màn nào hardcode `AppColors.light*`.
