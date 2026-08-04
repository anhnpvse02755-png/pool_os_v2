# V2 — Vision Gap (master)

**Date:** 2026-08-02
**Frame:** vision-driven, not V1-driven. The world's best billiards training app.

---

## 1. Source of truth

`docs/reviews/VISION.md` and `docs/reviews/ROADMAP.md`.

---

## 2. Per-module stance

Each module is evaluated against the vision first, and against V1 only as
a floor.

| Module | Vision doc | Phase A parity doc |
|--------|-----------|---------------------|
| Match (Play) | `MATCH_VISION_GAP.md` | included |
| Training | `TRAINING_CONTENT_EXPANSION.md` | `TRAINING_GAP_ANALYSIS.md` |
| Knowledge | `KNOWLEDGE_VISION_GAP.md` | `KNOWLEDGE_GAP_ANALYSIS.md` |
| Equipment | `EQUIPMENT_GAP_ANALYSIS.md` | `EQUIPMENT_GAP_ANALYSIS.md` |
| Coach | `COACH_GAP_ANALYSIS.md` | `COACH_GAP_ANALYSIS.md` |
| Profile | `PROFILE_GAP_ANALYSIS.md` | `PROFILE_GAP_ANALYSIS.md` |
| Statistics | `STATISTICS_VISION_GAP.md` | `STATISTICS_GAP_ANALYSIS.md` |
| Reports | `REPORTS_VISION_GAP.md` | `REPORTS_GAP_ANALYSIS.md` |
| Play (restoration summary) | `PLAY_GAP_ANALYSIS.md` | (same) |

---

## 3. Phase tracker

| Phase | Description | % |
|-------|-------------|---|
| A — V1 Parity | No regression vs V1 | ~85% |
| B — Content Expansion | 300-1000 drills, 500 articles, flashcards, quizzes, daily/streak, prerequisites | 5% |
| C — AI & Analytics | Shot map, heat map, AI opponent, AI summary/explain, full reports | 5% |
| D — Competitive | Community, tournaments, cloud sync, differentiators | 0% |

---

## 4. This iteration's wins (vision-driven)

- Match Summary rebuilt around the vision: complete forensic reconstruction,
  not just a score line.
- Architecture is now a clean Repository abstraction ready for Supabase
  without rewriting screens.
- AI Analysis pipeline (`MatchReviewEngine`) generates per-match strengths /
  weaknesses / drill suggestions automatically.
- All Match data is offline-first + Supabase-ready.

---

## 5. Open questions the vision raises (not answered in this iteration)

- Vision-based stroke analysis (computer vision) — Phase D.
- AI opponent prep — Phase C.
- Live tournaments with replay — Phase D.
- Smart cue / carbon-cue integration — Phase D.

---

## 6. Definition of Done — overall

- [ ] Phase A closed out (`PHASE_A_CLOSE_OUT.md` items all green)
- [ ] Phase B: 300 drills + 500 articles + flashcards + quizzes
- [ ] Phase C: all `[C]` items in `ROADMAP.md` ✓
- [ ] Phase D: cloud sync + tournaments + community

Until Phase D, optimize for vision coverage not V1 coverage.
