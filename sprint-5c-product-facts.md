---
name: sprint-5c-status
description: Sprint 5C (Decision Engine) closed. Coach AI can reason about tactical decisions.
metadata:
  type: project
---

**Sprint 5C** = Decision Engine

**North Star:** "Coach hiểu chiến thuật."

**Closed:** 2026-08-07.

**Shipped:**

### Phase 5C — Decision Engine Foundation

**New Node Types:**
- `SituationNode` — Game situations (easy_shot, no_good_shot, hill_hill, etc.)
- `TacticNode` — Tactical decisions with full context (risk, skills, conditions)
- `DecisionRule` — When Coach recommends a tactic

**Knowledge Graph Relationships:**
```
Situation → recommends → Tactic
Situation → avoids → Tactic
Tactic → requires → Skill
Tactic → carries → Risk
Tactic → improves → Goal
```

**Seed Data:**
- 10 situation nodes
- 9 tactic nodes (safety, run_out, conservative, etc.)
- 10 decision rules

**Coach AI Reasoning:**
```
Situation: "Không có cú đánh tốt"
↓ Tại sao nên Safety?
↓ Vì rủi ro miss cao
↓ Risk: thấp
↓ Alternative: Push Out
```

**Example Coach Explanation:**
> "Trong tình huống không có cú đánh tốt, tôi khuyên bạn nên chơi Safety vì rủi ro miss cao. Lưu ý: Ưu tiên leave cho đối thủ khó đánh."

**Design Principle Applied:**
- Tactics là knowledge
- Decision là intelligence
- Phase 5 kết thúc với Coach AI có khả năng reasoning theo ngữ cảnh
- Phase 6 sẽ sử dụng Decision Engine này

**Engineering gate:** All routes analyze clean.

**Product validation:** Deferred to Phase 7 Milestone.

**Next:** Phase 6 — Coach Foundation

Related: [[phase-3-vertical-slice-roadmap]], [[sprint-5b-product-facts]].
