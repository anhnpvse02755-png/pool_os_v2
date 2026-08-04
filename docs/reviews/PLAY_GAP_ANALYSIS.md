# Play / Match — V1 vs V2 Gap Analysis

**Date:** 2026-08-02

---

## 1. Executive Summary

The Play module gained a full Record / History / Summary cycle in this
iteration. Tournament list, quick match, friendly match, and tournament
detail were already present in V2. After this iteration, Play is at
V1 parity for match recording, post-match summary, and historical
review.

---

## 2. Pre-iteration state

| Capability | Status |
|------------|--------|
| Tournament list | ✅ |
| Tournament detail | ✅ |
| Quick match | ✅ |
| Friendly match | ✅ |
| Vision recording | ✅ |
| Play hub | ✅ |
| Match history | ⚠️ hardcoded demo |
| Match recording | ⚠️ half-wired, dropped fields |
| Match summary | ❌ absent |
| Match timeline | ❌ absent |
| AI analysis | ❌ absent |

---

## 3. Post-iteration state

| Capability | Status | Path |
|------------|--------|------|
| Tournament list | ✅ | `tournament_list_screen.dart` |
| Tournament detail | ✅ | `tournament_detail_screen.dart` |
| Quick match | ✅ | `quick_match_screen.dart` |
| Friendly match | ✅ | `friendly_match_screen.dart` |
| Vision recording | ✅ | `vision_recording_screen.dart` |
| Play hub | ✅ | `play_screen.dart` |
| Match recording (V1 parity) | ✅ | `match_recording_screen.dart` (rewired) |
| Match history (Repository-backed) | ✅ | `match_history_screen.dart` (rewrote) |
| **Match summary (full V1 parity)** | ✅ | **`match_summary_screen.dart` (new)** |
| **Match timeline** | ✅ | **`match_summary_screen.dart` section** |
| **AI Analysis** | ✅ | **`MatchReviewEngine` (new)** |

---

## 4. Architectural Wins

- Introduced `IMatchRepository` abstraction with offline-first
  `LocalMatchRepository` impl.
- All persistence routes through `LocalStorageService` (SharedPreferences).
- Future Supabase sync swaps in `SupabaseMatchRepository` with same interface.
- `MatchStatisticsService` aggregates from a single match; reusable for Coach.
- `MatchReviewEngine` is deterministic and side-effect-free.

---

## 5. Router

- `GET /play/match` — history list.
- `POST /play/match/new` — recording.
- `GET /play/match/:id/summary` — full report.
- `GET /play/match/:id/timeline` — rack timeline.

(All routes available via `go_router`.)

---

## 6. Tests

- `tests/05-match-summary.spec.ts` covers basic flow + sections + AI.

---

## 7. Definition of Done — status

- [x] Match recording end-to-end
- [x] Repository persistence
- [x] Match summary full screen
- [x] AI Analysis generation
- [x] All V1 sections rendered
- [x] Documentation complete
