# Knowledge Migration Tool

> Sprint 1, Commit 1 — SKELETON ONLY.

## Purpose

A permanent, deterministic migration tool that ingests V1 Knowledge
articles and emits V2 schema JSON for the Pool OS V2 codebase.

## Scope (Sprint 1)

- Bridge domain (30 items)
- Pattern Play domain (28 items)
- Safety domain (23 items)
- Mental domain (21 items)
- Total: **92 articles** imported from V1 verified.

## Layout

```
tools/knowledge_migration/
├── migrate_v1_to_v2.dart      ← CLI entry
├── src/
│   ├── cli_options.dart       ← CLI parsing
│   ├── migration_dto.dart     ← V1/V2 article DTOs + report DTOs
│   ├── migration_pipeline.dart← orchestration (Commit 4)
│   └── io.dart                ← file system abstraction
├── schema_mapper.dart         ← V1 → V2 mapping (Commit 2)
├── validators.dart            ← 12-rule engine (Commit 3)
├── report_generator.dart      ← Markdown + JSON reports
├── hash_utils.dart            ← SHA256 helpers
└── README.md
```

## Usage (planned)

```bash
# Show help
dart run tools/knowledge_migration/migrate_v1_to_v2.dart --help

# Dry-run (validate only, no writes)
dart run tools/knowledge_migration/migrate_v1_to_v2.dart bridge/ --check

# Real migration (writes to assets/knowledge/_staging/)
dart run tools/knowledge_migration/migrate_v1_to_v2.dart bridge/

# Promote staging to live (after clean report)
dart run tools/knowledge_migration/migrate_v1_to_v2.dart bridge/ --promote
```

## Status

| Component | Status |
|-----------|--------|
| CLI entry | ✅ skeleton |
| DTOs | ✅ shape only |
| Schema mapper | ❌ stub (Commit 2) |
| Validators | ❌ registry only (Commit 3) |
| Pipeline | ❌ no-op (Commit 4) |
| Reporter | ✅ minimal Markdown/JSON (Commit 3 deepens) |
| Hash utils | ✅ interface (Commit 4 uses) |
| Tests | ❌ skeleton (this commit) |

## Boundaries

- Tool lives under `tools/`, not `lib/`. Not part of app runtime.
- Tool writes to staging dir by default. Promotion requires explicit
  flag and a clean migration report.
- Tool is **deterministic** (Section 7 of Sprint 1 spec).
- Tool never modifies V1 source files.

## See also

- `docs/reviews/SPRINT_1_KNOWLEDGE_PARITY.md` — full spec
- `docs/reviews/FEATURE_PARITY_SPRINT.md` — sprint overview