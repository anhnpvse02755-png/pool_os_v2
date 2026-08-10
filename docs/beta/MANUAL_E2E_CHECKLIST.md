# D0.4 — Manual E2E Checklist

**Test Date:** _______________
**Tester:** _______________
**Device:** _______________
**App Version:** _______________

---

## Coach Home Tests

### Empty State (Cold User)

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 1 | Fresh install, no data | Coach shows "Không có đủ dữ liệu" | ☐ | |
| 2 | Fresh install, no sessions | Empty state message shown | ☐ | |
| 3 | Coach Home accessed | No crash | ☐ | |

### Normal State (Warm User)

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 4 | 1 completed session | Coach shows ONE recommendation | ☐ | |
| 5 | Multiple sessions | Only 1 priority shown | ☐ | |
| 6 | Recommendation visible | Drill name + reason shown | ☐ | |
| 7 | "Vì sao?" button | Opens explain bottom sheet | ☐ | |
| 8 | Explain shows reason | Matches recommendation reason | ☐ | |
| 9 | Start button tap | Navigates to drill | ☐ | |
| 10 | Coach Voice check | No "Bạn muốn..." phrases | ☐ | |
| 11 | Coach Voice check | No "Theo phân tích..." phrases | ☐ | |

### Interrupted Session

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 12 | Have interrupted session | "Tiếp tục phiên" shown | ☐ | |
| 13 | Tap Continue | Resumes from saved progress | ☐ | |
| 14 | Session info shown | Drill name + progress visible | ☐ | |

### Recommendation Consistency

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 15 | Recommendation accepted | State updates | ☐ | |
| 16 | After accept | Same recommendation shown | ☐ | |
| 17 | New recommendation | Only after completion | ☐ | |

---

## Coach Chat Tests

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 18 | Open Coach Chat | History loads | ☐ | |
| 19 | Send "Tại sao?" | Coach responds | ☐ | |
| 20 | Response timing | Loading indicator shown | ☐ | |
| 21 | Coach Voice in chat | Natural, short sentences | ☐ | |
| 22 | Multiple messages | History scrolls | ☐ | |
| 23 | Empty input | Send button disabled | ☐ | |
| 24 | Chat error | Error message shown | ☐ | |

---

## Drill Session Tests

### Start Drill

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 25 | Start drill | Session created | ☐ | |
| 26 | Instructions shown | Drill name + tips visible | ☐ | |
| 27 | Start button | Tap navigates to session | ☐ | |

### During Session

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 28 | Complete 1 rep | Counter updates | ☐ | |
| 29 | Success tap | Success counter increments | ☐ | |
| 30 | Fail tap | Fail counter increments | ☐ | |
| 31 | Progress bar | Updates correctly | ☐ | |
| 32 | Timer | Counts up correctly | ☐ | |
| 33 | App backgrounded | Session preserved | ☐ | |

### Complete Drill

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 34 | Reach target reps | Completion screen shown | ☐ | |
| 35 | Score displayed | Matches actual performance | ☐ | |
| 36 | Next Action shown | Recommendation appears | ☐ | |
| 37 | Reflection prompt | Shown before completion | ☐ | |

### Interrupted Session

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 38 | Force close during drill | Session saved | ☐ | |
| 39 | Reopen app | "Continue" prompt shown | ☐ | |
| 40 | Continue tap | Resumes from saved state | ☐ | |
| 41 | Abandon session | Session marked interrupted | ☐ | |

---

## Black Box Export Tests

### Export Flow

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 42 | Settings → Black Box | Export screen opens | ☐ | |
| 43 | Export button tap | Feedback dialog shown | ☐ | |
| 44 | Skip feedback | Export proceeds | ☐ | |
| 45 | Submit feedback | Export proceeds | ☐ | |
| 46 | Progress shown | All steps visible | ☐ | |
| 47 | Recording events | Checkmark shown | ☐ | |
| 48 | Building replay | Checkmark shown | ☐ | |
| 49 | Creating snapshots | Checkmark shown | ☐ | |
| 50 | Packaging | Checkmark shown | ☐ | |
| 51 | Compressing ZIP | Checkmark shown | ☐ | |

### Success State

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 52 | Export complete | Success screen shown | ☐ | |
| 53 | Package name visible | PoolOS_Coach_v2.0.zip | ☐ | |
| 54 | Version shown | v2.0 badge | ☐ | |
| 55 | Size shown | Format: X.X MB | ☐ | |
| 56 | Generated time | Timestamp shown | ☐ | |
| 57 | Share button | Opens share sheet | ☐ | |
| 58 | Save button | Saves to downloads | ☐ | |

### Error State

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 59 | Export fails | Error screen shown | ☐ | |
| 60 | Retry button | Retries export | ☐ | |
| 61 | Cancel button | Returns to ready state | ☐ | |
| 62 | Error message | Reason shown | ☐ | |

---

## Edge Cases

### Empty/No Data

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 63 | No sessions, export | Package created (empty data) | ☐ | |
| 64 | No recommendations, export | Package created | ☐ | |
| 65 | No conversations, export | Package created | ☐ | |

### Large Data

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 66 | 100+ sessions, export | Export completes | ☐ | |
| 67 | Export timing | < 5 seconds | ☐ | |
| 68 | ZIP size | < 10 MB | ☐ | |

### Error Recovery

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 69 | Network error during export | Graceful error shown | ☐ | |
| 70 | Storage full | Error message shown | ☐ | |
| 71 | Permission denied | Error message shown | ☐ | |

---

## Privacy & Security

| # | Scenario | Expected Result | Pass | Notes |
|---|----------|-----------------|------|-------|
| 72 | ZIP contains email | Should NOT contain | ☐ | |
| 73 | ZIP contains phone | Should NOT contain | ☐ | |
| 74 | ZIP contains token | Should NOT contain | ☐ | |
| 75 | ZIP contains password | Should NOT contain | ☐ | |
| 76 | ZIP contains GPS | Should NOT contain | ☐ | |
| 77 | ZIP contains IP | Should NOT contain | ☐ | |

---

## Summary

| Category | Total | Passed | Failed |
|----------|-------|--------|--------|
| Coach Home | 11 | ___ | ___ |
| Coach Chat | 7 | ___ | ___ |
| Drill Session | 19 | ___ | ___ |
| Black Box Export | 20 | ___ | ___ |
| Edge Cases | 7 | ___ | ___ |
| Privacy | 6 | ___ | ___ |
| **TOTAL** | **70** | **___** | **___** |

### Overall Result

☐ **PASS** — All critical tests passed

☐ **FAIL** — ___ critical failures

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Tester | | | |
| Reviewer | | | |
| QA Lead | | | |
