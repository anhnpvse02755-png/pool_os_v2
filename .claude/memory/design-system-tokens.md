---
name: design-system-tokens
description: Sprint-19 Minimalist Luxury design tokens - API gotchas that repeatedly caused compile errors
metadata:
  type: project
---

Design system ở `lib/core/theme/`: `colors.dart`, `spacing.dart`, `shadows.dart`, `typography.dart`, `app_theme.dart`.

## Ba cạm bẫy API đã gây lỗi compile lặp lại trong Sprint-19

**1. `AppShadows` có HAI kiểu API — dễ dùng lẫn:**
```dart
AppShadows.lightSm          // getter  → List<BoxShadow>
AppShadows.sm(brightness)   // function → List<BoxShadow>
```
Cả hai trả về `List<BoxShadow>`, **không phải** `BoxShadow`. Gán thẳng vào `boxShadow:`, đừng bọc thêm `[...]`.

**2. `AppColors` dùng tiền tố brightness, không có tên trần:**
```dart
AppColors.lightBorder       // ✅  (KHÔNG phải borderLight)
AppColors.lightTextTertiary // ✅  (KHÔNG phải textTertiary)
AppColors.lightSurface, lightBackground, lightTextPrimary/Secondary
AppColors.darkBorder, darkSurface, ...
AppColors.accent = #3B82F6  // electric blue, token brand duy nhất không có tiền tố
```

**3. `AppSpacing` dùng tên số, alias được thêm sau:**
```dart
space1=4  space2=8  space3=12  space4=16  space5=20  space6=24  space8=32  space12=48  space16=64
radiusSm=6  radiusMd=8  radiusLg=12  radiusFull=9999
// aliases: xs=4 sm=8 md=12 lg=16 xl=20 xxl=24
```

## Import hay bị quên

`AppShadows` nằm ở `lib/core/theme/shadows.dart` — **không** re-export từ `theme.dart`. Thiếu import này là nguyên nhân phổ biến của lỗi analyze.

**Why:** Ba API này trông giống các design system khác nhưng đặt tên khác, nên trực giác dẫn sai — đã tốn nhiều vòng sửa lỗi compile trong Sprint-19.

**How to apply:** Đọc file này trước khi sửa bất kỳ screen nào. Chạy `flutter analyze` sau mỗi đợt migrate token. Xem [[sprint-status]].
