---
name: sprint-17-training-flow-bug
description: Sprint-17 bug forensic: DrillDetail "Bắt đầu nhập liệu" CTA trace
metadata:
  type: project
---

# Sprint-17 Training Flow Bug Forensic Report

## Bug Description
User taps "Bắt đầu nhập liệu — Level 1" on DrillDetail screen → incorrectly navigates to Training History.

## Key Findings

### CTA Location
- File: `lib/presentation/screens/training/drill_detail_screen.dart`
- Line: 792
- Label: "Bắt đầu nhập liệu — Level $_selectedLevel"

### Navigation Chain (CORRECT)
```
ElevatedButton._onStartPressed()
    ↓
context.push('/training/session/new?drill=${drill.code}&level=$_selectedLevel&target=$picked')
    ↓
DrillSessionScreen
    ↓
[User practices]
    ↓
_syncToTrainingHistory(completed)
    ↓
context.push('/training/session/complete', extra: completed)
    ↓
DrillCompletionScreen
```

### Root Cause Hypothesis
Two fallback scenarios can show Training History:

1. **Drill Not Found** (HIGH probability)
   - `DrillLibrary.getDrill(drillCode)` returns null
   - `DrillSessionScreen` shows error state
   - Error state has button: `context.go('/training/history')`

2. **Session Data Not Passed** (LOW probability)
   - `DrillCompletionScreen` receives null session
   - Falls back to `DrillCategoriesScreen`

### Critical Finding: Previous Wrong Fix
Previous attempt routed to `/play/vision` (VisionRecordingScreen) - THIS WAS WRONG because:
- VisionRecordingScreen is BETA/WIP
- Not part of main training flow
- Does not update PlayerIntelligence

### Code That Is NOT The Issue
- Route `/training/session/new` - registered correctly
- DrillDetailScreen CTA - correct navigation
- DrillSessionScreen - exists and works
- No new screen needed

## Related Memories
- [[sprint-17-recommendation-reliability]] - Sprint-17 commit d2c6021
- [[pool-os-v2-architecture]] - Overall app structure

## Next Steps
1. User should check browser DevTools Console for debug output
2. Verify if drill is found or null in DrillLibrary
3. If confirmed, minimal fix: change error fallback from `/training/history` to `context.pop()`
