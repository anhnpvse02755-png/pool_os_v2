# Training — Content Expansion Plan

**Source of truth:** vision.

---

## 1. Question

> What would the world's best drill library look like?

A library that grows with the player and matches their actual weaknesses.

---

## 2. Catalog growth

| Now | Quarter 1 | Quarter 2 | Quarter 3 | Quarter 4 |
|-----|-----------|-----------|-----------|-----------|
| ~25 | **300** | 500 | 750 | **1000** |

### Growth strategy

1. Seed at 300 in Q1: cover all V1 tiers + new skill axes (cue ball control
   family, pattern play family, speed-of-cloth family, defensive family).
2. Add tier axis: Foundation (1-100 Fargo) / Intermediate (100-400) / Advanced
   (400-600) / Master (600+).
3. Tag every drill with multiple axes:
   - shot type (cut/bank/kick/jump/combo/carom)
   - objective (pot / position / safety / pattern)
   - difficulty 1-5
   - table size (7/8/9-foot)
   - game context (8-ball / 9-ball / 10-ball / straight)

---

## 3. Drill schema (expanded)

```dart
class Drill {
  String id;
  String code;          // canonical URL slug
  String name;
  String description;
  DrillTier tier;       // foundation | intermediate | advanced | master
  int difficulty;       // 1..5
  List<String> tags;    // cut/bank/kick/jump/combo/pattern/safety
  String gameContext;   // 8-ball | 9-ball | 10-ball | straight
  int tableSize;        // 7 | 8 | 9
  int targetScore;      // points to reach
  int timeLimitSec;
  List<DrillVariant> variants;
  List<String> relatedArticleSlugs;
  List<String> relatedDrills;
  Achievements achievements;
}
```

---

## 4. Personalization

Per-session recommendation based on:
- Recent match errors (position errors → position-drill)
- Knowledge progress (haven't finished Safety → recommend safety drills)
- Personal best deltas (drill where PB plateau → recommend next tier)
- Daily curated drill (push notification)

---

## 5. Catalog delivery

`DrillLibraryService`:
- loads current catalog version from remote (offline-first, cache forever)
- expose `getByCode(code)`, `search(query)`, `recommend()`,
  `getDaily()`, `getByTier()`.

---

## 6. Definition of Done

`B`:
- [ ] Catalog 25 → 300
- [ ] Tier axis
- [ ] Tag axis
- [ ] Daily curated drill
- [ ] User-authored drills (pro/club)
- [ ] Drill leaderboard
- [ ] Marketplace
- [ ] Catalog 300 → 1000
