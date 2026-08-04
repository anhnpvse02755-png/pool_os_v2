# Phase C — AI & Analytics

**Goal:** Transform Pool OS from a score-recorder into a coach-grade
training app.

---

## Done

### Match technical analytics

| Item | File |
|------|------|
| Shot map (2D table with shots plotted) | `lib/presentation/widgets/shot_map_view.dart` + `shot_map_painter.dart` |
| Heat map (pot/miss density) | same painter (showHeat toggle) |
| Cue ball path overlay | `lib/presentation/widgets/cue_ball_path_overlay.dart` |
| Pocket accuracy per pocket | `lib/domain/services/pocket_accuracy_service.dart` + `pocket_accuracy_view.dart` |
| Decision quality grade per shot | `lib/domain/services/decision_quality_service.dart` + `decision_quality_view.dart` |
| Match replay (step through racks/shots) | `lib/presentation/screens/match/match_replay_screen.dart` |
| Voice notes per shot/rack | `lib/data/models/voice_note.dart` + `lib/data/repositories/voice_note_repository.dart` + `voice_notes_panel.dart` |
| Environment capture (table/cloth/humidity/lighting) | `lib/data/models/match_environment.dart` + `environment_capture_screen.dart` |

### Coach AI

| Item | File |
|------|------|
| AI summary / explain / ask | `lib/domain/services/ai_explain_service.dart` + `ai_explain_screen.dart` |
| Strength / weakness aggregator | `lib/domain/services/coach_profile_aggregator.dart` + `coach_profile_panel.dart` |

### Statistics

| Item | File |
|------|------|
| Win rate trend chart | `lib/presentation/widgets/skill_trend_chart.dart` |
| Daily streak | `lib/domain/services/streak_calculator.dart` + `streak_widget.dart` |
| AI Progress Score (composite) | `lib/domain/services/ai_progress_score_service.dart` + `ai_progress_score_card.dart` |

### Reports

| Item | File |
|------|------|
| Weekly report (already in Phase A) | `weekly_report_generator.dart` |
| Monthly report | `lib/domain/services/monthly_report_generator.dart` + `monthly_report_screen.dart` |

---

## Aggregator

`lib/presentation/widgets/progress_card.dart` — composes `AiProgressScoreCard`,
`SkillTrendChart`, `StreakWidget`, `LearningStreakWidget`, `CoachProfilePanel`
into a single tabbed card. Embedded in Home.

---

## Router

`lib/core/router/app_router.dart` — added:
- `/reports/monthly`
- `/knowledge/graph`
- `/knowledge/flashcards/:slug`
- `/knowledge/quiz/:slug`
- `/knowledge/ai-explain`

---

## Next

- [ ] Video timestamp linkage
- [ ] Tactical review (pattern play grading, option tree)
- [ ] AI opponent analysis (tendencies of the rival)
- [ ] Skill forecasting (30/60/90 day)
- [ ] Trend: Accuracy / Position / Pressure
- [ ] Equipment comparison view
- [ ] Opponent comparison
- [ ] Drill efficiency metric
- [ ] Weakness radar (6-axis)
- [ ] Tournament report
- [ ] Coach report
- [ ] Equipment report
- [ ] Health report
- [ ] AI review report
- [ ] PDF export
- [ ] Share sheet integration