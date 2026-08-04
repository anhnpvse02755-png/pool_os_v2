# Statistics — Vision Gap Analysis

**Source of truth:** vision.

---

## 1. Question

> What would the world's best billiards training app's statistics look like?

A Statistics module that doesn't just count — it tells the story of the
player's progression, highlights what to fix next, and predicts where they'll
be.

---

## 2. Required surface

### Aggregate totals `[A]`

| Item | Status |
|------|--------|
| Sessions / minutes / matches / wins | ✅ |
| Win rate | ✅ |

### Trends `[C]`

| Item | Status |
|------|--------|
| Accuracy trend (rolling per shot type) | ❌ |
| Position trend (cue ball control score over time) | ❌ |
| Pressure trend (performance when pressure ≥ 4) | ❌ |
| Streak | ❌ |
| Heatmap (calendar of activity) | ❌ |

### Comparisons `[C]`

| Item | Status |
|------|--------|
| Equipment comparison (cue A vs cue B win rate) | ⚠️ partial |
| Opponent comparison | ❌ |
| Drill efficiency (skill delta per minute) | ❌ |
| Weakness radar (6-axis) | ❌ |

### AI-driven insights `[C]`

| Item | Status |
|------|--------|
| Monthly review (auto-generated narrative) | ❌ |
| AI Progress Score (composite metric) | ❌ |
| Skill forecasting (30/60/90-day projection) | ❌ |

---

## 3. Architecture plan

```
Statistics aggregations derived from IMatchRepository,
IDrillSessionRepository, IKnowledgeProgressRepository.

New services:
- ITrendAggregator           → rolling series per axis
- IComparisonService         → equipment / opponent / drill deltas
- IRadarService              → 6-axis weakness radar
- IAiProgressScoreService    → composite score
- IMonthlyReviewService      → narrative generator
```

---

## 4. Definition of Done

`A`:
- [x] Aggregate totals
- [ ] Streak widget

`C`:
- [ ] Accuracy / Position / Pressure trends
- [ ] Equipment / Opponent / Drill comparisons
- [ ] Weakness radar
- [ ] Heatmap
- [ ] Monthly review
- [ ] AI Progress Score
- [ ] Skill forecasting
