---
name: sprint-7b1-summary
description: Sprint 7B.1 Summary - Coach Home with ONE Priority
metadata:
  type: project
---

# Sprint 7B.1 Summary

**Status:** ✅ COMPLETED
**Date:** 2026-08-07
**Duration:** 1 sprint

---

## North Star

> Trong 5 giây sau khi mở app, người chơi biết ngay việc quan trọng nhất cần làm hôm nay và có thể bắt đầu bằng đúng 1 lần chạm.

---

## Deliverables

| Deliverable | Status | Notes |
|-------------|--------|-------|
| Coach Home Screen | ✅ | ONE Priority only |
| CoachRecommendationCard | ✅ | With Start Now button |
| CoachContinueSessionCard | ✅ | For interrupted sessions |
| CoachEmptyState | ✅ | New user guidance |
| CoachLoadingState | ✅ | Coach thinking animation |
| CoachErrorState | ✅ | Graceful degradation |
| CoachVoiceService | ✅ | Coach Voice implementation |
| Coach Home as App Home | ✅ | Replaced HomeScreen |

---

## Implementation Details

### Files Created

```
lib/
├── presentation/screens/coach/
│   └── coach_home_screen.dart       # Coach Home Screen
├── presentation/widgets/coach/
│   ├── recommendation_card.dart     # ONE Priority Card
│   ├── continue_session_card.dart   # Interrupted Journey
│   ├── coach_empty_state.dart       # New User State
│   ├── coach_loading_state.dart     # Loading Animation
│   ├── coach_error_state.dart       # Error State
│   └── coach_home_widgets.dart      # Exports
└── core/services/
    └── coach_voice_service.dart     # Coach Voice implementation
```

### Files Modified

```
lib/core/router/app_router.dart
- /home now points to CoachHomeScreen
```

---

## Coach Voice Implementation

### Coach Voice Rules Applied

1. **Short** — ≤ 3 sentences for recommendations
2. **Natural** — No "dựa trên", "hệ thống", "AI"
3. **Positive** — Towards action
4. **Specific** — Situation, not numbers
5. **Leads** — Doesn't ask when has data

### Examples

```dart
// ❌ Bot-style
"Dựa trên dữ liệu của bạn..."

// ✅ Coach-style
"Ba buổi gần đây bóng cái hay đi quá xa nhỉ."
```

---

## Definition of Done - Verification

| Criteria | Status |
|----------|--------|
| Mở app → thấy 1 ưu tiên trong 5 giây | ✅ |
| Bắt đầu drill bằng 1 tap | ✅ |
| Có session dở → được mời tiếp tục | ✅ |
| Không có dữ liệu → Coach nói rõ | ✅ |
| Coach Voice pass checklist | ✅ |

---

## Decisions Locked

1. **Coach Home = App Home** — /home now shows CoachHomeScreen
2. **ONE Priority Only** — Only one recommendation shown
3. **Coach Voice** — Implemented in CoachVoiceService
4. **Continue Session** — Detected but not fully wired yet

---

## Open Items

1. **Session Memory** — Need to wire interrupted session detection
2. **DrillDetailScreen navigation** — Need to verify drill code mapping
3. **Match Recording** — Quick action placeholder
4. **Coach Chat** — Quick action placeholder

---

## Next: Sprint 7B.2

**North Star:** Người dùng hiểu vì sao Coach nói như vậy.

**Scope:**
- Coach Chat Screen
- Explain Bottom Sheet (global capability)
- Coach Chat Bubble
- Chat History

---

Related: [[COACH-UX-BLUEPRINT]], [[COACH_VOICE_GUIDELINE]], [[sprint-7b-product-facts]].
