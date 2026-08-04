# V2 — Historical V1 Regression Summary

> **Archived.** This document was written under the (incorrect) assumption
> that V1 was the source of truth. The new source of truth is
> `VISION.md` and `ROADMAP.md`. See `VISION_GAP.md` for the current view.

**Date:** 2026-08-02
**Scope:** Historical audit of all V1 modules against the V2 codebase.

---

## 1. Per-module summary

| Module | Status | Detail doc |
|--------|--------|------------|
| Equipment | ✅ parity with minor future work | `EQUIPMENT_GAP_ANALYSIS.md` |
| Training | ⚠️ screens exist; engine under-built | `TRAINING_GAP_ANALYSIS.md` |
| Knowledge | ✅ parity with cross-link gaps | `KNOWLEDGE_GAP_ANALYSIS.md` |
| **Match / Play** | ✅ **restored** | `MATCH_SUMMARY_GAP_ANALYSIS.md`, `MATCH_SUMMARY_RESTORATION_REPORT.md`, `PLAY_GAP_ANALYSIS.md` |
| Coach | ✅ parity (AI engine now wired) | `COACH_GAP_ANALYSIS.md` |
| Profile | ⚠️ minor Player State gap | `PROFILE_GAP_ANALYSIS.md` |
| Statistics | ⚠️ partial aggregates | `STATISTICS_GAP_ANALYSIS.md` |
| Reports | ✅ Match Summary restored; broader reports pending | `REPORTS_GAP_ANALYSIS.md` |

---

## 2. Highlights of this iteration

### Match Summary — full restore

Created/extended:
- `lib/data/models/match.dart` — Match now has 30+ fields, full V1 parity.
- `lib/data/models/match_analysis.dart` — AI Analysis, Player State, Equipment Snapshot, Timeline.
- `lib/data/models/shot.dart` — restored Shot model.
- `lib/data/repositories/match_repository.dart` — `IMatchRepository` + `LocalMatchRepository`.
- `lib/data/repositories/shot_repository.dart` — `IShotRepository` + `LocalShotRepository`.
- `lib/domain/services/match_statistics_service.dart` — `MatchStatisticsService` + `MatchReviewEngine`.
- `lib/presentation/screens/play/match_summary_screen.dart` — full Match Summary screen.
- `lib/presentation/screens/play/match_history_screen.dart` — repository-backed history.
- `lib/core/router/app_router.dart` — `/play/match/new`, `/play/match/:id/summary`.

Tests:
- `tests/05-match-summary.spec.ts` — 5 regression assertions.

Docs:
- `docs/reviews/MATCH_SUMMARY_GAP_ANALYSIS.md`
- `docs/reviews/MATCH_SUMMARY_RESTORATION_REPORT.md`

---

## 3. Architecture compliance

| Constraint | Status |
|------------|--------|
| No hardcoded persistence | Match Summary now uses `IMatchRepository`. |
| Repository abstraction | `IMatchRepository` ready for `SupabaseMatchRepository`. |
| Offline-first | `SharedPreferences` via `LocalStorageService`. |
| Supabase-ready | Swap implementation; same interface. |
| Match Summary not gated | Always reachable via `/play/match/:id/summary`. |

---

## 4. Per-screen coverage

| Screen | Backend | UI | Status |
|--------|---------|----|--------|
| Welcome / Onboarding / Interests | ✅ auth service | ✅ | pass |
| Home | ✅ service-based | ✅ | pass |
| Notification | ✅ | ✅ | pass |
| Training Center / Drill / Drill Session / Knowledge / Certification / Learning Path / History / Recommended / Progress / Assessment | ✅ services | ✅ | partial engine |
| Play / Tournament / Quick Match / Friendly Match | ✅ | ✅ | pass |
| **Match Recording** | ✅ (restored) | ✅ | **pass** |
| **Match History** | ✅ (restored) | ✅ | **pass** |
| **Match Summary** | ✅ (restored) | ✅ | **pass** |
| Coach / Analysis / Training Plan | ✅ | ✅ | partial engine |
| Profile / Edit Profile / Settings | ✅ | ✅ | pass |
| Equipment / Detail / Edit / Stats / Comparison | ✅ | ✅ | pass |
| Community | n/a | ✅ | pass |

---

## 5. Regression-free contracts

- Match, Rack, Shot, Tournament models all serialize via `toJson()` /
  `fromJson()` (round-trip tested implicitly through repository).
- `Match.copyWith` preserves immutability.
- `LocalMatchRepository.deleteMatch(id)` cleans sub-resources.
- `MatchStatisticsService.aggregatePlayerStats` is side-effect-free.
- `MatchReviewEngine.generateAnalysis` is deterministic per match.

---

## 6. Pending backlog

| Item | Priority | Effort |
|------|----------|--------|
| Drill session recovery | P1 | 2d |
| Recommendation graph | P1 | 3d |
| Player State screen | P2 | 1d |
| Weekly coach report | P2 | 2d |
| Personal best tracking | P2 | 1d |
| Coach profile aggregator | P2 | 1d |
| Share / PDF export | P3 | 2d |
| Achievements | P3 | 3d |
| Heatmap | P3 | 1d |

Total estimated: ~17 days.

---

## 7. Definition of Done — overall

- [x] Match Summary restored
- [x] All gap analyses on each module
- [x] No hardcoded persistence in Match flow
- [x] AI Analysis generated automatically
- [ ] Remaining P1 backlog (Drill recovery + Recommendation)
