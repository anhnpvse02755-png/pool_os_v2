# Pool OS V2 — Roadmap

**Vision:** Build the world's best billiards training app.

**Source of truth:** the vision. V1 is one historical reference, never the goal.
Every feature below is included because the world's best billiards app needs it,
not because V1 had it.

**Phase markers:**
- `[A]` — V1 parity (no regression)
- `[B]` — Content expansion
- `[C]` — AI & Analytics
- `[D]` — Competitive features (community / tournament / cloud sync / differentiators)

---

## Phase A — V1 Parity (close out)

Goal: remove every regression from V1. ~85% done.

| Backlog item | Tag | Effort |
|--------------|-----|--------|
| Drill session recovery (mid-session pause / resume) | A | 2d |
| DrillRecommendationService (knowledge-driven drill graph) | A | 3d |
| Personal best tracking per drill | A | 1d |
| Skill-rating delta per session | A | 1d |
| Player State screen (Profile) | A | 1d |
| Knowledge progress section (Profile) | A | 1d |
| Weekly coach report (Reports) | A | 2d |
| Coach profile aggregator | A | 1d |
| Equipment change audit log | A | 1d |
| Streak widget (Statistics) | A | 1d |

**Close-out criteria** — see `PHASE_A_CLOSE_OUT.md`.

---

## Phase B — Content Expansion

### Drill Library

| Item | Tag | Target |
|------|-----|--------|
| Expand drill catalog 25 → 300 | B | q1 |
| Tier system: Foundation / Intermediate / Advanced / Master | B | q1 |
| Drill tags: shot type, difficulty, objective, table size | B | q1 |
| Drill variants per family (8-ball rotation patterns, etc.) | B | q2 |
| Daily curated drill (push notification) | B | q2 |
| User-authored drills (pro/club owners) | B | q3 |
| Drill leaderboard / personal best ranking | B | q3 |
| Drill pack marketplace | B | q4 |
| Expand catalog 300 → 1000 | B | q4 |

### Knowledge Base

| Item | Tag | Target |
|------|-----|--------|
| Article catalog expansion (current → 500 articles) | B | q1 |
| Article tags + difficulty + prerequisite graph | B | q1 |
| Daily learning (push notification, 1 article per day) | B | q1 |
| Learning streak | B | q1 |
| Flashcards per article (spaced repetition) | B | q2 |
| Quiz per knowledge section | B | q2 |
| Knowledge graph visualization (DAG of prerequisites) | B | q3 |
| Prerequisite navigation (read X before Y) | B | q1 |

### Learning Path

| Item | Tag | Target |
|------|-----|--------|
| Path templates per skill (Safety / Position / Mental / Pattern) | B | q1 |
| Multi-path progression with prerequisites | B | q2 |
| Path completion rewards + badges | B | q2 |
| Adaptive difficulty progression | B | q3 |

---

## Phase C — AI & Analytics

### Match — Technical Analytics [C]

| Item | Tag | Description |
|------|-----|-------------|
| Shot map | C | Visualize every shot on a 2D table canvas |
| Heat map | C | Pot density / miss density per pocket per zone |
| Cue ball path | C | Trajectory overlay of cue ball |
| Pocket accuracy | C | Per-pocket make % |
| Shot difficulty distribution | C | Histogram of attempted vs made by difficulty |
| Decision quality | C | AI grade on each shot's intent vs outcome |
| Tactical review | C | Pattern play scoring, option tree analysis |
| AI opponent analysis | C | Identify opponent's tendencies |
| Match replay | C | Step through shots/racks with annotations |
| Video timestamp linkage | C | Sync recording to wall clock |
| Voice note | C | Per-rack / per-shot voice annotations |
| Table condition (cloth age / brand / speed) | C | Snapshot |
| Cloth condition (burn marks / chalk / humidity) | C | Snapshot |
| Humidity | C | Ambient sensor (manual entry) |
| Lighting | C | Manual entry |
| Match KPI board | C | Single screen of top-level KPIs |
| Training KPI board | C | Drill + match overlap |

### Coach AI [C]

| Item | Tag | Description |
|------|-----|-------------|
| AI strength / weakness summary (per match) | C | Already in MatchReviewEngine |
| Weekly coach report | C | Auto-generated |
| Recommended drill based on weak skill | C | Tier-aware |
| Skill forecasting (where you'll be in 30/60/90 days) | C | Trend extrapolation |
| Session-by-session mental coaching | C | Detect tilt, pressure patterns |
| Voice coach (TTS) during drills | C | Optional |

### Statistics [C]

| Item | Tag | Description |
|------|-----|-------------|
| Accuracy trend (rolling) | C | Line chart per shot type |
| Position trend | C | Cue ball control over time |
| Pressure trend | C | Performance under pressure |
| Equipment comparison | C | Multi-cue win-rate |
| Opponent comparison | C | Performance by opponent / opponent level |
| Drill efficiency | C | Skill delta per minute |
| Weakness radar | C | 6-axis radar |
| Monthly review | C | Auto-generated monthly narrative |
| AI Progress Score | C | Composite metric across all axes |

### Reports [C]

| Item | Tag | Description |
|------|-----|-------------|
| Season report | C | Quarter / year summary |
| Tournament report | C | Per-tournament deep dive |
| Coach report | C | What the coach sees |
| Equipment report | C | Performance per cue / chalk |
| Health report | C | Sleep / fatigue / energy trend |
| AI review report | C | AI weekly narrative |
| PDF export | C | All reports |
| Share sheet integration | C | Send to friends / social |

---

## Phase D — Competitive Features

### Community

| Item | Tag | Target |
|------|-----|--------|
| Public profiles | D | q1 |
| Follow other players | D | q1 |
| Skill-based matching | D | q1 |
| Group / clubs | D | q2 |
| Challenges (challenge a friend) | D | q1 |
| Comments / tips on match summaries | D | q3 |

### Tournaments

| Item | Tag | Target |
|------|-----|--------|
| Tournament organization (Pro / Club) | D | q1 |
| Bracket management | D | q2 |
| Live scoreboard | D | q2 |
| Tournament replay | D | q2 |
| Tournament ranking (ELO / Fargo) | D | q1 |
| Multi-table tournaments | D | q4 |

### Cloud Sync / Multi-Device

| Item | Tag | Target |
|------|-----|--------|
| Account system | D | q1 |
| Supabase backend | D | q1 |
| Offline-first → online sync | D | q1 |
| Conflict resolution | D | q1 |
| Web companion | D | q3 |

### Differentiators

| Item | Tag | Target |
|------|-----|--------|
| Vision-based stroke analysis (computer vision) | D | q3 |
| AI 8-ball pattern solver | D | q2 |
| AI 9-ball rack pattern | D | q3 |
| Snooker support | D | q3 |
| Carom support | D | q4 |
| Carbon-cue / smart cue integration | D | q4 |

---

## Strategy

```
┌──────────────────────────────────────────────────────────────────────┐
│  V2 Vision                                                           │
│  ─────────                                                           │
│  "The world's best billiards training app"                           │
│                                                                      │
│  ┌────────────┐   ┌────────────┐   ┌────────────┐   ┌────────────┐ │
│  │  Phase A   │ → │  Phase B   │ → │  Phase C   │ → │  Phase D   │ │
│  │  Parity    │   │  Content   │   │ AI+Stats   │   │ Competitive│ │
│  │            │   │            │   │            │   │            │ │
│  │ - no regr. │   │ - 1000 d.. │   │ - heatmap  │   │ - cloud    │ │
│  │            │   │ - 500 art. │   │ - AI coach │   │ - tourney  │ │
│  │  ✅ 85%    │   │ - flashcard│   │ - reports  │   │ - rank     │ │
│  └────────────┘   └────────────┘   └────────────┘   └────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
```

Don't optimize for V1 parity. Optimize for the vision. V1 parity is only
the floor, not the ceiling.
