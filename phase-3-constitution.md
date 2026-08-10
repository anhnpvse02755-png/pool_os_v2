---
name: phase-3-constitution
description: 6 rules governing Phase 3-7 internal build and Phase 7 Product Validation.
metadata:
  type: project
---

Phase 3 has 6 constitutional rules:

1. **Workflow Rule** — every change answers "User đang bị kẹt ở đâu trong workflow?" (Where is the user stuck?)
2. **North Star Rule** — every task serves the sprint's North Star metric.
3. **DoD Rule** — cold user completes workflow without reading instructions.
4. **Internal Build Rule (4A)** — Engineering Done = sprint gate. Continuous sprints until Phase 7. No per-sprint validation.
5. **Product Validation Rule (4B)** — Validation at Phase 7 Milestone only. After Coach AI Preview build.
6. **One Sprint, One Workflow** — AI hooks into completed workflows, not reverse-engineered.

**Why:** Phase 3-7 builds a complete Vertical Slice. Product Validation gates the full workflow end-to-end, not individual sprints.

**Internal Build (Phase 3 → Phase 7):**
- Sprint closes → Engineering gate verified
- Then → next sprint opens immediately
- No stopping between sprints for validation

**Milestone Validation (after Phase 7):**
- Build APK Preview
- Real user validation
- Measure North Star
- Decide next roadmap direction

**How to apply:**
- Sprint closes → DoD verified by code path + smoke tests → open next sprint
- Phase 7 closes → Product Validation Gate → then Branch A/B/C decision

Related: [[phase-3-rule-4a]], [[phase-3-rule-4b]], [[phase-3-vertical-slice-roadmap]].
