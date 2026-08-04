# Profile Module — V1 vs V2 Gap Analysis

**Date:** 2026-08-02

---

## 1. Executive Summary

V2 Profile surface is largely consistent with V1: profile, edit, settings,
equipment, preferences. Gaps are limited to integration with the Player
State / Knowledge progress surfaces.

---

## 2. V1 Surface

- Profile CRUD.
- Player State view (confidence / focus / pressure / fatigue).
- Knowledge progress view.
- Avatar / locale / theme.

---

## 3. V2 Surface

| Capability | Status |
|------------|--------|
| Profile view | ✅ |
| Profile edit | ✅ |
| Settings | ✅ |
| Equipment | ✅ (covered separately) |

---

## 4. Gap Analysis

| Capability | V1 | V2 | Action |
|------------|----|----|--------|
| Player State | ✅ | ❌ | add `player_state_screen.dart` |
| Knowledge progress | ✅ | partial | surface on Profile |
| Locale switcher | ✅ | ✅ | preserve |
| Theme switcher | ✅ | ✅ | preserve |
| Avatar | ✅ | ✅ | preserve |
| Avatar upload | ✅ | ❌ | future |

---

## 5. Restoration Plan

1. Add `player_state_screen.dart` showing aggregated mental + physical
   axes from `LocalMatchRepository`.
2. Add `knowledge_progress_section.dart` to Profile.

---

## 6. Definition of Done

- [x] Profile CRUD intact
- [x] Settings intact
- [x] Equipment intact
- [ ] Player State screen
- [ ] Knowledge progress section
