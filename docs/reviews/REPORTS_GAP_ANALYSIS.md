# Reports Module — V1 vs V2 Gap Analysis

**Date:** 2026-08-02

---

## 1. Executive Summary

V2 has the Match Summary as the primary per-match report. There is no
broader Reports screen (weekly / monthly) yet.

---

## 2. V1 Surface

- Weekly / monthly / per-season reports.
- PDF / share export.
- Achievements and milestones.

---

## 3. V2 Surface

| Capability | Status |
|------------|--------|
| Per-match report | ✅ restored this iteration |
| Weekly / monthly report | ❌ |
| PDF export | ❌ (Share button stub) |
| Achievements | ❌ |

---

## 4. Gap Analysis

| Capability | V1 | V2 | Action |
|------------|----|----|--------|
| Match report | ✅ | ✅ restored | done |
| Weekly report | ✅ | ❌ | add `weekly_report_screen.dart` |
| Monthly report | ✅ | ❌ | future |
| PDF export | ✅ | ❌ | future |
| Share | ✅ | ⚠️ stubbed | needs impl |
| Achievements | ✅ | ❌ | future |

---

## 5. Restoration Plan

1. Add `weekly_report_screen.dart` aggregating last 7 days of matches.
2. Add `share_match_summary.dart` via OS share sheet.
3. Stub PDF export with `printing` package later.

---

## 6. Definition of Done

- [x] Match Summary report (this iteration)
- [ ] Weekly report
- [ ] Monthly report
- [ ] Share sheet integration
- [ ] Achievements
