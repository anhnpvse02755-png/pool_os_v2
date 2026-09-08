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

## Sau Sprint-19 (8/9/2026)

- **Import từ điển kiến thức** (`d1f736f`): knowledge.json 112 → 138 mục, phủ
  đủ 36 mục của Tu-Dien-Kien-Thuc-Billiard-Pool.md. `cat_rules` và
  `cat_equipment` trước rỗng nay có nội dung. Sửa kèm lỗi lệch ID làm hỏng
  liên kết drill→kiến thức ở production.
- **Sửa hạ tầng E2E** (`ce2391f`): 5 pass → 22 pass. Xem
  [[e2e-playwright-accessibility]].

## Đang mở

| Việc | Trạng thái |
|---|---|
| Supabase wiring | 🔴 Cả 10 repository provider đều trả về `Local*`; chưa nhánh nào dùng `SupabaseConfig.client`. Dữ liệu hoàn toàn nằm ở SharedPreferences |
| Bản web deploy | 🟡 `deploy-web.yml` không truyền `--dart-define` Supabase → chạy offline; bấm Đăng nhập hiện lỗi kỹ thuật thô |
| Banner "offline-only" | 🟡 Được mô tả trong header `supabase_config.dart` nhưng không tồn tại trong `lib/presentation` |
| 4 test `test.fixme` | 🟡 UI chưa tồn tại (Skip onboarding, Home→Play, Training→path/coach) |
| BACKLOG.md | 🟡 Ghi 2/8/2026, đã lệch thực tế (vẫn ghi Testing chưa làm dù có 49 file test) |
| Sprint tiếp theo | 🟡 Chưa định hướng |

**Why:** Theo dõi sprint giúp không làm trùng việc và biết baseline nào đang đóng băng.

**How to apply:** Đọc file này trước khi plan sprint mới. Cập nhật bảng khi đóng một sprint.
