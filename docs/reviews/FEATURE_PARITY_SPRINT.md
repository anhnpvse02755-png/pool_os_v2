# Feature Parity Sprint (V1 → V2)

**Created:** 2026-08-03 (after tag `v2.0.0-rc1-eng`)
**Status:** Pending — gated by Engineer RC1 sign-off
**Goal:** Close 4 product-value gaps before Beta/Internal Preview.

---

## Why this sprint exists

The Stabilization Sprint closed every **stability gap** in the
codebase. The codebase is now ready for engineering reference
(tag `v2.0.0-rc1-eng`).

The remaining gaps are **product-value gaps** — features that
internal users will see immediately when they open the app.
These gaps are why the Beta release is gated.

This sprint closes those gaps before any internal user sees the app.

---

## Sprint scope (4 modules)

### 1. Knowledge Library parity

| Metric | Current | Target |
|--------|--------:|-------:|
| Article count | 10 | **~V1 level** (target: substantive catalog, not necessarily 500) |
| Categories | 8 | sufficient if ranking matches V1 |
| Tags | 20 | sufficient if ranking matches V1 |
| Bilingual | en + vi | required |
| Quality | shallow | technical depth matching V1 |

**Owner:** Content team + Engineering
**Acceptance:** QA review of 10 sample articles affirms depth matches V1.

### 2. Equipment Module parity

| Metric | Current | Target |
|--------|--------:|-------:|
| Equipment catalog | names only | full metadata (cue specs, table specs, etc.) |
| Statistics | n/a | V1-equivalent analytics per equipment |
| Match linkage | light | full snapshot support |

**Owner:** Content + Engineering
**Acceptance:** Equipment screen renders full catalog with stats matching V1.

### 3. Match Summary parity

| Metric | Current | Target |
|--------|--------:|-------:|
| Result | win/loss | full V1 fields |
| Statistics | light | full V1 (break-and-run, errors, longest run) |
| Strengths / weaknesses | n/a | full V1 recommendations |
| Trends | none | V1-equivalent trend analysis |

**Owner:** Engineering + Product
**Acceptance:** Match summary screen renders all V1 fields with correct data.

### 4. AI Coach (rule-based first)

| Metric | Current | Target |
|--------|--------:|-------:|
| Backend | stub | rule-based logic (post-match recommendations) |
| Insights | template | derived from match data (not random) |
| Coverage | limited | covers 4+ match scenarios |

**Owner:** Engineering
**Acceptance:** AI Coach returns non-template insights for 4 scenarios.

> Real LLM integration is **out of scope** for this sprint (cost
> analysis, API contract, prompt engineering). It is a Phase D /
> AI Sprint deliverable.

---

## Verification gates (per module)

Each module must pass:

- `flutter analyze` = 0 errors.
- `flutter test` ≥ 9 / 9 (regression-free).
- Widget tests for the affected screens (where UI changed).
- `flutter build web` PASS.
- `flutter build apk --debug` PASS.

---

## Out of scope (deferred to Phase D / AI Sprint)

- Tournament provider (STAB-029).
- Cloud sync (Phase D).
- Real LLM behind AI Coach.
- Performance KPIs (smoke only — never measured).

---

## Definition of Done for the Parity Sprint

When all 4 modules are closed AND verification gates pass:

1. Tag `v2.0.0-beta1` from `main`.
2. Distribute to internal users (~100 max).
3. Collect feedback (≥ 2 weeks).
4. Address critical feedback.
5. Tag `v2.0.0` (public release).

---

## See also

- `KNOWN_LIMITATIONS.md` — 10-item deferral list.
- `RELEASE_VERIFICATION_REPORT.md` — Day 2C sign-off.
- `RELEASE_READINESS_CHECKLIST.md` — Engineering RC1 matrix.
- `FINAL_STABILIZATION_SCORECARD.md` — sprint snapshot.