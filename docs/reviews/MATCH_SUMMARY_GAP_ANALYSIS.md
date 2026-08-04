# Match Summary — V1 vs V2 Gap Analysis

**Date:** 2026-08-02
**Sources:**
- V1: `C:\Users\anhnpv\OneDrive - Thanh Cong Group\Desktop\code\Pool OS\app\lib\features\match`
- V2: `lib\presentation\screens\play\match_history_screen.dart`

---

## 1. Executive Summary

The V2 Match History screen is a **regression** from V1. The current
implementation:

1. Stores 3 fields per match (winner, loser, final score) as inline
   demo data with no Repository backing.
2. Renders a static list with no Match Summary / detail screen.
3. Has **no AI analysis** (Strengths / Weaknesses / Drills / Knowledge).
4. Has **no timeline** of racks.
5. Has **no performance breakdown** (cue ball / mental / physical).
6. Has **no Match Equipment snapshot** (V1 RFC-302 froze equipment at
   match time).
7. Has **no aggregation** into player statistics / progress charts /
   achievements.

This is a top-level regression and the V1 surface must be fully restored.

---

## 2. V1 Inventory (Source of Truth)

### 2.1 `Match` model (`features/match/domain/models/match.dart`)

| Field | V1 Type | Description |
|-------|---------|-------------|
| id | `int?` | DB primary key |
| sessionId | `int` | FK to session |
| matchNumber | `int` | Match index in session |
| gameType | `String` | race_to, race_to_5, race_to_7, ghost_challenge, challenge_match, league_match, tournament_match, practice_match, warm_up, drill |
| raceTo | `int?` | Race-to format |
| opponent | `String?` | Opponent name |
| partner | `String?` | Partner (doubles) |
| teamMode | `String?` | solo / doubles / team |
| **winner** | `String?` | player / opponent |
| **result** | `String?` | Score summary |
| startTime | `DateTime?` | Match start |
| endTime | `DateTime?` | Match end |
| matchObjective | `String?` | Coach-assigned objective |
| notes | `String?` | Free-form |
| createdAt | `DateTime` | Audit |

### 2.2 `Rack` model (`features/rack/domain/models/rack.dart`)

| Field | V1 Type | Description |
|-------|---------|-------------|
| id | `int?` | DB primary key |
| matchId | `int` | FK to match |
| rackNumber | `int` | 1-based |
| result | `bool` | true = player won rack |
| **ballsPotted** | `int` | Total balls made |
| **largestRun** | `int` | Longest consecutive run |
| **breakSuccess** | `bool` | Made a ball on break |
| **breakScratch** | `bool` | Scratched on break |
| **breakFoul** | `bool` | Foul on break |
| **easyMissCount** | `int` | Missed easy shots |
| **hardMissCount** | `int` | Missed hard shots |
| **scratchErrorCount** | `int` | Scratch fouls |
| **positionErrorCount** | `int` | Position errors |
| **safetyErrorCount** | `int` | Safety mistakes |
| **kickErrorCount** | `int` | Kicks attempted/missed |
| **jumpErrorCount** | `int` | Jump shots attempted/missed |
| bestStrengths | `List<String>` | Tags |
| biggestMistakes | `List<String>` | Tags |
| notes | `String?` | Free-form |
| confidence | `int?` | 1-5 |
| biggestMistake | `String?` | One-line summary |
| biggestStrength | `String?` | One-line summary |
| createdAt | `DateTime` | Audit |

### 2.3 `Shot` model (`features/shot/domain/models/shot.dart`)

| Field | V1 Type | Description |
|-------|---------|-------------|
| id | `int?` | DB primary key |
| rackId | `int` | FK to rack |
| shotNumber | `int` | 1-based |
| shotType | `String` | break / opening / normal / safety / jump / bank / masse |
| difficulty | `String` | easy / medium / hard / extreme |
| result | `String` | made / missed / scratch / foul |
| positionQuality | `String?` | perfect / good / playable / recovery / bad |
| decision | `String?` | Free-form |
| confidence | `String?` | very_confident / confident / unsure / guessing |
| playerNote | `String?` | Free-form |
| intent | `String?` | pot / position / safety / break / escape |
| missReason | `String?` | Why it failed |
| createdAt | `DateTime` | Audit |

### 2.4 V1 Screens

| Screen | Path |
|--------|------|
| Match Recording Screen | `match_recording_screen.dart` |
| Match Detail Screen | `match_detail_screen.dart` |
| Match History View | `match_history_view.dart` |
| Match Statistics Panel | `match_statistics_panel.dart` |
| Post-Match Context Screen | `post_match_context_screen.dart` |
| Pre-Match Context Screen | `pre_match_context_screen.dart` |
| Match Engine View Model | `match_engine_view_model.dart` |

### 2.5 V1 Services

- `MatchRecordingService` — recording lifecycle
- `MatchStatisticsService` — compute match stats
- `MatchLifecycleService` — start / finish / resume
- `MatchRecoveryService` — recover in-progress match
- `MatchReviewEngine` — Coach review logic
- `MatchObjectivePolicy` — race-to completion policy
- `matchIdentityCompatibilityService` — schema migration
- `playerCareerMatchSource` — career aggregations

### 2.6 V1 Sub-Repositories

- `match_repository.dart` — Match CRUD
- `match_context_repository.dart` — Context (warm-up, post-match, etc.)
- `match_equipment_snapshot_repository.dart` — RFC-302 snapshot

### 2.7 V1 Player State

`PlayerStateLog` — captures per-match `confidence`, `focus`, `pressure`,
`tilt`, `fatigue`, `energy`, `eye_condition`, `sleep`, `composure`
(Knowledge §8: Player State Model).

### 2.8 V1 Stats Aggregations

`match_statistics_service.dart` aggregates from racks to:

- Win rate
- Break & Run count
- Run Outs count
- Golden Break count
- Safety success rate
- Fouls per match
- Per-shot-type accuracy (cut, bank, kick, jump, combo, carom)
- Position quality distribution
- Mental state distribution
- Physical state distribution

---

## 3. V2 Match Model vs V1

### 3.1 V2 `Match` fields

| V2 Field | V1 Equivalent | Status |
|----------|---------------|--------|
| id | id | ✅ |
| opponent | opponent | ✅ |
| opponentName | opponent | ✅ |
| raceTo | raceTo | ✅ |
| result | winner | ✅ |
| type | gameType | ✅ |
| opponentLevel | (none in V1) | V2 extension |
| table | (none in V1) | V2 extension |
| duration | duration (computed) | ✅ |
| notes | notes | ✅ |
| playerScore | (derived from racks) | ✅ |
| opponentScore | (derived from racks) | ✅ |
| racks | session/match has racks | ✅ |
| createdAt | createdAt | ✅ |
| **N/A** | matchNumber | ❌ missing |
| **N/A** | partner | ❌ missing |
| **N/A** | teamMode | ❌ missing |
| **N/A** | startTime | ❌ missing |
| **N/A** | endTime | ❌ missing |
| **N/A** | matchObjective | ❌ missing |

### 3.2 V2 `Rack` fields

| V2 Field | V1 Equivalent | Status |
|----------|---------------|--------|
| rackNumber | rackNumber | ✅ |
| result | result | ✅ |
| breakShot | (composite) | ✅ |
| breakSuccess | breakSuccess | ✅ |
| ballsPottedOnBreak | (composite) | ✅ |
| longestRun | largestRun | ✅ |
| totalBallsPotted | ballsPotted | ✅ |
| safetyPlays | (composite) | ✅ |
| fouls | (composite) | ✅ |
| howWon | (none) | V2 extension |
| biggestMistake | biggestMistake | ✅ |
| biggestStrength | biggestStrength | ✅ |
| confidence | confidence | ✅ |
| note | notes | ✅ |
| **N/A** | breakScratch | ❌ missing |
| **N/A** | breakFoul | ❌ missing |
| **N/A** | easyMissCount | ❌ missing |
| **N/A** | hardMissCount | ❌ missing |
| **N/A** | scratchErrorCount | ❌ missing |
| **N/A** | positionErrorCount | ❌ missing |
| **N/A** | safetyErrorCount | ❌ missing |
| **N/A** | kickErrorCount | ❌ missing |
| **N/A** | jumpErrorCount | ❌ missing |
| **N/A** | bestStrengths | ❌ missing |
| **N/A** | biggestMistakes | ❌ missing |

### 3.3 V2 has no `Shot` model — completely missing.

### 3.4 V2 Status

| Feature | V1 | V2 | Status |
|---------|----|----|--------|
| Hardcoded demo data | no | **YES** | gap |
| Match Repository | yes | no (inline) | gap |
| Match Detail Screen | yes | no | gap |
| Match Summary screen | yes | **no** | gap |
| Match Timeline | yes | **no** | gap |
| AI Analysis | yes | **no** | gap |
| Performance breakdown | yes | **no** | gap |
| Cue ball section | yes | **no** | gap |
| Mental section | yes | **no** | gap |
| Physical section | yes | **no** | gap |
| Equipment snapshot | yes (RFC-302) | **no** | gap |
| Aggregate stats update | yes | **no** | gap |
| Progress charts | yes | **no** | gap |
| Achievements | yes | **no** | gap |
| Skill ratings | yes | **no** | gap |
| AI Coach profile | yes | **no** | gap |
| 18-shot-type taxonomy | yes | partial | gap |

---

## 4. Gap Analysis

### 4.1 Missing Basic Information

| Field | Status | Action |
|-------|--------|--------|
| Match ID | ✅ (id) | preserve |
| Date | ✅ (createdAt) | map to date |
| Time | derive from startTime | add startTime |
| Duration | ✅ (computed) | preserve |
| Game type | ✅ (type) | normalize to V1 enum |
| Race format | ✅ (raceTo) | preserve |
| Venue | ❌ | add |
| Table | ✅ (table) | preserve |
| Opponent | ✅ (opponent) | preserve |
| Winner | ✅ (result) | preserve |
| Final score | ✅ (playerScore/opponentScore) | preserve |
| Match number | ❌ | add |
| Team mode | ❌ | add |
| Partner | ❌ | add |
| Match objective | ❌ | add |

### 4.2 Missing Performance

| V1 metric | V2 status | Action |
|-----------|-----------|--------|
| Total racks | derive from racks | preserve |
| Win % | derive | preserve |
| Breaks | derive ballsPottedOnBreak | preserve |
| Break & Run | derive (largestRun == ballsPotted) | add |
| Run Outs | derive (ballsPotted == ballsPerRack) | add |
| Golden Break | add (wingball on break) | add |
| Safety count | derive safetyPlays | preserve |
| Safety success | ❌ | add safetyErrorCount |
| Fouls | ✅ | preserve |
| Scratch | ✅ breakScratch | preserve |
| Missed easy shots | ❌ easyMissCount | add |
| Position errors | ❌ positionErrorCount | add |
| Kicks | ❌ kickErrorCount | add |
| Banks | (none) | add — bank shot tracking |
| Jump shots | ❌ jumpErrorCount | add |
| Combo shots | (none) | add |
| Carom shots | (none) | add |

### 4.3 Missing Cue Ball

| V1 metric | V2 status | Action |
|-----------|-----------|--------|
| Stop shots | Shot intent | add |
| Draw shots | Shot intent | add |
| Follow shots | Shot intent | add |
| Side spin usage | Shot intent | add |
| Position quality | Partial | preserve |

### 4.4 Missing Mental

| V1 metric | V2 status | Action |
|-----------|-----------|--------|
| Confidence | ✅ (per-rack) | aggregate |
| Focus | ❌ | add |
| Pressure | ❌ | add |
| Tilt moments | ❌ | add |

### 4.5 Missing Physical

| V1 metric | V2 status | Action |
|-----------|-----------|--------|
| Sleep | ❌ | add |
| Fatigue | ❌ | add |
| Energy | ❌ | add |
| Eye condition | ❌ | add |

### 4.6 Missing Equipment

| V1 metric | V2 status | Action |
|-----------|-----------|--------|
| Cue | ❌ | add — RFC-302 |
| Shaft | ❌ | add |
| Tip | ❌ | add |
| Chalk | ❌ | add |

### 4.7 Missing AI Analysis (entire feature)

- Strengths
- Weaknesses
- Biggest mistakes
- Most improved skill
- Suggested drills
- Related knowledge articles
- Recommended learning path

### 4.8 Missing Timeline

V1 has rack-by-rack timeline events. V2 has none.

### 4.9 Missing Stats Aggregations

V1 has these axes that V2 lacks:

- Player aggregate stats
- Equipment usage tracking
- Training recommendations
- Progress charts
- Achievements
- Skill ratings
- AI Coach profile

### 4.10 Missing Architecture

| Capability | V1 | V2 |
|------------|----|----|
| MatchRepository | ✅ | ❌ hardcoded |
| ShotRepository | ✅ | ❌ absent |
| RackRepository | ✅ | ❌ absent |
| MatchStatisticsService | ✅ | ❌ absent |
| MatchRecordingService | ✅ | ❌ absent |
| MatchReviewEngine | ✅ | ❌ absent |
| Equipment snapshot | ✅ (RFC-302) | ❌ absent |
| Drift schema for matches | ✅ | ❌ no schema |
| Player State log | ✅ | ❌ absent |

---

## 5. Restoration Plan

### Phase 1 — Data Layer

1. Extend `Match` model with all V1 fields + AI analysis fields.
2. Extend `Rack` model with all V1 fields + bank/jump/combo/carom.
3. Create `Shot` model with all V1 fields + V2 extensions.
4. Create `PlayerStateSnapshot` model (mental + physical).
5. Create `MatchEquipmentSnapshot` model (RFC-302).
6. Create `MatchTimelineEntry` model.
7. Create `MatchAnalysis` model (AI output).
8. Implement `MatchRepository` interface (CRUD + query + stats).
9. Implement `LocalMatchRepository` (SharedPreferences).
10. Implement `LocalShotRepository` (SharedPreferences).
11. Implement `LocalRackRepository` (SharedPreferences).
12. Implement `LocalPlayerStateRepository`.
13. Implement `LocalEquipmentSnapshotRepository`.
14. Implement `MatchStatisticsService` (aggregates from racks/shots).
15. Implement `MatchReviewEngine` (AI analysis).
16. Wire routes via `repository_providers.dart`.

### Phase 2 — UI

1. Replace `match_history_screen.dart` with full implementation.
2. Build `match_summary_screen.dart` — comprehensive post-match report.
3. Build `match_detail_screen.dart` — replica of V1 detail.
4. Build `match_recording_screen.dart` — live match recording.
5. Build `match_timeline_screen.dart` — rack-by-rack timeline.
6. Build `match_stats_section.dart` — performance breakdown.
7. Build `ai_analysis_section.dart` — strengths/weaknesses/drills.
8. Build `equipment_snapshot_section.dart` — cue/shaft/tip.
9. Build `mental_physical_section.dart` — confidence/focus/tilt/sleep.

### Phase 3 — Router

- `/play/match` → match history
- `/play/match/new` → recording
- `/play/match/recording` → live recording
- `/play/match/:id` → detail
- `/play/match/:id/summary` → full Match Summary
- `/play/match/:id/timeline` → rack timeline
- `/play/match/:id/analysis` → AI analysis

### Phase 4 — Tests

1. Playwright E2E for create match, finish match, view summary.
2. Test every summary section.
3. Test AI analysis generation.
4. Test stats aggregation.

### Phase 5 — Future-proofing

- Repository interface hides persistence.
- Replace `LocalMatchRepository` with `SupabaseMatchRepository` later.
- All DateTime fields are timezone-aware.
- `playerId` field on every match for multiplayer.

---

## 6. Definition of Done

- [ ] `Match` model ≥ V1 fields (15+)
- [ ] `Rack` model ≥ V1 fields (20+)
- [ ] `Shot` model added (12+ fields)
- [ ] `PlayerStateSnapshot` model added
- [ ] `MatchEquipmentSnapshot` model added
- [ ] `MatchAnalysis` model added
- [ ] `MatchRepository` + `ShotRepository` + `RackRepository`
- [ ] Match Summary screen with all V1 sections
- [ ] Match Timeline screen
- [ ] AI Analysis (auto-generated)
- [ ] Stats aggregation
- [ ] Equipment snapshot
- [ ] Player state capture
- [ ] No regressions in existing E2E
- [ ] New E2E coverage for summary
- [ ] Documentation complete
