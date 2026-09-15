# Plan: Warmup + Match Recording + Knowledge Dictionary

## Context

Cần triển khai 3 tính năng:
1. **Warmup Screen** — 3 giai đoạn khởi động 5 phút, xuất hiện trước buổi tập
2. **Match Recording** — form ghi nhận trận đấu thật (tái sử dụng `MatchRecordingScreen` đã có)
3. **Knowledge Dictionary** — bổ sung 30 mục từ `Tu-Dien-Kien-Thuc-Billiard-Pool.md` vào `assets/knowledge/knowledge.json`

## Các file cần tạo

### 1. `lib/core/models/warmup_models.dart`
```dart
class WarmupPhase {
  final int phase; // 1, 2, 3
  final String name;
  final String nameVi;
  final String instruction;
  final String instructionVi;
  final int suggestedMinutes;
  final List<String> relatedKnowledgeSlugs; // ví dụ ["stroke", "stop-shot"]
}

class WarmupLog {
  final DateTime date;
  final bool didWarmup;
  final double durationActualMinutes;
  final String ledTo; // "buoi_tap" | "tran_dau" | "tu_do"
  final List<int> phasesCompleted;
}
```

### 2. `lib/core/providers/warmup_provider.dart`
- `warmupSessionDoneTodayProvider` — kiểm tra đã warmup hôm nay chưa (đọc từ local storage)
- `warmupLogProvider` — ghi nhận kết quả warmup

### 3. `lib/presentation/screens/training/warmup_screen.dart`
- 3 tab giai đoạn: Đánh thức → Thích nghi tốc độ → Khôi phục góc cắt
- Soft timer đếm ngược (không thanh %)
- Nút "Bỏ qua khởi động" ở mọi giai đoạn
- Màn hình kết thúc: 3 lựa chọn → Buổi tập / Trận đấu / Đóng
- **Lưu `WarmupLog` vào local storage**

### 4. `assets/knowledge/knowledge.json` — chỉ cần thêm 1 mục `kn_warmup`
Tất cả 24 mục còn lại đã tồn tại trong file hiện tại (37 items). Chỉ cần thêm entry cho Warmup (Mục 23.1) — ghép nội dung từ `Tu-Dien...md`.

## Các file cần sửa

### 1. `lib/data/datasources/local/local_storage_datasource.dart`
Thêm storage key `_keyWarmupLog` và methods `getWarmupLogs()` / `saveWarmupLogs()`.

### 2. `lib/core/router/app_router.dart`
Thêm route `path: '/training/session/warmup'` → `WarmupScreen`.

### 3. `lib/presentation/screens/home/home_screen.dart`
CTA chính → "Khởi động 5 phút" nếu chưa warmup hôm nay; nếu rồi → "Buổi tập hôm nay".

### 4. `lib/presentation/screens/training/todays_session_screen.dart`
Thêm banner nhỏ "Bạn đã khởi động ✓" nếu `warmed_up: true` được truyền qua query param.

### 5. `assets/knowledge/knowledge.json`
Thêm 1 entry `kn_warmup` cho Mục 23.1 (Warm-up) ghép từ tài liệu.

## Implementation Order

1. **`warmup_models.dart`** + storage key in `local_storage_datasource.dart`
2. **`warmup_provider.dart`** — kiểm tra/log warmup
3. **`warmup_screen.dart`** — 3 phase + completion screen
4. **Route** — `/training/session/warmup` in `app_router.dart`
5. **Home CTA** — đổi thành warmup prompt
6. **Match recording** — navigate từ warmup completion
7. **`knowledge.json`** — thêm entry `kn_warmup`
8. **`todays_session_screen.dart`** — thêm banner warmup đã hoàn thành

## Verification

- `flutter analyze lib/` → 0 error
- Warmup: chạy thử 3 giai đoạn, kiểm tra `WarmupLog` được ghi vào local storage
- Home: nút "Khởi động 5 phút" hiện (nếu chưa warmup hôm nay)
- Warmup completion → 3 lựa chọn đúng: Buổi tập / Trận đấu / Đóng
- Match: "Ghi nhận trận đấu" → mở `MatchRecordingScreen`
- Knowledge: tìm `kn_warmup` trong `knowledge.json`
