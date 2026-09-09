# Redesign PoolOS — ngôn ngữ "Kem ấm & Xanh rêu"

**Ngày:** 2026-09-09
**Trạng thái:** Đã duyệt hướng, chờ duyệt spec
**Thay thế:** Sprint-19 "Minimalist Luxury"

---

## Mục tiêu

Đổi toàn bộ giao diện PoolOS sang ngôn ngữ thiết kế trong hai ảnh tham chiếu
người dùng cung cấp: nền kem ấm có blob màu mềm, xanh rêu đậm làm màu chính,
thẻ bo góc lớn, icon đặt trong ô pastel, chữ to và đậm.

**Không phải** một lớp sơn: nó đổi token nền (màu, thang bo góc, shadow) mà cả
68 màn hình đang ăn theo.

---

## Quyết định đã chốt

| Câu hỏi | Quyết định | Ghi chú |
|---|---|---|
| Phạm vi | **Toàn bộ 68 màn** | |
| Dark mode | **Giữ và làm cho đúng** | Hiện đang bị tắt cứng và sẽ vỡ nếu bật |
| Icon | **Material icon trong ô pastel** | KHÔNG dùng emoji, dù ảnh mẫu có |
| Font | **Giữ Plus Jakarta Sans** | Đã gần với ảnh mẫu; đổi font buộc kiểm lại toàn bộ line-height |
| Cách triển khai | **Token → component → quét theo lô** | |

### Vì sao không dùng emoji dù ảnh mẫu có

Ảnh mẫu dùng emoji cho mục lớn (🔴🎱💰🏆) và avatar người chơi (🐮🐹🦄). Người
dùng chọn giữ Material icon vì: emoji hiển thị khác nhau giữa các hệ điều
hành, và trình đọc màn hình đọc tên emoji nghe lạc lõng trong một nền tảng
huấn luyện. Vẻ vui tươi được giữ lại bằng **ô pastel bao quanh icon** — đó mới
là thứ tạo cảm giác ấm trong ảnh, không phải bản thân emoji.

---

## Hiện trạng cần biết trước khi làm

```
68 màn hình · 261 file Dart
53/68 màn hardcode AppColors.light*     <- sẽ vỡ nếu bật dark mode
19/68 màn có đọc Brightness
main.dart:137  themeMode: ThemeMode.light   <- ép sáng, dark chưa từng chạy
```

**Đây là phát hiện định hình cả kế hoạch.** App khai báo có dark mode
(`AppTheme.darkTheme` tồn tại) nhưng ép sáng và 53 màn sẽ vỡ nếu bật. Việc sửa
53 màn đó là **bắt buộc** cho dark mode, và nó **trùng khít** với việc quét
redesign. Gộp làm một lượt thay vì hai.

---

## Lớp 1 — Token màu

### Sáng (đọc trực tiếp từ ảnh tham chiếu)

| Vai trò | Hex | Ghi chú |
|---|---|---|
| `background` | `#F7F4EC` | kem ấm |
| `backgroundBlobPeach` | `#FBE9DC` | opacity 0.5-0.7, blur lớn |
| `backgroundBlobMint` | `#DFEFE4` | |
| `backgroundBlobButter` | `#FDF6E3` | |
| `surface` | `#FFFFFF` | thẻ |
| `surfaceRecessed` | `#F1EFEA` | thẻ chưa chọn (ảnh 2) |
| **`primary`** | `#0F4032` | xanh rêu đậm — thanh điểm, nút chính |
| `primaryDeep` | `#08291F` | nhấn mạnh hơn |
| `textPrimary` | `#12352B` | gần đen, ám xanh |
| `textSecondary` | `#5E6661` | xám ấm — sẫm hơn để đạt 4.5:1 trên nền kem |
| `accentLabel` | `#0F7A55` | nhãn hành động ("Chọn làm người bắn") |
| `border` | `#E7E3DA` | |

### Tối (thiết kế mới — ảnh mẫu không có bản tối)

Nguyên tắc: **không đen thuần.** Nền là than ám xanh để giữ hơi ấm của ngôn
ngữ gốc, và xanh chính phải sáng lên đáng kể mới đủ tương phản trên nền tối.

| Vai trò | Hex |
|---|---|
| `background` | `#121715` |
| `surface` | `#1B221F` |
| `surfaceElevated` | `#232B27` |
| **`primary`** | `#34A97C` |
| `primaryContainer` | `#16382C` |
| `textPrimary` | `#ECF1EE` |
| `textSecondary` | `#9AA6A0` |
| `border` | `#2C3531` |

### Ô icon pastel — 5 tông luân phiên

| | Sáng | Tối |
|---|---|---|
| mint | `#DCEFE5` | `#1C3830` |
| blue | `#DCE7F7` | `#1B2A3C` |
| peach | `#FBE7DA` | `#38281F` |
| lilac | `#EAE3F7` | `#2A2438` |
| butter | `#FBF0D5` | `#33301F` |

Gán tông theo **danh mục ổn định** (ví dụ: Ngắm bắn luôn mint, Chiến lược luôn
lilac), không gán ngẫu nhiên — người dùng học được màu.

### Màu trạng thái

Giữ nguyên `success #10B981`, `error #DC2626`, `warning #F59E0B` — chúng đã
hoạt động và không mâu thuẫn với ngôn ngữ mới.

---

## Lớp 1 — Hình khối

### Thang bo góc — thay đổi lớn nhất

| Token | Cũ | Mới |
|---|---|---|
| `radiusSm` | 6 | **12** |
| `radiusMd` | 8 | **20** |
| `radiusLg` | 12 | **28** |
| `radiusFull` | 9999 | 9999 |

Đây là thứ tạo cảm giác mềm của ảnh mẫu, **nhiều hơn cả màu**. Đổi token này
là ~15 màn không hardcode tự mềm ngay.

### Shadow

Mềm và loang hơn shadow hiện tại:

```
sm:  0 2  8  rgba(17,34,28,0.04)
md:  0 8  24 rgba(17,34,28,0.06)
lg:  0 16 40 rgba(17,34,28,0.08)
```

Bản tối dùng cùng hình dạng nhưng `rgba(0,0,0,0.35)` và thêm viền `border`
1px vì shadow gần như vô hình trên nền tối.

### Typography

Giữ `Plus Jakarta Sans`. Chỉ tăng cỡ và độ đậm ở tiêu đề:

- Tiêu đề trang: 28-32, `w800`
- Tiêu đề thẻ / tên người chơi: 22-26, `w700` — trong ảnh, tên người chơi to
  gần bằng tiêu đề trang
- Body: 15-16, `w400`, line-height 1.5
- Nhãn phụ: 13-14, `w600` cho nhãn hành động

---

## Lớp 2 — Sáu component dùng chung

Đây là chỗ quyết định độ đồng nhất. 68 màn dùng chung 6 widget này thì việc
quét thành cơ học chứ không phải sáng tác lại từng màn.

| Widget | Trách nhiệm | Phụ thuộc |
|---|---|---|
| `SoftBackground` | Nền kem/tối + 2-3 blob mờ đặt cố định | token màu |
| `PoolCard` | Thẻ bo `radiusMd`/`radiusLg`, shadow mềm, padding rộng, hỗ trợ trạng thái chọn/chưa chọn | token màu, shadow |
| `IconTile` | Ô 56×56 bo 18, nền pastel theo danh mục, Material icon bên trong | bảng pastel |
| `SectionHeader` | Tiêu đề lớn + phụ đề tuỳ chọn, có biến thể kèm số thứ tự (badge tròn) | typography |
| `ScoreBar` | Thanh `primary` bo lớn, N người chơi, vạch ngăn mảnh | token màu |
| `BottomActionBar` | 3-5 hành động icon + nhãn, có trạng thái vô hiệu | token màu |

Mỗi widget có widget test riêng cho: render ở cả hai chế độ sáng/tối, và trạng
thái (chọn/chưa chọn, bật/vô hiệu).

---

## Lớp 3 — Quét 68 màn theo lô

Theo luồng người dùng. **Mỗi lô chạy `flutter test` trước khi sang lô sau.**
Mỗi lô cũng sửa luôn phần hardcode `AppColors.light*` của các màn trong lô.

| Lô | Nhóm | Số màn |
|---|---|---|
| 1 | onboarding + auth | 6 |
| 2 | shell + home | 3 |
| 3 | training | 19 |
| 4 | play + match | 13 |
| 5 | coach | 8 |
| 6 | profile | 10 |
| 7 | knowledge | 4 |
| 8 | community + reports + session | 5 |

**Tổng 68.** Lô 3 và 4 là lớn nhất; nếu thấy quá dài có thể chẻ đôi khi làm
tới.

---

## Bật dark mode

Chỉ bật `themeMode: ThemeMode.system` ở `main.dart` **sau khi lô cuối xong**.
Bật sớm sẽ phơi ra các màn chưa quét ở trạng thái vỡ.

Trước khi bật, chạy một lượt kiểm tra: không còn màn nào hardcode
`AppColors.light*`.

---

## Kiểm chứng

| Mức | Cách |
|---|---|
| Token | Test khẳng định thang bo góc và các hex chính, chống sửa nhầm |
| Component | Widget test mỗi widget: render sáng + tối + các trạng thái |
| Màn | 488 test hiện có phải tiếp tục xanh sau mỗi lô |
| E2E | 22 test Playwright phải tiếp tục xanh — chúng dùng accessible name nên đổi màu/bo góc không ảnh hưởng, nhưng đổi nhãn thì có |
| Thật | Sau lô cuối: build web, deploy, xem trên link thật ở cả hai chế độ |

**Cảnh báo cho lô 1:** E2E hiện dựa vào các nhãn `"Bắt đầu ngay"`,
`"Tôi đã có tài khoản"`, `"Tiếp tục"`, `"Bắt đầu"`. Đổi chữ trong màn
onboarding/auth sẽ làm vỡ E2E — nếu đổi thì phải cập nhật `pages/*.ts` cùng lúc.

---

## Ngoài phạm vi

- Không đổi font
- Không dùng emoji
- Không đổi bố cục điều hướng (vẫn 4 mục: Home/Train/Progress/Profile)
- Không thêm ảnh banner hero (ảnh mẫu có, nhưng cần asset chưa tồn tại — để
  sprint riêng nếu muốn)
- Không đụng tới backend, sync, hay repository

---

## Rủi ro

| Rủi ro | Xử lý |
|---|---|
| App lệch giữa chừng — lô đã quét đẹp hơn lô chưa | Chấp nhận có chủ ý; đổi lại là thấy tiến độ sớm. Quét theo luồng người dùng để phần hay dùng nhất đẹp trước |
| Đổi nhãn làm vỡ E2E | Cập nhật `pages/*.ts` trong cùng lô, không để lệch |
| Bản tối là thiết kế mới, chưa có tham chiếu | Bật sau cùng; xem trên link thật trước khi chốt |
| Tương phản chữ trên nền kem/tối không đạt | Kiểm tra tỉ lệ tương phản khi viết token, không để tới lúc quét màn |
| 68 màn là nhiều phiên làm việc | Backend đứng yên trong thời gian đó — đã nêu và người dùng chấp nhận |

---

## Việc đang gác lại

Sprint 3 (nối Drill Progress lên Directus) dừng giữa chừng:
`lib/data/repositories/syncing_drill_repository.dart` đã viết xong — decorator
local-first nhắm đúng luồng `drill_session_screen.dart:250` — nhưng **chưa có
test và chưa nối vào provider**. Xem `BACKLOG.md`.
