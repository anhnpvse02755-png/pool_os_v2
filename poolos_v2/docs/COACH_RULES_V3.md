# POOL OS v2 - SMART COACH AI RULES
## Version 3.0 - Expert Billiard Knowledge

---

## PHILOSOPHY

**"Coach không chỉ nói 'tập thêm'. Coach phải chỉ ra ĐÚNG Bài tập nào, ĐÚNG Lý do, ĐÚNG Cách tập."**

---

## 1. PLAYER SKILL MODEL

### Skill Categories (10 Core Skills)

```
┌─────────────────────────────────────────────────────────────┐
│                    PLAYER DNA                                │
├──────────────┬──────────────┬──────────────┬────────────────┤
│  POTTING    │  CONTROL    │  POSITION   │   SAFETY      │
├──────────────┼──────────────┼──────────────┼────────────────┤
│ Aim         │ Stop Shot    │ 1-Rail      │ Distance      │
│ Thin Cut    │ Follow       │ 2-Rail      │ Hook          │
│ Thick Cut   │ Draw        │ Natural     │ Containing    │
│ Long Pot    │ Spin        │ Key Ball    │ Kick Safe    │
│ Pocket Speed│ Speed       │ Recovery     │ Two-Way      │
├──────────────┼──────────────┼──────────────┼────────────────┤
│  BANK/KICK  │   BREAK     │   MENTAL    │   PATTERN    │
├──────────────┼──────────────┼──────────────┼────────────────┤
│ Short Bank  │ Power Break  │ Confidence  │ Table Read   │
│ Long Bank   │ Control Brk  │ Focus       │ Key Ball     │
│ 1-Rail Kck │ Spread      │ Pressure     │ Cluster      │
│ 2-Rail Kck │ Scratch Prev │ Recovery     │ Run Out      │
│ Diamond    │ Wing Ball    │ Tilt        │ End Game     │
└──────────────┴──────────────┴──────────────┴────────────────┘
```

### Skill Score Calculation

```
Score = (Success Rate × 0.4) + (Consistency × 0.3) + (Difficulty Weight × 0.3)

Where:
- Success Rate = Balls Made / Total Attempts
- Consistency = 1 - (StdDev / Mean)
- Difficulty Weight = Easy=0.5, Medium=0.75, Hard=1.0
```

### Level Thresholds

| Level | Score Range | Description |
|-------|-------------|-------------|
| 🥉 Beginner | 0-40 | fundamentals |
| 🥈 Intermediate | 41-60 | consistent |
| 🥇 Advanced | 61-80 | competitive |
| 🏆 Pro | 81-100 | expert |

---

## 2. PROBLEM DETECTION RULES

### Rule Set A: POTTING ISSUES

**A1: AIMING PROBLEM**
```
IF (Straight Shot Accuracy < 70%) AND (Distance > 1m)
THEN → "Aiming Issue"
    → Root Cause: Alignment hoặc Stroke
    → Drill: Straight Line Practice
```

**A2: CUT ANGLE PROBLEM**
```
IF (Thin Cut < 40%) OR (Thick Cut < 50%)
THEN → "Cut Angle Difficulty"
    → Check: "Thin hay Thick yếu hơn?"
    → Drill: Half-Ball Practice
```

**A3: LONG POT PROBLEM**
```
IF (Long Pot < 50%) AND (Distance > 1.5m)
THEN → "Long Pot Issue"
    → Check: "Có phải stroke không đều?"
    → Drill: Long Straight with Cue Ball Control
```

**A4: EASY MISS PATTERN**
```
IF (Easy Shot Miss > 15%)
THEN → "Stroke Fundamentals Issue"
    → Không phải aiming
    → Drill: Straight Shot Center Ball (bi cách lỗ 30cm)
```

### Rule Set B: CUE BALL CONTROL ISSUES

**B1: DRAW PROBLEM**
```
IF (Draw Success < 50%) AND (Draw Attempts > 10)
THEN → "Draw Shot Issue"
    → Root Cause: Tip Position hoặc Acceleration
    → Check: "Draw xa hay gần yếu hơn?"
    → Drill: Draw Stop Follow Progression
```

**B2: FOLLOW PROBLEM**
```
IF (Follow Control < 60%)
THEN → "Follow Shot Issue"
    → Root Cause: Power hoặc Tip Position
    → Drill: Follow with Position Target
```

**B3: STOP SHOT PROBLEM**
```
IF (Stop Shot Accuracy < 70%)
THEN → "Stop Shot Issue"
    → Root Cause: Timing hoặc Power
    → Drill: Stop Shot at Various Distances
```

**B4: SCRATCH PROBLEM**
```
IF (Scratch Rate > 15%)
THEN → "Cue Ball Control Issue"
    → Check: "Scratch khi nào?"
        - Khi Follow → Follow over-hit
        - Khi Draw → Draw too much
        - Khi Spin → English misuse
    → Specific Drill based on pattern
```

### Rule Set C: POSITION PLAY ISSUES

**C1: NATURAL ROLL PREFERENCE**
```
IF (Natural Roll Success > Spin Roll Success)
THEN → "Natural Ball Player"
    → Recommendation: "Bạn đánh tự nhiên tốt hơn spin"
    → Prioritize: Position using natural angle
```

**C2: POSITION ERROR PATTERN**
```
IF (Position Error Rate > 40%)
THEN → "Position Control Issue"
    → Check pattern:
        - Too Long → Power control
        - Too Short → Draw control
        - Wrong Angle → Aim alignment
    → Specific drill based on error type
```

**C3: RECOVERY POSITION**
```
IF (Recovery Success < 50%)
THEN → "Recovery Position Issue"
    → Drill: After Miss Position Practice
    → Focus: Small position adjustments
```

### Rule Set D: SAFETY ISSUES

**D1: SAFETY SUCCESS RATE**
```
IF (Safety Success < 40%)
THEN → "Safety Play Issue"
    → Check: "Đánh safety hay bị ăn?"
    → Drill: Distance Safety → Hook Safety → Complex
```

**D2: KICK SAFE PROBLEM**
```
IF (Kick Safe Success < 30%)
THEN → "Kick Safe Issue"
    → Drill: Basic 1-Rail Kick → 2-Rail Kick
```

### Rule Set E: BREAK ISSUES

**E1: BREAK SPREAD**
```
IF (Break Balls Made < 3) AND (Spread Quality < 50%)
THEN → "Break Control Issue"
    → Check: "Pocket rải hay tập trung?"
    → Drill: Control Break → Power Break
```

**E2: BREAK SCRATCH**
```
IF (Break Scratch Rate > 20%)
THEN → "Break Scratch Issue"
    → Root Cause: "Nhắm băng nào?"
    → Drill: Scratch Prevention Break
```

### Rule Set F: MENTAL GAME

**F1: PRESSURE PERFORMANCE**
```
IF (Close Game Win Rate < Win Rate Overall - 20%)
THEN → "Pressure Issue"
    → Drill: Pressure Practice (simulate close games)
    → Focus: Mental routine
```

**F2: FATIGUE PATTERN**
```
IF (Accuracy Drops > 15% After 2 hours)
THEN → "Endurance Issue"
    → Recommendation: "Tập endurance"
    → Drill: Extended Practice Sessions
```

**F3: STREAK PATTERN**
```
IF (Lose 3+ consecutive matches)
THEN → "Confidence Issue"
    → Action: "Tạm nghỉ 1-2 ngày"
    → Drill: Easy drills để lấy lại feel
```

---

## 3. RECOMMENDATION ENGINE

### Recommendation Types

```
┌─────────────────────────────────────────────────────────────┐
│              RECOMMENDATION TYPES                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  URGENT (Critical)     → Fix immediate weakness           │
│  PRIORITY (High)      → Top 3 improvements               │
│  MAINTENANCE (Medium) → Keep strengths stable           │
│  EXPLORATION (Low)    → Try new skills                   │
│  RECOVERY (Special)    → After losing streak            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Priority Calculation

```
Priority = (Weakness × 0.3) + (Impact × 0.3) + (Frequency × 0.2) + (Trend × 0.2)

Where:
- Weakness = 100 - Current Score (higher weakness = higher priority)
- Impact = How much this skill affects overall win rate
- Frequency = How often this skill is used in games
- Trend = Declining trend gets boost
```

### Drill Selection Logic

```
FOR each identified weakness:
    1. Find matching drills (drill.targetSkill = weakness)
    2. Filter by player level (drill.difficulty <= player.level + 1)
    3. Sort by difficulty progression (easy → medium → hard)
    4. Check drill.prerequisites are met
    5. Select top 3 drills with different approaches
```

### Training Plan Generation

```
Weekly Plan Structure:
├── Day 1: Focus Skill (30 min) + Review (10 min)
├── Day 2: Maintenance Skills (20 min)
├── Day 3: Rest or Light Practice
├── Day 4: Focus Skill (30 min) + Match Analysis (15 min)
├── Day 5: Competition Prep
├── Day 6: Match Practice
└── Day 7: Rest

Progression:
- Week 1-2: Basic drills, establish routine
- Week 3-4: Intermediate drills, add complexity
- Week 5+: Advanced drills, pressure situations
```

---

## 4. CONTEXT-AWARE RULES

### Equipment Context

```
IF (Player changed cue)
THEN → Expect 10-20% performance variance
    → "Bạn vừa đổi cơ. Cần 2-3 buổi để thích nghi."
    → Monitor: Spin control, Power consistency
```

### Time Context

```
Morning Player (6-10h):
    → Focus: Technical drills
    → Avoid: Pressure situations early
    
Afternoon Player (14-18h):
    → Focus: Position play
    → Best for: Match practice
    
Evening Player (19-23h):
    → Focus: Quick decisions
    → Caution: Fatigue accumulation
```

### Match Context

```
Before Match:
    → Check readiness (sleep, stress)
    → Warm-up recommendation based on weakness
    
During Match:
    → Monitor fatigue signs
    → Suggest break if accuracy drops
    
After Match:
    → Immediate reflection (what went right/wrong)
    → Assign homework drill
```

---

## 5. FEEDBACK LOOP

### Coach Memory

```
Coach remembers:
├── Last 10 recommendations given
├── Player's response (completed/ignored/skipped)
├── Time since last focus on each skill
├── Seasonal patterns (VN: Tết, Summer tournament)
└── Long-term progression

Rule: Don't repeat same recommendation within 14 days unless critical
```

### Coach Confidence

```
High Confidence (Sample > 50 attempts):
    → "Tôi chắc chắn bạn yếu ở..."
    
Medium Confidence (Sample 20-50 attempts):
    → "Dữ liệu cho thấy bạn có thể..."
    
Low Confidence (Sample < 20 attempts):
    → "Tôi cần thêm dữ liệu để chắc chắn"
    → Suggest: Play/Practice more
```

---

## 6. VIETNAMESE BILLIARD CONTEXT

### VN Player Common Patterns

```
1. Strong: Natural position, aiming
2. Weak: Spin control (vì ít dùng áp phê)
3. Weak: Complex safety situations
4. Strong: 8-ball strategy (thường đánh 8-ball)

Coach should:
- Praise natural game strengths
- Encourage spin practice gently
- Teach safety progressively
- Use 8-ball as foundation
```

### VN Club Environment

```
Practice Habits:
- Short sessions (1-2h typical)
- Group practice common
- Match-oriented rather than drill-oriented

Coach Adaptation:
- Recommend: "3 bài tập 15 phút" thay vì "1 giờ liên tục"
- Gamify practice: "Hôm nay thử 10 lần, ai làm được trước?"
- Include social element: "Chia sẻ progress với nhóm"
```

---

## 7. COACH COMMUNICATION STYLE

### Language Rules

```
ALWAYS:
✓ Specific: "Bi cách lỗ 1.5m, đánh 1 băng về góc A"
✓ Evidence-based: "10 trận gần nhất, bạn hụt 8 lần ở cú này"
✓ Actionable: "Tập bài này 20 phút/ngày trong 1 tuần"
✓ Encouraging: "Đây là điểm yếu phổ biến, có cách cải thiện"

NEVER:
✗ "Bạn đánh dở"
✗ "Tệ quá"
✗ "Không bao giờ làm được"
✗ Random advice without data
```

### Coach Persona

```
Name: Coach (hoặc "HLV" trong tiếng Việt)
Style: Supportive Expert
Tone: Professional nhưng thân thiện
Language: Simple Vietnamese, no jargon
Avatar: Friendly coach character
```

---

## 8. IMPLEMENTATION REQUIREMENTS

### Data Needed

```
Minimum for meaningful Coach:
├── Last 10 sessions (or 50+ shots)
├── Shot type breakdown
├── Success/failure by difficulty
├── Match results
└── Self-reported confidence

Ideal for accurate Coach:
├── All sessions forever
├── Equipment used per session
├── Pre/post match readiness
├── Fatigue levels
└── Practice vs Match performance
```

### Rules Engine Structure

```dart
class CoachRulesEngine {
  
  // 1. Analyze player data
  Map<Skill, AnalysisResult> analyzePlayer(PlayerData data);
  
  // 2. Detect problems
  List<Problem> detectProblems(AnalysisResult analysis);
  
  // 3. Generate recommendations
  List<Recommendation> generateRecommendations(
    List<Problem> problems,
    PlayerContext context
  );
  
  // 4. Create training plan
  TrainingPlan createWeeklyPlan(List<Recommendation> recs);
}
```

---

## 9. SAMPLE COACH OUTPUTS

### Example 1: Beginner Player

```
Chào Minh! 👋

Tôi đã xem 15 trận gần nhất của bạn.

🎯 HÔM NAY BẠN NÊN TẬP:
1. Stop Shot - 15 phút
   Tại sao: Bạn hụt 12/30 cú stop shot (60%)
   Cách tập: Đặt bi cách bi mục tiêu 40cm, đánh dừng
   
2. Draw Shot - 15 phút
   Tại sao: Draw yếu hơn follow (40% vs 75%)
   Cách tập: Bắt đầu từ 30cm, tăng dần

📊 ĐIỂM MẠNH:
✓ Aiming tốt (78%)
✓ Position tự nhiên ổn định
✓ Mental khá, ít bị áp lực

💡 MẸO NHỎ:
"Khi draw, đầu cơ chạm bi cái ở điểm dưới tâm. 
 Không cần lực mạnh, quan trọng là điểm chạm."
```

### Example 2: Intermediate Player

```
Chào Việt! 👋

Tuần này bạn tiến bộ rõ!

📈 TIẾN BỘ:
↑ Position +8% (từ 62% lên 70%)
↑ Draw Control +5% (từ 55% lên 60%)

🎯 TUẦN NÀY TẬP:
1. Thin Cut - 20 phút
   Tại sao: Bạn hụt 8/15 cú cắt mỏng (47%)
   Cách tập: Bắt đầu 30°, tăng dần đến 15°
   
2. Safety Play - 15 phút
   Tại sao: Safety success 35%, ảnh hưởng game

⚠️ CẢNH BÁO:
"3 trận gần nhất bạn hụt nhiều hơn bình thường.
 Có thể do fatigue. Nên nghỉ 1 ngày."

💡 STRATEGY:
"Bạn đang ở giai đoạn quan trọng. 
 Nếu cải thiện được Thin Cut, win rate sẽ tăng 10-15%."
```

### Example 3: After Equipment Change

```
Chào Anh! 👋

Tôi thấy bạn vừa đổi sang cơ mới (Revo).

⚠️ LƯU Ý:
"Cơ mới = feel mới. Bạn cần 2-3 buổi để thích nghi."

📊 THEO DÕI:
- Ngày 1: 60% accuracy (bình thường 78%)
- Ngày 2: 68% accuracy (đang cải thiện)

💡 KHUYẾN NGHỊ:
"Tuần này tập nhẹ nhàng, tập trung feel không phải kết quả.
 Không nên đấu quan trọng trong tuần này."

🎯 BÀI TẬP PHÙ HỢP:
- Stop Shot (vì cần cảm nhận đầu cơ)
- Follow Shot (vì cơ mới có tip khác)
```

---

## 10. SUCCESS METRICS

### Coach Effectiveness

```
IF (Player follows recommendation) AND (Skill improves after 2 weeks)
THEN → Coach is effective

IF (Player ignores recommendation) AND (No improvement)
THEN → Need different approach

IF (Player improves without Coach suggestion)
THEN → Good instinct, need minimal guidance
```

### Player Progression

```
Short-term (1-2 weeks):
- Fix 1-2 specific weaknesses
- Establish practice routine

Medium-term (1-3 months):
- Improve 2-3 skill areas
- Win rate +5-10%

Long-term (6-12 months):
- Reach intermediate/advanced level
- Consistent competition performance
```

---

## END OF COACH RULES V3

**Next: Integrate with Claude API for enhanced reasoning**
