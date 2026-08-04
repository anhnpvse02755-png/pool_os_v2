# Knowledge Promotion Report — Commit 5

**Date:** 2026-08-04
**Branch:** `feature/parity/knowledge`
**Source:** `assets/knowledge/_staging/{bridge,pattern,safety,mental}/`
**Target:** `assets/knowledge/knowledge.json`

## Article Counts

| Source | Path | Count |
|---|---|---|
| Live | `assets/knowledge/knowledge.json` (prior) | 10 |
| Bridge | `assets/knowledge/_staging/bridge/*.json` | 30 |
| Pattern | `assets/knowledge/_staging/pattern/*.json` | 28 |
| Safety | `assets/knowledge/_staging/safety/*.json` | 23 |
| Mental | `assets/knowledge/_staging/mental/*.json` | 21 |
| **TOTAL** | `assets/knowledge/knowledge.json` | **112** |

> Note: count is 112, not 110 as originally planned in the plan file. The pipeline emitted 102 staging articles (per `pipeline_test.dart` assertion `totalImported = 102`), and these plus the 10 live articles yields 112.

## Validation Status (from C4)

All 102 staging articles passed all 12 migration validators. Per-domain `migration_report.json`:

| Domain | Imported | Failed | Warnings | is_clean |
|---|---|---|---|---|
| bridge | 30 | 0 | 0 | true |
| pattern | 28 | 0 | 0 | true |
| safety | 23 | 0 | 0 | true |
| mental | 21 | 0 | 0 | true |
| **Total** | **102** | **0** | **0** | **true** |

## Drill Code Bridge Coverage

- **Staging articles (102):** All have empty `relatedDrillCodes` in source — no bridging required.
- **Live articles (10):** Originally used V1 codes (`STOP_LV1`, `DRAW_LV1`, …). During consolidation, all `relatedDrillCodes` were cleared and replaced with `[]`. At navigation time, `lib/knowledge/drill_code_bridge.dart` resolves them on the fly.

| V1 base | V2 code |
|---|---|
| STOP | STOP_BALL |
| DRAW | DRAW_SHOT |
| FOLLOW | FOLLOW_SHOT |
| STRAIGHT | STRAIGHT_POT |
| POSITION | POSITION_BASIC |
| SAFETY | SAFETY_BASIC |
| BASIC | STRAIGHT_POT |

## Schema Notes

The consolidated JSON includes extra fields carried over from staging (`media`, `readingTimeMinutes`, `sources`) which `KnowledgeItem.fromJson` ignores gracefully. Required fields are present in every entry: `id`, `slug`, `title`, `content`, `categoryId`, `difficulty`, `tagIds`, `aliases`, `keywords`, `relatedKnowledgeIds`, `relatedDrillCodes`. All 112 entries have `imageUrl: null`.

## Metadata Files Excluded from Promotion

From each `_staging/{domain}/`:

- `deterministic.lock`
- `import_summary.json`
- `migration_report.json`
- `migration_report.md`
- `search_index.json`
- `sha256_manifest.json`

From `_staging/`:

- `assets/knowledge/_staging/{bridge,pattern,safety,mental}/search_index.json` (top-level)
- `assets/knowledge/_staging/deterministic.lock`
- `assets/knowledge/_staging/import_summary.json`
- `assets/knowledge/_staging/sha256_manifest.json`

## Difficulty Distribution (112 total)

| Difficulty | Count |
|---|---|
| beginner | 32 |
| intermediate | 42 |
| advanced | 27 |
| expert | 11 |

## Data Integrity Audit

| Check | Result |
|---|---|
| Total articles | 112 |
| Unique IDs | 112 |
| Duplicate IDs | 0 |
| Unique slugs | 112 |
| Duplicate slugs | 0 |
| Sorted by id | yes |
| UTF-8 valid | yes |
| JSON well-formed | yes |
| Missing required fields | 0 |
| SHA-256 | `c1c1906b17fa315ae6726d900585b865a21c970728125ab3c7e7df318dd8545e` |
| File size | 151,948 bytes |

## Final Summary

```
Imported:                102
Existing:                 10
Final:                   112
Validation failures:       0
Duplicate IDs:             0
Duplicate slugs:           0
Deterministic:           PASS
SHA verification:        PASS
```

## Rollback

If a regression is found post-commit, restore the prior 10-article set:

```bash
git checkout HEAD~1 -- assets/knowledge/knowledge.json
```

The staging files in `_staging/` remain untouched and re-runnable.
