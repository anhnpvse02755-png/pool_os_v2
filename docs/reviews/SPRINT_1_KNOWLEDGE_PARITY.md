# Sprint 1 — Knowledge Parity

**Created:** 2026-08-03 (after Product Kickoff)
**Baseline tag:** `v2.0.0-rc1-eng`
**Status:** Pending — awaiting Engineering Kickoff
**Estimated effort:** ~5 working days
**Owner:** Engineering + Content + Product

---

## Why this Sprint

`KNOWN_LIMITATIONS.md` flags Knowledge content as the largest
product-value gap (10/500 articles). Pool OS V2 positions itself as
a **learning platform** — without substantive Knowledge, the app
feels empty.

This Sprint closes the Knowledge gap so users can:

1. **Find** relevant articles (search + filter).
2. **Learn** the content (with full metadata).
3. **Connect** to drills (Knowledge → Drill bidirectional links).
4. **Track** progress (Read state).
5. **Follow** a learning path (Learning Path → Knowledge → Drill).

---

## V1 source (located, canonical)

```
C:\Users\anhnpv\OneDrive - Thanh Cong Group\Desktop\code\Pool OS\Knowledge\
```

Contains:
- **92 verified articles** (canonical, ready to import):
  - Bridge domain — 30 items
  - Pattern Play domain — 28 items
  - Safety domain — 23 items
  - Mental domain — 21 items
- **Inventory stubs** (~500 items across 7 domains).
- **Metadata**: categories.json, tags.json, aliases.json, vietnamese_localization_data.json, example_localized_item.json (schema template).

> V1 = **Canonical Source of Truth**. AI will NOT be used to
> expand inventory stubs in Sprint 1. That is Phase 2 work.

---

## Goal (revised)

Build a **Knowledge Library** + **Permanent Migration Pipeline**.

Sprint 1 closes feature parity on **real data** (92 verified
articles) and stands up a tool that can ingest **all** of V1 in
future sprints without manual rework.

---

## 1. Input Contract

### 1.1 V1 article schema (current)

See `example_localized_item.json`. Full field list:

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| `id` | string | ✓ | Article ID (e.g. `technique.stroke.fundamentals`) |
| `type` | string | ✓ | One of: `technique`, `strategy`, `safety`, `mental`, `pattern`, `bridge`, `aim`, `spin`, `rule`, `mistake`, `equipment` |
| `difficulty` | string | ✓ | One of: `beginner`, `intermediate`, `advanced`, `expert` |
| `category` | string | ✓ | Category slug (e.g. `stroke`, `positioning`, `safety`) |
| `title` | string | ✓ | English title |
| `titleVi` | string | ✓ | Vietnamese title |
| `summary` | string | ✓ | English summary |
| `summaryVi` | string | ✓ | Vietnamese summary |
| `localization` | object | – | Vietnamese localization details |
| `searchAliases` | object | – | Aliases + common misspellings |
| `purpose` | string | ✓ | English purpose statement |
| `purposeVi` | string | ✓ | Vietnamese purpose statement |
| `setup` | string[] | ✓ | Setup steps (English) |
| `execution` | string[] | ✓ | Execution steps (English) |
| `successCriteria` | string[] | ✓ | Success indicators |
| `failureCriteria` | string[] | ✓ | Failure indicators |
| `commonMistakes` | object[] | – | Mistake details |
| `media` | object | – | Image / video / diagram filenames |
| `relatedKnowledge` | object[] | – | `{id, weight}` |
| `prerequisites` | string[] | – | Required article IDs |
| `nextRecommended` | object | – | Next article to read |
| `estLearningMinutes` | number | ✓ | Estimated reading time |
| `estimatedSkillGain` | object | – | Skill impact |
| `tags` | string[] | ✓ | Tag slugs |
| `keywords` | string[] | ✓ | Search keywords |
| `status` | string | ✓ | One of: `draft`, `verified`, `needs_review` |
| `sources` | string[] | – | Reference sources |
| `version` | string | – | Schema version |
| `updatedAt` | string (ISO) | ✓ | Last update |

### 1.2 V2 article schema (target)

Stored in `assets/knowledge/knowledge.json` (existing). Each entry
must have at minimum:

| V2 field | V1 source | Required |
|----------|-----------|:--------:|
| `id` | `id` | ✓ |
| `slug` | derived from `id` | ✓ |
| `title` | `title` | ✓ |
| `titleVi` | `titleVi` | ✓ |
| `content` | synthesized from `purpose` + `setup` + `execution` + `successCriteria` + `failureCriteria` (markdown) | ✓ |
| `contentVi` | synthesized from `purposeVi` + `setup` (translated if needed) + `execution` | ✓ |
| `categoryId` | derived from `category` (via category mapper) | ✓ |
| `tagIds` | `tags` (via tag mapper) | ✓ |
| `difficulty` | `difficulty` | ✓ |
| `aliases` | `searchAliases.vi` + `keywords` | ✓ |
| `keywords` | `keywords` | ✓ |
| `relatedKnowledgeIds` | `relatedKnowledge[].id` | ✓ |
| `relatedDrillCodes` | resolved from inventory cross-reference (NOT in V1) | – |
| `readingTimeMinutes` | `estLearningMinutes` | ✓ |
| `media` | `media` | – |
| `sources` | `sources` | – |

### 1.3 Field mapping table (V1 → V2)

| V1 field | V2 field | Mapper |
|----------|----------|--------|
| `id` | `id` | identity |
| `id` | `slug` | `id.replaceAll('.', '-').toLowerCase()` |
| `title` | `title` | identity |
| `titleVi` | `titleVi` | identity |
| `purpose` + `setup` + `execution` + `successCriteria` + `failureCriteria` + `commonMistakes` | `content` | Markdown synthesis (see 2.3) |
| `purposeVi` + ... (Vietnamese counterparts) | `contentVi` | Markdown synthesis |
| `category` | `categoryId` | `category_mapper.dart` (see 2.2) |
| `tags` | `tagIds` | `tag_mapper.dart` (see 2.4) |
| `difficulty` | `difficulty` | identity |
| `searchAliases.vi` ∪ `keywords` | `aliases` | union, lowercase, dedupe |
| `keywords` | `keywords` | identity |
| `relatedKnowledge[].id` | `relatedKnowledgeIds` | extract `.id` |
| (resolved separately) | `relatedDrillCodes` | `drill_mapper.dart` (see 2.5) |
| `estLearningMinutes` | `readingTimeMinutes` | identity |
| `media` | `media` | identity |
| `sources` | `sources` | identity |

---

## 2. Migration Rules

### 2.1 ID mapping

V1 IDs are dotted (`technique.stroke.fundamentals`). V2 IDs can be
the same dotted form OR dotless (`kn_stroke_fundamentals`). Decision:
**preserve V1 ID** (dotted) — backward compatible, easier diff.

Slug derivation: `id.replaceAll('.', '-').toLowerCase()`
Example: `technique.stroke.fundamentals` → `technique-stroke-fundamentals`.

### 2.2 Category mapping

V1 `category` is a free-form string. V2 categories live in
`assets/knowledge/categories.json` with strict IDs.

| V1 category | V2 categoryId | Notes |
|-------------|---------------|-------|
| `stroke` | `cat_fundamentals` | |
| `aiming`, `aim` | `cat_aiming` | |
| `cueball`, `cue ball control` | `cat_positioning` | |
| `strategy` | `cat_strategy` | |
| `safety`, `safety_play` | `cat_strategy` | Safety is strategy |
| `bridge` | `cat_fundamentals` | Bridge is fundamental |
| `pattern`, `pattern_play` | `cat_strategy` | Pattern is strategy |
| `mental` | `cat_psychology` | |
| `equipment` | `cat_equipment` | |
| `rules` | `cat_rules` | |
| `spin` | `cat_positioning` | Spin is positioning |
| `mistake` | (no mapping → skip) | Mistakes not standalone |

If a V1 category has no V2 mapping, the article is **skipped with
warning** (not silently dropped).

### 2.3 Content synthesis (markdown)

V1 has structured fields. V2 `content` is markdown. Synthesizer
template:

```markdown
# {title}

{summary}

## Purpose

{purpose}

## Setup

{setup joined as numbered list}

## Execution

{execution joined as numbered list}

## Success Criteria

{successCriteria joined as checklist}

## Common Mistakes

{commonMistakes as bullets with correction}

## Sources

{sources joined}
```

The synthesizer must NOT rephrase. Each field is **inserted
verbatim** into the template.

### 2.4 Tag mapping

V1 `tags` are free-form slugs. V2 tags live in
`assets/knowledge/tags.json`. Mapper:

| V1 tag | V2 tagId |
|--------|----------|
| `fundamentals` | `tag_basic` |
| `stroke` | `tag_technique` |
| `beginner` | `tag_basic` |
| `intermediate` | `tag_intermediate` |
| `advanced` | `tag_advanced` |
| `expert` | `tag_expert` |
| `aiming` | `tag_aiming` |
| `position`, `positioning`, `cueball` | `tag_positioning` |
| `strategy` | `tag_strategy` |
| `safety`, `defense` | `tag_defense` |
| `power` | `tag_speed` |
| `consistency` | `tag_technique` |
| `precision` | `tag_accuracy` |

Unmapped tags → warning, article still imported, unmapped tag
recorded in migration report.

### 2.5 Related drill mapping

V1 has **no `relatedDrillCodes`** field. Sprint 1 mapper:

- For each V1 article, look up drill inventory
  (`assets/data/drills_data.json`).
- Match by tag overlap: ≥ 2 shared tags → suggest drill.
- Suggestions appear in migration report as `suggestedDrillCodes[]`
  per article — **not auto-injected** into article JSON.
- Sprint 2 will do the full bidirectional mapping.

### 2.6 Related knowledge mapping

`relatedKnowledge[].id` maps directly to `relatedKnowledgeIds[]`
(extract `.id` from each object). Broken refs (referenced ID not in
imported set) → warning, not error.

### 2.7 Reading time

`estLearningMinutes` → `readingTimeMinutes` identity mapping. If
absent in V1: default to 5 minutes (one-screen read).

### 2.8 Search index generation

Tool generates `assets/knowledge/search_index.json` with one entry
per article:

```json
{
  "id": "...",
  "slug": "...",
  "title": "...",
  "titleVi": "...",
  "keywords": [...],
  "tags": [...],
  "category": "..."
}
```

Index is consumed by `knowledge_screen.dart` for fast filter/search.

---

## 3. Validation Rules (12)

Each rule must explicitly define PASS, FAIL, and example.

| # | Rule | PASS | FAIL | Example |
|---|------|------|------|---------|
| 1 | **id unique** | Article id appears ≤ 1 time in corpus | Duplicate id | `id: "bridge.open_bridge"` appears twice → FAIL |
| 2 | **title non-empty** | `title.length >= 3` and not whitespace | Empty or `<3` chars | `title: ""` → FAIL |
| 3 | **category valid** | `categoryId` exists in V2 categories.json | Unknown category | `categoryId: "cat_foo"` → FAIL |
| 4 | **difficulty valid** | One of `beginner`, `intermediate`, `advanced`, `expert` | Other value | `difficulty: "novice"` → FAIL |
| 5 | **body non-empty** | `content.length >= 100` (real content) | `<100` chars | `content: ""` or `"# hi"` → FAIL |
| 6 | **tags non-empty** | `tagIds.length >= 1`, all valid | Empty or invalid tag | `tagIds: []` → FAIL |
| 7 | **relatedDrillCodes valid** (when present) | All codes exist in `assets/data/drills_data.json` | Unknown drill code | `relatedDrillCodes: ["DRILL_X"]` where DRILL_X doesn't exist → FAIL |
| 8 | **relatedKnowledgeIds valid** (when present) | All IDs exist in imported corpus (or referenced) | Unknown knowledge id | `relatedKnowledgeIds: ["kn_xxx"]` where kn_xxx missing → WARNING (not fail) |
| 9 | **readingTime > 0** | `readingTimeMinutes > 0` | 0 or negative | `readingTimeMinutes: 0` → FAIL |
| 10 | **search index generated** | Entry exists in `search_index.json` | Missing | Article imported but not in index → FAIL |
| 11 | **markdown valid** | `content` parses as valid markdown (no broken syntax) | Unclosed code fences, malformed headings | `content: "## Title\n#broken"` → FAIL |
| 12 | **UTF-8** | File byte-decodes as UTF-8, no replacement chars | Replacement char `?` or mojibake | `title: "Cú bóng ???"` → FAIL |

### Validator output

```json
{
  "articleId": "bridge.open_bridge",
  "passed": true,
  "warnings": ["relatedKnowledgeIds: kn_xxx not found"],
  "errors": []
}
```

Article fails if `errors.length > 0`. Warnings do not block import.

---

## 4. Acceptance Criteria (KPIs)

### Functional parity

- ✅ 92 / 92 V1 articles imported.
- ✅ Search by title + content (Vietnamese + English) returns matches across corpus.
- ✅ Filter by Category (8), Tag (20), Difficulty (4), Read time, Read status all functional.
- ✅ Learning Path reads Knowledge directly.
- ✅ Related Knowledge visible on every article.
- ✅ Drill integration UI scaffolded (data-link later in Sprint 2).
- ✅ Read Progress persists per user.

### Data quality KPIs

- ✅ **92 / 92** articles imported successfully.
- ✅ **0** duplicate IDs.
- ✅ **0** broken drill references.
- ✅ **0** broken knowledge references (warnings acceptable).
- ✅ **100%** articles searchable (index contains all).
- ✅ **100%** category filter works (each V2 category has ≥ 1 article after import).
- ✅ **100%** read progress works (mark + persist).
- ✅ **0** data mutation (body content preserved byte-for-byte, verified via SHA256 hash comparison).

### Tool KPIs

- ✅ Tool is **reproducible**: running twice on same V1 input produces identical output (byte-for-byte).
- ✅ Tool is **reusable**: `migrate_v1_to_v2 <domain>` works for any of {bridge, pattern, safety, mental, technique, ...}.
- ✅ Tool generates **clean report**: `migration_report.md` + `migration_summary.json`.
- ✅ Tool supports `--check` flag (dry-run, no writes) for CI.

---

## 5. Rollback Plan

Migration is **non-destructive by design**:

1. Tool writes to staging directory: `assets/knowledge/_staging/`
2. Validation runs against staging.
3. Only after `errors.length == 0`, staging is atomically moved to
   `assets/knowledge/<domain>/`.
4. If `errors.length > 0` at any point:
   - Staging is preserved (NOT deleted).
   - Tool exits non-zero with report pointing to staging.
   - Manual investigation, fix, re-run.
5. If merge to `main` fails post-deploy:
   - Revert the merge commit (1 commit rollback).
   - `assets/knowledge/` returns to pre-Sprint state.
   - No data in `knowledge.json` is lost (V2 already has 10 seed articles preserved).

**Staging is the rollback mechanism.** Never import directly to
live `assets/knowledge/`.

---

## 6. Commit Plan

| # | Commit | Description | Verification |
|---|--------|-------------|--------------|
| 1 | `feat(parity/knowledge): migration tool skeleton` | Tool entry, directory layout, README | `dart run --help` exits 0 |
| 2 | `feat(parity/knowledge): schema mapper` | V1→V2 field mapping (id, slug, title, content synthesis) | Unit tests for mapper; 92 dry-runs |
| 3 | `feat(parity/knowledge): 12-rule validator + reports` | All validation rules + Markdown + JSON report | Unit tests; 92 dry-runs |
| 4 | `feat(parity/knowledge): import 92 V1 verified articles` | Bridge/Pattern/Safety/Mental via tool, staging→live | Migration report clean, 0 broken refs |
| 5 | `feat(parity/knowledge): feature parity + widget tests` | Search/filter/related/learning path/read progress + 2 widget tests | `flutter analyze` 0 errors, `flutter test` ≥ 9/9 + 2 widget tests |
| 6 | `docs(sprint1): verification report` | `SPRINT_1_VERIFICATION.md` summarizing gates | Manual review |

Each commit has:

- Acceptance criteria (above)
- Verification gate (`flutter analyze` 0 errors, `flutter test` 9/9+, `dart run migrate_v1_to_v2 --check` clean)
- Rollback path (`git revert <commit>` returns to previous state)

---

## 7. Idempotency & Deterministic Migration

The migration tool MUST produce **identical output** across runs
when input is unchanged. This is essential because Sprint 2, 3, 4
will reuse the tool to import hundreds more articles. Without
deterministic output:

- Git diffs become noisy (false changes).
- PR review breaks down (cannot tell real changes from tool noise).
- Reproducibility claims are false.

### Why this section

Migration pipelines that produce different output each run are a
common source of regressions. The cost of debugging a "did the
content actually change, or did the tool re-emit it differently?"
question is enormous. Better to lock down determinism at Sprint 1.

### Acceptance criteria

| KPI | Description |
|-----|-------------|
| **IDM-1** | Running migration twice on the same V1 input produces **byte-identical output**. |
| **IDM-2** | Output file order is deterministic (no OS/filesystem dependency). |
| **IDM-3** | `migration_summary.json` is identical across runs if input is unchanged. |
| **IDM-4** | SHA256 hash of the entire output directory is unchanged across runs. |

### Verification command

```bash
# Run 1
dart run migrate_v1_to_v2.dart bridge/ --output=out1/
find out1/ -type f | sort | xargs sha256sum > hash1.txt

# Run 2
dart run migrate_v1_to_v2.dart bridge/ --output=out2/
find out2/ -type f | sort | xargs sha256sum > hash2.txt

# Compare
diff hash1.txt hash2.txt
# Empty diff = PASS
# Non-empty diff = FAIL
```

### Determinism guarantees (what the tool MUST do)

| Concern | Guarantee |
|---------|-----------|
| **File order** | Output files are sorted by article id before write. |
| **Map iteration** | All `Map<String, ...>` accesses use ordered iteration (`SplayTreeMap` or sorted keys). |
| **Date / time** | No `DateTime.now()` in output. If a timestamp is needed (e.g. `updatedAt`), it comes from V1 input. |
| **Set iteration** | All `Set` conversions to list sort first. |
| **Random / UUID** | No `Random.next*()` or generated UUIDs in output. All ids come from V1. |
| **JSON formatting** | Use a deterministic JSON encoder: `jsonEncode` (Dart's stdlib, alphabetical key order). |
| **Whitespace** | No trailing newlines or trailing whitespace inside JSON values. |
| **Line endings** | LF (`\n`) only. No CRLF. |
| **File encoding** | UTF-8 without BOM. |

### Determinism guarantees (what the tool MUST NOT do)

- Read environment variables (timestamps, paths, user names) into
  output.
- Include absolute paths in output.
- Include build metadata (version, branch, commit hash) in output.
- Use the current locale for sorting (always use `en_US.UTF-8`
  collation or codepoint order).

### CI integration (recommended, Sprint 1.5+)

Once the tool is in CI, add a determinism check:

```yaml
- name: Migration determinism check
  run: |
    dart run migrate_v1_to_v2.dart bridge/ --output=ci_out/
    sha256sum ci_out/ > ci_hash.txt
    git show HEAD:tools/knowledge_migration/lockfile.sha256 > lockfile.txt
    diff ci_hash.txt lockfile.txt
```

Lockfile `lockfile.sha256` is updated only when content changes
intentionally. CI fails if the tool re-emits differently.

### Testing

Add a unit test that exercises determinism:

```dart
test('migration is deterministic', () async {
  final v1Dir = fixture('bridge_v1/');
  final out1 = await runMigration(v1Dir);
  final out2 = await runMigration(v1Dir);
  expect(hashDir(out1), equals(hashDir(out2)));
});
```

This test runs as part of `flutter test` and fails immediately if
the tool regresses.

### Failure mode

If migration is non-deterministic:

```
FAIL

Reason:
Non-deterministic output detected

Run #1 SHA256: abc123...
Run #2 SHA256: def456...

Investigate:
- Map iteration order
- Date/time injection
- File write order
- Locale-dependent sorting
```

No merge until determinism is restored.

---

## 8. Sprint structure (4 phases)

### Phase A — Schema Migration Tool (permanent)

Build a reusable Dart tool:

```
tools/knowledge_migration/
├── migrate_v1_to_v2.dart      ← Main entry
├── schema_mapper.dart         ← V1 article → V2 schema
├── category_mapper.dart       ← V1 category → V2 categoryId
├── tag_mapper.dart            ← V1 tag → V2 tagId
├── validators.dart            ← 12 validation rules
├── report_generator.dart      ← Markdown + JSON reports
└── README.md
```

Tool invocations:

```bash
dart run tools/knowledge_migration/migrate_v1_to_v2.dart bridge/
dart run tools/knowledge_migration/migrate_v1_to_v2.dart pattern/
dart run tools/knowledge_migration/migrate_v1_to_v2.dart safety/
dart run tools/knowledge_migration/migrate_v1_to_v2.dart mental/
dart run tools/knowledge_migration/migrate_v1_to_v2.dart bridge/ --check
```

### Phase B — Validation (12 rules, mandatory)

See section 3. Every article must pass before import.

### Phase C — Engineering Review Gate

Migration report must show:

```
Imported:          92
Passed:            92
Failed:             0
Warnings:           3 (acceptable)
Broken drill links: 0
Broken knowledge links: 1
Duplicate tags:     5
Missing read time:  0
```

If broken drill links > 0 → STOP. Fix mapper, re-run.

### Phase D — Preserve Content (no rewriting)

V1 body content is verified. Tool MUST NOT rewrite. Allowed:

- Schema mapping
- Metadata addition
- Reference resolution
- Search index generation

Disallowed: AI rewriting, manual copy-editing, body reformatting.

---

## 9. Out of Scope (Sprint 1)

- AI expansion of V1 inventory stubs (Phase 2 = Sprint 2).
- Knowledge Graph Visualization UI (Sprint 1.5+).
- Equipment inventory (Sprint 2).
- Bidirectional drill ↔ knowledge mapping (Sprint 2).
- Translation beyond what V1 already has.
- New category schema changes.
- New repository abstraction.

---

## 10. Technical scope

### Touch points

| Path | Change |
|------|--------|
| `tools/knowledge_migration/` | **NEW** — 7 files (permanent tool) |
| `assets/knowledge/{bridge,pattern,safety,mental}/*.json` | **NEW** — 92 article files (or bundled) |
| `assets/knowledge/knowledge.json` | Updated manifest |
| `assets/knowledge/search_index.json` | **NEW** |
| `lib/data/models/knowledge.dart` | Add `readingTimeMinutes`, `readStatus`, `aliases`, `keywords`, `media`, `sources` |
| `lib/data/repositories/knowledge_repository.dart` | Persist Read Progress (cache via existing `ICacheRepository`) |
| `lib/presentation/screens/training/knowledge_screen.dart` | AC-2 + AC-3 |
| `lib/presentation/screens/training/knowledge_detail_screen.dart` | AC-5 + AC-6 + AC-7 |
| `lib/presentation/screens/training/learning_path_screen.dart` | AC-4 |
| `lib/domain/services/knowledge_graph_service.dart` | Extend with `nextReadable()` coverage |
| `test/widget/knowledge_screen_test.dart` | **NEW** |
| `test/widget/knowledge_detail_screen_test.dart` | **NEW** |

### Verification gate

| Gate | Target |
|------|--------|
| `flutter analyze --no-pub` | **0 errors** |
| `flutter test --no-pub` | **≥ 9 / 9** + ≥ 2 new widget tests |
| `flutter build web --no-pub` | PASS |
| `flutter build apk --debug --no-pub` | PASS |
| `dart run tools/knowledge_migration/migrate_v1_to_v2.dart --check` | 92 imported, 0 broken drill refs |
| Migration report | Clean (warnings acceptable) |
| SHA256 byte-equality | V1 body byte-identical to V2 body |

---

## 11. Definition of Done checklist

- [ ] Migration tool implemented (`tools/knowledge_migration/`).
- [ ] 92 V1 articles imported (Bridge/Pattern/Safety/Mental).
- [ ] Migration report shows 0 broken drill references.
- [ ] All 7 functional AC met.
- [ ] All 5 quality AC met.
- [ ] SHA256 byte-equality verified.
- [ ] 2 new widget tests added.
- [ ] Verification gates pass.
- [ ] `FEATURE_PARITY_SPRINT.md` updated with Sprint 1 status.
- [ ] Tag `v2.0.0-parity-knowledge` cut from `main` after merge.

---

## Phase 2 preview (Sprint 2 = Knowledge Expansion)

After Sprint 1 ships:

```
Inventory stubs (~500 items)
        │
        ▼
Coverage Analysis (which categories are thin?)
        │
        ▼
AI Drafts (gap filler)
        │
        ▼
Engineering Validation
        │
        ▼
Product Review
        │
        ▼
Merge to knowledge/
```

Target Sprint 2: **180–220 articles** total.

---

## See also

- `FEATURE_PARITY_SPRINT.md` — Sprint overview
- `KNOWN_LIMITATIONS.md` — Knowledge gap context
- `RELEASE_READINESS_CHECKLIST.md` — quality gates reference