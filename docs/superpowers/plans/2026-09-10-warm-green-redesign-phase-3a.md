# Redesign "Kem ấm & Xanh rêu" — Kế hoạch lô 3a (lõi bài tập)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Quét 3 màn lõi của luồng bài tập — danh sách nhóm bài, chi tiết bài, và phiên tập — sang ngôn ngữ kem ấm + xanh rêu, và thay bức tường thẻ gradient nhiều màu ở màn danh sách bằng ô pastel gán theo danh mục.

**Architecture:** Lô 3 (training, 19 màn, 9328 dòng) quá lớn cho một plan nên chia thành 5 lô con theo luồng người dùng; đây là lô con đầu. Lô này giống **lô 1** chứ không giống lô 2: `drill_list` và `drill_detail` **không đọc `Brightness` một lần nào** — chúng hardcode chế độ sáng hoàn toàn, nên việc chính là cứu dark mode, không phải đổi màu. `drill_session` thì ngược lại, đã brightness-aware sẵn và gần như sạch.

**Tech Stack:** Flutter 3.47.0 · Dart 3.12.2 · flutter_riverpod · go_router · flutter_animate · google_fonts (Plus Jakarta Sans) · flutter_test · Playwright

**Spec:** `docs/superpowers/specs/2026-09-09-warm-green-redesign-design.md`

**Lô đã xong:** `2026-09-09-warm-green-redesign-phase-1.md` (6 màn) · `2026-09-10-warm-green-redesign-phase-2.md` (3 màn)

## Global Constraints

- **KHÔNG dùng emoji làm icon.** Cả 3 màn lô 3a hiện đã sạch emoji — giữ nguyên như vậy.
- **KHÔNG đổi font.** Giữ `GoogleFonts.plusJakartaSans()`.
- **KHÔNG bật `ThemeMode.system`** cho tới khi hết lô 8. `main.dart:137` giữ `ThemeMode.light`.
- **Mọi màn đã quét phải dùng `AppColors.foo(brightness)`** — không để lại `AppColors.lightFoo`, `AppColors.darkFoo`, `AppColors.fooSubtleLight`, `AppColors.accentColor`, `AppColors.accentSubtle`, hay hằng `Color(0xAARRGGBB)` thô. Tám luật trong `test/screens/token_hygiene.dart` gác đúng những thứ này.
- **KHÔNG dùng `Colors.*` của Material.** `Colors.transparent` là ngoại lệ duy nhất.
- Màu chính sáng `#0F4032`, tối `#34A97C`. Nền sáng `#F7F4EC`, tối `#121715`.
- Thang bo góc: `radiusSm = 12`, `radiusMd = 20`, `radiusLg = 28`, `radiusTile = 18`, `radiusFull = 9999`.
- **Chữ và icon đặt trên nền `primary` hoặc trên gradient dùng `AppColors.onPrimary(brightness)` NGUYÊN ĐỘ MỜ.** Không `withValues` trên màu chữ — lô 2 đã đo: alpha 0.8 chỉ đạt 3,15:1 ở chế độ tối. `withValues` vẫn hợp lệ cho nền wash của `Container` và màu `boxShadow`.
- **Chữ trên nền hằng bất biến theo chế độ** (`AppColors.error`, `success`, `warning`) dùng `AppColors.onPrimary(Brightness.light)` — truyền literal, cố ý, vì nền đó giống nhau ở cả hai chế độ. Đã dùng ở `main_shell.dart` và `notification_screen.dart`.
- Sau mỗi task: `flutter test` phải xanh toàn bộ (hiện **581 test**).
- **Lệnh chạy test:** `flutter` KHÔNG có trên PATH. Prefix `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH";`
- **KHÔNG dùng vòng lặp `Get-Content`/`Set-Content` của PowerShell để patch file** — PowerShell 5.1 đọc UTF-8 bằng ANSI và phá hỏng tiếng Việt. Dùng tool Edit.
- **E2E bám vào các nhãn sau — KHÔNG được đổi:**
  - `'${category.drills.length} drills'` trong `drill_list_screen.dart` — Playwright định vị thẻ nhóm bài bằng `getByRole('button', { name: /\d+ drills/i })`. Đổi chuỗi này là gãy test điều hướng.
  - Tên nhóm bài hiển thị (`category.nameVi`), đặc biệt `'Ngắm đánh'` — có locator riêng `/ngắm đánh/i`.
  - `/all drills/i` ở màn training center (không thuộc lô này, nhưng đừng đổi route).

---

## Hiện trạng 3 màn (đã khảo sát, đếm trực tiếp)

| File | Dòng | `light*`/`dark*` | `Colors.*` | `accent*` | `Color(0x…)` thô | đọc Brightness |
|---|---|---|---|---|---|---|
| `drill_list_screen.dart` | 613 | 32 | `white` ×6 | 10 | 4 | **0** |
| `drill_detail_screen.dart` | 1009 | 48 | `white` ×10 | 14 | 0 | **0** |
| `drill_session_screen.dart` | 685 | 0 | `white` ×2 | 1 | 0 | 8 |

Không màn nào có emoji.

**Nền của từng chỗ `Colors.white` — đã truy trực tiếp, không đoán.** (Lô 2 mất một vòng sửa vì tôi kết luận nền từ việc đọc thân hàm mà không truy nơi gọi.)

| File | Dòng | Nền thật | Thành |
|---|---|---|---|
| `drill_list` | 571, 576, 588, 597, 604 | thẻ nhóm bài, nền `LinearGradient(color, color@80%)` | thẻ hết gradient — xem Task 1, chữ thành token thường |
| `drill_list` | 86 | nền `AppColors.accent` | `onPrimary(brightness)` |
| `drill_detail` | 127 | gradient của `SliverAppBar` | `onPrimary(brightness)` |
| `drill_detail` | 389, 391, 395 | vòng tròn nền `AppColors.success` / `AppColors.accent` / màu khoá | `onPrimary(Brightness.light)` — nền hằng bất biến |
| `drill_detail` | 434 | nền `AppColors.success` | `onPrimary(Brightness.light)` |
| `drill_detail` | 485, 855, 1004 | nền `AppColors.accent` | `onPrimary(brightness)` sau khi accent → primary |
| `drill_detail` | 903, 918 | `ChoiceChip` khi được chọn, `selectedColor: AppColors.accent` | `onPrimary(brightness)` |
| `drill_session` | 667, 674 | nút nền `widget.color` (màu truyền vào) | giữ sáng — xem Task 3 |

---

## Quyết định thiết kế của lô này

**Bức tường thẻ gradient ở màn danh sách nhóm bài.** `drill_list_screen.dart` render mỗi nhóm bài thành một thẻ full-width nền `LinearGradient` bão hoà, 11 nhóm liên tiếp trong một lần cuộn. Đây đúng vấn đề lô 2 đã xử ở màn Home, nhưng nặng hơn: 11 mảng màu thay vì 3.

Nguồn màu là `_getColor(int index)` (dòng 511-521):

```dart
  Color _getColor(int index) {
    final colors = [
      AppColors.accent,
      AppColors.warning,
      const Color(0xFF8B5CF6),
      const Color(0xFF14B8A6),
      const Color(0xFFEC4899),
      const Color(0xFF6366F1),
    ];
    return colors[index % colors.length];
  }
```

Hàm này sai ba thứ cùng lúc:
1. Bốn hằng `Color(0x…)` thô — luật thứ 8 cấm.
2. `AppColors.accent` — token xanh điện của thiết kế cũ, luật thứ 7 cấm.
3. **Gán màu theo `index`, tức theo VỊ TRÍ trong danh sách.** Spec đòi "gán theo danh mục ỔN ĐỊNH, không ngẫu nhiên — người dùng học được màu, nên cùng một danh mục phải luôn cùng tông". Thêm hay sắp xếp lại một nhóm bài là mọi nhóm sau nó đổi màu.

Cách xử lý: bỏ hẳn `_getColor`, thay bằng `_toneFor(String categoryId)` gán cố định theo **id** chứ không theo vị trí, và thẻ chuyển từ gradient sang `PoolCard` + `IconTile`. Đây đúng khuôn đã dùng cho `interest_selection_screen.dart` ở lô 1.

11 nhóm bài trên 5 tông pastel thì có lặp; điều đó chấp nhận được và spec đã lường (`pastelFor` lặp vòng). Cái không chấp nhận được là màu **đổi** khi danh sách đổi.

---

## Cấu trúc file

| File | Trách nhiệm |
|---|---|
| `test/screens/batch3a_dark_mode_test.dart` | Tạo: áp `expectTokenHygiene` cho lô 3a, thêm dần từng màn |
| `lib/presentation/screens/training/drill_list_screen.dart` | Sửa: bỏ tường gradient, tông pastel theo id |
| `lib/presentation/screens/training/drill_detail_screen.dart` | Sửa: 48 token cứng, 14 accent, 10 `Colors.white` |
| `lib/presentation/screens/training/drill_session_screen.dart` | Sửa: 2 `Colors.white`, 1 accent |

---

### Task 1: `drill_list_screen.dart` — danh sách nhóm bài

**Files:**
- Modify: `lib/presentation/screens/training/drill_list_screen.dart`
- Create: `test/screens/batch3a_dark_mode_test.dart`

**Interfaces:**
- Consumes: `expectTokenHygiene(String, List<String>)` từ `test/screens/token_hygiene.dart`; `PoolCard`, `IconTile`, `SoftBackground`; `AppColors.primary/onPrimary/textPrimary/textSecondary/textTertiary/surface/border/background(Brightness)`, `AppColors.pastelFor(int, Brightness)`
- Produces: không có API mới.

- [ ] **Step 1: Viết test lô 3a, mới liệt kê 1 màn**

Tạo `test/screens/batch3a_dark_mode_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 3a', const [
    'lib/presentation/screens/training/drill_list_screen.dart',
  ]);

  test('lô 3a giữ nhãn E2E của thẻ nhóm bài', () {
    // Playwright định vị thẻ nhóm bài bằng getByRole('button', name: /\d+ drills/i).
    // Đổi chuỗi này là gãy test điều hướng sang danh sách bài.
    final source =
        File('lib/presentation/screens/training/drill_list_screen.dart')
            .readAsStringSync();

    expect(source, contains(r"${category.drills.length} drills"),
        reason: 'E2E bám vào chuỗi "<n> drills"');
  });

  test('màu nhóm bài gán theo id, không theo vị trí trong danh sách', () {
    // Spec: cùng một danh mục phải LUÔN cùng tông, để người dùng học được màu.
    // Gán theo index nghĩa là thêm/bớt một nhóm sẽ đổi màu mọi nhóm sau nó.
    final source =
        File('lib/presentation/screens/training/drill_list_screen.dart')
            .readAsStringSync();

    expect(source, isNot(contains('_getColor(')),
        reason: 'Hàm gán màu theo index phải bị bỏ');
    expect(source, contains('_toneFor('),
        reason: 'Phải có hàm gán tông theo id danh mục');
    expect(source, contains("case 'aiming'"),
        reason: '_toneFor phải switch trên id danh mục');
  });
}
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test test/screens/batch3a_dark_mode_test.dart`

Expected: FAIL 5 luật — `AppColors.light*` (32 chỗ), `Colors.*` (`Colors.white`), `AppColors.accent*` (10 chỗ), hằng `Color(0x…)` thô (4 chỗ), và luật đọc `Brightness` (màn này không đọc lần nào) — cộng test `_toneFor` chưa tồn tại. Luật `dark*`, luật `Subtle*`, luật emoji và test nhãn E2E PASS ngay.

- [ ] **Step 3: Thay `_getColor` bằng `_toneFor`**

Trong `lib/presentation/screens/training/drill_list_screen.dart`, thay toàn bộ hàm ở dòng 511-521:

```dart
  Color _getColor(int index) {
    final colors = [
      AppColors.accent,
      AppColors.warning,
      const Color(0xFF8B5CF6),
      const Color(0xFF14B8A6),
      const Color(0xFFEC4899),
      const Color(0xFF6366F1),
    ];
    return colors[index % colors.length];
  }
```

bằng:

```dart
  /// Tông pastel của nhóm bài, gán CỐ ĐỊNH theo id — KHÔNG theo vị trí trong
  /// danh sách. Người dùng học được màu, nên thêm hoặc sắp xếp lại một nhóm
  /// không được làm đổi màu các nhóm khác.
  ///
  /// 11 nhóm trên 5 tông thì có lặp; spec đã lường điều đó. Cái không chấp
  /// nhận được là màu ĐỔI khi danh sách đổi.
  int _toneFor(String categoryId) {
    switch (categoryId) {
      case 'aiming':
        return 0;
      case 'cueball':
        return 1;
      case 'position':
        return 2;
      case 'safety':
        return 3;
      case 'special':
        return 4;
      case 'break':
        return 2;
      case 'spin':
        return 1;
      case 'pattern':
        return 3;
      case 'fundamentals':
        return 0;
      case 'mental':
        return 4;
      case 'situations':
        return 1;
      default:
        return 0;
    }
  }
```

- [ ] **Step 4: Đổi thẻ nhóm bài từ gradient sang `PoolCard` + `IconTile`**

Thêm import ở đầu file:

```dart
import '../../widgets/icon_tile.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';
```

Trong `itemBuilder` (quanh dòng 538-606), thay:

```dart
          final category = DrillLibrary.categories[index];
          final color = _getColor(index);

          return InkWell(
            onTap: () => context.push('/training/drills/${category.id}'),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
```

bằng:

```dart
          final category = DrillLibrary.categories[index];
          final tone = _toneFor(category.id);

          return PoolCard(
            onTap: () => context.push('/training/drills/${category.id}'),
            radius: AppSpacing.radiusLg,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
```

Rồi trong thân `Row` đó, thay ô icon 56×56:

```dart
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(
                      _getIcon(category.icon),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
```

bằng:

```dart
                  IconTile(
                    icon: _getIcon(category.icon),
                    toneIndex: tone,
                    size: 56,
                  ),
```

và ba chỗ chữ còn lại trong thẻ:

```dart
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
```

thành `color: AppColors.textPrimary(brightness)`;

```dart
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
```

thành `color: AppColors.textSecondary(brightness)` (bỏ hẳn `withValues`);

```dart
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
```

thành:

```dart
                  Icon(Icons.arrow_forward_ios,
                      color: AppColors.textTertiary(brightness), size: 18),
```

**KHÔNG đổi chuỗi `'${category.drills.length} drills'`** — E2E bám vào nó.

Đóng khối bằng `);` thay vì các dấu đóng của `InkWell`+`Container`; chạy analyzer sau bước này để bắt sai lệch dấu ngoặc thay vì đếm tay.

- [ ] **Step 5: Thêm `brightness` và chuyển 32 token cứng**

Màn này không đọc `Brightness` lần nào. Với **mỗi** hàm `build()` và `_build*()` trong file, thêm dòng đầu tiên:

```dart
    final brightness = Theme.of(context).brightness;
```

Hàm nào không có `BuildContext` thì thêm tham số `Brightness brightness` và truyền từ nơi gọi — đó là mẫu `_NotificationCard` đã dùng ở lô 2 và luật thứ 6 chấp nhận.

Rồi thay theo bảng, **đúng thứ tự này** để tránh va chạm tiền tố (`accentSubtle` phải đi trước `accent`):

| Từ | Thành |
|---|---|
| `AppColors.accentSubtle(...)` / `AppColors.accentSubtleLight` | `AppColors.pastelFor(0, brightness)` |
| `AppColors.accentColor(brightness)` | `AppColors.primary(brightness)` |
| `AppColors.accent` | `AppColors.primary(brightness)` |
| `AppColors.lightBackground` | `AppColors.background(brightness)` |
| `AppColors.lightSurface` | `AppColors.surface(brightness)` |
| `AppColors.lightBorder` | `AppColors.border(brightness)` |
| `AppColors.lightTextPrimary` | `AppColors.textPrimary(brightness)` |
| `AppColors.lightTextSecondary` | `AppColors.textSecondary(brightness)` |
| `AppColors.lightTextTertiary` | `AppColors.textTertiary(brightness)` |

Chỗ `Colors.white` ở dòng 86 nằm trên nền `AppColors.accent` (sau khi đổi là `primary`) → `AppColors.onPrimary(brightness)`.

- [ ] **Step 6: Bọc `body` bằng `SoftBackground`**

Trong `build()` của màn, đổi `backgroundColor` của `Scaffold` sang `AppColors.background(brightness)` và bọc `body:` bằng `SoftBackground(child: ...)`, thêm một `)` tương ứng.

- [ ] **Step 7: Chạy analyzer**

Run: `$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter analyze lib/presentation/screens/training/drill_list_screen.dart`

Expected: `No issues found!`

Lỗi hay gặp: `const_eval_method_invocation` — một `const TextStyle`/`const Icon` giờ chứa lời gọi hàm. Bỏ `const` ở đúng widget đó, **không** quay lại màu cứng.

Nếu analyzer báo warning có sẵn từ trước (import thừa, biến chết), dọn luôn — nhưng ghi rõ trong báo cáo là dọn thêm ngoài phạm vi, và nói rõ từng chỗ.

- [ ] **Step 8: Chạy test lô 3a và toàn bộ suite**

Run: `flutter test test/screens/batch3a_dark_mode_test.dart` → Expected: 10 PASS (8 luật + 2 test riêng).

Run: `flutter test` → Expected: 591 PASS (581 + 10 mới).

- [ ] **Step 9: Commit**

```bash
git add lib/presentation/screens/training/drill_list_screen.dart test/screens/batch3a_dark_mode_test.dart
git commit -m "feat(ui): Danh sach nhom bai theo o pastel, mau gan theo id"
```

---

### Task 2: `drill_detail_screen.dart` — chi tiết bài tập

Màn lớn nhất của lô 3a (1009 dòng, 24 hàm build) và nặng token nhất (48 token cứng, 14 accent, 10 `Colors.white`).

**Files:**
- Modify: `lib/presentation/screens/training/drill_detail_screen.dart`
- Modify: `test/screens/batch3a_dark_mode_test.dart`

**Interfaces:**
- Consumes: như Task 1
- Produces: không có API mới.

- [ ] **Step 1: Thêm màn này vào danh sách lô 3a**

Trong `test/screens/batch3a_dark_mode_test.dart`, sửa lời gọi thành:

```dart
  expectTokenHygiene('lô 3a', const [
    'lib/presentation/screens/training/drill_list_screen.dart',
    'lib/presentation/screens/training/drill_detail_screen.dart',
  ]);
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

Run: `flutter test test/screens/batch3a_dark_mode_test.dart`

Expected: FAIL 4 luật — `AppColors.light*` (48 chỗ), `Colors.*` (`Colors.white` ×10), `AppColors.accent*` (14 chỗ), và luật đọc `Brightness`. Luật `dark*`, `Subtle*`, raw-color và emoji PASS.

- [ ] **Step 3: Thêm `brightness` vào 24 hàm build**

Với mỗi hàm `build()` / `_build*()`, thêm dòng đầu:

```dart
    final brightness = Theme.of(context).brightness;
```

Hàm không có `BuildContext` thì nhận `Brightness brightness` qua tham số và truyền từ nơi gọi.

- [ ] **Step 4: Chuyển token theo đúng bảng ở Task 1 Step 5**

Cùng bảng, cùng thứ tự (`accentSubtle` trước `accent`).

- [ ] **Step 5: Xử lý 10 chỗ `Colors.white` theo nền THẬT của từng chỗ**

Đây là chỗ dễ sai nhất và đã sai hai lần ở các lô trước. Nền của từng dòng đã được truy trực tiếp:

| Dòng | Nền thật | Thành |
|---|---|---|
| 127 | gradient của `SliverAppBar` | `AppColors.onPrimary(brightness).withValues(alpha: 0.3)` — **giữ nguyên alpha**. Đây là icon trang trí cỡ 80 nằm sau nội dung, không phải chữ để đọc, nên luật "không `withValues` trên màu chữ" không áp dụng. Nó là hoa văn nền, cùng loại với wash của `Container` |
| 389 | vòng tròn nền `AppColors.success` (hằng bất biến) | `AppColors.onPrimary(Brightness.light)` |
| 391 | vòng tròn nền màu khoá | `AppColors.onPrimary(Brightness.light)` |
| 395 | vòng tròn nền `AppColors.accent` → `primary` | `AppColors.onPrimary(brightness)` |
| 434 | nền `AppColors.success` | `AppColors.onPrimary(Brightness.light)` |
| 485 | nền `AppColors.accent` → `primary` | `AppColors.onPrimary(brightness)` |
| 855 | nền `AppColors.accent` → `primary` | `AppColors.onPrimary(brightness)` |
| 903 | `ChoiceChip` được chọn, `selectedColor: AppColors.accent` → `primary` | `AppColors.onPrimary(brightness)` |
| 918 | như trên | `AppColors.onPrimary(brightness)` |
| 1004 | nền `AppColors.accent` → `primary` | `AppColors.onPrimary(brightness)` |

Quy tắc để nhớ: nền là **hằng bất biến theo chế độ** (`success`/`error`/`warning`) thì truyền literal `Brightness.light`; nền là **token theo chế độ** (`primary`) thì truyền `brightness`.

- [ ] **Step 6: Bọc `body` bằng `SoftBackground`**

Đổi `backgroundColor` của `Scaffold` sang `AppColors.background(brightness)`. Màn này dùng `CustomScrollView`/`SliverAppBar` — bọc `SoftBackground` **quanh `body`**, không quanh từng sliver.

- [ ] **Step 7: Chạy analyzer**

Run: `flutter analyze lib/presentation/screens/training/drill_detail_screen.dart`
Expected: `No issues found!`

- [ ] **Step 8: Chạy test và suite**

Run: `flutter test test/screens/batch3a_dark_mode_test.dart` → Expected: 10 PASS.
Run: `flutter test` → Expected: 591 PASS (Task 2 không thêm test mới).

- [ ] **Step 9: Commit**

```bash
git add lib/presentation/screens/training/drill_detail_screen.dart test/screens/batch3a_dark_mode_test.dart
git commit -m "feat(ui): Man chi tiet bai tap theo xanh reu"
```

---

### Task 3: `drill_session_screen.dart` — phiên tập, và chạy E2E

Màn này đã brightness-aware (8 chỗ đọc `Brightness`) và gần như sạch: chỉ 2 `Colors.white` và 1 `accentColor`. Task nhẹ nhất, nên gộp luôn bước E2E của cả lô.

**Files:**
- Modify: `lib/presentation/screens/training/drill_session_screen.dart`
- Modify: `test/screens/batch3a_dark_mode_test.dart`

**Interfaces:**
- Consumes: như Task 1
- Produces: không có API mới.

- [ ] **Step 1: Thêm màn này vào danh sách lô 3a**

```dart
  expectTokenHygiene('lô 3a', const [
    'lib/presentation/screens/training/drill_list_screen.dart',
    'lib/presentation/screens/training/drill_detail_screen.dart',
    'lib/presentation/screens/training/drill_session_screen.dart',
  ]);
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

Run: `flutter test test/screens/batch3a_dark_mode_test.dart`

Expected: FAIL 3 luật — `Colors.*` (`Colors.white` ×2), `AppColors.accent*` (`accentColor` ×1), và luật `Subtle*` (1 chỗ `*SubtleLight`). Các luật khác PASS.

- [ ] **Step 3: Sửa nút nền màu truyền vào**

Hai chỗ `Colors.white` (dòng 667, 674) nằm trên nút có nền `widget.color` — một màu truyền từ nơi gọi, không phải token cố định, nên không thể suy ra chế độ.

Đổi cả hai thành `AppColors.onPrimary(Brightness.light)` và thêm comment giải thích:

```dart
              // Nền là widget.color do nơi gọi truyền vào — không suy ra được
              // chế độ từ đây, và mọi nơi gọi hiện truyền màu đậm bão hoà.
              // Chữ sáng là lựa chọn an toàn cho cả hai chế độ.
              Icon(widget.icon,
                  color: AppColors.onPrimary(Brightness.light), size: 24),
```

Nếu khảo sát cho thấy có nơi gọi truyền màu nhạt, dừng lại và báo — lúc đó cần đổi chữ ký để nhận cả màu chữ.

- [ ] **Step 4: Đổi `accentColor` và token `*SubtleLight`**

`AppColors.accentColor(brightness)` → `AppColors.primary(brightness)`.
Token `*SubtleLight` → accessor tương ứng `AppColors.errorSubtle/warningSubtle/successSubtle(brightness)`.

- [ ] **Step 5: Chạy analyzer, test lô, và toàn bộ suite**

Run: `flutter analyze lib/presentation/screens/training/drill_session_screen.dart` → `No issues found!`
Run: `flutter test test/screens/batch3a_dark_mode_test.dart` → 10 PASS.
Run: `flutter test` → 591 PASS.

- [ ] **Step 6: Chạy E2E**

```powershell
$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter build web --release --base-href /
npx playwright test --project=chromium --reporter=line
```

Expected: **22 pass, 4 skip.**

Nếu test `should navigate to all drills` hoặc test nhóm bài đỏ, nghĩa là một chuỗi hiển thị đã bị đổi ở Task 1 — hoàn lại chuỗi, **đừng sửa test**. Locator bám vào `/\d+ drills/i` và `/ngắm đánh/i`.

**Lưu ý build:** dùng PowerShell cho lệnh có `--base-href /`; Git Bash biến `/` thành đường dẫn Windows.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/screens/training/drill_session_screen.dart test/screens/batch3a_dark_mode_test.dart
git commit -m "feat(ui): Man phien tap theo xanh reu, hoan tat lo 3a"
```

---

## Sau kế hoạch này

Còn 4 lô con của lô 3 (16 màn), rồi 4 lô lớn (40 màn):

| Lô con | Màn | Dòng |
|---|---|---|
| 3b | `drill_recording_preparation` · `drill_result` · `drill_completion` · `session_detail` | 1685 |
| 3c | `training_center` · `learning_path` · `recommended` · `assessment` | 2177 |
| 3d | `knowledge` · `knowledge_detail` · `certification_list` · `certification_detail` | 1516 |
| 3e | `progress` · `training_history` · `trend_dashboard` · `unified_timeline` | 1643 |

Hai việc còn nợ từ lô 2, nên gộp vào một lô con sau của lô 3:

1. **`AppColors.accentLabelLight` không bị luật nào bắt.** Luật 7 dùng `accent(Color|Subtle|Light|Dark)?\b` nên `\b` không khớp giữa `t` và `L`; luật 1 đòi `light` ở đầu tên; luật 3 đòi có đoạn `Subtle`. Sửa cùng lúc với việc rà `accentLabel` và các biến thể.
2. **`_NotificationCard` chưa có widget test.** Luật đọc-mã-nguồn không bắt được `Dismissible.onDismissed` bị vô hiệu hay `maxLines` bị rơi.

**Chỉ bật `ThemeMode.system` ở `main.dart:137` sau khi hết lô 8**, và trước đó chạy `expectTokenHygiene` trên toàn bộ 68 màn. Mọi tỉ lệ tương phản ghi trong các plan đến giờ là **tính toán, chưa phải quan sát** — dark mode chưa từng chạy thật.
