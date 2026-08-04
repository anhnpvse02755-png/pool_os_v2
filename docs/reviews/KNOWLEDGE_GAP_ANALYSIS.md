# Knowledge Module — V1 vs V2 Gap Analysis

**Date:** 2026-08-02

---

## 1. Executive Summary

Knowledge Base is well-covered in V2 with list + detail screens + slug
routing. The gap is in cross-linking and progress tracking.

---

## 2. V1 Surface

- Article repository with hierarchical categories.
- Search + tags + difficulty.
- Article ↔ Drill graph: each article linked to drill(s).
- Reader progress: read % + read time + last-seen.
- Bookmark + favorite collections.

---

## 3. V2 Surface

| Capability | Status |
|------------|--------|
| Article list | ✅ (`knowledge_screen.dart`) |
| Article detail | ✅ (`knowledge_detail_screen.dart`) |
| Slug routing | ✅ via `/training/knowledge/:slug` |
| Categories | ✅ |
| Search | partial |
| Tags | partial |
| Reader progress | ❌ only `LocalStorageService.markKnowledgeAsRead` |
| Article ↔ Drill link | ❌ |
| Bookmark | ❌ |

---

## 4. Gap Analysis

| Capability | V1 | V2 | Action |
|------------|----|----|--------|
| Article repository | ✅ | ✅ | preserve |
| Categories | ✅ | ✅ | preserve |
| Difficulty filter | ✅ | partial | add |
| Read % progress | ✅ | ❌ | add scroll listener |
| Read time | ✅ | ❌ | add timestamp tracking |
| Tags | ✅ | partial | surface tags in UI |
| Article ↔ Drill link | ✅ | ❌ | add `relatedDrills` |
| Bookmark | ✅ | ❌ | add bookmark flag |
| Favorite collections | ✅ | ❌ | add collection list |
| Knowledge graph | ✅ | ❌ | future |

---

## 5. Restoration Plan

1. Extend `lib/data/models/knowledge.dart` with:
   - `tags: List<String>`
   - `relatedDrills: List<String>`
   - `relatedArticles: List<String>`
   - `readPercent`, `lastReadAt`, `bookmarked`.
2. Add `KnowledgeProgressRepository`.
3. Wire bookmark toggle on article screen.
4. Add "Related drills" CTA.
5. Restore tags filter on knowledge list.

---

## 6. Definition of Done

- [ ] Knowledge model has tags, relatedDrills, bookmark.
- [ ] KnowledgeProgress repository.
- [ ] Bookmark UX.
- [ ] Related drills section.
- [ ] Tags filter.
- [ ] Playwright test for read progress + bookmark.
