# Redesign "Kem ấm & Xanh rêu" — Kế hoạch lô 4 (community)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Quét `community_screen.dart` sang ngôn ngữ kem ấm + xanh rêu, và trong lúc đó dựng hai thứ mà bảy nhóm còn lại sẽ dùng lại: bộ token huy chương (bạc/đồng bên cạnh `gold` đã có) và quy ước ánh xạ `Colors.*` → token.

**Architecture:** Ba lớp như các lô trước. Khác biệt của lô này: `community_screen` **đã đọc `Brightness` sẵn** (74 chỗ) và **không còn `AppColors.lightX` nào** — nên việc không phải di trú accessor, mà là gỡ 9 chỗ `Colors.*` của Material. Ba trong chín chỗ là **màu nền có chữ đè lên**, phải kiểm cả hai chiều theo bài học lô 3a.

**Tech Stack:** Flutter 3.47.0 · Dart 3.13.0 · flutter_riverpod · google_fonts (Plus Jakarta Sans) · flutter_test

**Spec:** `docs/superpowers/specs/2026-09-09-warm-green-redesign-design.md`

**Các lô đã xong:** phase-1 (token + 6 component + onboarding/auth) · phase-2 (shell/home) · phase-3a–3e (20 màn training)

## Global Constraints

- **Mọi màn đã quét phải dùng `AppColors.foo(brightness)`** — không để lại `AppColors.lightFoo`, `darkFoo`, hay `fooSubtleLight`.
- **KHÔNG dùng `Colors.*` của Material** làm màu giao diện. `Colors.transparent` là ngoại lệ duy nhất.
- **KHÔNG dùng emoji làm icon.** Dùng Material icon trong ô pastel (`IconTile`).
- **KHÔNG đổi font.** Giữ `GoogleFonts.plusJakartaSans()`.
- **KHÔNG bật `ThemeMode.system`.** `main.dart:137` giữ `ThemeMode.light` tới hết lô 8.
- Màu chính sáng `#0F4032`, tối `#34A97C`. Nền sáng `#F7F4EC`, tối `#121715`.
- Bo góc: `radiusSm=12` `radiusMd=20` `radiusLg=28` `radiusTile=18` `radiusFull=9999`.
- Chữ trên nền `primary` dùng `AppColors.onPrimary(brightness)`, **không dùng `Colors.white`** — chế độ tối `primary` là `#34A97C` nên chữ trắng chỉ đạt ~2.5:1.
- **Thêm token màu thì kiểm CẢ HAI chiều**: nó làm chữ trên nền gì, và nó làm nền cho chữ gì. Bài học lô 3a — kiểm một chiều đủ để lọt qua ba vòng review.
- Sau mỗi nhóm: `flutter analyze` phải **0 error**. `flutter test` chạy **một lượt duy nhất ở cuối lô 4** (yêu cầu của chủ dự án), hiện **680 test**.
- `flutter` không có trên PATH. Bash: `export PATH="/c/Users/anhnpv/flutter/bin:$PATH"`.

---

## Hiện trạng — khảo sát 40 màn còn lại

Đếm bằng regex loại trừ `AppColors.`: `(?<![A-Za-z])Colors[.]`. **Lần khảo sát đầu đếm sai gấp ~5 lần** vì `Colors\.` khớp cả `AppColors.` — ghi lại để lô sau không lặp.

| Nhóm | Màn | Dòng | `lightX` | hex thô | `Colors.*` |
|---|---:|---:|---:|---:|---:|
| session | 2 | 551 | 22 | 0 | 6 |
| reports | 2 | 709 | 37 | 0 | 7 |
| **community** | **1** | **754** | **0** | **0** | **9** |
| match | 2 | 1085 | 45 | 2 | 24 |
| knowledge | 4 | 1086 | 3 | 0 | 7 |
| coach | 8 | 4038 | 13 | 0 | 50 |
| profile | 10 | 6111 | 276 | 10 | 50 |
| play | 11 | 7333 | 206 | 1 | 160 |
| **Tổng** | **40** | **21667** | **602** | **13** | **313** |

Gánh chính của lô 4–8 là **602 chỗ `lightX`**, tập trung ở `profile` và `play`.

## Chín chỗ `Colors.*` của community

| Dòng | Mã hiện tại | Bài toán |
|---|---|---|
| 93 | `Colors.grey.shade400` | Bục hạng 2 — thiếu token **bạc** bên cạnh `AppColors.gold` |
| 111 | `Colors.brown.shade300` | Bục hạng 3 — thiếu token **đồng** |
| 230 | `Colors.white` | Chữ số hạng **đè lên** khối huy chương → hai chiều |
| 487 | `Colors.purple` | Bậc `Pro` |
| 491 | `Colors.blue` | Bậc `Advanced` — **đúng xanh điện mà đợt này loại bỏ** |
| 542 | `Colors.purple.withValues(alpha: 0.1)` | Nền badge bậc trong sheet |
| 548 | `Colors.purple` | Chữ badge **đè lên** nền dòng 542 → hai chiều |
| 596 | `Colors.white` | Icon trên nút nền `accentColor` |
| 597 | `Colors.white` | Nhãn trên cùng nút đó |

`_getLevelColor` (dòng 484) dùng **cả hai chiều**: dòng 440 làm nền `alpha 0.1`, dòng 446 làm chữ đè lên chính nền đó.

**Tiền lệ phải theo:** `assessment_screen.dart:542` đã có `_getLevelColor(String, Brightness)` bốn bậc dùng đúng bốn hue tách bạch — `difficultyExpert` 262° / họ xanh rêu 157–163° / `warning` 38° / `error` 0°, không cặp nào dưới 20°. Lô này **tái dùng bộ đó theo thứ hạng**, không đặt bảng màu thứ hai.

---

### Task 1: Token huy chương bạc và đồng

`AppColors.gold` đã có (`#A67C00`) kèm `goldOnTintLight/Dark`. Bục vinh danh cần đủ bộ ba. Hex dưới đây là **điểm xuất phát, không phải kết luận** — test ở Step 1 là cửa ải; trượt thì chỉnh hex, **không nới sàn**.

**Files:**
- Modify: `lib/core/theme/colors.dart` (cạnh khối `gold`, ~dòng 184–246 và ~319–330)
- Test: `test/theme/batch4_contrast_test.dart` (tạo mới)

**Interfaces:**
- Produces: `AppColors.silver`, `AppColors.bronze` (`static const Color`); `AppColors.silverOnTint(Brightness)`, `AppColors.bronzeOnTint(Brightness)`; hằng `silverOnTintLight/Dark`, `bronzeOnTintLight/Dark`.

- [ ] **Step 1: Viết test thất bại — kiểm CẢ HAI chiều**

Tạo `test/theme/batch4_contrast_test.dart`:

```dart
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// `computeLuminance()` BỎ QUA alpha — đo thẳng màu có alpha sẽ ra số của màu
/// đặc. Phải kết tủa lên nền thật trước.
Color _over(Color tone, double alpha, Color ground) =>
    Color.alphaBlend(tone.withValues(alpha: alpha), ground);

const _brightnesses = [Brightness.light, Brightness.dark];

void main() {
  group('lô 4 — bộ ba huy chương, kiểm hai chiều', () {
    // CHIỀU 1: huy chương làm NỀN, chữ số hạng đè lên. Số hạng 24px bold →
    // vượt ngưỡng chữ lớn 18.66px bold của WCAG nên sàn là 3:1.
    test('làm nền: chữ onPrimary đọc được trên cả ba huy chương', () {
      for (final b in _brightnesses) {
        final medals = <String, Color>{
          'vàng': AppColors.gold,
          'bạc': AppColors.silver,
          'đồng': AppColors.bronze,
        };
        for (final e in medals.entries) {
          expect(_contrast(e.value, AppColors.onPrimary(b)),
              greaterThanOrEqualTo(3.0),
              reason: 'Số hạng trên bục ${e.key} ($b) phải đạt 3:1');
        }
      }
    });

    // CHIỀU 2: huy chương làm CHỮ trên nền dịu — chiều mà lô 3a bỏ sót.
    test('làm chữ: bản OnTint đọc được trên nền 10% của chính nó', () {
      for (final b in _brightnesses) {
        final pairs = <String, List<Color>>{
          'vàng': [AppColors.gold, AppColors.goldOnTint(b)],
          'bạc': [AppColors.silver, AppColors.silverOnTint(b)],
          'đồng': [AppColors.bronze, AppColors.bronzeOnTint(b)],
        };
        for (final e in pairs.entries) {
          final ground = _over(e.value[0], 0.10, AppColors.background(b));
          expect(_contrast(ground, e.value[1]), greaterThanOrEqualTo(4.5),
              reason: 'Chữ ${e.key} trên nền dịu của nó ($b) phải đạt 4.5:1');
        }
      }
    });

    test('ba huy chương tách bạch nhau', () {
      final pairs = [
        [AppColors.gold, AppColors.silver],
        [AppColors.silver, AppColors.bronze],
        [AppColors.gold, AppColors.bronze],
      ];
      for (final p in pairs) {
        expect(_contrast(p[0], p[1]), greaterThanOrEqualTo(1.3),
            reason: 'Hai huy chương cạnh nhau không được gần như trùng màu');
      }
    });
  });
}
```

- [ ] **Step 2: Chạy để xác nhận nó đỏ**

```bash
export PATH="/c/Users/anhnpv/flutter/bin:$PATH"
flutter test test/theme/batch4_contrast_test.dart
```

Kỳ vọng: FAIL biên dịch — `The getter 'silver' isn't defined for the type 'AppColors'`.

- [ ] **Step 3: Thêm token vào `colors.dart`**

Đặt ngay dưới khối `gold` để ba huy chương nằm cùng chỗ:

```dart
  /// Huy chương bạc — bậc 2 của bục vinh danh.
  ///
  /// Không dùng `Colors.grey.shade400` (#BDBDBD): quá sáng để mang chữ
  /// `onPrimary` ở chế độ sáng, và nằm đúng dải xám mà `border`/`textTertiary`
  /// đang chiếm nên bục trông như một ô bị vô hiệu hoá.
  static const Color silver = Color(0xFF6E7276);

  /// Huy chương đồng — bậc 3.
  ///
  /// Không dùng `Colors.brown.shade300` (#A1887F) vì cùng lý do độ sáng, và
  /// vì sắc nâu xám của nó đọc ra "bẩn" cạnh nền kem `#F7F4EC`.
  static const Color bronze = Color(0xFF8A5A2B);

  static const Color silverOnTintLight = Color(0xFF585C60);
  static const Color silverOnTintDark = Color(0xFFAFB4B9);
  static const Color bronzeOnTintLight = Color(0xFF7A4E24);
  static const Color bronzeOnTintDark = Color(0xFFCE9A63);
```

Hai accessor, cạnh `goldOnTint`:

```dart
  static Color silverOnTint(Brightness brightness) =>
      brightness == Brightness.light ? silverOnTintLight : silverOnTintDark;

  static Color bronzeOnTint(Brightness brightness) =>
      brightness == Brightness.light ? bronzeOnTintLight : bronzeOnTintDark;
```

- [ ] **Step 4: Chạy lại tới khi xanh**

```bash
flutter test test/theme/batch4_contrast_test.dart
```

Kỳ vọng: PASS cả 3 test. Đỏ thì **chỉnh hex**, tuyệt đối không hạ sàn trong test.

- [ ] **Step 5: Commit**

```bash
git add lib/core/theme/colors.dart test/theme/batch4_contrast_test.dart
git commit -m "feat(tokens): them huy chuong bac va dong, kiem ca hai chieu"
```

---

### Task 2: Bục vinh danh dùng token huy chương

**Files:**
- Modify: `lib/presentation/screens/community/community_screen.dart:93`, `:111`, `:230`

**Interfaces:**
- Consumes: `AppColors.silver`, `AppColors.bronze` từ Task 1.

- [ ] **Step 1: Thay hai màu bục**

Dòng 93: `color: Colors.grey.shade400,` → `color: AppColors.silver,`
Dòng 111: `color: Colors.brown.shade300,` → `color: AppColors.bronze,`

- [ ] **Step 2: Sửa chữ số hạng (dòng 230)**

`_PodiumItem` đã nhận sẵn tham số `brightness`:

```dart
              style: TextStyle(
                color: AppColors.onPrimary(brightness),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
```

- [ ] **Step 3: Xác nhận vùng bục đã sạch**

```bash
grep -nP "(?<![A-Za-z])Colors\.(?!transparent)" lib/presentation/screens/community/community_screen.dart
```

Kỳ vọng: còn đúng 6 dòng (487, 491, 542, 548, 596, 597).

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/screens/community/community_screen.dart
git commit -m "fix(ui): buc vinh danh dung token huy chuong thay Colors.grey/brown"
```

---

### Task 3: Bậc trình độ theo bộ bốn hue đã có

`_getLevelColor` hiện trả `Colors.purple` / `AppColors.warning` / `Colors.blue` / `AppColors.success`. Hai vấn đề: `Colors.blue` là xanh điện phải loại, và `success` cùng họ xanh rêu 157–163° với `primary` nên không đứng cạnh nhau được.

Ánh xạ **theo thứ hạng**, khớp tiền lệ `assessment_screen.dart:542`:

| Bậc | Trước | Sau | Hue |
|---|---|---|---|
| Pro | `Colors.purple` | `AppColors.difficultyExpert(b)` | 262° |
| Expert | `AppColors.warning` | `AppColors.primary(b)` | 157–163° |
| Advanced | `Colors.blue` | `AppColors.warning` | 38° |
| (mặc định) | `AppColors.success` | `AppColors.error` | 0° |

Đây là **đổi màu nhìn thấy được** ở bậc Expert và bậc mặc định — có chủ đích, để bốn bậc không cặp nào dưới 20° hue.

**Files:**
- Modify: `lib/presentation/screens/community/community_screen.dart:484-496`, `:440`, `:446`, `:542`, `:548`
- Test: `test/theme/batch4_contrast_test.dart` (bổ sung group)

- [ ] **Step 1: Viết test thất bại cho chiều nền**

Thêm group này vào `main()` của `batch4_contrast_test.dart`:

```dart
  group('lô 4 — bốn bậc trình độ community', () {
    // Badge bậc: nền là màu bậc ở alpha 0.1, chữ là màu bậc đặc.
    // Chữ badge 12-14px bold → dưới 18.66px nên sàn là 4.5:1.
    test('chữ bậc đọc được trên nền 10% của chính nó', () {
      for (final b in _brightnesses) {
        final levels = <String, Color>{
          'Pro': AppColors.difficultyExpert(b),
          'Expert': AppColors.primary(b),
          'Advanced': AppColors.warning,
          'Beginner': AppColors.error,
        };
        for (final e in levels.entries) {
          final ground = _over(e.value, 0.10, AppColors.background(b));
          expect(_contrast(ground, e.value), greaterThanOrEqualTo(4.5),
              reason: 'Badge bậc ${e.key} ($b) phải đạt 4.5:1');
        }
      }
    });
  });
```

- [ ] **Step 2: Chạy — ghi lại kết quả THẬT**

```bash
flutter test test/theme/batch4_contrast_test.dart
```

Nếu một bậc trượt, **đó là phát hiện thật, không phải lỗi test**: badge đó cần bản `OnTint` giống họ `success`/`warning`/`error` đã có. Thêm accessor `OnTint` tương ứng rồi dùng nó làm màu chữ ở dòng 446 và 548 — **không làm nhạt nền để lách**.

- [ ] **Step 3: Sửa `_getLevelColor` nhận `Brightness`**

Nâng thành **top-level private function** trong cùng file (vì `_PlayerProfileSheet` là lớp riêng cũng cần dùng):

```dart
/// Tông của bốn bậc trình độ, theo THỨ HẠNG.
///
/// Dùng đúng bộ bốn hue tách bạch của hệ — `difficultyExpert` 262° / họ xanh
/// rêu 157-163° / `warning` 38° / `error` 0° — giống `assessment_screen`.
/// `Advanced` KHÔNG giữ `Colors.blue`: xanh điện là thứ đợt redesign này tồn
/// tại để loại bỏ. Bậc mặc định dời từ `success` sang `error` vì `success`
/// cùng họ xanh rêu với `primary` của bậc `Expert` ngay trên nó.
Color _getLevelColor(String level, Brightness brightness) {
  switch (level) {
    case 'Pro':
      return AppColors.difficultyExpert(brightness);
    case 'Expert':
      return AppColors.primary(brightness);
    case 'Advanced':
      return AppColors.warning;
    default:
      return AppColors.error;
  }
}
```

- [ ] **Step 4: Cập nhật các điểm gọi**

Dòng 440 và 446 đã có sẵn `brightness` trong scope: `_getLevelColor(level)` → `_getLevelColor(level, brightness)`.

Dòng 542/548 trong `_PlayerProfileSheet` đang hardcode `Colors.purple`:

```dart
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getLevelColor(player['level'] as String, brightness)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              player['level'] as String,
              style: TextStyle(
                color: _getLevelColor(player['level'] as String, brightness),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
```

Bỏ `const` khỏi `TextStyle` vì màu không còn là hằng.

- [ ] **Step 5: Test + analyze**

```bash
flutter test test/theme/batch4_contrast_test.dart
flutter analyze lib/presentation/screens/community/
```

Kỳ vọng: test PASS, analyze 0 error.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/screens/community/community_screen.dart test/theme/batch4_contrast_test.dart
git commit -m "fix(ui): bon bac trinh do community theo bo bon hue, bo xanh dien"
```

---

### Task 4: Chữ trên nút nền accent

**Files:**
- Modify: `lib/presentation/screens/community/community_screen.dart:596-597`

- [ ] **Step 1: Thay hai `Colors.white`**

Nút dùng `backgroundColor: AppColors.accentColor(brightness)`:

```dart
                  icon: Icon(Icons.sports_cricket,
                      color: AppColors.onPrimary(brightness)),
                  label: Text('Thách đấu',
                      style: TextStyle(color: AppColors.onPrimary(brightness))),
```

- [ ] **Step 2: Xác nhận file sạch `Colors.*`**

```bash
grep -cP "(?<![A-Za-z])Colors\.(?!transparent)" lib/presentation/screens/community/community_screen.dart
```

Kỳ vọng: `0`.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/community/community_screen.dart
git commit -m "fix(a11y): chu tren nut accent dung onPrimary thay Colors.white"
```

---

### Task 5: Khoá bằng luật vệ sinh token

**Files:**
- Test: `test/screens/batch4_dark_mode_test.dart` (tạo mới)

- [ ] **Step 1: Viết test hygiene**

```dart
import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 4 — community', const [
    'lib/presentation/screens/community/community_screen.dart',
  ]);
}
```

- [ ] **Step 2: Chạy**

```bash
flutter test test/screens/batch4_dark_mode_test.dart
```

Kỳ vọng: PASS cả 10 luật. Luật nào đỏ thì sửa **màn**, đừng nới luật.

- [ ] **Step 3: `flutter analyze` toàn dự án**

```bash
flutter analyze
```

Kỳ vọng: **0 error**. (216 info/warning ở `test/` và `tools/` là nợ cũ, không phải việc của lô này.)

- [ ] **Step 4: Commit**

```bash
git add test/screens/batch4_dark_mode_test.dart
git commit -m "test(hygiene): khoa man community vao 10 luat ve sinh token"
```

---

## Sau nhóm community

Bảy nhóm còn lại, thứ tự tăng dần độ khó:

| Thứ tự | Nhóm | Màn | Dòng | Gánh chính |
|---|---|---:|---:|---|
| 2 | session | 2 | 551 | 22 `lightX` |
| 3 | reports | 2 | 709 | 37 `lightX` |
| 4 | match | 2 | 1085 | 45 `lightX`, 2 hex thô |
| 5 | knowledge | 4 | 1086 | 7 `Colors.*` |
| 6 | coach | 8 | 4038 | 50 `Colors.*` |
| 7 | profile | 10 | 6111 | **276 `lightX`**, 10 hex, `settings_screen` 1355 dòng |
| 8 | play | 11 | 7333 | **206 `lightX`**, 160 `Colors.*`, `match_recording_screen` 1408 dòng |

Mỗi nhóm theo đúng hình dạng task của lô này: token trước (kèm test hai chiều nếu thêm màu mới) → sửa màn → `expectTokenHygiene` → `flutter analyze`.

**`flutter test` đầy đủ chạy MỘT LƯỢT sau nhóm play** — không chạy giữa chừng. Đây là yêu cầu của chủ dự án; bù lại `flutter analyze` chạy sau mỗi nhóm để lỗi biên dịch không tích luỹ qua tám nhóm.

## Hai việc còn nợ từ lô 2

1. **`_NotificationCard` chưa có widget test** — `lib/presentation/screens/home/notification_screen.dart`. Luật đọc-mã-nguồn không bắt được `Dismissible.onDismissed` bị vô hiệu hay `maxLines` bị rơi. Gộp vào nhóm `profile`.
2. **`DrillListScreen` chưa đổi sang `PoolCard`/`IconTile`** — còn một đường nối thấy được cách một cú chạm. Gộp vào nhóm `play`.

## Cổng sau lô 8

Chỉ sau khi tám nhóm xong và `expectTokenHygiene` phủ đủ 68 màn mới được bật `ThemeMode.system` ở `main.dart:137`. **Mọi tỉ lệ tương phản chế độ tối ghi trong các plan đến giờ là tính toán, chưa phải quan sát** — dark mode chưa từng chạy thật lần nào. Việc bật phải là task riêng có bước nhìn bằng mắt.
