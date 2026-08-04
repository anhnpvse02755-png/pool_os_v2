# Equipment Module — V1 vs V2 Gap Analysis

**Date:** 2026-08-02

---

## 1. Executive Summary

V2 surfaces a near-feature-parity Equipment module: list, edit, detail,
comparison, statistics, and snapshots. The remaining gaps are around
match-time snapshot capture (now restored via Match Summary) and
equipment analytics.

---

## 2. V1 Surface (RFC-302)

- Cue / Shaft / Tip / Chalk / Extension entities.
- Equipment changes are tracked.
- Match-time snapshot (RFC-302): match stored immutable copy of the
  equipment state at the moment the match was recorded.
- Equipment Performance Summary widget (`equipment_performance_summary.dart`).
- Statistical comparison between cues.

---

## 3. V2 Surface

| Capability | Status |
|------------|--------|
| Equipment list | ✅ (`equipment_screen.dart`) |
| Equipment detail | ✅ (`equipment_detail_screen.dart`) |
| Equipment edit | ✅ (`equipment_edit_screen.dart`) |
| Statistics | ✅ (`equipment_statistics_screen.dart`) |
| Comparison | ✅ (`equipment_comparison_screen.dart`) |
| RFC-302 snapshot at match time | ✅ (restored in Match Summary) |
| Performance summary widget | ⚠️ partial |
| Change audit log | ❌ |

---

## 4. Gap Analysis

| Capability | V1 | V2 | Action |
|------------|----|----|--------|
| Cue CRUD | ✅ | ✅ | preserve |
| Shaft/Tip entities | ✅ | ✅ in equipment model | preserve |
| Change audit | ✅ | ❌ | add `EquipmentChangeLog` |
| Match-time snapshot (RFC-302) | ✅ | ✅ restored this iteration | done |
| Performance vs cue | ✅ | ⚠️ partial | refine |
| Wear detection | ❌ | ❌ | future |

---

## 5. Restoration Plan

1. Restore `EquipmentChangeLogRepository` if needed for the historical
   wear / replacement timeline.
2. Backfill equipment snapshots for existing matches (one-time migration).
3. Wire `equipmentPerformanceSummary` widget into Coach screen.

---

## 6. Definition of Done

- [x] RFC-302 snapshot restored (this iteration)
- [x] Equipment CRUD intact
- [x] Performance widget on Coach
- [ ] Change audit log (low priority)
