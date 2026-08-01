# Training Center - Design Specification

**Version:** 1.0
**Date:** 2026-08-02
**Status:** Draft

---

## Core Philosophy

> Pool OS không phải là "ông thầy" bắt người chơi học theo giáo trình. Pool OS là một "HLV cá nhân" hiểu người chơi, đề xuất con đường tối ưu, nhưng luôn để họ tự quyết định muốn luyện gì.

---

## Three Recommendation Factors

### 1. Rank (Hạng)
- User's current pool rating level
- Used for difficulty suggestions, not restrictions

### 2. Interest (Sở thích)
- Captured during onboarding
- User selects what they enjoy learning
- Influences recommendation priority

### 3. Performance (Kết quả)
- Drill success rates
- Common mistakes
- Strengths and weaknesses

---

## Training Center Structure

```
Training Center
├── Learning Paths       ← AI Personalization
├── All Drills           ← OPEN
├── Knowledge            ← OPEN
├── AI Coach             ← Recommend Only
├── Progress             ← Track
└── History             ← Past Sessions
```

---

## 1. Learning Paths

### Purpose
AI-generated personalized learning path based on 3 factors.

### Display
```
┌─────────────────────────────────────────────┐
│ Lộ trình của bạn                            │
├─────────────────────────────────────────────┤
│                                             │
│ ⭐ Recommended for you                       │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ 🎯 Draw Shot                    ⭐⭐⭐⭐⭐ │ │
│ │    Phù hợp với sở thích của bạn        │ │
│ │    [Bắt đầu tập]                        │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ 🎯 Position Control             ⭐⭐⭐⭐   │ │
│ │    Dựa trên kết quả tập gần đây        │ │
│ │    [Bắt đầu tập]                        │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ Note: All drills are available in Drill     │
│ Library. This is just AI's recommendation.  │
│                                             │
└─────────────────────────────────────────────┘
```

### Recommendation Logic
```
RECOMMENDATION_SCORE = 
  (Interest_Match × 0.4) +
  (Performance_Need × 0.3) +
  (Rank_Appropriate × 0.3)
```

---

## 2. All Drills

### Purpose
Complete drill library - ALL OPEN to all users.

### Display
```
┌─────────────────────────────────────────────┐
│ Thư viện bài tập                           │
├─────────────────────────────────────────────┤
│ [Tất cả] [Cú đánh] [Vị trí] [An toàn]... │
├─────────────────────────────────────────────┤
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ 🎱 Đánh thẳng                   🟢 Dễ │ │
│ │    Cú đánh cơ bản                     │ │
│ │    [Tập ngay]                           │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ 🎱 Draw Shot                    🟡 TB  │ │
│ │    Bi cái quay ngược lại                │ │
│ │    [Tập ngay]                           │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ ... all drills available ...                │
│                                             │
└─────────────────────────────────────────────┘
```

### Key Principles
- **No rank lock** - All drills visible to all users
- **No unlock requirement** - User chooses what to learn
- **Difficulty shown** - Helps user self-assess
- **Related knowledge** - Linked below each drill

---

## 3. Knowledge

### Purpose
Educational content about pool techniques - ALL OPEN.

### Structure
```
Knowledge
├── Cue Ball
│   ├── Stop Shot
│   ├── Follow
│   ├── Draw
│   ├── Stun
│   └── Position Control
├── Spin
│   ├── Top Spin
│   ├── Back Spin
│   ├── Side Spin
│   └── English
├── Kick
├── Jump
├── Masse
├── Bank
├── Safety
├── Bridge
├── Psychology
├── Strategy
├── Equipment
└── ...
```

### Drill-Knowledge Link
```
┌─────────────────────────────────────────────┐
│ Draw Shot Drill                            │
├─────────────────────────────────────────────┤
│ [Instructions]                             │
│ [Start Practice]                           │
├─────────────────────────────────────────────┤
│ 📚 Related Knowledge                       │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ Grip - Cách cầm cơ                     │ │
│ │ Tip Placement - Vị trí đầu đánh       │ │
│ │ Acceleration - Gia tốc                 │ │
│ │ Common Mistakes - Lỗi thường gặp      │ │
│ │ Draw Physics - Vật lý draw             │ │
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

### Key Principles
- **Independent exploration** - User can read without doing drills
- **Linked to drills** - Each drill shows related knowledge
- **Bidirectional** - Drill → Knowledge, Knowledge → Drill

---

## 4. AI Coach

### Purpose
Analyze performance and recommend improvements - RECOMMEND ONLY.

### Display
```
┌─────────────────────────────────────────────┐
│ AI Coach                                   │
├─────────────────────────────────────────────┤
│                                             │
│ 🔍 Phân tích gần đây                       │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ ⚠️ Scratch nhiều                       │ │
│ │    Xảy ra 12 lần trong 5 buổi gần nhất │ │
│ │    [Xem chi tiết]                        │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ ⭐ Đề xuất cải thiện                       │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ 🎯 Stop Shot                    ⭐⭐⭐⭐ │ │
│ │    Giúp kiểm soát cue ball tốt hơn    │ │
│ │    [Tập ngay]                           │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ 🎯 Draw Drill                  ⭐⭐⭐   │ │
│ │    Cải thiện khả năng hãm bi          │ │
│ │    [Tập ngay]                           │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ Note: You can still practice any drill      │
│ from the library. AI only recommends.       │
│                                             │
└─────────────────────────────────────────────┘
```

### Recommendation Based On
- Weaknesses identified from recent sessions
- Success rates by drill type
- Common mistakes
- But **user can always choose any drill**

---

## 5. Progress

### Purpose
Track learning journey and improvements.

### Display
```
┌─────────────────────────────────────────────┐
│ Tiến độ của bạn                            │
├─────────────────────────────────────────────┤
│                                             │
│ Overall: 23 drills completed                │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ Draw Shot                    ████░░ 80%│ │
│ │ Stop Shot                    ███░░░ 60%│ │
│ │ Follow                     ████░░ 75%│ │
│ │ Bank                       ██░░░░ 40%│ │
│ │ ...                                       │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ 📈 Improvement trends                       │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 6. History

### Purpose
Review past training sessions.

### Display
```
┌─────────────────────────────────────────────┐
│ Lịch sử tập luyện                         │
├─────────────────────────────────────────────┤
│                                             │
│ Hôm nay                                     │
│ ┌─────────────────────────────────────────┐ │
│ │ Draw Shot Practice                      │ │
│ │ 14:30 • 10 reps • 80% success        │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ Hôm qua                                     │
│ ┌─────────────────────────────────────────┐ │
│ │ Position Control                        │ │
│ │ 18:45 • 15 reps • 73% success         │ │
│ └─────────────────────────────────────────┘ │
│                                             │
└─────────────────────────────────────────────┘
```

---

## Onboarding: Interest Selection

### When
Shown during initial onboarding after rank assessment.

### Display
```
┌─────────────────────────────────────────────┐
│ Bạn thích học gì?                          │
│                                             │
│ Chọn những gì bạn muốn cải thiện.          │
│                                             │
│ ☐ 🎱 Draw Shot                             │
│ ☐ 🎯 Position Control                      │
│ ☐ 💎 Bank Shot                            │
│ ☐ 🚀 Kick                                 │
│ ☐ 🦘 Jump Shot                            │
│ ☐ 🔄 Masse                                │
│ ☐ 🛡️ Safety Play                          │
│ ☐ 🎳 3 Cushion                            │
│ ☐ ✨ Trickshot                            │
│                                             │
│ [Tiếp tục]                                 │
│                                             │
└─────────────────────────────────────────────┘
```

### Storage
```dart
class PlayerInterests {
  String playerId;
  List<String> interests; // ['draw', 'position', 'bank', ...]
  DateTime updatedAt;
}
```

---

## Recommendation Algorithm

### Factor Weights
```dart
const InterestWeight = 0.4;    // 40% - Matches user preference
const PerformanceWeight = 0.3;  // 30% - Addresses weaknesses
const RankWeight = 0.3;         // 30% - Appropriate difficulty
```

### Calculation
```
For each drill:
  score = 0;
  
  // Interest match
  if (drill.category in user.interests)
    score += InterestWeight * 100;
  
  // Performance need
  if (drill.category in user.weaknesses)
    score += PerformanceWeight * 100;
  
  // Rank appropriate
  if (drill.difficulty <= user.rankLevel + 1)
    score += RankWeight * 100;
  
  recommendationScore = score;
```

### Output
```dart
class DrillRecommendation {
  String drillCode;
  String drillName;
  double score;          // 0-100
  String reason;         // "Phù hợp với sở thích", "Cần cải thiện", etc.
  bool isRecommended;   // score > 70
}
```

---

## Key UX Principles

1. **No Locked Content**
   - All drills visible to all users
   - All knowledge visible to all users
   - AI only recommends, never restricts

2. **Transparency**
   - Show why something is recommended
   - Let user understand the logic

3. **User Choice**
   - User can always pick any drill
   - Interest selection influences but doesn't restrict

4. **Progressive Disclosure**
   - Simple view first (recommendations)
   - Full library available when wanted
   - Knowledge linked contextually

---

## Component Mapping

### Screens
| Screen | Route | Status |
|--------|-------|--------|
| Training Center Home | `/training` | ✅ Done |
| Learning Paths | `/training/paths` | 📋 Design |
| All Drills | `/training/drills` | ✅ Done |
| Knowledge | `/training/knowledge` | 📋 Design |
| AI Coach | `/training/coach` | 📋 Design |
| Progress | `/training/progress` | 📋 Design |
| History | `/training/history` | 📋 Design |

### Key Components
| Component | Description |
|-----------|-------------|
| InterestSelector | Onboarding multi-select |
| DrillCard | Drill with difficulty badge |
| DrillSession | Practice recording |
| KnowledgeCard | Knowledge article preview |
| CoachCard | AI recommendation card |
| ProgressChart | Skill progression |

---

## Related Documents

- [RFC-014 Training Drill Library](../Pool OS/RFC-014 - Training Drill Library.md)
- [FIX-004 Training Library & Drill Experience](../Pool OS/FIX-004 - Training Library & Drill Experience.md)
- [BR-001 Separation of Training and Play](./README.md)

---

## Status

- [x] Design Complete
- [ ] Interest Selector Implemented
- [ ] Learning Paths with 3-factor recommendation
- [ ] Drill Library (All Open)
- [ ] Knowledge Library
- [ ] AI Coach (Recommend Only)
- [ ] Progress Tracking
- [ ] History View
