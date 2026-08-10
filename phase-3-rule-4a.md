---
name: phase-3-rule-4a
description: Phase 3 Constitution Rule 4A — Internal Build Phase, continuous sprints until Phase 7.
metadata:
  type: project
---

**Rule 4A — Internal Build Phase**

During Internal Build (Phase 3 → Phase 7):

- **Engineering Done** = sprint gate (not Product Validation)
- No per-sprint validation required
- Continuous sprints without interruption
- Validation occurs at Milestone level, not Sprint level

**Milestone = Phase 7 (Coach AI Preview)**

**Why:** Building a complete Vertical Slice requires uninterrupted flow. Stopping after each sprint for validation fragments momentum and delays discovering cross-sprint integration issues.

**How to apply:**
- Sprint closes → Engineering gate (DoD, smoke tests, code path) → open next sprint immediately
- No blocking for user testing between sprints
- Keep building until Phase 7 is complete

**Exception:** Stop only if:
1. Serious technical blocker
2. User requests roadmap change

Related: [[phase-3-constitution]], [[phase-3-rule-4b]].
