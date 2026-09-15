# Plan: Hoàn thiện hệ thống thiết bị

## Context

Người dùng cần: (1) đánh dấu cơ đang dùng để ghép người với cơ, và (2) so
sánh cơ sở hữu với cơ trên thị trường để biết có nên nâng cấp không.

Khảo sát nhanh cho thấy:
- Model `Equipment` đã có `isActive`, `isBreakCue`, `isJumpCue` — ✅
- Form chỉnh sửa đã có toggle `isActive` — ✅
- Form đã có `tipBrand`, `tipDiameter`, `tipHardness` — ✅
- `equipment_comparison_screen.dart` TỒN TẠI NHƯNG KHÔNG CÓ TRONG ROUTER — inaccessible!
- Màn so sánh hiện chỉ so sánh cơ sở hữu với nhau, không có cơ thị trường
- `MarketCue` thiếu `shaftDiameter` và `tipHardness` — không so sánh được

## Việc cần làm

### 1. Thêm comparison screen vào router (dễ)

`lib/core/router/app_router.dart`:
- Import `equipment_comparison_screen.dart`
- Thêm route: `path: '/profile/equipment/compare'` nhận `equipmentIds` là query param

### 2. Điều hướng đến màn so sánh (dễ)

**Từ màn danh sách** (`equipment_screen.dart`):
- Thêm nút "So sánh" trên AppBar
- Cho phép chọn 2-4 cơ bằng checkbox
- Bấm "So sánh" → navigate đến route mới với `?ids=1,2,3`

**Từ màn chi tiết** (`equipment_detail_screen.dart`):
- Thêm nút "So sánh" → thêm cơ này vào danh sách so sánh (dùng SharedPreferences hoặc simple state)

### 3. Mở rộng MarketCue model (trung bình)

`lib/data/models/market_cues.dart`:

Thêm hai trường:
```dart
final double shaftDiameter; // mm, nullable
final String tipHardness; // 'Soft' | 'Medium' | 'Hard' | 'Super Hard'
```

Cập nhật 16 cơ hiện có trong `MarketCueDatabase.cues` với giá trị hợp lý.
Đây là thông tin có thể tra cứu — dùng giá trị phổ biến cho từng brand/model.

### 4. Cho phép so sánh hỗn hợp (trung bình)

**Sửa `equipment_comparison_screen.dart`**:
- Thêm tab/chế độ: "Cơ của tôi" | "Cơ thị trường" | "So sánh hỗn hợp"
- Tab "Cơ thị trường": hiện `MarketCueDatabase.cues`, cho check chọn
- Tab "So sánh hỗn hợp": chọn cơ sở hữu + cơ thị trường, hiển thị cùng bảng
- Chỉ hiện các hàng specs CÓ trong ít nhất 1 cơ được chọn (tránh cột trống)

**Thêm `MarketCue.toEquipment()`** để convert sang `Equipment` tạm thời
(với `id`, `name`, `brand`, `model`, các trường specs) — dùng chung bảng hiển thị.

### 5. Hiện badge "đang dùng" nổi bật hơn (dễ)

**`equipment_screen.dart`** — card cơ đang active:
- Thêm badge/chip nổi bật: "Đang dùng" với màu accent
- Không phải trạng thái bình thường — cần nổi bật

**`equipment_detail_screen.dart`** — header:
- Hiện badge "Cơ chính" / "Break cue" / "Jump cue" rõ ràng hơn

### 6. Nút so sánh trong statistics (dễ)

**`equipment_statistics_screen.dart`**:
- Thêm nút "So sánh cơ của bạn với thị trường" dẫn đến màn so sánh
- Hoặc hiện trực tiếp: "Cơ của bạn so với thị trường cùng phân khúc"

## File cần sửa

| File | Thay đổi |
|---|---|
| `lib/core/router/app_router.dart` | Thêm route comparison |
| `lib/data/models/market_cues.dart` | Thêm shaftDiameter, tipHardness; cập nhật 16 cơ |
| `lib/presentation/screens/profile/equipment_screen.dart` | Thêm checkbox chọn + nút so sánh |
| `lib/presentation/screens/profile/equipment_detail_screen.dart` | Thêm nút so sánh, badge nổi bật hơn |
| `lib/presentation/screens/profile/equipment_comparison_screen.dart` | Thêm tab thị trường, so sánh hỗn hợp |
| `lib/presentation/screens/profile/equipment_statistics_screen.dart` | Thêm nút so sánh với thị trường |

## Không cần làm (ngoài scope)

- Thuật toán ghép người-cơ phức tạp — "active" là đủ
- Chỉnh sửa cơ thị trường — chỉ xem
- Đồng bộ cơ mới mua vào kho — sau này

## Verification

- `flutter analyze lib/` → 0 error
- `flutter test` → pass
- Mở app → vào Thiết bị → thấy badge "Đang dùng" trên cơ active
- Vào chi tiết cơ → bấm So sánh → thấy tab "Cơ thị trường"
- Chọn cơ của mình + cơ thị trường → bảng so sánh hiện đủ specs
