# PoolOS V2 - Training Center (Final Specification)

**Version:** 1.0
**Date:** 2026-08-02
**Status:** Final

---

## 1. Structure

```
Training Center
├── AI Learning Path     ← AI đề xuất lộ trình
├── Drill Library        ← Thư viện bài tập
├── Knowledge           ← Thư viện kiến thức
└── Skill Certification ← Bài kiểm tra kỹ năng
```

---

## 2. AI Learning Path

### Purpose
AI đề xuất lộ trình học tuần này.

### Display
```
Tuần này

1. Stop Shot Lv1
2. Follow Shot Lv1
3. Basic Position Lv1
4. Straight Shot Lv1

[Follow AI]  [Bỏ qua]
```

### User Actions
- **Follow AI**: Làm theo lộ trình
- **Bỏ qua**: Tự chọn bài tập khác

### Key Rule
> AI chỉ đề xuất. Không ép.

---

## 3. Drill Library

### Tabs
```
[Recommended] [All Drill]
```

### Recommended Tab
- Lấy từ AI Learning Path
- Có thể làm hoặc bỏ qua

### All Drill Tab
- Toàn bộ bài tập
- Filter theo:
  - **Difficulty**: Easy, Medium, Hard, Expert
  - **Category**: Potting, Position, Safety, Kick, Jump, Masse, Bridge, Cue Ball, Mental
- Search

---

## 4. Drill Structure

### Each Drill Contains
```
├── Video
├── Description
├── Setup
├── Steps
├── Goal
├── Knowledge (linked)
├── Common Mistakes
└── Related Drill
```

### Level System
```
Stop Shot
├── Lv1
├── Lv2
├── Lv3
├── Lv4
└── Lv5
```

### Level Locking Rule
```
Lv1 → Lv2 → Lv3 → Lv4 → Lv5

Phải hoàn thành Lv2 mới được mở Lv3
```

### Level Completion Criteria
```
Ví dụ:
10 attempts → 8 successes = Pass

Nếu Fail → Retry
```

### NO "Complete" Button
> App tự đánh giá dựa trên tiêu chí. Không cho phép user tự đánh dấu.

---

## 5. Knowledge

### Purpose
Thư viện kiến thức độc lập.

### Access
1. Training Center → Knowledge
2. Drill → Knowledge (linked)

### Relationship
- Knowledge ↔ Drill: Nhiều-nhiều
- Drill → Knowledge: Related
- Knowledge → Drill: Related

### Key Rule
> **Knowledge không bị khóa.**
> Người chơi hạng I vẫn có thể học Masse.
> Không giới hạn theo trình độ.

---

## 6. Skill Certification

### Purpose
Bài kiểm tra kỹ năng.

### Not For
- ❌ Mở khóa Drill
- ❌ Xác nhận hoàn thành Level

### Only For
- ✅ Đo kỹ năng
- ✅ Theo dõi tiến bộ

### Examples
```
├── Stop Shot Test
├── Position Test
├── Follow Test
└── Draw Test
```

### Availability
> Người chơi có thể làm bất cứ lúc nào.

---

## 7. Module Relationships

```
AI
  ↓
Recommended Drill (Learning Path)
  ↓
Drill (with Levels - LOCKED progression)
  ↓
Knowledge (NOT locked - always accessible)
  ↓
Related Drill
```

### Locking Rules
| Module | Locked? | Rule |
|--------|---------|------|
| Knowledge | ❌ NO | Always accessible |
| Drill Levels | ✅ YES | Progressive unlock |
| Skill Certification | ❌ NO | Always accessible |

---

## 8. What's NOT in Training Center

```
❌ Match Recording
❌ Thi đấu
❌ League
❌ Tournament
❌ Ranking Match
❌ Coffee Bet
❌ Challenge
❌ Social
```

> Training Center chỉ dành cho luyện tập.

---

## 9. Philosophy

> Học đi đôi với hành.

| Component | Purpose |
|-----------|---------|
| Knowledge | Giúp hiểu |
| Drill | Giúp luyện |
| Skill Certification | Giúp đo tiến bộ |

### AI's Role
> AI chỉ gợi ý. Người chơi luôn có quyền tự học bất kỳ kỹ thuật nào.

### Unlocking Philosophy
> **Không khóa kiến thức theo trình độ.**
> Chỉ khóa Level của từng Drill để đảm bảo người chơi luyện đúng thứ tự.

---

## 10. Screen List

| Screen | Route | Status |
|--------|-------|--------|
| Training Center Home | `/training` | ✅ Done |
| AI Learning Path | `/training/path` | 📋 |
| Drill Library | `/training/drills` | ✅ Done |
| Drill Detail | `/training/drill/:id` | 📋 |
| Drill Session | `/training/session/:id` | ✅ Done |
| Knowledge | `/training/knowledge` | 📋 |
| Knowledge Detail | `/training/knowledge/:id` | 📋 |
| Skill Certification | `/training/certification` | 📋 |
| Skill Test | `/training/test/:id` | 📋 |

---

## 11. Data Models

### Drill
```dart
class Drill {
  String id;
  String name;
  String nameVi;
  String category;      // 'potting', 'position', etc.
  String difficulty;   // 'easy', 'medium', 'hard', 'expert'
  String description;
  String? videoUrl;
  List<String> steps;
  String goal;
  List<DrillLevel> levels;
  List<String> knowledgeIds;
  List<String> commonMistakes;
  List<String> relatedDrillIds;
}
```

### DrillLevel
```dart
class DrillLevel {
  int level;           // 1, 2, 3, 4, 5
  int attempts;        // required attempts
  int passCount;      // successes needed
  bool isUnlocked;    // depends on previous level
  int? userBestScore; // user's best result
}
```

### Knowledge
```dart
class Knowledge {
  String id;
  String title;
  String titleVi;
  String category;
  String content;
  List<String> drillIds;  // related drills
  List<String> relatedKnowledgeIds;
}
```

### SkillCertification
```dart
class SkillCertification {
  String id;
  String name;
  String nameVi;
  String description;
  List<CertificationTest> tests;
}
```

---

## 12. Implementation Priority

### Phase 1: Core (Current)
- [x] Drill Library with categories
- [x] Drill Session (manual recording)
- [ ] Drill Levels with locking
- [ ] Level completion criteria

### Phase 2: Knowledge
- [ ] Knowledge library
- [ ] Drill-Knowledge linking
- [ ] Knowledge search

### Phase 3: AI
- [ ] AI Learning Path generation
- [ ] Recommendation algorithm
- [ ] Progress tracking

### Phase 4: Certification
- [ ] Skill tests
- [ ] Certification criteria
- [ ] Progress visualization
