# POOL OS v2 - USER JOURNEY & PRODUCT SPECIFICATION
## Complete Vision: AI Coach + Progress Tracker + Journey Document

---

## 1. PRODUCT VISION

### Core Mission

**"Pool OS là người huấn luyện viên cá nhân của bạn. Mỗi ngày bạn mở app, bạn biết mình cần làm gì để tiến bộ."**

### User Promise

```
┌─────────────────────────────────────────────────────────────┐
│                    EVERY DAY WITH POOL OS                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ☀️ MỖI SÁNG:                                              │
│  "Hôm nay tôi nên tập gì?"                                │
│       → Coach đã chuẩn bị sẵn Today's Focus                │
│                                                             │
│  🏋️ TRƯỚC KHI TẬP:                                        │
│  "Cách tập đúng như thế nào?"                             │
│       → Video/Instructions + Drill Setup                     │
│                                                             │
│  📊 SAU KHI TẬP:                                           │
│  "Tôi đã tiến bộ chưa?"                                   │
│       → Progress + Coach Feedback                            │
│                                                             │
│  🏆 KHI THI ĐẤU:                                           │
│  "Mình đang làm gì đúng/sai?"                              │
│       → Real-time Coach Insights                            │
│                                                             │
│  📈 SAU TRẬN:                                               │
│  "Tại sao mình thắng/thua?"                                │
│       → Match Analysis + Next Steps                          │
│                                                             │
│  🌙 CUỐI NGÀY:                                              │
│  "Mình đã tiến bộ bao xa?"                                │
│       → Journey Timeline + Achievements                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. USER PERSONAS

### Persona 1: Minh - Beginner (New Player)

```
Profile:
- Chơi billiard 3-6 tháng
- Biết cách đánh cơ bản
- Thắng thua随机, không hiểu tại sao
- Muốn học đúng cách từ đầu

Goals:
✓ Hiểu mình đang làm đúng hay sai
✓ Có lộ trình tập luyện rõ ràng
✓ Thấy tiến bộ sau mỗi tuần
✓ Không muốn học sai thói quen

Pain Points:
✗ Không biết bắt đầu từ đâu
✗ Không có ai hướng dẫn
✗ Tập sai cách, không cải thiện
✗ Nản lòng vì không thấy progress

Pool OS Solution:
→ Coach khuyến nghị: Bắt đầu từ fundamentals
→ Daily drills phù hợp level
→ Progress tracking thấy rõ tiến bộ
→ Encouragement khi có wins nhỏ
```

### Persona 2: Tuấn - Intermediate (Club Player)

```
Profile:
- Chơi billiard 1-3 năm
- Có điểm mạnh (VD: đánh thẳng tốt)
- Có điểm yếu rõ (VD: draw yếu, safety kém)
- Muốn cải thiện để đấu giải club

Goals:
✓ Biết chính xác điểm yếu của mình
✓ Có kế hoạch cải thiện cụ thể
✓ Theo dõi tiến bộ theo thời gian
✓ Chuẩn bị cho tournament

Pain Points:
✗ Biết yếu nhưng không biết cách cải thiện
✗ Tập trùng lặp, không hiệu quả
✗ Không biết mình tiến bộ thế nào
✗ Lịch tập không nhất quán

Pool OS Solution:
→ Coach phân tích: "Draw success của bạn 45%, nên tập 15 phút/ngày"
→ Targeted drills cho weakness
→ Weekly progress dashboard
→ Training reminders & streak tracking
```

### Persona 3: Việt - Advanced (Tournament Player)

```
Profile:
- Chơi billiard 5+ năm
- Đã có thành tích tournament
- Muốn đạt rank cao hơn
- Hiểu rõ game của mình

Goals:
✓ Tối ưu hóa strength/weakness ratio
✓ Mental game chiến lược hơn
✓ Recovery sau injury/fatigue
✓ Scout đối thủ

Pain Points:
✗ Cần objectivity từ bên ngoài
✗ Mental game ảnh hưởng nhiều
✗ Cần fresh perspective
✗ Equipment analysis quan trọng hơn

Pool OS Solution:
→ Coach với advanced analytics
→ Mental game tracking & recommendations
→ Equipment comparison
→ Tournament preparation strategy
```

---

## 3. DAILY USER FLOW

### Flow 1: Morning Check-in (5 phút)

```
┌─────────────────────────────────────────────────────────────┐
│                    MORNING CHECK-IN                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Open App → Dashboard                                   │
│                                                             │
│  2. See "Today's Focus"                                   │
│     "Chào Minh! Hôm nay bạn nên tập:"                      │
│                                                             │
│  3. Today's Recommendations:                              │
│     🎯 Primary: Draw Shot - 15 phút                         │
│        "Bạn hụt 8/20 cú draw gần đây"                    │
│                                                             │
│     📚 Secondary: Stop Shot Review - 10 phút                │
│        "巩固 fundamentals tuần này"                         │
│                                                             │
│  4. Quick Stats:                                           │
│     📊 Win Rate: 52% (↑ 3%)                                │
│     🏆 Streak: 5 ngày liên tiếp                            │
│     ⭐ Skill Level: Intermediate 62%                        │
│                                                             │
│  5. Start Practice → Tap "Start"                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Flow 2: Practice Session (15-30 phút)

```
┌─────────────────────────────────────────────────────────────┐
│                   PRACTICE SESSION                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Select Drill: Draw Shot Basics                        │
│                                                             │
│  2. Setup Instructions:                                    │
│     "Đặt bi cái cách bi mục tiêu 40cm"                 │
│     "Bi tiếp theo 30cm phía sau"                        │
│     "Mục tiêu: Bi cái quay về 20-30cm"                   │
│                                                             │
│  3. Start Practice:                                       │
│     ⏱️ 15:00                                              │
│                                                             │
│  4. Log Attempts:                                         │
│     [✓] [✓] [✓] [✗] [✓] [ ] [ ] [ ] [ ] [ ]          │
│     Success: 3/5                                           │
│                                                             │
│  5. Complete Session:                                    │
│     "Bạn đã tập Draw Shot 12 phút"                       │
│     "Kết quả: 7/10 (70%) - Tốt!"                        │
│                                                             │
│  6. Coach Feedback:                                       │
│     "Cải thiện từ 60% → 70% tuần này!"                  │
│     "Mẹo: Chú ý điểm tip, đừng hurry"                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Flow 3: Match Recording (Ongoing)

```
┌─────────────────────────────────────────────────────────────┐
│                   MATCH RECORDING                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Start Match: Race to 7                                 │
│                                                             │
│  2. After Each Rack: Quick Log                             │
│     Rack 3: Win                                            │
│     ├─ Balls Potted: 5                                     │
│     ├─ Longest Run: 3                                      │
│     ├─ Easy Miss: 0                                       │
│     ├─ Position Error: 1 (over-hit)                        │
│     └─ Scratch: No                                         │
│                                                             │
│  3. After Match: Summary                                   │
│     "Kết quả: Thắng 7-4"                                 │
│     "Run dài nhất: 5 balls"                               │
│     "Accuracy: 78%"                                        │
│                                                             │
│  4. Coach Analysis:                                       │
│     "Bạn đánh tốt khi không có áp lực"                  │
│     "Position errors xuất hiện khi rack 5+"                │
│     "Khuyến nghị: Tập position dưới áp lực"              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Flow 4: Progress Review (Weekly)

```
┌─────────────────────────────────────────────────────────────┐
│                   WEEKLY REVIEW                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📅 TUẦN NÀY (vs TUẦN TRƯỚC)                             │
│                                                             │
│  Practice Hours: 2.5h → 3.2h (↑ 28%)                    │
│  Sessions: 4 → 6 (↑ 50%)                                 │
│  Win Rate: 48% → 54% (↑ 6%)                               │
│                                                             │
│  📈 SKILL PROGRESSION:                                     │
│                                                             │
│  Draw Shot: 60% → 68% (↑ 8%) ████████░░ ✓              │
│  Position: 55% → 57% (↑ 2%) ██████░░░░░ ✓              │
│  Safety: 42% → 45% (↑ 3%) █████░░░░░░ ✓                │
│  Long Pot: 58% → 58% (→ 0%) ███████░░░░ →               │
│                                                             │
│  🎯 NEXT WEEK FOCUS:                                      │
│  1. Continue Draw practice (momentum tốt)                  │
│  2. Add Safety drills (chưa đạt target)                   │
│  3. Try Long Pot progression (level ready)                 │
│                                                             │
│  🏆 ACHIEVEMENT UNLOCKED:                                  │
│  "Consistency King" - 10 sessions trong 2 tuần            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. CORE FEATURES

### 4.1 DASHBOARD

```
┌─────────────────────────────────────────────────────────────┐
│                       DASHBOARD                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [User Avatar]  Minh  |  Level: Intermediate 62%           │
│                                                             │
│  ╭───────────────────────────────────────────────────────╮ │
│  │                    TODAY'S FOCUS                      │ │
│  │                                                       │ │
│  │  🎯 Primary: Draw Shot Practice                       │ │
│  │     "Bạn hụt 8/20 cú draw (60%)"                   │ │
│  │     [Start 15min]                                    │ │
│  │                                                       │ │
│  │  📚 Secondary: Stop Shot Review                       │ │
│  │     "巩固 fundamentals"                                │ │
│  │     [Start 10min]                                    │ │
│  ╰───────────────────────────────────────────────────────╯ │
│                                                             │
│  ╭───────────────────╮  ╭───────────────────╮            │
│  │  🏆 Streak       │  │  📊 Win Rate     │            │
│  │  5 days         │  │  54% (↑ 6%)    │            │
│  ╰───────────────────╯  ╰───────────────────╯            │
│                                                             │
│  ╭───────────────────╮  ╭───────────────────╮            │
│  │  ⏱️ Practice    │  │  🎯 Accuracy     │            │
│  │  3.2h this wk   │  │  72%           │            │
│  ╰───────────────────╯  ╰───────────────────╯            │
│                                                             │
│  📰 RECENT ACTIVITY                                       │
│  ├─ Hôm qua: Drilled Draw Shot (70%) ★                   │
│  ├─ 2 ngày trước: Won vs Tuấn 7-4 ★★                   │
│  └─ 3 ngày trước: Drilled Stop Shot (65%)               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 TRAINING CENTER

```
┌─────────────────────────────────────────────────────────────┐
│                   TRAINING CENTER                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Search...────────────────────────────────] 🔍           │
│                                                             │
│  ══════════════ CATEGORIES ══════════════                 │
│                                                             │
│  🎯 POTTING              12 drills                        │
│     Đánh bi vào lỗ - Aim, Cut, Long Pot                   │
│                                                             │
│  🎮 CUE BALL CONTROL    14 drills                        │
│     Stop, Follow, Draw, Spin                              │
│                                                             │
│  📍 POSITION PLAY       10 drills                        │
│     1-Rail, 2-Rail, Natural Angle                       │
│                                                             │
│  🛡️ SAFETY              8 drills                         │
│     Distance, Hook, Containing                            │
│                                                             │
│  🔄 BANK & KICK        8 drills                         │
│     Short/Long Bank, 1-Rail/2-Rail Kick                  │
│                                                             │
│  💪 BREAK               5 drills                         │
│     Soft Break, Power Break, Spread                       │
│                                                             │
│  ══════════════ MY PROGRESSION ═════════════             │
│                                                             │
│  Draw Shot        ████████████░░░░ 68%                   │
│  Stop Shot       ██████████████░░ 75%                   │
│  Position        ████████░░░░░░░░ 57%                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 MATCH CENTER

```
┌─────────────────────────────────────────────────────────────┐
│                      MATCH CENTER                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │ 🏆 Quick Match │  │ 📋 Tournament  │                  │
│  └─────────────────┘  └─────────────────┘                  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │             CURRENT RECORD                          │  │
│  │                                                   │  │
│  │   23 Wins  -  19 Losses  =  +4                  │  │
│  │                                                   │  │
│  │   Win Rate: 55%                    Streak: 3W    │  │
│  │                                                   │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  📊 THIS WEEK                                              │
│  ├─ Matches: 5 (3W, 2L)                                 │
│  ├─ Best: Won vs Tuấn 7-3                                │
│  └─ Avg Duration: 35 min                                  │
│                                                             │
│  🆚 RECENT OPPONENTS                                        │
│  ├─ Tuấn: 5W-3L vs you                                  │
│  ├─ Hùng: 2W-4L vs you                                  │
│  └─ Minh: 1W-1L vs you                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.4 COACH SCREEN

```
┌─────────────────────────────────────────────────────────────┐
│                    COACH AI                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  👋 Chào Minh!                                            │
│                                                             │
│  ╭───────────────────────────────────────────────────────╮ │
│  │  📈 TUẦN NÀY BẠN ĐÃ TIẾN BỘ                           │ │
│  │                                                       │ │
│  │  ✓ Draw Shot: 60% → 68% (+8%)                       │ │
│  │  ✓ Confidence: 55% → 58% (+3%)                      │ │
│  │  ✓ Practice Frequency: 4 → 6 sessions               │ │
│  │                                                       │ │
│  │  💪 Strengths:                                      │ │
│  │  • Stop Shot ổn định (75%)                          │ │
│  │  • Position tự nhiên tốt                            │ │
│  │  • Mental game khá (ít bị tilt)                     │ │
│  │                                                       │ │
│  │  ⚠️ Cần cải thiện:                                 │ │
│  │  • Safety success thấp (42%)                         │ │
│  │  • Long pot accuracy giảm gần đây                   │ │
│  ╰───────────────────────────────────────────────────────╯ │
│                                                             │
│  ╭───────────────────────────────────────────────────────╮ │
│  │  🎯 HƯỚNG DẪN HÔM NAY                                │ │
│  │                                                       │ │
│  │  1. [Draw Shot] - 15 phút                            │ │
│  │     Bạn đang có momentum, tiếp tục!                  │ │
│  │     [Start →]                                         │ │
│  │                                                       │ │
│  │  2. [Safety Basics] - 10 phút                        │ │
│  │     Điểm yếu lớn nhất hiện tại                       │ │
│  │     [Start →]                                         │ │
│  │                                                       │ │
│  │  3. [Review Match] - 5 phút                           │ │
│  │     Phân tích trận vs Tuấn                            │ │
│  │     [View →]                                          │ │
│  ╰───────────────────────────────────────────────────────╯ │
│                                                             │
│  💡 MẸO TỪ COACH:                                          │
│  "Khi safety, hãy nghĩ về vị trí leave trước khi đánh.  │
│   Một good safety không chỉ là không cho ăn, mà còn là      │
│   để lại thế khó cho đối thủ."                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.5 PROGRESS & JOURNEY

```
┌─────────────────────────────────────────────────────────────┐
│                  MY JOURNEY                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ══════════════ 90-DAY OVERVIEW ══════════════             │
│                                                             │
│  90 ngày trước          Hôm nay            90 ngày sau      │
│      │                      │                      │       │
│      ▼                      ▼                      ▼       │
│  Beginner 45% ──────► Intermediate 62% ──────► ?         │
│                                                             │
│  📈 TIẾN BỘ TRONG 3 THÁNG:                                │
│                                                             │
│  Skill          Before    Now      Change                   │
│  ─────────────────────────────────────────                 │
│  Draw Shot      45%      68%      +23% ⬆️                  │
│  Position       50%      57%      +7%  ⬆️                  │
│  Safety         40%      42%      +2%  ➡️                  │
│  Long Pot       55%      58%      +3%  ➡️                  │
│                                                             │
│  🏆 MILESTONES:                                           │
│  ├─ 🥉 Beginner → Intermediate (Day 30)                   │
│  ├─ 🔥 30-Day Practice Streak (Day 45)                   │
│  ├─ 📊 50% Win Rate Achieved (Day 60)                    │
│  └─ 🎯 Personal Best: 7-Run (Day 75)                     │
│                                                             │
│  📅 NEXT MILESTONE:                                        │
│  Target: Advanced (80%)                                   │
│  Est. Date: ~45 ngày nữa                                   │
│  Focus: Safety + Advanced Position                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. FEATURE SPECIFICATIONS

### 5.1 DRILL SYSTEM

```dart
// Drill Structure
class Drill {
  String id;              // DRILL-POT-001
  String name;            // "Draw Shot Basic"
  String nameVi;          // "Kéo băng cơ bản"
  String category;         // POTTING, CONTROL, POSITION, etc.
  int difficulty;         // 1-5
  int durationMin;         // 15
  
  String setup;           // "Bi cái cách bi mục tiêu 40cm"
  String instructions;      // Step-by-step guide
  String successCriteria;  // "7/10 lần thành công"
  
  List<String> targetSkills;
  List<String> relatedMistakes;
  List<String> prerequisites;  // Drill IDs
  
  int successRate;        // User's current success
  int totalAttempts;      // User's practice count
  DateTime lastPracticed;
}
```

### 5.2 PROGRESS TRACKING

```dart
// Progress Calculation
class ProgressTracker {
  
  // Weekly Stats
  int practiceMinutesThisWeek;
  int sessionsThisWeek;
  double accuracyThisWeek;
  
  // Skill Levels (0-100)
  Map<Skill, int> skillLevels;
  
  // Streaks
  int currentStreak;      // Days practicing
  int longestStreak;      // All-time record
  
  // Milestones
  List<Milestone> achievedMilestones;
  Milestone nextMilestone;
  
  // Trend Analysis
  Trend skillTrend(Skill s) {
    // Compare last 7 days vs previous 7 days
    // Return: IMPROVING, STABLE, DECLINING
  }
}
```

### 5.3 MATCH RECORDING

```dart
// Match Structure
class Match {
  String id;
  DateTime date;
  String opponent;
  int myScore;
  int opponentScore;
  int raceTo;
  
  List<Rack> racks;
  String winReason;      // OPPONENT_MISS, CLEAN_WIN, etc.
  String biggestMistake;
  String biggestStrength;
  
  // Computed Stats
  int longestRun;
  int totalBallsPotted;
  double accuracy;
  int fouls;
}
```

### 5.4 COACH RECOMMENDATIONS

```dart
// Recommendation Engine
class CoachEngine {
  
  // Analyze Player
  PlayerAnalysis analyze(PlayerData data) {
    // 1. Calculate all skill levels
    // 2. Find weakest skills
    // 3. Detect patterns (recent decline, etc.)
    // 4. Consider context (equipment change, fatigue)
  }
  
  // Generate Recommendations
  List<Recommendation> recommend(PlayerAnalysis analysis) {
    // 1. Primary: Fix biggest weakness
    // 2. Secondary: Maintain strengths
    // 3. Context: Equipment, time, goals
    // 4. Exclude recently recommended
  }
  
  // Weekly Plan
  WeeklyPlan createWeeklyPlan(List<Recommendation> recs) {
    // Distribute across 7 days
    // Include rest days
    // Balance skill types
  }
}
```

---

## 6. IMPLEMENTATION PRIORITIES

### Phase 1: MVP (NOW)

```
✅ Dashboard with Today's Focus
✅ Drill Library (50+ drills)
✅ Practice Session Recording
✅ Basic Progress Tracking
✅ Coach Recommendations (rule-based)
✅ Match Recording
```

### Phase 2: Enhanced (Next Sprint)

```
⏳ Knowledge Base Integration
⏳ Equipment Management
⏳ Equipment Comparison
⏳ Advanced Progress Analytics
⏳ Streak & Achievement System
⏳ Social Features (optional)
```

### Phase 3: AI Enhancement (Later)

```
⏳ Claude API Integration
⏳ Natural Language Coach
⏳ Video Analysis (future)
⏳ Community Features (future)
```

---

## 7. SUCCESS METRICS

### User Engagement

```
Daily Active Users (DAU):
- Target: 70% of registered users open app daily
- Measure: 7-day rolling average

Session Length:
- Target: 5-15 min per session
- Measure: Average session duration

Retention:
- Target: 60% users active after 30 days
- Measure: Cohort analysis
```

### User Progress

```
Skill Improvement:
- Target: 50% users improve at least 1 skill per month
- Measure: Skill level change

Practice Consistency:
- Target: 3+ sessions/week average
- Measure: Sessions per user per week

Win Rate Correlation:
- Target: Users with Coach usage have higher win rate improvement
- Measure: Win rate change vs Coach usage
```

---

## END OF USER JOURNEY SPEC

**Next: Coach AI Enhancement + Knowledge Base Integration**
