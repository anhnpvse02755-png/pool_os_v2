# Match — Vision Gap Analysis

**Date:** 2026-08-02
**Source of truth:** the vision in `ROADMAP.md`. V1 is one historical reference; the goal is the world's best billiards training app.

---

## 1. Vision

A player should be able to open Match Summary and see a complete forensic
reconstruction of the match — every shot mapped, every decision graded,
every missed pocket explained, every rack turned into an actionable drill.

---

## 2. Question

> If Pool OS were the world's best billiards training app, what would Match
> Summary look like, and what capabilities must back it?

---

## 3. Required surface

### 3.1 Identity & book-keeping `[A]`

| Item | Status | Notes |
|------|--------|-------|
| Match ID | ✅ | done |
| Date / Time | ✅ | done |
| Duration | ✅ | done |
| Game type / Race | ✅ | done |
| Venue / Table / Opponent / Winner / Final score | ✅ | done |

### 3.2 Aggregate performance `[A]`

| Item | Status | Notes |
|------|--------|-------|
| Total racks, Win % | ✅ | done |
| Breaks / B&R / Run outs / Golden break | ✅ | done |
| Safety count + success | ✅ | done |
| Fouls / scratches / easy-miss / position-error | ✅ | done |
| Specialty shots (kicks/banks/jumps/combos/caroms) | ✅ | done |

### 3.3 Cue Ball `[A]`

| Item | Status | Notes |
|------|--------|-------|
| Stop / Draw / Follow / Side spin / Position quality | ✅ | done |

### 3.4 Mental `[A]`

| Item | Status | Notes |
|------|--------|-------|
| Confidence / Focus / Pressure / Tilt | ✅ | done |

### 3.5 Physical `[A]`

| Item | Status | Notes |
|------|--------|-------|
| Sleep / Fatigue / Energy / Eye | ✅ | done |

### 3.6 Equipment `[A]`

| Item | Status | Notes |
|------|--------|-------|
| Cue / Shaft / Tip / Tip hardness / Chalk | ✅ RFC-302 | done |

### 3.7 AI Analysis `[A]`

| Item | Status | Notes |
|------|--------|-------|
| Strengths / Weaknesses / Biggest mistakes / Suggested drills / Articles / Learning path | ✅ | done |

### 3.8 Timeline `[A]`

| Item | Status | Notes |
|------|--------|-------|
| Rack-by-rack events | ✅ | done |

### 3.9 Stats aggregation `[A]`

| Item | Status | Notes |
|------|--------|-------|
| Player aggregates (wins/losses/win-rate/avg-duration) | ✅ | done |
| Equipment usage tracking | ⚠️ partial | need: per-equipment win-rate |
| Training recommendations | ⚠️ basic | need: drill-skill drill-suggest graph |
| Progress charts | ⚠️ basic | need: per-skill trend |
| Achievements | ❌ | P3 |
| Skill ratings | ⚠️ schema only | need: actual rolling series |
| AI Coach profile | ⚠️ basic | need: aggregate profile |

---

## 4. New capabilities the world's best billiards app needs

### 4.1 Technical analytics `[C]`

| Item | Why | Tag |
|------|-----|-----|
| Shot map (2D table with every shot plotted) | Diagnostic input for AI review | C |
| Heat map (pot / miss density by zone & pocket) | Show patterns of misses | C |
| Cue ball path (trajectory overlay) | Drill cue ball control | C |
| Pocket accuracy (per-pocket make %) | Identify weak pockets | C |
| Shot difficulty distribution (histogram) | Calibrate improvement | C |
| Decision quality grade per shot (intent vs outcome) | Coach-level feedback | C |
| Tactical review (pattern play grading, option tree) | AI as second opinion | C |
| AI opponent analysis (tendencies of the rival) | Pre-match prep | C |
| Match replay (step through shots) | Self-coaching | C |
| Video timestamp linkage | Camera timestamp ↔ shot | C |
| Voice note per rack/shot | Quick annotation | C |

### 4.2 Environment capture `[C]`

| Item | Why | Tag |
|------|-----|-----|
| Table condition (cloth brand, age, speed) | Equipment fair comparison | C |
| Cloth condition (burn / chalk marks / humidity) | Match variance explanation | C |
| Humidity sensor / manual entry | Speed-of-cloth science | C |
| Lighting entry | Visual fatigue | C |

### 4.3 Reports `[C]`

| Item | Tag |
|------|-----|
| Match report (full) | C — done in spirit |
| Tournament report (multi-match) | C |
| Coach report | C |
| Equipment report | C |
| Health report | C |

---

## 5. Architecture compliance

| Constraint | Status |
|------------|--------|
| Repository abstraction | ✅ `IMatchRepository` |
| Offline-first | ✅ SharedPreferences |
| Supabase-ready | ✅ swap implementation |
| Shot-as-aggregate | ✅ `IShotRepository` |

---

## 6. Definition of Done

`A`:
- [x] Performance / Cue ball / Mental / Physical / Equipment / AI Analysis / Timeline

`B` (content): drills/knowledge — handled in `KNOWLEDGE_VISION_GAP.md`

`C`:
- [ ] Shot map
- [ ] Heat map
- [ ] Cue ball path
- [ ] Pocket accuracy
- [ ] Shot difficulty distribution
- [ ] Decision quality
- [ ] Tactical review
- [ ] AI opponent analysis
- [ ] Match replay
- [ ] Video timestamp
- [ ] Voice note
- [ ] Table condition
- [ ] Cloth condition
- [ ] Humidity
- [ ] Lighting
- [ ] Match KPI board
- [ ] Training KPI board
