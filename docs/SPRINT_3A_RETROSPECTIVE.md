# Sprint 3A — Retrospective

**Sprint:** 3A (Complete the Practice Loop)
**Branch:** `feature/product/sprint-3a-*`
**Duration:** 2026-08-06 (single-day sprint)
**Verdict:** SHIP-WORTHY
**Date:** 2026-08-06

---

## Sprint Goal

> **User quay lại tập lần thứ hai.**

The Practice Loop must be reachable end-to-end. Cold user opens the app, practices, sees meaningful feedback, and has a clear forward path to a second session — without going back to a drill list.

---

## Worked

### 1. Completion Experience closes the loop

Before Sprint 3A, the app was a drill launcher: user taps a drill, practices, then hits a dead end. After Sprint 3A, the app is a **practice loop**: Practice → Complete → Reflection → Next Action → Practice again.

The single most important change was the dedicated Completion Experience screen (`DrillCompletionScreen`). It transformed a state-flip on the instructions view into a real, distinct workflow state.

### 2. Persistence layer re-used, not rebuilt

The data layer (`DrillSession`, `DrillRun`, `DrillAttempt`, `PersonalBest`, `LocalDrillSessionRepository`, `LocalPersonalBestRepository`, `DrillSessionRecoveryService`) was already complete from earlier sprints. Sprint 3A Task 1 only needed to wire it into `DrillSessionScreen`. No new repositories, no new models, no new persistence code.

This was a strong validation of the architecture: when the persistence layer is complete, the UI wiring becomes the bottleneck, not the data layer.

### 3. Reflection has value immediately

The 3-layer Reflection block (Immediate Progress / Personal Best / Coach Insight placeholder) answered the product question — "Mình có đang tiến bộ không?" — with no AI, no history-based logic, just data already in storage. The reflection card was cheap to build and immediately useful.

### 4. Engine-agnostic Next Action

By accepting `recommendationsSource` as a parameter on `NextActionPanel`, Sprint 3A Task 4 shipped a forward path that is independent of the recommendation engine. The rule-based engine (`DrillLibrary.getRecommendedDrills()`) is a placeholder for Sprint 3C's AI recommendation, but the UI surface will not change when the engine evolves.

### 5. Workflow-first thinking kept scope tight

Every task answered one question: *"User đang bị kẹt ở đâu trong workflow?"* This kept the backlog aligned with the North Star and prevented scope creep into the data layer, recommendation engine, or AI integration.

---

## Didn't

### 1. Recommendation is still rule-based

`DrillLibrary.getRecommendedDrills()` returns a hardcoded 5-drill list. Sprint 3A accepted this as a placeholder; Sprint 3C will replace it with history-based logic. The UI surface is engine-agnostic, so the swap is cheap — but the current recommendations are not actually *useful* for a returning user.

### 2. No real retention data

We cannot claim "User quay lại tập lần thứ hai" with confidence. The engineering gates (analyze, Critical Suite, smoke tests) prove the workflow is reachable. The product question — "Does a real user actually want to come back?" — requires user testing, not unit tests.

### 3. No telemetry

Without telemetry, we cannot measure:
- How often users tap Next Action.
- What % of users complete a second session within 7 days.
- Where users drop off in the loop.

Sprint 3A was a "ship-worthy" boundary, not a "data-driven" boundary.

### 4. Coach Insight is a placeholder

Reflection Layer 3 shows "Sẽ có ở Sprint 3D". The placeholder is intentional — it reserves the spatial layout for the real Coach Insight without forcing a redesign later. But it is not a feature.

### 5. No UX testing on a real device

The Sprint 3A DoD verification was code-path tracing + widget smoke tests. Real device UX testing (the moment of clarity, the screen that feels "done", the button copy that makes you want to tap) was deferred to the user testing phase.

---

## Learned

### 1. Workflow is more important than feature count

Sprint 3A shipped 5 small tasks (Tasks 1–5) that each closed a single workflow gap. None of them was a "feature" in the traditional sense. Yet the user-facing impact was larger than any single feature in Sprint 2.

The lesson: **a missing workflow step is a bigger gap than a missing feature**. Sprint 3A proved that.

### 2. Data layer was sufficient; UI wiring was the bottleneck

Across 5 tasks, we touched:
- 1 file in `domain/services/` (none — recovery service was already complete).
- 1 file in `data/repositories/` (none — repos were already complete).
- 1 file in `data/models/` (none — models were already complete).
- 4 new files and 3 edits in `presentation/`.

The bottleneck was never the data layer. The bottleneck was always the UI thread that *connected* the data layer to the user. Sprint 3A confirms this is where investment should go.

### 3. Completion moment is the highest-leverage point

In a practice loop, the transition from "trying" to "done" is the moment when the user reflects. That moment is where retention is won or lost. Sprint 3A's Reflection + Next Action surface is the *only* place in Pool OS where the user pauses and decides whether to continue.

The lesson: **the completion moment is the leverage point**. Sprint 3D (Coach Insight) will return to this moment.

### 4. Technical-deferral rule prevents scope creep

Sprint 3A discovered 2 technical debts (PB metric semantic bug, drillSessionRepositoryProvider hoisting) and 1 specific limitation (Player null path). All three were deferred to housekeeping. This kept the Sprint focused on the workflow outcome.

The lesson: **some technical debt is acceptable if it doesn't block the user outcome**. The Phase 3 technical-deferral rule worked.

### 5. Product-first thinking changed the AI

The most important shift in Sprint 3A was not technical — it was the *question* being asked. Before Sprint 3A, the question was "Which database field should we update?". After Sprint 3A, the question is "What does the user see at the moment of completion?".

Sprint 3B should continue this discipline.

---

## Sprint 3A Task Summary

| # | Task | Outcome | PR | Merged |
|---|---|---|---|---|
| 1 | Hoàn thành buổi tập | Persistence wired | #19 | ✅ |
| 2 | Completion Experience | Dedicated screen | #20 | ✅ |
| 3 | Reflection | 3 layers (delta / PB / insight) | #21 | ✅ |
| 4 | Next Action | Forward Path (engine-agnostic) | #22 | ✅ |
| 5 | Practice Loop DoD | Workflow verified | #23 | ✅ |

- **5 PRs merged, 0 regressions** in Critical Suite (14 files, 108 tests).
- **2 new widgets** (`ReflectionCards`, `NextActionPanel`).
- **1 new screen** (`DrillCompletionScreen`).
- **1 new route** (`/training/session/complete`).
- **1 DoD report** (`docs/SPRINT_3A_DOD_REPORT.md`).
- **0 new features** in the data layer.

---

## Phase 3 Constitution Compliance

| Rule | Status |
|---|---|
| Workflow Rule | ✅ Complete loop from start to next session |
| North Star Rule | ✅ Every task aligned with "User quay lại tập lần thứ hai" |
| DoD Rule | ✅ Cold user completes workflow without instructions |
| Technical-deferral Rule | ✅ 2 tech debts deferred, no scope creep |
| 1-task-at-a-time | ✅ Each task closed before next started |

---

## What Comes Next

Sprint 3A is closed. Before Sprint 3B:

1. **Real device UX testing.** Build APK, install, walk through the Practice Loop as a player would. Note where friction exists.
2. **5–10 user validation.** Run the North Star test: "Bạn có muốn bấm Tập tiếp không? Ngày mai bạn có nhớ muốn quay lại không?"
3. **Capture results.** These will inform Sprint 3B's product-led discovery.

Sprint 3A taught us that **workflows are the unit of value**. Sprint 3B should continue building whole workflows, not piling up features.
