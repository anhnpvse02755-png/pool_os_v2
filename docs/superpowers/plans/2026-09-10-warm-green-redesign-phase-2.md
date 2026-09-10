# Redesign "Kem ấm & Xanh rêu" — Kế hoạch lô 2 (shell + home)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Quét 3 màn của lô 2 — thanh điều hướng dưới, màn Home, màn Thông báo — sang ngôn ngữ kem ấm + xanh rêu, và rút luật kiểm tra token thành helper dùng chung cho 6 lô còn lại.

**Architecture:** Lô 2 khác lô 1 ở một điểm quyết định cách làm: **3 màn này đã đọc `Brightness` sẵn** và phần lớn đã dùng accessor `AppColors.foo(brightness)`. Việc chính không còn là sửa dark mode, mà là **đổi màu chính từ xanh điện `#3B82F6` (`AppColors.accentColor`) sang xanh rêu `#0F4032` (`AppColors.primary`)**, và hạ 3 banner gradient bão hoà xuống còn 1 điểm nhấn. Vì luật kiểm tra token sẽ lặp lại y hệt ở 6 lô sau, task 1 rút chúng thành helper trước khi dùng tới lần thứ hai.

**Tech Stack:** Flutter 3.47.0 · Dart 3.12.2 · flutter_riverpod · go_router · flutter_animate · google_fonts (Plus Jakarta Sans) · flutter_test · Playwright

**Spec:** `docs/superpowers/specs/2026-09-09-warm-green-redesign-design.md`

**Kế hoạch lô 1 (đã xong):** `docs/superpowers/plans/2026-09-09-warm-green-redesign-phase-1.md`

## Global Constraints

- **KHÔNG dùng emoji làm icon.** Dùng Material icon đặt trong ô pastel. Cả 3 màn lô 2 hiện đã sạch emoji — giữ nguyên như vậy.
- **KHÔNG đổi font.** Giữ `GoogleFonts.plusJakartaSans()`.
- **KHÔNG bật `ThemeMode.system`** cho tới khi lô 8 xong. `main.dart:137` giữ nguyên `ThemeMode.light` trong suốt giai đoạn này.
- **Mọi màn đã quét phải dùng `AppColors.foo(brightness)`** — không để lại `AppColors.lightFoo`, `AppColors.darkFoo`, hay `AppColors.fooSubtleLight`.
- **KHÔNG dùng `Colors.*` của Material** làm màu giao diện. `Colors.transparent` là ngoại lệ duy nhất được phép.
- Màu chính sáng `#0F4032`, tối `#34A97C`. Nền sáng `#F7F4EC`, tối `#121715`.
- Thang bo góc: `radiusSm = 12`, `radiusMd = 20`, `radiusLg = 28`, `radiusTile = 18`, `radiusFull = 9999`.
- Chữ đặt trên nền `primary` phải dùng `AppColors.onPrimary(brightness)`, **không dùng `Colors.white`** — chế độ tối `primary` là `#34A97C` nên chữ trắng chỉ đạt ~2.5:1.
- Sau mỗi task: `flutter test` phải xanh toàn bộ (hiện **568 test**).
- **Lệnh chạy test:** `flutter` KHÔNG có trên PATH. Mọi lệnh PowerShell phải prefix `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH";`
- **KHÔNG dùng vòng lặp `Get-Content`/`Set-Content` của PowerShell để patch file.** PowerShell 5.1 đọc UTF-8 bằng ANSI và sẽ phá hỏng tiếng Việt trong file. Sửa bằng tool Edit, hoặc commit trước rồi `git checkout --` để khôi phục.
- **E2E bám vào các nhãn hiển thị sau — KHÔNG được đổi:** `'Home'`, `'Train'`, `'Progress'`, `'Profile'` (thanh dưới, so khớp `exact: true`), và `'Start Training'`, `'Start Training Session'`, `'View Training History'`, `'Read knowledge article'` (màn Home). Chuỗi `'Start Training'` xuất hiện ở **3 chỗ** trong `home_screen.dart` (dòng 310, 385, 485) và chỉ một chỗ hiện tại một thời điểm tuỳ trạng thái dashboard — giữ nguyên cả ba.

---

## Hiện trạng 3 màn (đã khảo sát trước khi viết plan)

| File | Dòng | `light*`/`dark*` | `*SubtleLight` | `Colors.*` | `accentColor` | `gold` | đọc Brightness |
|---|---|---|---|---|---|---|---|
| `shell/main_shell.dart` | 195 | 2 | 0 | `white` ×1 | 1 | 0 | có |
| `home/home_screen.dart` | 992 | 0 | 2 | `white` ×19, `blue` ×3 | 9 | 1 | có |
| `home/notification_screen.dart` | 288 | 1 | 0 | `white` ×1, `purple` ×1 | 2 | 1 | có |

Không màn nào có emoji. `main_shell.dart` còn 2 hằng màu thô `Color(0x0D000000)` và `Color(0x26000000)` trong shadow.

---

## Quyết định thiết kế của lô này

**Ba banner gradient bão hoà xuống còn một.** `home_screen.dart` hiện có 3 khối `LinearGradient` full-width xếp chồng nhau trong một lần cuộn: banner chính (gradient accent), banner trận đấu (`Colors.blue.shade600` → `shade400`), banner streak (`AppColors.warning` → `warningLight`). Ba mảng màu bão hoà cạnh nhau thì không mảng nào còn là điểm nhấn, và nó ngược hẳn ngôn ngữ tham chiếu — nền kem tĩnh, đúng một khối màu đậm dẫn mắt.

Cách xử lý:

| Hàm | Dòng | Trước | Sau |
|---|---|---|---|
| `_buildAICoachSection` | 160-327 | gradient `accent` → `accent@80%` | gradient `primary` → `primaryDeep`, chữ `onPrimary` — **giữ là điểm nhấn duy nhất** |
| `_buildAfterMatchCard` | 328-392 | gradient `Colors.blue.shade600/400` | `PoolCard` + `IconTile(toneIndex: 1)` (pastel xanh), chữ theo token thường |
| `_buildStreakWarningCard` | 493-559 | gradient `warning` → `warningLight` | `PoolCard` + `IconTile(toneIndex: 2)` (pastel đào) |

**ĐÍNH CHÍNH LẦN 3 (sau rà soát cuối lô 2).** Bảng trên, bản đầu, ghi thẻ streak giữ icon lửa màu `AppColors.streak` "vì nó nằm trên ô pastel nên đủ tương phản" — nhưng phần step-by-step lại viết là `Icon` trần, mâu thuẫn với chính bảng này. Implementer làm theo step, nên cam `#F97316` rơi thẳng lên mặt thẻ trắng: **2,80:1**, dưới ngưỡng 3:1 cho hình đồ hoạ mang nghĩa, và lý do biện minh ở trên trở thành sai.

Đã sửa: thẻ streak dùng `IconTile(icon: Icons.local_fire_department, toneIndex: 2, size: 36)` như bảng nói ngay từ đầu. Hệ quả là **icon lửa không còn màu cam** — `IconTile` luôn tô icon bằng `AppColors.primary(brightness)`, và trên pastel đào con số đó là 8,9:1 ở chế độ sáng. Ngữ nghĩa "chuỗi ngày" giờ do ô pastel đào mang, không do màu icon.

`AppColors.streak` vẫn là token đúng cho tín hiệu chuỗi ngày ở chỗ khác (`notification_screen.dart`), nhưng **không dùng được làm màu chữ hay icon trên nền trắng** — 2,80:1.

**Bài học:** khi bảng quyết định và phần step mâu thuẫn nhau, người thực thi làm theo step. Bảng là thứ mang lý do, step là thứ mang lệnh — viết plan phải để hai thứ khớp nhau, và khi sửa một cái phải sửa cái kia.

**Phân bố 19 chỗ `Colors.white` (đã đếm chính xác):**

| Vị trí | Số chỗ | Xử lý |
|---|---|---|
| `_buildAICoachSection` (160-327) | 9 | → `AppColors.onPrimary(brightness)` (vẫn nằm trên gradient) |
| `_buildAfterMatchCard` (328-392) | 4 | → token chữ thường (khối hết gradient) |
| `_buildStreakWarningCard` (493-559) | 4 | → token chữ thường (khối hết gradient) |
| `_buildEmptyRecommendations` (560-568) | 1 | → `AppColors.onPrimary(brightness).withValues(alpha: 0.8)` — xem đính chính dưới |
| `_ActionRow` (931+) | 1 | → `AppColors.onPrimary(brightness)` (badge trên nền primary) |

**ĐÍNH CHÍNH (ghi sau khi thực thi) — khẳng định gốc ở đây SAI.**

Bản đầu của plan này viết: `_buildEmptyRecommendations` (dòng 560) render `'Start your training journey today!'` bằng `Colors.white.withValues(alpha: 0.8)` nhưng "KHÔNG nằm trong khối gradient nào — nó là `Text` trần trên nền kem", và gọi đó là bug có sẵn cần sửa thành `textSecondary`.

Sai. Hàm này có đúng hai call site, **cả hai nằm TRONG** Container gradient của `_buildAICoachSection`: dòng 235 (nhánh `data:` khi `path.isEmpty`) và dòng 278 (nhánh `error:`). Bằng chứng: widget anh em ngay cạnh ở dòng 275 là `CircularProgressIndicator(color: AppColors.onPrimary(brightness))`.

Nghĩa là chữ trắng 80% vốn **đúng** cho nền đó, và bản "sửa lỗi" kê trong plan mới là lỗi thật: `#5E6661` trên `#0F4032` ≈ 2.0:1, đúng ở màn empty-state mà mọi người dùng mới gặp đầu tiên, cộng thêm màn lỗi provider.

Giá trị đúng là `AppColors.onPrimary(brightness)` — giữ ràng buộc không dùng `Colors.*`, và **để nguyên độ mờ 100%**.

**ĐÍNH CHÍNH LẦN 2 (sau rà soát cuối lô 2) — con số "4,8:1 ở chế độ tối" ở trên SAI.** Bản trước của mục này khuyên dùng `.withValues(alpha: 0.8)` và ghi 4,8:1 cho chế độ tối. Đo lại trên đúng hai điểm dừng của gradient (`primary → primaryDeep`, nên chữ có thể rơi vào bất kỳ điểm nào):

| | trên `primary` tối `#34A97C` | trên `primaryDeep` tối `#2A8A65` |
|---|---|---|
| alpha 1.0 | 5,77:1 ✓ | 4,00:1 |
| alpha 0.9 | 4,97:1 ✓ | 3,56:1 ✗ |
| alpha 0.8 | 4,21:1 ✗ | 3,15:1 ✗ |

Chế độ sáng đạt ở mọi mức (8,08–15,59:1). Chỉ chế độ tối gãy, và gãy ở cả 0.8 lẫn 0.9.

**Idiom cho các lô sau chép lại: chữ trên gradient dùng `AppColors.onPrimary(brightness)` nguyên độ mờ, không `withValues`.** Phân cấp thị giác đã có sẵn qua `fontSize`/`fontWeight` — không cần hạ alpha để tạo cấp bậc. `withValues` vẫn hợp lệ cho nền wash của `Container` và màu `boxShadow`, chỉ cấm trên màu chữ và màu icon.

**Nguyên nhân sai:** kết luận "không nằm trong gradient" rút ra từ việc đọc thân hàm mà không truy nơi gọi. Với helper chỉ nhận `Brightness` chứ không nhận màu nền, **nơi gọi mới quyết định nền**. Các lô sau: trước khi đổi màu chữ trong một helper, luôn `grep` tên hàm để xem nó được gọi ở đâu.

---

## Cấu trúc file

| File | Trách nhiệm |
|---|---|
| `test/screens/token_hygiene.dart` | Tạo: helper kiểm token dùng chung cho mọi lô |
| `test/screens/batch1_dark_mode_test.dart` | Sửa: gọi helper thay vì tự viết 6 luật |
| `test/screens/batch2_dark_mode_test.dart` | Tạo: áp helper cho lô 2, thêm dần từng màn |
| `lib/presentation/screens/shell/main_shell.dart` | Sửa: thanh dưới sang xanh rêu, bỏ hằng màu thô |
| `lib/presentation/screens/home/notification_screen.dart` | Sửa: bảng màu theo loại thông báo sang pastel |
| `lib/presentation/screens/home/home_screen.dart` | Sửa: 3 banner còn 1 điểm nhấn, xanh điện sang xanh rêu |

---

### Task 1: Rút luật kiểm token thành helper dùng chung

Lô 1 viết 6 luật thẳng trong file test của nó. Còn 7 lô nữa sẽ cần đúng 6 luật đó. Chép tay 7 lần là 7 cơ hội để một luật bị bỏ sót ở một lô — rút ra trước khi dùng tới lần thứ hai.

**Files:**
- Create: `test/screens/token_hygiene.dart`
- Modify: `test/screens/batch1_dark_mode_test.dart`

**Interfaces:**
- Consumes: không
- Produces: `void expectTokenHygiene(String batchName, List<String> paths)` — đăng ký 6 `test()` cho danh sách file truyền vào. Gọi trong `main()` của file test mỗi lô.

- [ ] **Step 1: Viết helper**

Tạo `test/screens/token_hygiene.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Sáu luật vệ sinh token mà MỌI lô quét đều phải đạt.
///
/// Đọc mã nguồn chứ không render: mục tiêu là chặn token khoá-sáng quay lại,
/// và việc đó rẻ hơn nhiều so với dựng đủ provider để pump từng màn.
///
/// [batchName] chỉ dùng để đặt tên test cho dễ đọc khi đỏ.
void expectTokenHygiene(String batchName, List<String> paths) {
  String offendersFor(RegExp pattern) {
    final offenders = <String>[];
    for (final path in paths) {
      final matches = pattern
          .allMatches(File(path).readAsStringSync())
          .map((m) => m.group(0)!)
          .toSet();
      if (matches.isNotEmpty) {
        offenders.add(path + ': ' + matches.join(', '));
      }
    }
    return offenders.join('\n');
  }

  test('$batchName không hardcode AppColors.light*', () {
    final offenders = offendersFor(RegExp(r'AppColors\.light[A-Z]\w*'));
    expect(offenders, isEmpty,
        reason: 'Phải dùng AppColors.foo(brightness):\n$offenders');
  });

  test('$batchName không hardcode AppColors.dark*', () {
    final offenders = offendersFor(RegExp(r'AppColors\.dark[A-Z]\w*'));
    expect(offenders, isEmpty,
        reason: 'Token tối cứng cũng sai như token sáng cứng:\n$offenders');
  });

  test('$batchName không hardcode nền dịu bản sáng/tối', () {
    // `AppColors.errorSubtleLight` KHÔNG khớp regex `light[A-Z]` ở trên vì
    // chữ light nằm cuối tên — cần luật riêng, nếu không nó lọt lưới.
    final offenders =
        offendersFor(RegExp(r'AppColors\.\w*Subtle(Light|Dark)\b'));
    expect(offenders, isEmpty,
        reason: 'Dùng AppColors.errorSubtle(brightness) và anh em:\n$offenders');
  });

  test('$batchName không dùng emoji làm icon', () {
    final offenders = offendersFor(
        RegExp(r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{27BF}]', unicode: true));
    expect(offenders, isEmpty,
        reason: 'Quyết định thiết kế: Material icon trong ô pastel.\n'
            '$offenders');
  });

  test('$batchName không dùng Colors.* của Material', () {
    // Lookbehind loại `AppColors.` — nếu không, mọi token của app đều bị bắt
    // nhầm vì chuỗi "AppColors.x" có chứa "Colors.x".
    final offenders =
        offendersFor(RegExp(r'(?<!App)\bColors\.(?!transparent)\w+'));
    expect(offenders, isEmpty,
        reason: 'Dùng AppColors.foo(brightness):\n$offenders');
  });

  test('$batchName mọi màn đọc Brightness', () {
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      // Widget con nhận Brightness qua tham số cũng hợp lệ — cái sai là file
      // không hề biết tới Brightness ở bất kỳ dạng nào.
      if (!source.contains('Theme.of(context).brightness') &&
          !source.contains('Brightness brightness')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty,
        reason: 'Màn không đọc Brightness thì không đổi màu theo chế độ:\n'
            '${offenders.join("\n")}');
  });
}
```

- [ ] **Step 2: Trỏ test lô 1 sang helper**

Thay TOÀN BỘ nội dung `test/screens/batch1_dark_mode_test.dart` bằng:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 1', const [
    'lib/presentation/screens/onboarding/welcome_screen.dart',
    'lib/presentation/screens/onboarding/onboarding_screen.dart',
    'lib/presentation/screens/onboarding/interest_selection_screen.dart',
    'lib/presentation/screens/auth/login_screen.dart',
    'lib/presentation/screens/auth/register_screen.dart',
    'lib/presentation/screens/auth/reset_password_screen.dart',
  ]);

  test('lô 1 giữ nguyên các chuỗi E2E bám vào', () {
    // E2E Playwright định vị bằng nhãn hiển thị. Đổi chuỗi là gãy E2E, nên
    // khoá chúng lại ngay trong suite Flutter để biết sớm.
    const anchors = {
      'lib/presentation/screens/onboarding/welcome_screen.dart': [
        'Bắt đầu ngay',
        'Tôi đã có tài khoản',
      ],
      'lib/presentation/screens/onboarding/onboarding_screen.dart': [
        'Tiếp tục',
      ],
    };

    final missing = <String>[];
    anchors.forEach((path, labels) {
      final source = File(path).readAsStringSync();
      for (final label in labels) {
        if (!source.contains(label)) missing.add('$path: "$label"');
      }
    });

    expect(missing, isEmpty,
        reason: 'E2E bám vào các nhãn này, không được đổi:\n'
            '${missing.join("\n")}');
  });
}
```

- [ ] **Step 3: Chạy test lô 1, xác nhận vẫn XANH**

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test test/screens/batch1_dark_mode_test.dart`

Expected: 7 PASS. Đây là refactor thuần — số test và kết quả phải y hệt trước khi rút helper. Nếu đỏ thì helper viết sai, không phải màn lô 1 hỏng.

- [ ] **Step 4: Chứng minh helper thật sự bắt lỗi**

Bước này chống trường hợp "helper rỗng nên test nào cũng xanh". Sửa tạm `lib/presentation/screens/auth/login_screen.dart`, đổi đúng một dòng trong `_StyledTextField`:

```dart
        fillColor: AppColors.surface(brightness),
```

thành:

```dart
        fillColor: AppColors.lightSurface,
```

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test test/screens/batch1_dark_mode_test.dart`

Expected: FAIL ở luật `lô 1 không hardcode AppColors.light*`, và thông báo phải in đúng đường dẫn `login_screen.dart` kèm `AppColors.lightSurface`. Nếu nó FAIL mà không in ra đường dẫn thì phần `reason` của helper hỏng — sửa helper.

Hoàn lại:

```bash
git checkout -- lib/presentation/screens/auth/login_screen.dart
```

Run lại: `flutter test test/screens/batch1_dark_mode_test.dart` → 7 PASS.

- [ ] **Step 5: Chạy toàn bộ suite**

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test`

Expected: 568 PASS.

- [ ] **Step 6: Commit**

```bash
git add test/screens/token_hygiene.dart test/screens/batch1_dark_mode_test.dart
git commit -m "refactor(test): Rut 6 luat ve sinh token thanh helper dung chung"
```

---

### Task 2: `main_shell.dart` — thanh điều hướng dưới

Màn nhỏ nhất nhưng hiện trên mọi màn khác. Làm đầu để sai lộ sớm.

**Files:**
- Modify: `lib/presentation/screens/shell/main_shell.dart`
- Create: `test/screens/batch2_dark_mode_test.dart`

**Interfaces:**
- Consumes: `expectTokenHygiene` (Task 1), `AppColors.primary/textSecondary/surface/border/onPrimary(Brightness)`, `AppShadows.soft(Brightness)`
- Produces: không có API mới — đây là task sửa giao diện.

- [ ] **Step 1: Viết test lô 2, mới liệt kê 1 màn**

Tạo `test/screens/batch2_dark_mode_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 2', const [
    'lib/presentation/screens/shell/main_shell.dart',
  ]);

  test('lô 2 giữ nguyên 4 nhãn thanh điều hướng', () {
    // E2E so khớp `exact: true` với đúng bốn chuỗi này. Đổi bất kỳ chuỗi nào
    // là gãy 4 test điều hướng cùng lúc.
    final source =
        File('lib/presentation/screens/shell/main_shell.dart')
            .readAsStringSync();

    for (final label in const ['Home', 'Train', 'Progress', 'Profile']) {
      expect(source, contains("'$label'"), reason: 'thiếu nhãn "$label"');
    }
  });

  test('main_shell không còn hằng màu thô', () {
    // Shadow của thanh dưới từng viết thẳng Color(0x0D000000)/Color(0x26000000).
    // Màu thô không đổi theo Brightness, và không ai tìm ra nó khi sửa token.
    final source =
        File('lib/presentation/screens/shell/main_shell.dart')
            .readAsStringSync();

    expect(RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)').allMatches(source), isEmpty,
        reason: 'Dùng AppShadows.soft(brightness) thay cho hằng màu thô.');
  });
}
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test test/screens/batch2_dark_mode_test.dart`

Expected: FAIL 4 luật — `AppColors.light*` (`lightTextSecondary`), `AppColors.dark*` (`darkTextSecondary`), `Colors.*` (`Colors.white`), và luật hằng màu thô. Hai luật nhãn và emoji PASS ngay từ đầu.

- [ ] **Step 3: Thêm import và đọc brightness ở `MainShell`**

Trong `lib/presentation/screens/shell/main_shell.dart`, thêm import sau `colors.dart`:

```dart
import '../../../core/theme/shadows.dart';
```

Trong `build()` của `MainShell`, thêm dòng ngay sau `final currentLocation = ...`:

```dart
    final brightness = Theme.of(context).brightness;
```

- [ ] **Step 4: Đổi nền và shadow của thanh dưới**

Thay khối `decoration` của `bottomNavigationBar`:

```dart
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          // Thanh dưới đổ bóng LÊN TRÊN nên phải lật offset của token, và
          // chia đôi vì token soft dành cho thẻ nổi giữa màn, không phải mép.
          boxShadow: AppShadows.soft(brightness)
              .map((s) => BoxShadow(
                    color: s.color,
                    blurRadius: s.blurRadius,
                    offset: Offset(0, -s.offset.dy / 2),
                  ))
              .toList(),
          border: Border(top: BorderSide(color: AppColors.border(brightness))),
        ),
```

- [ ] **Step 5: Đổi màu `_NavItem` sang xanh rêu**

Thay ba dòng đầu trong `build()` của `_NavItem`:

```dart
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final accentColor = AppColors.primary(brightness);
    final mutedColor = AppColors.textSecondary(brightness);
```

Ba dòng cũ bị thay là `AppColors.accentColor(...)` cộng ternary `lightTextSecondary`/`darkTextSecondary` viết tay. Accessor `textSecondary(brightness)` làm đúng việc ternary đó — viết lại bằng tay chỉ tạo thêm chỗ để sai.

- [ ] **Step 6: Đổi chữ trên badge đếm thông báo**

Trong `_NavItem`, badge nằm trên nền `AppColors.error`. Thay:

```dart
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
```

bằng:

```dart
                        style: TextStyle(
                          // CỐ Ý truyền Brightness.light: nền badge là
                          // AppColors.error — hằng đỏ giống nhau ở cả hai chế
                          // độ — nên chữ trên nó phải sáng ở cả hai, không
                          // được lật theo Brightness của màn.
                          color: AppColors.onPrimary(Brightness.light),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
```

- [ ] **Step 7: Chạy test lô 2, xác nhận PASS**

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test test/screens/batch2_dark_mode_test.dart`

Expected: 8 PASS.

- [ ] **Step 8: Chạy analyzer và toàn bộ suite**

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter analyze lib/presentation/screens/shell/main_shell.dart`

Expected: `No issues found!`

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test`

Expected: 576 PASS (568 + 8 mới).

- [ ] **Step 9: Commit**

```bash
git add lib/presentation/screens/shell/main_shell.dart test/screens/batch2_dark_mode_test.dart
git commit -m "feat(ui): Thanh dieu huong duoi theo xanh reu"
```

---

### Task 3: `notification_screen.dart` — màn Thông báo

**Files:**
- Modify: `lib/presentation/screens/home/notification_screen.dart`
- Modify: `test/screens/batch2_dark_mode_test.dart`

**Interfaces:**
- Consumes: `expectTokenHygiene` (Task 1), `AppColors.pastelFor(int, Brightness)`, `AppColors.primary/border/surface/onPrimary(Brightness)`, `SoftBackground`, `PoolCard`, `IconTile`
- Produces: không có API mới.

- [ ] **Step 1: Thêm màn này vào danh sách lô 2**

Trong `test/screens/batch2_dark_mode_test.dart`, sửa lời gọi `expectTokenHygiene` thành:

```dart
  expectTokenHygiene('lô 2', const [
    'lib/presentation/screens/shell/main_shell.dart',
    'lib/presentation/screens/home/notification_screen.dart',
  ]);
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test test/screens/batch2_dark_mode_test.dart`

Expected: FAIL 2 luật — `AppColors.light*` (`lightBorder`) và `Colors.*` (`Colors.white`, `Colors.purple`).

- [ ] **Step 3: Đổi bảng màu theo loại thông báo sang chỉ số pastel**

Màn này gán mỗi loại thông báo một màu. Bản cũ trộn 3 nguồn: hằng ngữ nghĩa (`warning`, `success`), token thương hiệu (`accentColor`), và một màu Material thô (`Colors.purple`). Đổi sang chỉ số pastel để cùng một loại luôn cùng tông, và để `Colors.purple` biến mất.

Trong `_NotificationCard`, thay toàn bộ `_getTypeColor()`:

```dart
  /// Tông pastel của từng loại thông báo. Gán CỐ ĐỊNH theo loại — người dùng
  /// học được màu, nên `level_up` phải luôn là cùng một tông.
  int _getToneIndex() {
    switch (notification.type) {
      case 'streak_warning':
        return 2; // đào
      case 'level_up':
        return 0; // bạc hà
      case 'test_available':
        return 1; // xanh
      case 'match_analysis':
        return 3; // tử đinh hương
      case 'streak_milestone':
        return 4; // bơ
      default:
        return 0;
    }
  }

  /// Màu icon và chấm chưa đọc. Nằm TRÊN ô pastel nên phải là màu đậm.
  Color _getTypeColor() {
    switch (notification.type) {
      case 'streak_warning':
        return AppColors.warning;
      case 'level_up':
        return AppColors.success;
      case 'streak_milestone':
        return AppColors.streak;
      default:
        return AppColors.primary(brightness);
    }
  }
```

- [ ] **Step 4: Đổi thẻ thông báo sang `PoolCard` + `IconTile`**

Thêm import ở đầu file:

```dart
import '../../widgets/icon_tile.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';
```

Trong `build()` của `_NotificationCard`, thay từ `child: InkWell(` cho tới hết khối `Container` bọc ngoài. Cụ thể, thay:

```dart
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isUnread
                ? color.withValues(alpha: 0.05)
                : AppColors.surface(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isUnread
                  ? color.withValues(alpha: 0.2)
                  : AppColors.lightBorder,
            ),
            boxShadow: AppShadows.sm(brightness),
          ),
          child: Row(
```

bằng:

```dart
      // Chưa đọc = bề mặt nổi, đã đọc = bề mặt chìm. Đúng cách PoolCard mã hoá
      // trạng thái, thay cho viền màu mờ của bản cũ.
      child: PoolCard(
        selected: isUnread,
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
```

Và thay ô icon 44×44:

```dart
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: color,
                  size: 22,
                ),
              ),
```

bằng:

```dart
              IconTile(
                icon: _getTypeIcon(),
                toneIndex: _getToneIndex(),
                size: 44,
              ),
```

Xoá hai dấu `)` thừa ở cuối `build()` do bỏ một lớp `InkWell` + `Container`; analyzer ở Step 7 sẽ chỉ ra nếu đếm sai.

**Lưu ý:** `IconTile` luôn tô icon bằng `AppColors.primary(brightness)`, nên màu ngữ nghĩa từ `_getTypeColor()` giờ chỉ còn dùng cho chấm "chưa đọc" và nhãn hành động. Đó là chủ ý: ô pastel mang thông tin loại, icon giữ một màu để lưới thẻ không loang lổ.

- [ ] **Step 5: Đổi nhãn hành động và nền nút xoá**

Thay nền của nhãn hành động (`notification.actionLabel`):

```dart
                        decoration: BoxDecoration(
                          color: AppColors.pastelFor(_getToneIndex(), brightness),
                          borderRadius: BorderRadius.circular(6),
                        ),
```

và chữ của nhãn đó — bản cũ dùng `color: color`, tức màu ngữ nghĩa đậm trên nền màu ngữ nghĩa nhạt. Giờ nền là pastel, `AppColors.warning` (`#F59E0B`) trên pastel đào không đủ tương phản cho chữ 12px. Đổi sang:

```dart
                          style: TextStyle(
                            color: AppColors.textPrimary(brightness),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
```

Thay icon trên nền xoá đỏ:

```dart
        child: Icon(Icons.delete, color: AppColors.onPrimary(Brightness.light)),
```

Cùng lý do như badge ở Task 2: nền `AppColors.error` là hằng đỏ chung cho hai chế độ.

- [ ] **Step 6: Bọc body bằng `SoftBackground` và đổi màu nút AppBar**

Trong `build()` của `NotificationScreen`, thay:

```dart
                style: TextStyle(color: AppColors.accentColor(brightness)),
```

bằng:

```dart
                style: TextStyle(color: AppColors.primary(brightness)),
```

và thay:

```dart
      body: notificationState.notifications.isEmpty
          ? _buildEmptyState(brightness)
          : _buildNotificationList(context, ref, notificationState, brightness),
```

bằng:

```dart
      body: SoftBackground(
        child: notificationState.notifications.isEmpty
            ? _buildEmptyState(brightness)
            : _buildNotificationList(
                context, ref, notificationState, brightness),
      ),
```

- [ ] **Step 7: Chạy analyzer**

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter analyze lib/presentation/screens/home/notification_screen.dart`

Expected: `No issues found!` Nếu báo `AppShadows` không dùng nữa thì xoá import `shadows.dart`.

- [ ] **Step 8: Chạy test lô 2 và toàn bộ suite**

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test test/screens/batch2_dark_mode_test.dart`

Expected: 8 PASS.

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test`

Expected: 576 PASS.

- [ ] **Step 9: Commit**

```bash
git add lib/presentation/screens/home/notification_screen.dart test/screens/batch2_dark_mode_test.dart
git commit -m "feat(ui): Man Thong bao theo o pastel"
```

---

### Task 4: `home_screen.dart` — màn Home

Màn lớn nhất của lô (992 dòng) và là nơi có quyết định thiết kế "3 banner còn 1".

**Files:**
- Modify: `lib/presentation/screens/home/home_screen.dart`
- Modify: `test/screens/batch2_dark_mode_test.dart`

**Interfaces:**
- Consumes: `expectTokenHygiene` (Task 1), `AppColors.primary/primaryDeep/onPrimary/successSubtle/warningSubtle/accentLabel/streak(Brightness)`, `AppColors.pastelFor(int, Brightness)`, `SoftBackground`, `PoolCard`, `IconTile`
- Produces: không có API mới.

- [ ] **Step 1: Thêm màn này vào danh sách lô 2 và khoá nhãn E2E**

Trong `test/screens/batch2_dark_mode_test.dart`, sửa lời gọi thành:

```dart
  expectTokenHygiene('lô 2', const [
    'lib/presentation/screens/shell/main_shell.dart',
    'lib/presentation/screens/home/notification_screen.dart',
    'lib/presentation/screens/home/home_screen.dart',
  ]);
```

Và thêm test mới trước dấu `}` đóng `main()`:

```dart
  test('home giữ nguyên các nhãn E2E bám vào', () {
    final source = File('lib/presentation/screens/home/home_screen.dart')
        .readAsStringSync();

    for (final label in const [
      'Start Training',
      'Start Training Session',
      'View Training History',
      'Read knowledge article',
    ]) {
      expect(source, contains(label), reason: 'thiếu nhãn E2E "$label"');
    }
  });

  test('home chỉ còn đúng một khối gradient', () {
    // Ba mảng màu bão hoà cạnh nhau thì không mảng nào là điểm nhấn. Ngôn ngữ
    // tham chiếu là nền kem tĩnh, đúng một khối màu đậm dẫn mắt.
    final source = File('lib/presentation/screens/home/home_screen.dart')
        .readAsStringSync();

    expect(RegExp(r'LinearGradient\(').allMatches(source), hasLength(1),
        reason: 'Chỉ banner CTA chính được giữ gradient.');
  });
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test test/screens/batch2_dark_mode_test.dart`

Expected: FAIL 3 luật — `*SubtleLight` (`successSubtleLight`, `warningSubtleLight`), `Colors.*` (`Colors.white`, `Colors.blue`), và luật "chỉ còn một gradient" (hiện có 3). Hai luật nhãn PASS ngay.

- [ ] **Step 3: Bọc body bằng `SoftBackground`**

Thêm import:

```dart
import '../../widgets/icon_tile.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';
```

Trong `build()` của `HomeScreen`, thay:

```dart
      body: SafeArea(
        child: SingleChildScrollView(
```

bằng:

```dart
      body: SoftBackground(
        child: SafeArea(
          child: SingleChildScrollView(
```

và thêm một `)` tương ứng ở cuối `body`.

- [ ] **Step 4: Đổi 9 chỗ `accentColor` sang xanh rêu**

Đây là thay đổi cơ học, cùng một dạng ở 9 chỗ. Thay mọi:

```dart
    final accentColor = AppColors.accentColor(brightness);
```

bằng:

```dart
    final accentColor = AppColors.primary(brightness);
```

và mọi lời gọi lẻ `AppColors.accentColor(brightness)` (ví dụ dòng 462) bằng `AppColors.primary(brightness)`.

Cùng lúc, thay 2 chỗ `AppColors.accentSubtle(brightness)` (avatar hồ sơ ở header, ô icon trong `_GoalRow`) bằng `AppColors.pastelFor(0, brightness)`.

**Giữ nguyên tên biến `accentColor`** trong thân hàm — đổi tên biến ở 9 hàm là nhiễu không cần thiết cho một task đã lớn, và nó không phải thứ test kiểm.

- [ ] **Step 5: Banner chính — giữ gradient, đổi sang xanh rêu**

Đây là banner duy nhất còn gradient. Thay khối gradient trong `_buildAICoachSection` (dòng 172):

```dart
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor,
            accentColor.withValues(alpha: 0.8),
          ],
        ),
```

bằng:

```dart
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary(brightness),
            AppColors.primaryDeep(brightness),
          ],
        ),
```

Rồi trong CÙNG hàm này (dòng 160-327), thay cả **9** chỗ `Colors.white` thành `AppColors.onPrimary(brightness)`, và dạng `Colors.white.withValues(alpha: X)` thành `AppColors.onPrimary(brightness).withValues(alpha: X)`.

Riêng nút trắng trên nền gradient (dòng 298):

```dart
                backgroundColor: Colors.white,
```

thành:

```dart
                backgroundColor: AppColors.onPrimary(brightness),
```

và chữ trên nút đó phải là `AppColors.primary(brightness)` để đọc được.

- [ ] **Step 6: Banner trận đấu — bỏ gradient xanh Material**

Thay toàn bộ `Container` + `BoxDecoration` gradient trong `_buildAfterMatchCard` (dòng 338-352):

```dart
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
```

bằng:

```dart
    return PoolCard(
      radius: AppSpacing.radiusLg,
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: Column(
```

Trong thân khối này, thay:

```dart
              const Icon(Icons.sports_score, color: Colors.white, size: 20),
```

bằng:

```dart
              IconTile(icon: Icons.sports_score, toneIndex: 1, size: 36),
```

và **3** chỗ `Colors.white` còn lại trong hàm này thành `AppColors.textPrimary(brightness)`, riêng `Colors.white.withValues(alpha: 0.9)` (dòng 373) thành `AppColors.textSecondary(brightness)`.

Nút trong khối này:

```dart
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade600,
```

thành:

```dart
              backgroundColor: AppColors.primary(brightness),
              foregroundColor: AppColors.onPrimary(brightness),
```

Đóng khối bằng `);` thay vì `),` cuối `Container` — analyzer ở Step 9 sẽ chỉ ra nếu đếm sai dấu.

- [ ] **Step 7: Banner streak — bỏ gradient hổ phách**

Thay khối gradient trong `_buildStreakWarningCard` (dòng 500-515):

```dart
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning,
            AppColors.warningLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
```

bằng:

```dart
    return PoolCard(
      radius: AppSpacing.radiusLg,
      padding: const EdgeInsets.all(AppSpacing.space6),
```

Icon lửa giữ màu ngữ nghĩa của chuỗi ngày:

```dart
                    const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
```

thành:

```dart
                    Icon(Icons.local_fire_department,
                        color: AppColors.streak, size: 20),
```

**3** chỗ `Colors.white` còn lại trong hàm này (dòng 527, 538, 549) thành `AppColors.textPrimary(brightness)`, riêng dạng `withValues(alpha: 0.9)` thành `AppColors.textSecondary(brightness)`. Nút:

```dart
              backgroundColor: Colors.white,
```

thành:

```dart
              backgroundColor: AppColors.primary(brightness),
```

kèm chữ `AppColors.onPrimary(brightness)`.

- [ ] **Step 8: Đổi 2 nền dịu và 1 chỗ `gold`**

Trong `_GoalRow` (quanh dòng 840):

```dart
                color: isDone
                    ? AppColors.successSubtleLight
                    : AppColors.accentSubtle(brightness),
```

thành:

```dart
                color: isDone
                    ? AppColors.successSubtle(brightness)
                    : AppColors.pastelFor(0, brightness),
```

Nhãn "Suggested" (quanh dòng 865):

```dart
                  color: AppColors.warningSubtleLight,
```

thành:

```dart
                  color: AppColors.warningSubtle(brightness),
```

Và `valueColor: AppColors.gold` (dòng 712) thành `valueColor: AppColors.accentLabel(brightness)`. Chỗ này `brightness` là tham số của `_buildProgressSection` nên đã có sẵn trong scope.

Bỏ `Colors.white` trong `_buildEmptyRecommendations` (dòng 564):

```dart
        color: Colors.white.withValues(alpha: 0.8),
```

thành:

```dart
        color: AppColors.onPrimary(brightness).withValues(alpha: 0.8),
```

**Đây KHÔNG phải sửa bug hiển thị — chỉ là bỏ `Colors.*` mà giữ nguyên hiệu quả thị giác.** Hàm này được gọi từ hai nhánh nằm TRONG gradient của `_buildAICoachSection` (dòng 235 và 278), nên nền của nó là xanh rêu đậm chứ không phải nền kem. Chữ sáng ở đây vốn đúng. Xem mục ĐÍNH CHÍNH ở phần đầu plan.

Badge trong `_ActionRow` (quanh dòng 979) nằm trên nền `accentColor`:

```dart
                  style: const TextStyle(
                    color: Colors.white,
```

thành:

```dart
                  style: TextStyle(
                    color: AppColors.onPrimary(brightness),
```

- [ ] **Step 9: Chạy analyzer**

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter analyze lib/presentation/screens/home/home_screen.dart`

Expected: `No issues found!`

Lỗi hay gặp ở bước này là `const_eval_method_invocation` — một `const TextStyle`/`const Icon` giờ chứa lời gọi hàm. Cách sửa là bỏ chữ `const` ở đúng widget đó, không phải bỏ token.

- [ ] **Step 10: Chạy test lô 2 và toàn bộ suite**

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test test/screens/batch2_dark_mode_test.dart`

Expected: 10 PASS.

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test`

Expected: 578 PASS (568 + 10 mới).

- [ ] **Step 11: Chạy E2E**

Build trước, rồi chạy Playwright:

```powershell
$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter build web --release --base-href /
npx playwright test --project=chromium --reporter=line
```

Expected: **22 pass, 4 skip.**

Nếu có test đỏ vì không tìm thấy nhãn thì một chuỗi đã bị đổi ở Step 5-8 — hoàn lại chuỗi đó, đừng sửa test. Bốn test skip là `test.fixme` có sẵn, không liên quan tới lô này.

**Lưu ý build:** dùng PowerShell cho lệnh có `--base-href /`; Git Bash biến `/` thành đường dẫn Windows.

- [ ] **Step 12: Commit**

```bash
git add lib/presentation/screens/home/home_screen.dart test/screens/batch2_dark_mode_test.dart
git commit -m "feat(ui): Man Home theo xanh reu, ba banner con mot diem nhan"
```

---

## Sau kế hoạch này

Còn 5 lô (59 màn): 3. training (19) · 4. play+match (13) · 5. coach (8) · 6. profile (10) · 7. knowledge (4) · 8. community+reports+session (5).

Từ lô 3 trở đi, mỗi lô chỉ cần: thêm danh sách file vào `expectTokenHygiene`, chạy FAIL, quét, chạy PASS. Helper ở Task 1 làm phần lặp lại, nên plan các lô sau ngắn hơn hẳn plan này — phần dài của lô 2 nằm ở quyết định thiết kế banner, không ở luật kiểm.

**Chỉ bật `ThemeMode.system` ở `main.dart:137` sau khi lô 8 xong**, và trước đó chạy một lượt `expectTokenHygiene` trên toàn bộ 68 màn để chắc không còn màn nào hardcode.
