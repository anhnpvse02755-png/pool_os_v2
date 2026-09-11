---
name: warm-green-redesign
description: Redesign "Kem ấm & Xanh rêu" — 8 lô quét 68 màn, đang ở lô 3 xong, 40 màn còn lại
metadata:
  type: project
---

Đợt redesign đang chạy (bắt đầu 9/9/2026), thay ngôn ngữ **xanh điện →
kem ấm + xanh rêu**. Nhánh `feat/warm-green-3bcde`.

**Giá trị chốt:**

| | Sáng | Tối |
|---|---|---|
| primary | `#0F4032` | `#34A97C` |
| nền | `#F7F4EC` | `#121715` |

Bo góc: `radiusSm=12` `radiusMd=20` `radiusLg=28` `radiusTile=18` `radiusFull=9999`.

**Ba luật xuyên suốt:**

1. Màn đã quét **phải** dùng accessor `AppColors.foo(brightness)` — không
   được để lại `AppColors.lightFoo` / `darkFoo` / `fooSubtleLight`.
2. Không `Colors.*` của Material (`Colors.transparent` là ngoại lệ duy nhất).
   Không emoji làm icon — dùng Material icon trong ô pastel.
3. `main.dart:137` giữ `ThemeMode.light` **cho tới khi hết lô 8**. Mọi tỉ lệ
   tương phản chế độ tối ghi trong plan đều là **tính toán, chưa quan sát**.

**Tiến độ:** lô 1 (token + 6 component + onboarding/auth), lô 2 (shell/home),
lô 3a–3e (20 màn training) — xong. Còn **40 màn**: coach, play, profile,
knowledge, match, session, reports, community.

**Bài học đắt nhất (lô 3a):** thêm một token màu thì phải kiểm **CẢ HAI
chiều** — nó làm chữ trên nền gì, và nó làm nền cho chữ gì. `difficultyExpert`
chỉ được kiểm một chiều nên nút back tụt 3,16 → 2,03:1 ở chế độ SÁNG, lọt qua
cả ba vòng review.

**Việc còn nợ:** `_NotificationCard` (lô 2) chưa có widget test ·
`DrillListScreen` chưa đổi hết sang `PoolCard`/`IconTile`.

**Why:** Đây là đợt thay đổi lớn nhất kể từ Sprint-19 và nó **đảo ngược** các
quy ước token của Sprint-19 — xem [[design-system-tokens]].

**How to apply:** Đọc plan ở `docs/superpowers/plans/2026-09-*-warm-green-*.md`
trước khi mở lô mới. Chạy `expectTokenHygiene` (10 luật, `test/screens/token_hygiene.dart`)
cho mỗi màn quét xong. Xem [[sprint-status]].
