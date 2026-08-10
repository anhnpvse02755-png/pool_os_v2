---
name: sprint-3a-status
description: Sprint 3A (Complete the Practice Loop) is closed at Engineering + Product level. Sprint 3B blocked pending real-user validation.
metadata:
  type: project
---

Sprint 3A = Complete the Practice Loop.

Closed: 2026-08-06, merge commit `c3757a8`.

Shipped:
- Task 1: Persistence wired (#19)
- Task 2: Completion Experience (#20)
- Task 3: Reflection 3-layer (#21)
- Task 4: Next Action forward path (#22)
- Task 5: Practice Loop DoD verification (#23)
- Retrospective (#24)

Engineering gates: PASS (analyze 0 issues, Critical Suite 14/14, smoke 2/2).
Product validation: NOT YET.

Deferred tech debt:
- #27: drillSessionRepositoryProvider hoisting
- #30: PB metric semantic bug for non-accuracy metrics

**Why:** Sprint 3A proved the *capability* for users to return but not the *validation* that they actually do.

**How to apply:** Do not open Sprint 3B (Match Experience) until user runs:
- Real device UX testing
- 5-10 user validation with North Star questions
- Friction observation

Only after these results land does Sprint 3B Discovery begin.

Related: [[phase-3-constitution]], [[phase-3-validation-rule]].
