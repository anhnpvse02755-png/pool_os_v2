# Sprint 1 — Final Verification

> **Date:** 2026-08-04
> **Sprint:** 1 (Knowledge Parity)
> **Commits verified:** `6ef3c74` … `22ed422` (10 commits, 5 sprint + 3 recovery + 2 merge)
> **Status:** PASS on all gates

## Repository Completeness Gate (the new gate)

The recovery work in this Sprint ran head-first into a source of truth
problem: `main` was not buildable from a clean clone. The Discovery
arose during the post-merge check on Commit 5. The Recovery Plan 1.5
restored `main` to a buildable state on top of the existing Sprint 1
work, preserving the principle of scope control.

This final verification runs the canonical Repository Completeness Gate
on a fresh clone of `origin/main` at the C6 commit.

| Gate | Result |
|---|---|
| Fresh clone (no working tree, no untracked files) | PASS |
| `flutter pub get` | PASS |
| `flutter analyze` | **0 errors** / 57 warnings / 47 info |
| `flutter test` (Sprint 1 knowledge gates) | **88/88 PASS** |
| `flutter build web --release` | **PASS** (113.6s) |
| `flutter build apk --debug` | **PASS** (93.6s) |

## Knowledge data integrity

| Metric | Value |
|---|---|
| Total articles | 112 |
| Unique IDs | 112 |
| Unique slugs | 112 |
| Duplicate IDs | 0 |
| Duplicate slugs | 0 |
| Sorted by id | yes |
| UTF-8 valid | yes |
| JSON well-formed | yes |
| Missing required fields | 0 |
| SHA-256 | `c1c1906b17fa315ae6726d900585b865a21c970728125ab3c7e7df318dd8545e` |
| File size | 151,948 bytes |

The SHA-256 is identical to the one captured at R1 commit time. No
drift across the C6 commit.

## Sprint 1 deliverables (parity scope)

| Commit | Subject | Status |
|---|---|---|
| `6ef3c74` | C1 — Migration Tool Skeleton | PASS |
| `2be55de` | C2 — Schema Mapper (real V1→V2 mapping) | PASS |
| `230d832` | C3 — 12 Validators + Reports (quality gate) | PASS |
| `edd8e0a` | C4 — Import 102 verified articles | PASS |
| `2858d81` | C5 — Feature Parity + Promotion | PASS |

## Recovery deliverables (post-Sprint 1)

| Commit | Subject | Status |
|---|---|---|
| `74ae5ef` | R1 — Repository Build Recovery (51 files) | PASS |
| `267648e` | R2 — Documentation recovery (42 files) | PASS |
| `22ed422` | R3 — Minimal `.gitignore` cleanup | PASS |

## Sprint 1 feature surface (delivered)

- Knowledge feature parity on the new V2 architecture.
- Search integration with 300ms debounce.
- Difficulty filter (Cơ bản / Trung bình / Nâng cao / Chuyên gia).
- Learning Path integration — "Đọc trước khi tập" chips.
- Drill code bridge (V1 `_LV` → V2 `DrillLibrary`).
- Asset loading via `KnowledgeNotifier._loadData`.
- Knowledge provider boundary enforced (UI does not read JSON).
- 88 widget / integration / migration tests passing.

## Pre-existing failures (still out of scope)

These two failures predate Sprint 1 and remain unchanged:

- `test/coach_profile_aggregator_test.dart` — pre-existing
- `test/drill_session_recovery_test.dart` — pre-existing

Both are tracked in the Sprint 1 backlog and will be addressed in
future parity sprints.

## Acceptance Criteria for Sprint 1 Sign-off

| Criterion | Status |
|---|---|
| Knowledge feature parity complete | ✅ |
| 102 articles migrated and validated | ✅ |
| 12-validator quality gate | ✅ |
| Promotion report + integrity audit | ✅ |
| All Sprint 1 tests pass | ✅ |
| Build web PASS | ✅ |
| Build apk PASS | ✅ |
| Source of Truth restored | ✅ |
| Scope control maintained | ✅ |
| No feature additions in C6 | ✅ |

## Sign-off

Sprint 1 is complete. The Repository Completeness Gate is now a
mandatory pre-RC/Beta check — see `REPOSITORY_HEALTH_CHECKLIST.md`.
