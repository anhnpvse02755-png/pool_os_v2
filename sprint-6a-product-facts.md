---
name: sprint-6a-status
description: Sprint 6A (Player Intelligence Model) closed. Coach AI now understands the player.
metadata:
  type: project
---

**Sprint 6A** = Player Intelligence Model

**North Star:** "Coach AI hiểu người chơi."

**Closed:** 2026-08-07.

**Shipped:**

### Phase 6A — Personal Intelligence Layer

**Player Intelligence Model Components:**

1. **Identity Layer** (`PlayerIdentity`)
   - Name, experience level, play style
   - Goals, started date

2. **Skill Profile** (`SkillProfile`)
   - Individual skill levels (0-100)
   - Primary strength/weakness
   - Most practiced skills

3. **Progress Tracker** (`ProgressTracker`)
   - Historical scores
   - Current trend (improving/stable/declining)
   - Personal best, improvement rate
   - Consistency score

4. **Mistake Patterns** (`MistakePatterns`)
   - Top recurring mistakes
   - Improving mistakes
   - New mistakes

5. **Memory Layers:**
   - **Short-term**: Recent sessions, matches, reflections
   - **Long-term**: PB, trends, habits
   - **Semantic**: Level, mastered concepts
   - **Working**: Current conversation context

6. **Practice & Match Patterns**
   - Session frequency, favorite drills
   - Win rate, streaks, opponent analysis

7. **Mental Model**
   - Confidence, focus, pressure handling
   - Tilt tendency, triggers, mental blocks

**Coach AI Can Now Answer:**

1. "Người này là ai?" → `PlayerIdentity`
2. "Đang tiến bộ thế nào?" → `ProgressTracker`
3. "Thường mắc lỗi gì?" → `MistakePatterns`
4. "Lần sau hướng dẫn điều gì?" → `RecommendationHistory` + reasoning

**Example Coach Explanation:**
> "Tôi cho rằng bạn nên tập Stop Shot vì:
> - Tuần trước accuracy giảm 10%
> - Lỗi recurring là speed control
> - Bạn đã có nền tảng từ Straight Pot"

**Design Principles Applied:**
- Player Model = living model (updates from every session/match)
- Not CRUD profile — dynamic intelligence
- Memory is layered (short/long/semantic/working)
- Phase 7 will add conversation orchestration

**Engineering gate:** All routes analyze clean.

**Product validation:** Deferred to Phase 7 Milestone.

**Next:** Sprint 6B — Coach Recommendation Engine

Related: [[phase-3-vertical-slice-roadmap]], [[sprint-5c-product-facts]].
