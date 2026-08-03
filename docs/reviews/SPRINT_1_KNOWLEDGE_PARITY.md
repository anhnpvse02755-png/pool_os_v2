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
- **Inventory stubs** (~500 items across 7 domains):
  - techniques_inventory.json (~150 items)
  - strategies_inventory.json (~100 items)
  - spin_inventory.json (~200 items)
  - rules_inventory.json (~90 items)
  - mistakes_inventory.json
  - equipment_inventory.json
  - drills_inventory.json
- **Metadata**:
  - categories.json, tags.json, aliases.json
  - vietnamese_localization_data.json
  - example_localized_item.json (schema template)

> V1 = **Canonical Source of Truth**. AI will NOT be used to
> expand inventory stubs in Sprint 1. That is Phase 2 work.

---

## Goal (revised)

Build a **Knowledge Library** + **Permanent Migration Pipeline**.

Sprint 1 closes feature parity on **real data** (92 verified
articles) and stands up a tool that can ingest **all** of V1 in
future sprints without manual rework.

---

## Sprint structure (4 phases)

### Phase A — Schema Migration Tool (permanent)

Build a reusable Dart tool:

```
tools/knowledge_migration/
├── migrate_v1_to_v2.dart      ← Main entry
├── schema_mapper.dart         ← V1 article → V2 schema
├── validators.dart            ← 12 validation rules
├── report_generator.dart      ← Markdown + JSON reports
└── README.md
```

Input:

```
V1/
    articles/
        *.json
```

Output:

```
assets/knowledge/
    bridge/
    pattern/
    safety/
    mental/

reports/
    migration_report.md
    migration_summary.json
```

Tool will be **invoked per domain**:

```bash
dart run tools/knowledge_migration/migrate_v1_to_v2.dart bridge/
dart run tools/knowledge_migration/migrate_v1_to_v2.dart pattern/
dart run tools/knowledge_migration/migrate_v1_to_v2.dart safety/
dart run tools/knowledge_migration/migrate_v1_to_v2.dart mental/
```

> Tool design principle: **tool = API**, not script. Future
> sprints call it with a domain, get back a clean import.

### Phase B — Validation (12 rules, mandatory)

Every article must pass:

```
✓ id unique
✓ title (non-empty)
✓ category (valid id)
✓ difficulty (beginner | intermediate | advanced | expert)
✓ body (non-empty)
✓ tags (non-empty, all valid)
✓ relatedDrillCodes (all exist in drill catalog)
✓ relatedKnowledgeIds (all exist or skip with warning)
✓ estimatedReadMinutes (> 0)
✓ search index generated
✓ markdown valid
✓ UTF-8
```

Failed articles are **skipped with reason**:

```
Skipped
Reason:
- missing title
- duplicate id
- invalid category
- broken drill reference
- markdown invalid
- ...
```

### Phase C — Engineering Review Gate

After migration completes, **no merge without a clean report**:

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

If report is dirty (e.g. broken links > 0), the migration **stops**
until fixed. This is the only way to keep quality as the corpus
grows.

### Phase D — Preserve Content (no rewriting)

V1 body content is **verified and canonical**. The migration tool
**must NOT rewrite** body content. Allowed operations:

- Schema mapping (snake_case → camelCase, etc.)
- Metadata addition (id, slug, tags, difficulty)
- Reference resolution (relatedDrillCodes → real IDs)
- Search index generation

Disallowed operations:

- AI rewriting
- Manual copy-editing
- Reformatting body markdown
- Translating

---

## Functional AC (must)

| AC | Description |
|----|-------------|
| **AC-1** | 92 V1 articles imported successfully (Bridge, Pattern, Safety, Mental). |
| **AC-2** | Search by title + content (Vietnamese + English). |
| **AC-3** | Filter by: Category, Tag, Difficulty, Estimated read time, Read status. |
| **AC-4** | Learning Path Integration — `learning_path_screen` reads Knowledge directly. |
| **AC-5** | Related Knowledge on every article (existing field, ensure populated). |
| **AC-6** | Drill Integration — bidirectional Knowledge ↔ Drill links. |
| **AC-7** | Read Progress — each user can mark Unread / Reading / Completed per article. |

## Quality AC (must)

| AC | Description |
|----|-------------|
| **AC-8** | Migration tool reproducible — running it twice produces identical output. |
| **AC-9** | 0 broken drill references. |
| **AC-10** | 0 broken knowledge references (or documented as warnings). |
| **AC-11** | All 92 articles have full metadata (id, slug, title, category, difficulty, tags, related, read time). |
| **AC-12** | Body content preserved byte-for-byte from V1 source. |

## Coverage targets (must)

| Coverage | Target |
|----------|-------:|
| Imported from V1 verified | **92 / 92** |
| Migration report clean | ✅ |
| Tools reusable for future sprints | ✅ |

> Sprint 1 explicitly does **not** chase 100-150 articles.
> Coverage of the 4 V1-verified domains is the target.
> Sprint 2 will extend.

---

## CI Integration (recommended but not blocking Sprint 1)

Long-term: integrate migration + validation into CI. Every PR that
touches `assets/knowledge/` triggers the pipeline:

```
CI
  ↓
Migration dry-run
  ↓
Validation
  ↓
Reference Check
  ↓
Search Index Build
  ↓
Duplicate Detection
  ↓
Report
  ↓
PASS / FAIL
```

This is essential once the corpus reaches 500–900 articles.
Sprint 1 ships the tool; CI integration can be Sprint 1.5.

---

## Out of scope (Sprint 1)

- AI expansion of V1 inventory stubs (Phase 2).
- Knowledge Graph Visualization UI (Sprint 1.5+).
- Equipment inventory (Sprint 2).
- Translation / localization beyond what V1 already has.
- New category schema changes.
- New repository abstraction.

---

## Technical scope

### Touch points

| Path | Change |
|------|--------|
| `tools/knowledge_migration/` | **NEW** — 5 files (permanent tool) |
| `assets/knowledge/{bridge,pattern,safety,mental}/*.json` | **NEW** — 92 article files (or bundled) |
| `assets/knowledge/knowledge.json` | Updated manifest |
| `lib/data/models/knowledge.dart` | Add `readingTimeMinutes`, `readStatus` |
| `lib/data/repositories/knowledge_repository.dart` | Persist Read Progress (cache via existing `ICacheRepository`) |
| `lib/presentation/screens/training/knowledge_screen.dart` | AC-2 + AC-3 |
| `lib/presentation/screens/training/knowledge_detail_screen.dart` | AC-5 + AC-6 + AC-7 |
| `lib/presentation/screens/training/learning_path_screen.dart` | AC-4 |
| `lib/domain/services/knowledge_graph_service.dart` | Extend with `nextReadable()` coverage |
| `test/widget/knowledge_screen_test.dart` | **NEW** (Day 2A.5 pattern) |
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

---

## Risks

| Risk | Mitigation |
|------|------------|
| V1 articles have unknown schema quirks | Tool has 12-rule validation + report = early signal. |
| Related drill codes don't resolve | Drill catalog exists in `assets/data/drills_data.json`; tool resolves against it. |
| Body content gets accidentally rewritten | Tool policy: body pass-through, no transformations except markdown normalize. |
| Sprint scope creeps (graph viz) | Hard rule: graph viz deferred to Sprint 1.5. |

---

## Definition of Done checklist

- [ ] Migration tool implemented (`tools/knowledge_migration/`).
- [ ] 92 V1 articles imported (Bridge/Pattern/Safety/Mental).
- [ ] Migration report shows 0 broken drill references.
- [ ] All 7 functional AC met.
- [ ] All 5 quality AC met.
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