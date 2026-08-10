---
name: sprint-7b-summary
description: Sprint 7B Summary - Coach Preview UI Complete
metadata:
  type: project
---

# Sprint 7B Summary

**Status:** ✅ COMPLETED
**Date:** 2026-08-07
**Duration:** 4 sprints (7B.1 - 7B.4)

---

## North Star

> "Người chơi thực sự sử dụng Coach AI trong quá trình tập luyện."

---

## Sprint Breakdown

| Sprint | Status | North Star | Deliverables |
|--------|--------|------------|--------------|
| 7B.1 | ✅ | 5s to know what to do | Coach Home, ONE Priority, Coach Voice |
| 7B.2 | ✅ | Understand why Coach says | Chat, Explain, Coach Voice |
| 7B.3 | ✅ | Coach remembers me | Timeline, Session Memory |
| 7B.4 | ✅ | No guidance needed | Onboarding, Polish |

---

## Deliverables

### 7B.1 - Coach Home
- [x] Coach Home Screen (ONE Priority)
- [x] Recommendation Card
- [x] Continue Session Card
- [x] Empty State
- [x] Loading State
- [x] Error State
- [x] Coach Voice Service
- [x] Coach Home = App Home

### 7B.2 - Explain + Chat
- [x] Coach Chat Screen
- [x] Explain Bottom Sheet
- [x] Coach Chat Bubbles
- [x] Suggestion Chips
- [x] Intent parsing

### 7B.3 - Timeline + Memory
- [x] Coach Timeline Screen
- [x] Session Memory Service
- [x] Timeline Entry Cards
- [x] Continue Session Detection

### 7B.4 - Polish
- [x] Coach Onboarding (3 screens)
- [x] Empty States refinement
- [x] Loading States refinement
- [x] Error States refinement

---

## Files Created

```
lib/
├── presentation/screens/coach/
│   ├── coach_home_screen.dart
│   ├── coach_chat_screen.dart
│   ├── coach_timeline_screen.dart
│   └── coach_onboarding_screen.dart
├── presentation/widgets/coach/
│   ├── recommendation_card.dart
│   ├── continue_session_card.dart
│   ├── coach_empty_state.dart
│   ├── coach_loading_state.dart
│   ├── coach_error_state.dart
│   ├── explain_bottom_sheet.dart
│   ├── coach_chat_bubble.dart
│   ├── coach_suggestion_chips.dart
│   └── coach_home_widgets.dart
└── core/services/
    ├── coach_voice_service.dart
    └── session_memory_service.dart
```

---

## Coach Voice Implementation

### 10 Rules Applied

1. **Coach Home = App Home**
2. **ONE Priority Only**
3. **Actionable**
4. **5-second value**
5. **Explain Everywhere**
6. **Coach Leads, Never Asks**
7. **Every Recommendation Has Outcome**
8. **Silence when no data**
9. **Consistency**
10. **Coach Voice**

### Examples

```dart
// ❌ Bot-style
"Dựa trên dữ liệu của bạn trong 5 buổi gần nhất..."

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
| Hỏi "Tại sao?" ở mọi nơi | ✅ |
| Coach nhớ session | ✅ |
| Coach Voice pass checklist | ✅ |
| New user có thể tự dùng | ✅ |

---

## Phase 7 Complete

**Phase 7 Coach AI Preview** is now complete.

### What works:
- Open app → Coach Home
- ONE Priority recommendation
- Start Now (1 tap)
- Coach Chat
- Explain Bottom Sheet
- Coach Timeline
- Coach Voice

### Next: Preview/Beta Milestone

After Phase 7, the next step is:

1. **Test with real users**
2. **Collect conversation quality data**
3. **Collect recommendation quality data**
4. **Collect retention data**
5. **Collect feedback**

Only after Beta data:
- Decide Phase 8 (Vision AI, Video Analysis, etc.)
- Or continue improving Coach

---

## Principles Maintained

1. **Product First** - No Brain expansion
2. **Experience Layer** - UI only
3. **Continuous Delivery** - No asking "Ready?" between sprints
4. **Coach Voice** - Natural, like a real coach
5. **ONE Priority** - Clear focus

---

Related: [[COACH-UX-BLUEPRINT]], [[COACH_VOICE_GUIDELINE]], [[phase-3-vertical-slice-roadmap]].
