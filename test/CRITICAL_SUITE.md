# Critical Suite Manifest

> **Authoritative list of Tier 1 tests that gate every release.**
> **Source of truth:** `docs/engineering-constitution.md` Article 5.
> **Last updated:** 2026-08-06.

## What this is

This manifest enumerates **exactly** which test files are part of
the Critical Suite. `scripts/run_critical_suite.sh` and
`scripts/run_critical_suite.ps1` read from this list (via the
scripts). The list is **explicit, not discovered**, so reviewers can
verify membership by reading this file.

## How to add a test

1. Verify the test protects a **business rule** (Article 1).
2. Add the file path below with a one-line rationale.
3. Update both `scripts/run_critical_suite.sh` and
   `scripts/run_critical_suite.ps1` to include the new path.
4. Open a PR. Reviewer confirms the rationale.

## How to remove a test

1. Verify the test no longer protects a business rule, OR the file
   has moved to a non-critical area.
2. Remove the entry from this manifest.
3. Remove the path from both runner scripts.
4. Justify the demotion in the PR description.

---

## Current Critical Suite

### Knowledge migration (4 files)

| File | Business rule protected |
|---|---|
| `test/knowledge_migration/pipeline_test.dart` | Migration runs end-to-end without data loss and produces a valid knowledge.json. |
| `test/knowledge_migration/validators_test.dart` | All 12 article validators catch malformed input that would corrupt the production knowledge corpus. |
| `test/knowledge_migration/mappers_test.dart` | V1 article schema maps to V2 schema without losing fields. |
| `test/knowledge_migration/cli_options_test.dart` | CLI entrypoint parses all supported flags; wrong flags do not silently corrupt migration output. |

### Knowledge runtime (2 files)

| File | Business rule protected |
|---|---|
| `test/knowledge_runtime_loading_test.dart` | Knowledge feature loads articles from bundled JSON at runtime; failure mode is graceful, not crash. |
| `test/knowledge_article_count_test.dart` | Knowledge feature guarantees a minimum article count invariant after migration; prevents silent data loss. |

### Personal bests (1 file)

| File | Business rule protected |
|---|---|
| `test/personal_best_repository_test.dart` | Personal best repository transactions are atomic; concurrent writes do not lose data. |

### Streak calculation (1 file)

| File | Business rule protected |
|---|---|
| `test/streak_calculator_test.dart` | Daily streak calculation correctly handles timezones, gaps, and session boundaries. |

### Weekly reports (1 file)

| File | Business rule protected |
|---|---|
| `test/weekly_report_generator_test.dart` | Weekly aggregation correctly sums sessions, calculates averages, and includes the correct date range. |

### Coach profile (1 file)

| File | Business rule protected |
|---|---|
| `test/coach_profile_aggregator_test.dart` | Coach profile aggregation produces stable output across re-runs for the same input set: empty-repo zero-state, 30-day window filter, win/loss tally + winRate formula, rack-level error aggregation, tone classification (Hot/Steady/Slumping/Rising), and cold-start recommendation shape. Sprint 2C expanded the seed case (1 → 6 cases). |

### Session recovery (1 file)

| File | Business rule protected |
|---|---|
| `test/drill_session_recovery_test.dart` | In-flight drill sessions can be recovered after app restart without losing recorded shots. |

### Equipment (1 file)

| File | Business rule protected |
|---|---|
| `test/equipment_repository_test.dart` | Equipment CRUD, archive, maintenance log, active-role resolution, recommendation, value totals, and duplicate-ID guard are correct and idempotent. Case 9 caught a latent duplicate-row bug on re-import. |

### Match (1 file)

| File | Business rule protected |
|---|---|
| `test/match_repository_test.dart` | Match CRUD, cascade delete (racks/timeline/analysis), getMatchesByPlayer newest-first, getPlayerAggregates (wins/losses/draws + winRate formula), score invariants, duplicate-ID guard, invalid-reference safety, and isWin/isLoss/isDraw get consistent. |

### Drill attempt (1 file)

| File | Business rule protected |
|---|---|
| `test/drill_attempt_repository_test.dart` | DrillAttempt is the data-loss path that gates session completion. Locks 6 cases: CRUD round-trip, multi-attempt ordering with monotonic `attemptNumber`, session isolation (no cross-session leakage), empty-session case, toJson/fromJson round-trip with nullable fields, and append-only semantics with duplicate-id behavior pinned. Critical because a missed `addAttempt` silently breaks session completion and corrupts training analytics. Sprint 2D AC-1. |

---

## Inventory at a glance

- **Total files in Critical Suite:** 14
- **Last reviewed:** 2026-08-06 (Sprint 2E cross-domain consolidation)
- **Sprint 1 baseline:** 10/10 PASS
- **Sprint 2A:** 11/11 PASS
- **Sprint 2B:** 12/12 PASS
- **Sprint 2C:** 12/12 PASS (rationale refresh; file count unchanged)
- **Sprint 2D:** 13/13 PASS (AC-1 added `drill_attempt_repository_test.dart`)
- **Sprint 2E:** 14/14 PASS (AC-1 re-audit; count drift 13 → 14 fixed)

## Non-critical tests (Tier 2 / Tier 3)

These tests run during the **Repository Health gate** (fresh-clone
verification), not during sprint-close. They are valuable but not
business-critical:

- `test/widget/match_history_screen_test.dart` (Tier 2 widget test)
- `test/presentation/**` (Tier 2 widget tests)
- `test/widget_test.dart` (legacy)

New Tier 2 widget tests belong in `test/widget/` or
`test/presentation/`, NOT in this manifest.

Tier 2 widget smokes (NOT in Critical Suite):
- `test/widget/equipment_list_flow_test.dart` (Sprint 2A)
- `test/widget/match_history_screen_test.dart` (Sprint 2A.5)
- `test/widget/match_summary_flow_test.dart` (Sprint 2B)
- `test/widget/coach_recommendation_panel_test.dart` (Sprint 2C)
- `test/widget/drill_session_screen_test.dart` (Sprint 2D)
- `test/widget/create_session_screen_test.dart` (Sprint 2E)
- `test/presentation/**` (knowledge/learning-path widget tests)

## Related

- `docs/engineering-constitution.md` — Tier definitions, gate definitions.
- `scripts/run_critical_suite.sh` — Linux / CI runner.
- `scripts/run_critical_suite.ps1` — Windows local-dev runner.
- `scripts/run_full_gates.sh` — full Engineering Gate (analyze + critical + builds).