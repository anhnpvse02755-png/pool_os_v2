# Training Module — V1 vs V2 Gap Analysis

**Date:** 2026-08-02
**Sources:**
- V1: `C:\Users\anhnpv\OneDrive - Thanh Cong Group\Desktop\code\Pool OS\app\lib\features\training`
- V2: `lib\presentation\screens\training\*`

---

## 1. Executive Summary

V2 surfaces the major Training screens (Drill List, Drill Detail,
Drill Session, Knowledge, Certification, Learning Path, Training
History, Recommended, Progress). However, several V1 capabilities are
stubbed at the UI level with hardcoded data or are missing entirely:

- No actual drill engine for pose/shape scoring.
- No session-recovery / mid-session pause.
- No rating system (player ranking curve in V1).
- Hardcoded drill library.

---

## 2. V1 Surface

| Capability | V1 path |
|------------|---------|
| Drill Catalog (`drill_repository.dart`) | ✅ |
| Drill Library (V1) | seed / shuffle / curated set |
| Drill Session Model (V1) | repository + session state machine |
| Recovery (V1) | mid-session pause + resume |
| Progress curve | line chart of rating per day |
| Knowledge ↔ Drill graph | articles → drills |
| Recommendations (`drill_recommendation_service.dart`) | V1 |
| Rating system | numeric 1-5 stars + skill curve |
| Personal best per drill | tracked over time |

---

## 3. V2 Surface (current)

| Capability | Status | Path |
|------------|--------|------|
| Drill list | ✅ | `drill_list_screen.dart` |
| Drill detail | ✅ | `drill_detail_screen.dart` |
| Drill session | ✅ | `drill_session_screen.dart` |
| Knowledge list | ✅ | `knowledge_screen.dart` |
| Knowledge detail | ✅ | `knowledge_detail_screen.dart` |
| Certification list | ✅ | `certification_list_screen.dart` |
| Certification detail | ✅ | `certification_detail_screen.dart` |
| Learning path | ✅ | `learning_path_screen.dart` |
| Training history | ✅ | `training_history_screen.dart` |
| Recommended | ✅ | `recommended_screen.dart` |
| Progress | ✅ | `progress_screen.dart` |
| Assessment | ✅ | `assessment_screen.dart` |
| Center | ✅ | `training_center_screen.dart` |

The screens exist; the underlying data model is in `lib/data/models/drill_progress.dart` plus service-level code in `core/services/training_service.dart`.

---

## 4. Gap Analysis

### 4.1 Hardcoded data

| Symptom | V1 | V2 |
|---------|----|----|
| Drill list source | repository + JSON seed | repository but with limited categories |
| Drill session outcomes | session → drill library | hardcoded counts in some screens |

### 4.2 Missing

| Capability | V1 | V2 | Action |
|------------|----|----|--------|
| Session recovery | ✅ | ❌ | Add recovery service |
| Rating curve | ✅ | partial | Add rating model to session |
| Personal best | ✅ | ❌ | Track best per drill |
| Knowledge ↔ Drill graph | ✅ | ❌ | Link articles → drills |
| Skill rating delta | ✅ | ❌ | Add to drill_progress |
| Drill recommendation graph | ✅ | ❌ | Add RecommendationService |

### 4.3 Architecture

- V1 used `drill_session_repository`, `drill_progress_repository`,
  `drill_recommendation_service`, `drill_session_state_machine`,
  `drill_session_recovery_service`.
- V2 only has `drill_progress.dart` and `training_service.dart` —
  the latter is monolithic.

---

## 5. Restoration Plan

### Phase 1 — Data Layer

1. Create `lib/data/models/drill_session.dart` (outcome, rating, accuracy, duration).
2. Create `lib/data/models/drill_attempt.dart` (per-attempt score, time).
3. Create `lib/data/models/personal_best.dart`.
4. Extend `drill_progress.dart` with `skillDelta`, `confidence`, `mood`.

### Phase 2 — Repositories

1. `DrillSessionRepository` — list, save, getByDrill, getByPlayer.
2. `DrillProgressRepository` — per-drill progress.
3. `PersonalBestRepository` — fastest / most accurate per drill.
4. `DrillRecommendationService` — recommend based on weak skills.

### Phase 3 — UI

1. Replace hardcoded data in `drill_session_screen.dart`.
2. Add `drill_progress_curve.dart` widget.
3. Add `personal_best_widget.dart`.
4. Add `recommendation_widget.dart` on Home.

### Phase 4 — Tests

1. E2E: start session → mid-session pause → resume → finish → progress updated.
2. E2E: knowledge article click → related drill appears.

---

## 6. Definition of Done

- [ ] DrillSession model with rating + accuracy
- [ ] DrillSessionRepository
- [ ] DrillProgressRepository
- [ ] PersonalBest tracking
- [ ] Recommendation service
- [ ] Recovery service
- [ ] All hardcoded drill data removed
- [ ] Tests for session lifecycle
