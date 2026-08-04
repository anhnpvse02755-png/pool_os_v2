# Knowledge — Vision Gap Analysis

**Source of truth:** vision (world's best billiards training app). V1 only as a historical reference.

---

## 1. Question

> What would the world's best knowledge base for a billiards training app look
> like?

A learning system that goes beyond reading. It would explain, test, remind,
connect, and adapt.

---

## 2. Required surface

### Reading `[A]`

| Item | Status | Notes |
|------|--------|-------|
| Article catalog | ✅ | exists |
| Categories | ✅ | exists |
| Slug routing | ✅ | exists |
| Difficulty filter | ⚠️ partial | surface in UI |
| Tags | ⚠️ partial | surface in UI |
| Bookmark / favorite | ⚠️ partial | basic save only |
| Read % progress | ❌ | scroll listener |
| Read time | ❌ | timestamp |

### Learning aids `[B]`

| Item | Status | Notes |
|------|--------|-------|
| Flashcards per article (spaced repetition) | ❌ | new module |
| Quiz per knowledge section | ❌ | new module |
| Daily learning (push + 1 article/day) | ❌ | service |
| Learning streak | ❌ | calculator |
| Difficulty progression | ❌ | adaptive |
| Prerequisite navigation (read X before Y) | ❌ | graph |

### AI-powered `[C]`

| Item | Status | Notes |
|------|--------|-------|
| AI summary of an article | ❌ | new |
| AI explain (conversational in-article Q&A) | ❌ | new |
| AI ask (free-form) | ❌ | new |
| Knowledge graph visualization (DAG) | ❌ | new |

### Community `[D]`

| Item | Status |
|------|--------|
| Comments / discussion | ❌ |
| Authored articles (pro / club) | ❌ |
| Knowledge rating | ❌ |

---

## 3. Catalog growth target

| Now | Target |
|-----|--------|
| Tens of articles | 500 articles, indexed, cross-linked, quiz-able |

---

## 4. Architecture plan

```
┌─────────────────────────────────┐
│   Knowledge Service (orchestrator)│
├─────────────────────────────────┤
│ IArticleRepository                │
│ IKnowledgeProgressRepository      │
│ IFlashcardRepository              │
│ IQuizRepository                   │
│ IKnowledgeGraphService            │
│ IAiExplainService                 │
└─────────────────────────────────┘
```

Cross-link table:
```
article_prerequisites:  (article_id → prereq_article_id)
article_drills:         (article_id → drill_code)
article_flashcards:     (article_id → flashcard_id)
article_quizzes:        (article_id → quiz_id)
```

---

## 5. Definition of Done

`A`:
- [x] Article catalog
- [x] Slug routing
- [ ] Read progress
- [ ] Bookmark

`B`:
- [ ] Flashcards
- [ ] Quizzes
- [ ] Daily learning
- [ ] Learning streak
- [ ] Prerequisite graph
- [ ] Catalog → 500

`C`:
- [ ] AI summary
- [ ] AI explain
- [ ] AI ask
- [ ] Knowledge graph visualization

`D`:
- [ ] Community
