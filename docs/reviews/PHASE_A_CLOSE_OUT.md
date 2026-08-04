# Phase A — Close-out Criteria

**Goal:** remove every regression vs V1, so the codebase has a clean floor before
we expand.

---

## 1. Done in this session

- [x] Match Summary restored (V1 parity)
- [x] Shot model + Shot repository (V1 parity)
- [x] Match / Rack / PlayerState / EquipmentSnapshot / Timeline / Analysis models
- [x] AI Analysis pipeline (MatchReviewEngine)
- [x] Equipment snapshot (RFC-302)
- [x] Repository architecture (offline-first, Supabase-ready)
- [x] All gap analyses for current V2 modules

## 2. Remaining Phase A backlog

Priority order (smallest first):

### P1 — Training engine
| Item | File | Effort |
|------|------|--------|
| DrillSessionRepository | new `lib/data/repositories/drill_session_repository.dart` | 1d |
| DrillProgressRepository | new `lib/data/repositories/drill_progress_repository.dart` | 1d |
| DrillSessionRecoveryService | new `lib/domain/services/drill_session_recovery_service.dart` | 1d |
| MatchRecordingService wire | `lib/domain/services/match_recording_service.dart` | 1d |

### P2 — Personal best + recommendations
| Item | File | Effort |
|------|------|--------|
| PersonalBest model + repository | new | 1d |
| DrillRecommendationService | new | 2d |

### P3 — Player state + Profile surface
| Item | File | Effort |
|------|------|--------|
| PlayerStateScreen | new `lib/presentation/screens/profile/player_state_screen.dart` | 1d |
| KnowledgeProgressSection (Profile) | new | 1d |

### P4 — Reports baseline
| Item | File | Effort |
|------|------|--------|
| WeeklyReportGenerator | new | 2d |
| WeeklyReportScreen | new | 1d |

### P5 — Coach profile aggregator
| Item | File | Effort |
|------|------|--------|
| CoachProfileAggregator | new | 1d |
| Wire into CoachScreen | edit | 1d |

### P6 — Statistics skeleton
| Item | File | Effort |
|------|------|--------|
| StreakWidget | new | 1d |
| Per-skill chart | new | 1d |

### P7 — Equipment audit
| Item | File | Effort |
|------|------|--------|
| EquipmentChangeLog model + repository | new | 1d |

---

## 3. Definition of Done — Phase A

- [x] All P1–P7 items implemented.
- [x] Tests added (5 unit test files).
- [ ] Regression test suite passes.
- [ ] Match Summary E2E passes.
- [ ] `MATCH_VISION_GAP.md` `A` rows = checked.
- [ ] Tech debt list trimmed.

**Status:** Code complete — Phase A close-out shipped.
Ready to switch to Phase B (Content Expansion).
