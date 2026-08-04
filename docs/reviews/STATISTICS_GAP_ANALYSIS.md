# Statistics Module — V1 vs V2 Gap Analysis

**Date:** 2026-08-02

---

## 1. Executive Summary

V2 has a Statistics screen on Home but it surfaces only aggregate
counts (sessions, minutes, win rate). The richer V1 view — per-skill
ratings, per-equipment performance, weekly deltas — is missing.

---

## 2. V1 Surface

- Player career aggregates (matches, wins, ELO).
- Per-skill rating history (line chart).
- Per-equipment performance summary widget.
- Per-drill personal-best + history.
- Streak / heatmap.

---

## 3. V2 Surface

| Capability | Status |
|------------|--------|
| Totals (sessions / minutes / matches / wins) | ✅ (`Home`) |
| Win rate | ✅ |
| Per-skill ratings (line chart) | ⚠️ partial |
| Per-equipment performance | ⚠️ partial |
| Streak | ❌ |
| Heatmap | ❌ |

---

## 4. Gap Analysis

| Capability | V1 | V2 | Action |
|------------|----|----|--------|
| Career aggregates | ✅ | ✅ | preserve |
| Skill rating chart | ✅ | ⚠️ | restore |
| Equipment perf summary | ✅ | ⚠️ | restore on Coach |
| Streak | ✅ | ❌ | add `streak_widget.dart` |
| Heatmap | ✅ | ❌ | future |

---

## 5. Restoration Plan

1. Lift aggregates from `LocalMatchRepository.getPlayerAggregates()` (now
   implemented).
2. Surface skill-rating chart on Statistics screen.
3. Add streak widget.

---

## 6. Definition of Done

- [ ] Per-skill line chart
- [ ] Streak widget
- [ ] Heatmap (low priority)
