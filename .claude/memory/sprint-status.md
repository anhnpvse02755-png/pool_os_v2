---
name: sprint-status
description: Sprint completion status tracker - Sprint-19 closed, next sprint TBD
metadata:
  type: project
---

**Cập nhật lần cuối:** 28/8/2026 (memory cũ dừng sai ở "Sprint-9 Planning")

## Completed

| Sprint | Focus | Closed |
|--------|-------|--------|
| 3A–3B | Engineering | Aug 6–7 |
| 4A–4C | Engineering | Aug 7 |
| 5A–5C | Knowledge Graph / Reasoning Chain / Decision Engine | Aug 7 |
| 6A–6B | Player Intelligence Model / Priority Engine | Aug 7 |
| 7A–7B | Conversation Engine / Coach Preview UI | Aug 7 |
| Sprint-8 | Match Recording → Coach AI | Aug 20 |
| Sprint-17 | Drill session / Training flow | Aug 24 |
| **Sprint-19** | **Minimalist Luxury UI redesign** | **Aug 28** |

## Sprint-19 (mới nhất)

Migrate toàn bộ presentation layer từ `AppTheme` cũ sang design tokens mới. Xem [[design-system-tokens]].

- ~50 file, +9,257 dòng
- `flutter analyze` sạch lỗi ✅
- Test Sprint-17 drill session: 15/15 pass ✅
- Commits: `f438cd3` (redesign) → `80e09e8` (3 regression) → `2e7b792` (fix CI base href)
- Đã push lên `origin/main`

## Đang mở

| Việc | Trạng thái |
|---|---|
| E2E Playwright | 🔴 Fail — xem [[e2e-playwright-accessibility]] |
| Sprint tiếp theo | 🟡 Chưa định hướng |

**Why:** Theo dõi sprint giúp không làm trùng việc và biết baseline nào đang đóng băng.

**How to apply:** Đọc file này trước khi plan sprint mới. Cập nhật bảng khi đóng một sprint.
