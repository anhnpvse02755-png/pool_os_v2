---
name: sprint-3b-status
description: Sprint 3B (Match Experience) is closed at Engineering level. 6 tasks completed.
metadata:
  type: project
---

Sprint 3B = Match Experience.

**North Star:**
"User xem lại trận vừa chơi và hiểu mình vừa chơi như thế nào."

**Closed:** 2026-08-07.

**Shipped:**
- Task 3B.1: MatchSummaryScreen wired to app_router (route + navigation)
- Task 3B.2: Auto-save match data (already implemented in _endMatch)
- Task 3B.3: Match Reflection stats (basic stats in MatchSummaryScreen)
- Task 3B.4: Match History screen (MatchHistoryScreen via matchRepositoryProvider)
- Task 3B.5: End-to-end workflow (all routes wired, no dead ends)
- Task 3B.6: DoD verification (cold user can complete match record-to-history)

**Workflow:** Record (MatchRecordingScreen) → Summary (MatchSummaryScreen) → History (MatchHistoryScreen)

**Routes:**
- `/play` → PlayScreen
- `/play/recording` → MatchRecordingScreen
- `/play/match/:matchId/summary` → MatchSummaryScreen
- `/play/history` → MatchHistoryScreen

**Engineering gate:** All routes analyze clean, navigation is go_router consistent.

**Product validation:** Deferred to Phase 7 Milestone (Rule 4B).

**Deferred tech debt:**
- #TODO-1: `getRecentMatches(limit)` not implemented (Phase D)
- #TODO-2: `MatchStats` typed model missing (Phase D)

**Why:** Match workflow now mirrors Sprint 3A pattern: persist → surface → reflect → history.

**How to apply:** Continue to Phase 4 (History & Analytics). Phase 4A = Training History.

Related: [[phase-3-constitution]], [[phase-3-vertical-slice-roadmap]], [[sprint-3a-product-facts]].
