# MATCH RECORDING → COACH AI INTEGRATION

## MỤC TIÊU

Feed dữ liệu từ Match Recording vào Coach AI để:
1. Phân tích điểm mạnh/yếu từ trận đấu thật
2. Đưa ra đề xuất bài tập dựa trên weaknesses thật
3. Track improvement over time

---

## DATA TỪ MATCH RECORDING

### Rack Data Available:
```dart
class Rack {
  String result;           // 'win' | 'lose'
  int ballsPotted;        // Tổng bi vào
  int longestRun;          // Run dài nhất
  int easyMiss;           // Miss dễ
  int hardMiss;           // Miss khó
  int scratch;             // Scratch
  int positionError;      // Lỗi position
  int safetyError;        // Lỗi safety
  int fouls;              // Fouls
  String? biggestMistake;  // Ghi chú lỗi lớn
  String? biggestStrength; // Ghi chú điểm mạnh
}
```

### Analysis Needed:

#### 1. Từ Win Rate
- Win率高 → strength
- Win率低 → cần cải thiện

#### 2. Từ Cues Shot Types
- Bank shots nhiều → Bank skill
- Kick shots nhiều → Kick skill
- Safety play nhiều → Safety skill

#### 3. Từ Errors
- Miss dễ nhiều → Aiming cần tập
- Position error nhiều → Position control cần tập
- Scratch nhiều → Follow/Draw cần tập
- Safety error nhiều → Safety play cần tập

#### 4. Từ Notes
- "Bi cái chạy quá xa" → Draw control
- "Khó kiểm soát lực" → Speed control
- "Đánh góc hay miss" → Cut shots

---

## IMPLEMENTATION

### 1. MatchData Model (convert from Rack)
```dart
class MatchAnalysis {
  final int totalRacks;
  final int wins;
  final int losses;
  final int totalBallsPotted;
  final int longestRun;
  final int easyMisses;
  final int hardMisses;
  final int scratches;
  final int positionErrors;
  final int safetyErrors;
  final Map<String, int> shotTypes;  // e.g., {'bank': 5, 'kick': 2}
  final List<String> commonMistakes;
  final List<String> strengths;
}
```

### 2. CoachService Method
```dart
/// Analyze matches and update player intelligence
Future<CoachAnalysis> analyzeMatches(List<Match> matches) {
  // Convert matches to analysis
  final analysis = _convertToAnalysis(matches);
  
  // Identify patterns
  final weaknesses = _identifyWeaknesses(analysis);
  final strengths = _identifyStrengths(analysis);
  
  // Generate recommendations
  final recommendations = _generateRecommendations(weaknesses);
  
  // Update player intelligence
  _updatePlayerIntelligence(weaknesses, strengths);
  
  return CoachAnalysis(
    weaknesses: weaknesses,
    strengths: strengths,
    recommendations: recommendations,
  );
}
```

### 3. Integration Point
- Sau khi user hoàn thành match recording
- Gọi `CoachService.analyzeMatches()` với các racks vừa record
- Update PlayerIntelligence
- Refresh Coach screen

---

## FLOW

```
1. User record trận đấu xong
   ↓
2. Lưu match data vào storage
   ↓
3. Gọi CoachService.analyzeMatches()
   ↓
4. Coach phân tích → ra weaknesses/strengths
   ↓
5. Update PlayerIntelligence
   ↓
6. Refresh Coach Home với analysis mới
```

---

## UI CHANGES

### Coach Home - Thêm phần "Từ trận đấu gần nhất"

```
┌─────────────────────────────────────┐
│ 📊 Từ trận đấu gần nhất          │
├─────────────────────────────────────┤
│                                     │
│ Điểm mạnh:                         │
│ • Long run: 5 bi                   │
│ • Bank shots: 3 lần                │
│                                     │
│ Cần cải thiện:                     │
│ • Miss dễ: 2 lần                  │
│ • Position error: 1 lần             │
│                                     │
│ 💡 Gợi ý: Tập Draw Shot để       │
│    kiểm soát bi cái tốt hơn      │
│                                     │
└─────────────────────────────────────┘
```

---

## FILES TO CREATE/MODIFY

### Create:
- `lib/core/services/match_analysis_service.dart` - Analyze match data
- `lib/core/models/coach_analysis.dart` - Analysis model

### Modify:
- `match_recording_screen.dart` - Gọi analyze sau khi record
- `coach_provider.dart` - Cập nhật từ match data
- `coach_screen.dart` - Hiển thị match analysis
