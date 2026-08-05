# Sprint 2B — Retrospective

> **Sprint:** 2B — Match Parity
> **Period:** 2026-08-05
> **Branch merged:** `feature/parity/match` → main (commit `5326b06`)
> **Constitution baseline:** `dbe357d` (post-Sprint 2A merge)
> **One page by design** — process reflection, not handover.

---

## What worked well

1. **Article 8 again kept the test surface honest.** Going in,
   the natural temptation was to write tests for all 30+
   `IMatchRepository` methods (CDUD, racks, timeline, analysis,
   aggregates, AI integration). The 8-case spec kept the Tier 1
   work to the 8 invariants that actually protect business
   rules. Adding more would have felt productive without adding
   signal.
2. **Pre-implementation grep audit.** Verifying
   `SupabaseService` and `MatchModel` had zero importers before
   AC-3 ran kept the deletion risk-free. The audit also
   surfaced the wider chain (`rack_model.dart`, `shot_model.dart`,
   two `.g.dart` files, plus the barrel exports) — without the
   pre-check, AC-3 would have shipped a partial cleanup with
   orphan `.g.dart` files left behind. We did catch the orphan
   in review, but the audit could be hardened into a mandatory
   step for future dead-code ACs.
3. **Architectural mismatch surfaced early.** Writing the test
   exposed `Match.sessionId` (int?) vs
   `getMatchesBySession(String)` with a `.toString()` compare.
   That was not 2B's problem to fix, but we documented it in the
   AC-1 commit body so it cannot get lost. The right home for
   that fix is a separate architectural refactor.

## Bug detected

| Bug | Severity | Where |
|---|---|---|
| None found in production code in this sprint. | — | — |

The duplicate-id guard in `LocalMatchRepository.saveMatch`
already existed before this sprint (lines 105-110 of
`match_repository.dart`). The test confirms it.

## Does the Constitution need to change?

**No.** Article 8 once again prevented scope inflation:

- Initial inventory of 30+ repo methods could have justified
  15+ test cases. The 8-case shape held.
- AC-3 scope expanded during implementation (5 files deleted, not
  the original 3) — but the expansion was cleanup of the same
  dead-code chain, not a scope change.
- The retrospective format is the same as 2A. No second form
  needed.

## Were any ACs redundant?

- **AC-3 (Delete Supabase + chain):** correctly expanded. The
  initial 3-file plan was 5 files + barrel edits; all in the
  same dead-code chain. Article 8 supports this kind of "delete
  what we already started deleting."
- **AC-2 (Widget smoke):** correctly narrow. The original plan
  asserted "scores visible" but the screen's stats service uses
  `LocalShotRepository()` directly (not overridable), which
  pushed full score assertion into Tier 1 territory. We
  tightened to "loading completes" — that's the real smoke.
- **AC-1 Case 3 (originally getMatchesBySession):** correctly
  swapped for `getMatchesByPlayer` after the architectural
  mismatch surfaced.

No AC was redundant in the final 4-AC shape.

## Tier 1 demote candidates

Looking at the existing 12-file Critical Suite, none of the
entries need demotion based on this sprint's experience. The
Sprint 1 baseline is still healthy. The Sprint 2A and 2B
additions are both protecting real bugs/invariants.

## Open items for backlog (NOT Sprint 2C scope)

| Item | Reason it's not Sprint 2C |
|---|---|
| `Match.sessionId` (int?) vs `getMatchesBySession` (String) | Architectural refactor; Coach parity sprint should not pick this up. |
| `saveRack`/`saveTimelineEntry`/`saveAnalysis` not enforcing parent match existence | Same: needs an architectural call, not a parity sweep. |
| `getPlayerAggregates` redundant empty checks (line 233 + 267, 268) | Cosmetic; can be cleaned in a future refactor sprint. |
| MatchStatisticsService not covered by Tier 1 | Match stats is consumed by MatchSummaryScreen via `LocalShotRepository()` (inline), which makes a clean Tier 1 test environment expensive. Recommend promoting in a Regression Sprint where the test infrastructure is in scope. |

## Sprint 2B process scorecard

| Dimension | Result |
|---|---|
| Article 1 (One-Line Rule) | Honored — 8 cases each protect one invariant |
| Article 2 (Test Tiers) | Honored — Tier 1 promotion with rationale, Tier 2 smoke intentionally narrow |
| Article 3 (Sprint Gates) | Honored — gate output is the verification |
| Article 4 (Test Budget) | Honored — ~50% feature + test, 0% report |
| Article 5 (Critical Suite) | Honored — manifest updated, 12 files |
| Article 6 (Bug-Fix Rule) | N/A — no production bug found this sprint |
| Article 7 (Amendment) | Honored — Constitution unchanged |
| Article 8 (Evidence over Artifacts) | Honored — no per-AC scorecard, no SPRINT_2B_VERIFICATION.md |

## Hand-off to Sprint 2C

Match domain is closed. Next P0 module is **Coach Parity**
(Sprint 2C). Same Article 8 discipline: kickoff → 4 AC max →
gate output as verification.

Decisions already locked for Sprint 2C kickoff:
- The `MatchStatisticsService` and `MatchReviewEngine` write
  paths are most likely where the AI Coach domain will need to
  hook in. Coordinate via `analysis` field on `Match`.
- The `MatchWeaknessSignals` service (66 lines) is already
  Coach-adjacent; whether it becomes a Coach-side consumer or
  stays in Match domain is a kickoff decision, not a sprint
  question.

## Comparing 2A and 2B side-by-side

| | Sprint 2A | Sprint 2B |
|---|---|---|
| Domain | Equipment | Match |
| Model complexity | 17+ fields, flat | 30+ fields, embedded |
| Repo methods | 30+ | 30+ |
| Test cases added | 10 (Tier 1) + 1 widget | 8 (Tier 1) + 1 widget |
| Production code change | 11 lines (dup guard) | 0 (guard already existed) |
| Dead code removed | 2 files, 86 lines | 7 files, 586 lines |
| Manifest count | 10 → 11 | 11 → 12 |
| Net ROI | Found 1 bug, added coverage | Added coverage, removed 6.7x more dead code than 2A |

The dead-code removal in 2B dwarfs the dead-code removal in 2A
in absolute terms, because `SupabaseService` was a planned-but-
never-wired feature rather than a stale V1 import. Same Article 8
rule, different surface to apply it to.