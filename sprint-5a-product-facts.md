---
name: sprint-5a-status
description: Sprint 5A (Knowledge Graph) closed. Coach AI Brain foundation built.
metadata:
  type: project
---

**Sprint 5A** = Knowledge Graph

**North Star:** "Coach AI hiểu từng drill."

**Closed:** 2026-08-07.

**Shipped:**

### Phase 5A — Knowledge Graph Foundation

**Node Types:**
- `DrillNode` — Drill knowledge (skillsTrained, prerequisites, fixesMistakes, tips)
- `SkillNode` — Pool skills (aiming, stroke, cue_ball_control, etc.)
- `MistakeNode` — Common mistakes (cue_ball_overrun, thin_hit, etc.)

**Knowledge Graph Relationships:**
```
Drill → trains → Skill
Drill → fixes → Mistake
Drill → requires → Drill (prerequisite)
Drill → progresses → Drill
Skill → relates → Mistake
```

**Seed Data:**
- 15 drill nodes
- 12 skill nodes
- 11 mistake nodes

**Coach AI Query Interface:**
```dart
kg.getDrill(code)           // Get drill knowledge
kg.getDrillsBySkill(skillId)  // Get drills for skill
kg.getPrerequisites(code)   // Get prerequisites
kg.getProgressionDrills(code) // Get next drills
kg.explainDrillPurpose(code)  // Explain why to practice
```

**Design Principle:**
- Structured nodes, not documents
- AI queries graph → not "reads 900 articles"
- Knowledge Graph ready for Phase 6-7 reasoning

**Engineering gate:** All routes analyze clean.

**Product validation:** Deferred to Phase 7 Milestone.

**Next:** Sprint 5B — Reasoning Chain

Related: [[phase-3-vertical-slice-roadmap]], [[sprint-5b-product-facts]].
