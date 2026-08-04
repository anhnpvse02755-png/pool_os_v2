# Phase B — Content Expansion

**Goal:** Move from 25 drills / tens of articles to the world's best
billiards knowledge & drill corpus.

---

## Done

| Item | File(s) |
|------|---------|
| Drill catalog schema (tier, tags, table size, game context) | `lib/data/models/drill.dart` |
| 300-drill library with offline-first cache | `lib/domain/services/drill_library_service.dart` |
| Daily curated drill (deterministic per day) | same |
| Search / by-tier / by-tag filters | same |
| Knowledge-gap-aware recommender | `lib/domain/services/drill_recommender_v2.dart` + `match_weakness_signals.dart` |
| Knowledge graph (DAG) | `lib/domain/services/knowledge_graph_service.dart` + `lib/data/models/knowledge_node.dart` |
| Graph visualisation (layered depth) | `lib/presentation/screens/knowledge/knowledge_graph_screen.dart` |
| Flashcards + SM-2 style spaced repetition | `lib/data/models/flashcard.dart` + `lib/domain/services/spaced_repetition_service.dart` + `flashcard_screen.dart` |
| Quiz engine with scoring + persistence | `lib/data/models/quiz.dart` + `lib/domain/services/quiz_service.dart` + `quiz_screen.dart` |
| AI summary / explain / ask (local stub, swappable LLM) | `lib/domain/services/ai_explain_service.dart` + `ai_explain_screen.dart` |
| Daily learning + learning streak | `lib/domain/services/learning_streak_service.dart` + `learning_streak_widget.dart` |
| Catalog → 300 drills | seeded in `assets/data/drills_data.json` (300 drills across 20 categories) |

---

## Catalogue growth target

| Now | Target | Status |
|-----|--------|--------|
| ~300 drills | 1000 drills | Q4 roadmap (depends on content team) |

---

## Next

- [ ] Catalogue → 1000 drills
- [ ] Drill leaderboard
- [ ] Drill marketplace
- [ ] User-authored drills (pro / club)
- [ ] Daily learning push notification (requires permissions)
- [ ] Flashcard authoring (admin tool)
- [ ] Quiz authoring (admin tool)
- [ ] Path templates per skill (Safety / Position / Mental / Pattern)
- [ ] Path completion rewards + badges