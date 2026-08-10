# RACK RECORDING - ENHANCED DATA CAPTURE

## 1-MINUTE RACKING TIME DESIGN

### UX Flow
```
Rack kết thúc → Màn hình data hiện ra → 60 giây đếm ngược
→ User nhập data → Bấm "Lưu" hoặc timeout auto-save
```

---

## DATA FIELDS FOR COACH AI

### A. SHOT PERFORMANCE (Đánh bi)
| Field | Type | Description |
|-------|------|-------------|
| ballsPottedOnBreak | int | Số bi đánh vào ở break |
| totalBallsPotted | int | Tổng số bi vào |
| longestRun | int | Run dài nhất trong rack |
| easyMissCount | int | Số cú dễ miss |
| hardMissCount | int | Số cú khó miss |
| scratchErrorCount | int | Số lần scratch |

### B. SHOT TYPES (Loại cú đánh)
| Field | Type | Description |
|-------|------|-------------|
| bankShotCount | int | Số cú bank (dội) |
| comboShotCount | int | Số cú combo |
| caromShotCount | int | Số cú carom |

### C. POSITION & CONTROL
| Field | Type | Description |
|-------|------|-------------|
| positionErrorCount | int | Số lần position sai |
| safetyPlays | int | Số lần safety |
| safetyErrorCount | int | Số lần safety thất bại |
| kickErrorCount | int | Số lần kick miss |

### D. FOULS & ERRORS
| Field | Type | Description |
|-------|------|-------------|
| fouls | int | Số lần phạm lỗi |
| breakScratch | bool | Có scratch khi break không |
| breakFoul | bool | Có lỗi khi break không |
| jumpErrorCount | int | Số lần cue ball nhảy |

### E. RESULT & ANALYSIS
| Field | Type | Description |
|-------|------|-------------|
| howWon | enum | Cách thắng: clean, opponent_miss, safety, foul, break |
| biggestMistake | text | Lỗi lớn nhất trong rack |
| biggestStrength | text | Điểm mạnh nhất trong rack |

---

## SCREEN LAYOUT

```
┌────────────────────────────────────────────┐
│  ⏱️ RACK 3 - 60s                           │
├────────────────────────────────────────────┤
│                                            │
│  KẾT QUẢ RACK                              │
│  ┌─────────┐  ┌─────────┐                  │
│  │ WIN ✓   │  │ LOSE ✗ │                  │
│  └─────────┘  └─────────┘                  │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│  📊 KẾT QUẢ ĐÁNH                          │
│                                            │
│  Bi vào từ Break: [0] [-] [+]            │
│  Tổng bi vào:       [0] [-] [+]           │
│  Run dài nhất:      [0] [-] [+]           │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│  ❌ SAI SÓT                                 │
│                                            │
│  Miss dễ:          [0] [-] [+]            │
│  Miss khó:          [0] [-] [+]           │
│  Scratch:           [0] [-] [+]            │
│  Lỗi position:     [0] [-] [+]            │
│  Lỗi safety:       [0] [-] [+]            │
│  Lỗi kick:          [0] [-] [+]            │
│  Cue nhảy:          [0] [-] [+]            │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│  🎯 LOẠI CÚ ĐÁNH                          │
│                                            │
│  Bank shots:       [0] [-] [+]            │
│  Combo:            [0] [-] [+]            │
│  Carom:            [0] [-] [+]           │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│  💡 GHI CHÚ NHANH                         │
│                                            │
│  Cách thắng:                              │
│  ○ Thắng sạch    ○ Đối miss              │
│  ○ Safety        ○ Đối lỗi               │
│                                            │
│  Lỗi lớn nhất: _________________         │
│  Điểm mạnh:     _________________         │
│                                            │
├────────────────────────────────────────────┤
│  [Bỏ qua]              [💾 Lưu]          │
└────────────────────────────────────────────┘
```

---

## IMPLEMENTATION

### MatchRecordingScreen Changes:
1. Mở rộng `_showRackDataSheet`
2. Thêm counter cho tất cả fields
3. Countdown timer 60s
4. Auto-save khi timeout

### Countdown Timer:
```dart
Timer.periodic(Duration(seconds: 1), (timer) {
  if (secondsRemaining > 0) {
    setState(() => secondsRemaining--);
  } else {
    _commitRackResult(); // Auto-save
    timer.cancel();
  }
});
```

---

## COACH AI ANALYSIS

Sau khi có đủ data, Coach AI có thể phân tích:

```dart
// Phân tích pattern
if (easyMissCount > 2) → "Bạn cần tập aim cơ bản"
if (scratchErrorCount > 1) → "Kiểm soát bi cái khi cu lê"
if (positionErrorCount > 2) → "Tập position play"
if (safetyErrorCount > 1) → "Safety technique cần cải thiện"

// Strengths
if (longestRun >= 5) → "Run dài 5+, position tốt"
if (bankShotCount > 0 && win) → "Bank shot là điểm mạnh"
```
