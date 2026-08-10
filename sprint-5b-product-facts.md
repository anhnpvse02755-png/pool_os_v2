---
name: sprint-5b-status
description: Sprint 5B (Reasoning Chain) closed. Coach AI can explain, not just recommend.
metadata:
  type: project
---

**Sprint 5B** = Reasoning Chain

**North Star:** "Coach AI có thể explain."

**Closed:** 2026-08-07.

**Shipped:**

### Phase 5B — Reasoning Chain Foundation

**New Node Types:**
- `ObservationNode` — Observable data signals (accuracy_drop, cue_ball_overrun, etc.)
- `CauseNode` — Root causes of mistakes (rolling_cue_ball, over_hit, poor_stun, etc.)

**Updated Node Types:**
- `DrillNode` — Added `fixesCauses` field
- `MistakeNode` — Added `suggestedByObservations` field

**Knowledge Graph Relationships:**
```
Observation → suggests → Mistake
Mistake → caused_by → Cause
Cause → fixed_by → Drill
Cause → affects → Skill
```

**Reasoning Chain (Coach AI explains):**
```
Observation (accuracy giảm)
  ↓
Pattern (speed control unstable)
  ↓
Mistake (cue ball speed control)
  ↓
Cause (rolling cue ball, over-hit)
  ↓
Drill (Stop Shot, Speed Control)
```

**Example Coach Explanation:**
> "Tôi cho rằng bạn đang gặp vấn đề về Speed Control vì trong 5 buổi gần nhất accuracy giảm trong khi Position Recovery tăng. Drill Stop Shot sẽ giải quyết nguyên nhân này."

**Coach AI Impact:**
- ✅ AI can explain WHY (not just WHAT)
- ✅ Reasoning chain from Observation → Cause → Drill
- ✅ Diagnostic questions available for each cause
- ✅ Indicators for cause identification

**Design Principle Applied:**
- Recommendation chỉ là output
- Reasoning mới là giá trị
- Sprint 5B xây nền reasoning trước
- Recommendation sẽ được xây ở Phase 6

**Engineering gate:** All routes analyze clean.

**Product validation:** Deferred to Phase 7 Milestone.

**Next:** Sprint 5C — Chiến thuật (Tactics)

Related: [[phase-3-vertical-slice-roadmap]], [[sprint-5a-product-facts]].
