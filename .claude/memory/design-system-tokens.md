---
name: design-system-tokens
description: API gotchas của AppColors/AppShadows/AppSpacing — và cảnh báo các giá trị Sprint-19 đã bị redesign kem-ấm đảo ngược
metadata:
  type: project
---

Design system ở `lib/core/theme/`: `colors.dart`, `spacing.dart`, `shadows.dart`,
`typography.dart`, `app_theme.dart`.

## ⚠️ Bản ghi Sprint-19 của file này ĐÃ LỖI THỜI

Đợt [[warm-green-redesign]] (từ 9/9/2026) đảo ngược ba điều mà bản cũ dạy:

| Bản cũ (Sprint-19) dạy | Thực tế bây giờ |
|---|---|
| `AppColors.accent = #3B82F6` là "token brand duy nhất" | Xanh điện là thứ redesign **tồn tại để loại bỏ**. Brand là `primary` — `#0F4032` sáng / `#34A97C` tối |
| Dùng `AppColors.lightBorder`, `lightTextTertiary` | Màn đã quét **phải** dùng accessor `AppColors.border(brightness)`. Tên tiền tố chỉ còn hợp lệ ở 40 màn chưa quét |
| `radiusSm=6 radiusMd=8 radiusLg=12` | `radiusSm=12 radiusMd=20 radiusLg=28`, thêm `radiusTile=18` |

`AppColors.accent` **vẫn còn trong `colors.dart`** — không phải vì nó đúng, mà
vì 40 màn chưa quét còn dùng. Đừng coi sự tồn tại của nó là lời cho phép.

## Cạm bẫy API còn nguyên giá trị

**1. `AppShadows` có HAI kiểu API — dễ dùng lẫn:**
```dart
AppShadows.lightSm          // getter  → List<BoxShadow>
AppShadows.sm(brightness)   // function → List<BoxShadow>
```
Cả hai trả về `List<BoxShadow>`, **không phải** `BoxShadow`. Gán thẳng vào
`boxShadow:`, đừng bọc thêm `[...]`.

**2. `AppSpacing` dùng tên số, alias thêm sau:**
```dart
space1=4  space2=8  space3=12  space4=16  space5=20  space6=24  space8=32  space12=48  space16=64
// aliases: xs=4 sm=8 md=12 lg=16 xl=20 xxl=24
```

**3. Import hay bị quên:** `AppShadows` ở `lib/core/theme/shadows.dart` —
**không** re-export từ `theme.dart`. Thiếu import này là nguyên nhân phổ biến
của lỗi analyze.

**4. Thêm token màu thì kiểm CẢ HAI chiều** — làm chữ trên nền gì, và làm nền
cho chữ gì. Một chiều là đủ để lọt qua ba vòng review (xem [[warm-green-redesign]]).

**Why:** Ba API này trông giống design system khác nhưng đặt tên khác, nên trực
giác dẫn sai. Và bản ghi cũ giờ **chủ động chỉ sai đường** — nó dạy đúng những
token mà đợt redesign đang gỡ.

**How to apply:** Đọc file này trước khi sửa bất kỳ screen nào. Chạy
`flutter analyze` sau mỗi đợt migrate token. Xem [[sprint-status]].
