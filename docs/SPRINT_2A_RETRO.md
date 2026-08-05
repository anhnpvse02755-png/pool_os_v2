# Sprint 2A — Retrospective

> **Sprint:** 2A — Equipment Parity
> **Period:** 2026-08-05
> **Branch merged:** `feature/parity/equipment` → main (commit `743df7a`)
> **Constitution baseline:** `b582eaf`
> **One page by design** — this is process reflection, not handover.

---

## What worked well

1. **Tier classification before writing code.** Calling Equipment
   Tier B (not Tier A, not Tier C) up-front set the test scope to
   ~30% of the sprint rather than the ~60% the original 6-AC plan
   would have produced. Article 8 was adopted mid-sprint specifically
   to prevent the test surface from growing past the value it added.
2. **Pre-existing test helpers.** `FakeMatchRepository` from Day 2A.5
   gave us a template to write `FakeEquipmentRepository` in <30
   minutes. This is what Convention over Configuration looks like
   in practice.
3. **Equipment model already complete.** The 17+ V1 fields, the
   `EquipmentStats` aggregate, and the `MaintenanceEntry` log were
   all already wired. Sprint 2A added no new model surface — just
   tests, a one-line bug fix, and a delete. This is the right
   shape for a "parity" sprint.
4. **Bug caught at the test boundary.** Case 9 (duplicate ID guard)
   found a latent `items.add()` bug that would have manifested
   during V1→V2 data import. Article 6 + Article 8 in concert:
   one test, one fix, one commit.

## Bug detected

| Bug | Severity | Where |
|---|---|---|
| `createEquipment` blindly appended on duplicate id, producing duplicate rows | High (data corruption on re-import) | `LocalEquipmentRepository.createEquipment` |

Fix: `indexWhere` check before `items.add`, replace in place.
Total production code change: **11 lines**.

## Does the Constitution need to change?

**No** — but Article 8 was adopted mid-sprint, which is the right
outcome of the question "does the Constitution need to change?"
Sprint 2A is the first proof that Article 8 works:

- Original 6-AC plan would have produced a `SPRINT_2A_VERIFICATION.md`
  that copied gate output. Article 8 prevented that.
- Widget test scope collapsed from a 4-step flow to 3 assertions.
  No per-AC scorecard, no per-sprint closeout doc.

Article 8 should not be touched again until someone surfaces a
case where the rule is genuinely wrong (Article 7 amendment
policy).

## Were any ACs redundant?

- **AC-3 (Playwright):** correctly removed. Equipment CRUD is
  exactly the kind of flow Playwright adds no signal to.
- **AC-5 (Image placeholder):** correctly removed. V2 already
  handles `imageUrls: const []` gracefully; a placeholder widget
  would have been cosmetic.
- **AC-2 (Widget test) was right-sized, not removed.** Three
  assertions caught a real "does the screen even open?" question.
  Smaller and the test would have been noise.

No AC was redundant in the final 4-AC shape. The mistake was the
original 6-AC shape.

## Tier 1 demote candidates

Looking at the existing 10-file Critical Suite, none of the
entries need demotion based on this sprint's experience. The
Sprint 1 baseline is still healthy.

## Sprint 2A process scorecard

| Dimension | Result |
|---|---|
| Article 1 (One-Line Rule) | Honored — duplicate-ID test guards a real bug |
| Article 2 (Test Tiers) | Honored — Tier 1 promoted with rationale |
| Article 3 (Sprint Gates) | Honored — gate output is the verification |
| Article 4 (Test Budget) | Honored — ~50% feature + test, 0% report |
| Article 5 (Critical Suite) | Honored — manifest updated, 11 files |
| Article 6 (Bug-Fix Rule) | Honored — fix + test in same commit |
| Article 7 (Amendment) | Honored — Article 8 is one amendment, no drift |
| Article 8 (Evidence over Artifacts) | **Authored** — and applied |

## Hand-off to Sprint 2B

Equipment domain is closed. The next P0 module is **Match Parity**
(Sprint 2B). Same Article 8 discipline: kickoff → 4 AC max → gate
output as verification.

One open question for Sprint 2B kickoff: does Match need a
Tier 1 promotion, or can it ride on Tier 2 widget tests?
This depends on how much match-record business logic lives in the
repository vs. in screen state. Decision belongs in the Sprint 2B
kickoff doc, not retroactively here.