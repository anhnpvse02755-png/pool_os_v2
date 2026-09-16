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

**Tiến độ: XONG TOÀN BỘ 68/68 màn** (11/9/2026). Lô 1 (token + 6 component +
onboarding/auth), lô 2 (shell/home), lô 3a–3e (20 màn training), lô 4 (40 màn
còn lại, 8 nhóm: community → session → reports → match → knowledge → coach →
profile → play).

`flutter analyze` 0 error · `flutter test` 767/767 · `expectTokenHygiene` phủ
đủ 68 màn.

**`ThemeMode.system` ĐÃ BẬT** (11/9/2026) và đã kiểm bằng mắt — không chỉ bằng
tính toán. Dựng web thật, chụp 6 màn qua Playwright với `colorScheme: 'dark'`,
đo độ sáng ảnh: cả 6 ra nền tối và có nội dung.

Spec ở `tests/90-dark-mode-visual.spec.ts` + bộ giải mã PNG tối giản ở
`tests/helpers/png-luminance.ts` (Flutter Web vẽ bằng WebGL nên `getImageData`
trả null — phải đo trên ảnh chụp của Playwright).

**Bài học đắt nhất (lô 3a):** thêm một token màu thì phải kiểm **CẢ HAI
chiều** — nó làm chữ trên nền gì, và nó làm nền cho chữ gì. `difficultyExpert`
chỉ được kiểm một chiều nên nút back tụt 3,16 → 2,03:1 ở chế độ SÁNG, lọt qua
cả ba vòng review.

**Việc còn nợ:** `_NotificationCard` (lô 2) chưa có widget test ·
`DrillListScreen` chưa đổi hết sang `PoolCard`/`IconTile` (còn 3 `Card` thô) ·
**nhãn nút VÔ HIỆU chỉ đạt 2,59:1** (nền `textTertiary`, chữ `onPrimary`) —
khuôn này trải trên ít nhất 8 màn nên cần một task đổi đồng loạt, WCAG miễn trừ
nên không có test nào bắt · **`ColorScheme.onError` là trắng trên #EF4444 =
3,76:1** — cần một token mực cho nền đỏ, theo khuôn `onGold`.

**Luật hygiene không đo tương phản** — nó đọc mã nguồn. Nó cũng quét cả
COMMENT, nên đừng viết tên token bị cấm hay emoji vào chú thích.

## Lỗ cuối: `ThemeData` (sửa 16/9/2026)

Vệ sinh token về 0 vi phạm mà xanh điện **vẫn hiển thị**: `ColorScheme.primary`
của cả `lightTheme` lẫn `darkTheme` được nạp `AppColors.accent` = #3B82F6.
Mười luật hygiene đọc CÁCH VIẾT nên không luật nào bắt được
`Theme.of(context).colorScheme.primary` — một lời gọi hợp lệ tới một token hợp
lệ, cái sai nằm ở GIÁ TRỊ. Xanh điện qua đó chảy ra ~200 điểm: `PrimaryButton`
(24 màn), 56 `ElevatedButton`, 50 `TextButton`, viền focus input, chip đã chọn,
progress, switch, bottom nav, NavigationBar.

Sửa: `app_theme.dart` đổi toàn bộ họ `accent*` sang `primary(b)` /
`accentLabel(b)` / `primarySubtle(b)`, `Colors.white` sang `onPrimary(b)`, và
`onSecondary` sang `onGold(b)` (trắng trên gold chỉ 3,82). Xoá luôn khối 10
alias `AppTheme.*` — đã hết điểm dùng sau lô A–F.

Token mới `primarySubtle`: `#EAF2ED` sáng / `#1A3D30` tối — bản xanh rêu của
`accentSubtle`, dùng cho pill chip đã chọn và vệt chỉ mục NavigationBar (khác
`primaryContainer`, vốn là mảng xanh ĐẶC để chữ trắng đè lên).

Canh gốc theme: `test/theme/color_scheme_test.dart` — 24 test, khẳng định
không điểm sơn nào trong `ThemeData` trùng năm hằng số họ `accent`, cộng
tương phản hai chiều tại từng điểm vừa đổi.

**Bẫy khi test `ThemeData`:** dựng theme trong thân `main()` là lỗi "Binding has
not yet been initialized" (GoogleFonts cần binding). Dựng trong thân test thì
gặp bẫy thứ hai: GoogleFonts nạp font BẤT ĐỒNG BỘ, trong test luôn hỏng, và lỗi
nổ sau khi test gọi nó đã xong nên làm đỏ test KẾ TIẾP ("This test failed after
it had already completed") dù mọi assertion đều đúng — 22/24 đỏ vì lý do này.
Bọc `runZonedGuarded` quanh chỗ dựng theme thì hết.

## Chip không được nằm trong vùng cuộn ngang

Tìm ra khi nhìn ảnh thật: mọi chip lọc **cụt ký tự cuối** ("Kiểm Soát Vị Trí" →
"Kiểm Soát Vị Tr"). Có ở **cả hai chế độ**, không phải lỗi của chế độ tối.

Nguyên nhân: trong `ListView`/`SingleChildScrollView` cuộn ngang, con được cấp
**bề rộng vô hạn**; Material Chip đo bề rộng nhãn trong hoàn cảnh đó bị hụt rồi
cắt phần thừa. Đặt trong **`Wrap`** thì hết.

Ba giả thuyết đã loại trừ bằng thực nghiệm (đừng thử lại): `height: 50` bó chip,
`google_fonts` tải chậm, thiếu `labelPadding`.

Luật chặn tái phát: `test/screens/chip_layout_test.dart`.

**Why:** Đây là đợt thay đổi lớn nhất kể từ Sprint-19 và nó **đảo ngược** các
quy ước token của Sprint-19 — xem [[design-system-tokens]].

**How to apply:** Đọc plan ở `docs/superpowers/plans/2026-09-*-warm-green-*.md`
trước khi mở lô mới. Chạy `expectTokenHygiene` (10 luật, `test/screens/token_hygiene.dart`)
cho mỗi màn quét xong. Xem [[sprint-status]].
