# Coach Module — V1 vs V2 Gap Analysis

**Date:** 2026-08-02

---

## 1. Executive Summary

The V2 Coach module exposes the AI analysis engine on a screen
(`coach_screen.dart`, `analysis_screen.dart`, `training_plan_screen.dart`),
but it does not yet consume the full V1 `MatchReviewEngine`. The
restoration this iteration introduced means the Coach can now surface
match-by-match strengths/weaknesses with one click.

---

## 2. V1 Surface

- `MatchReviewEngine` — generates recommendations per match.
- `MatchObjectivePolicy` — assigns objectives.
- `CoachProfile` — aggregated rolling skill.
- `weekly_coach_report.dart` — periodic summary.
- `match_objective_policy.dart` — manages per-match goals.

---

## 3. V2 Surface

| Capability | Status |
|------------|--------|
| Coach screen | ✅ `coach_screen.dart` |
| Analysis screen | ✅ `analysis_screen.dart` |
| Training plan screen | ✅ `training_plan_screen.dart` |
| Recommendation engine | ⚠️ partial (`coach_service.dart`) |
| Weekly coach report | ❌ |
| Coach profile aggregation | ❌ |
| Match-objective policy | ❌ |

---

## 4. Gap Analysis

| Capability | V1 | V2 | Action |
|------------|----|----|--------|
| MatchReviewEngine | ✅ | ✅ restored this iteration | done |
| Recommendation pipeline | ✅ | ⚠️ | enhance |
| Weekly report | ✅ | ❌ | build `weekly_report_screen.dart` |
| Coach profile | ✅ | ❌ | aggregate from `Match` |
| Objective policy | ✅ | ❌ | add `MatchObjectivePolicy` |

---

## 5. Restoration Plan

1. Wire `MatchReviewEngine.generateAnalysis` into `CoachService`.
2. Add `WeeklyCoachReport` generator.
3. Add `CoachProfile` aggregator (rolling skill ratings).
4. Surface AI Match Analysis on the Analysis screen.

---

## 6. Definition of Done

- [x] MatchReviewEngine integrated (this iteration)
- [ ] Weekly coach report
- [ ] Coach profile aggregation
- [ ] Objective policy
