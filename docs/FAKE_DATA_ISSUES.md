# FAKE DATA ISSUES - CẦN FIX

## TỔNG HỢP CÁC NƠI CÓ FAKE/HARDCODED DATA

---

### 1. Training Center - "Tiến độ của bạn"
**File:** `training_center_screen.dart` line 491-495
**Vấn đề:** Hardcoded progress
```dart
_ProgressItem(label: 'Draw', progress: 0.8, color: Colors.orange),
_ProgressItem(label: 'Position', progress: 0.6, color: Colors.blue),
_ProgressItem(label: 'Bank', progress: 0.4, color: Colors.purple),
```
**Fix:** Lấy từ drill sessions thực tế

---

### 2. Training Center - "Recommended for you"
**File:** `training_center_screen.dart` line 230-248
**Vấn đề:** Hardcoded recommendations
```dart
_Draw Shot recommendation
reason: 'Phù hợp với sở thích của bạn'  // KHÔNG có sở thích
_Position recommendation
reason: 'Dựa trên kết quả tập gần đây'  // KHÔNG có kết quả
```
**Fix:** Lấy từ onboarding interests + drill sessions

---

### 3. Coach - "Hôm nay nên tập"
**File:** `coach_screen.dart` 
**Vấn đề:** Fallback hardcoded
```dart
// coach_rules_engine.dart:513
if (drillCodes.isEmpty) return 'STROKE_STRAIGHT';  // DEFAULT!
```
**Fix:** Hiển thị "Chưa có dữ liệu" thay vì fake recommendation

---

### 4. Coach - "Điểm cần cải thiện"
**File:** `coach_screen.dart` line 244-246
**Vấn đề:** Hiển thị như lỗi thật nhưng không có data
```dart
final mistakes = kg.getAllMistakes().take(3).toList();
```
**Fix:** Kiểm tra hasData, hiển thị message trung thực

---

### 5. Coach - "3 yếu tố"
**File:** `training_center_screen.dart` line 33
**Vấn đề:** Text không có logic
```dart
subtitle: 'AI cá nhân hóa theo 3 yếu tố',
```
**Fix:** Xóa text hoặc explain rõ 3 yếu tố là gì

---

### 6. Progress Screen - Chi tiết trống
**File:** `progress_screen.dart`
**Vấn đề:** "Tổng quan" và "Tiến độ theo danh mục" không có gì
**Fix:** Implement real progress từ drill sessions

---

### 7. "Hoạt động gần đây"
**File:** Nhiều screen
**Vấn đề:** "Chưa có hoạt động" có thể đúng nếu chưa tập
**Fix:** Cần kiểm tra xem có thật sự không có data không

---

## NGUNHÊN TẮC FIX

### Khi CHƯA có dữ liệu:
```
┌─────────────────────────────────────┐
│ ⚠️  Chưa có dữ liệu              │
├─────────────────────────────────────┤
│ Bạn cần:                           │
│ • Tập ít nhất 3-5 bài tập        │
│ • Hoặc ghi nhận 2-3 trận đấu     │
│                                     │
│ [Bắt đầu tập]  [Ghi trận đấu]    │
└─────────────────────────────────────┘
```

### Khi CÓ dữ liệu:
- Hiển thị real data từ drill sessions
- Hiển thị real data từ match recordings
- Không hardcoded bất kỳ số % nào

---

## TODO LIST

- [ ] Fix Training Center progress → Real data
- [ ] Fix Recommended → Real logic từ onboarding + sessions
- [ ] Fix Coach recommendation → Honest when no data
- [ ] Fix Coach weaknesses → Honest when no data
- [ ] Xóa "3 yếu tố" hoặc explain rõ
- [ ] Fix Progress Screen chi tiết
- [ ] Implement Coach Entry Survey (tùy chọn)
