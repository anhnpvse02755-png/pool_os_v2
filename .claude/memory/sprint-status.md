---
name: sprint-status
description: Sprint tracker — Sprint-19 đóng 28/8; từ 9/9 đang chạy redesign kem ấm & xanh rêu, lô 3 xong
metadata:
  type: project
---

**Cập nhật lần cuối:** 11/9/2026

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
| Sprint-19 | Minimalist Luxury UI redesign | Aug 28 |

## Sau Sprint-19

- **Import từ điển kiến thức** (`d1f736f`, 8/9): knowledge.json 112 → 138 mục.
  `cat_rules` và `cat_equipment` trước rỗng nay có nội dung. Sửa kèm lỗi lệch
  ID làm hỏng liên kết drill→kiến thức ở production.
- **Sửa hạ tầng E2E** (`ce2391f`, 8/9): 5 pass → 22 pass. Xem
  [[e2e-playwright-accessibility]].

## Đang chạy: redesign "Kem ấm & Xanh rêu" (từ 9/9)

Nhánh `feat/warm-green-3bcde`, 13 commit trên `main`. Lô 1, 2, 3a–3e xong
(28/68 màn). **40 màn còn lại.** Chi tiết ở [[warm-green-redesign]].

Sức khoẻ tại 11/9/2026: `flutter analyze` **0 error** (216 info/warning, đều ở
`test/` và `tools/`) · `flutter test` **680/680 pass**.

## Đang mở

| Việc | Trạng thái |
|---|---|
| 22 commit chưa push | 🔴 `main` hơn `origin/main` 9 commit; `feat/warm-green-3bcde` chưa có upstream, hơn `main` 13 commit |
| `CLAUDE.md` rỗng | 🔴 File tồn tại nhưng 0 byte — không có project instruction nào được nạp mỗi session |
| Supabase wiring | 🔴 Cả 10 repository provider đều trả về `Local*`; chưa nhánh nào dùng `SupabaseConfig.client`. Dữ liệu hoàn toàn ở SharedPreferences |
| Bản web deploy | 🟡 `deploy-web.yml` không truyền `--dart-define` Supabase → chạy offline; bấm Đăng nhập hiện lỗi kỹ thuật thô |
| Banner "offline-only" | 🟡 Mô tả trong header `supabase_config.dart` nhưng không tồn tại trong `lib/presentation` |
| 4 test `test.fixme` | 🟡 UI chưa tồn tại (Skip onboarding, Home→Play, Training→path/coach) |
| `BACKLOG.md` | 🟡 Ghi 2/8/2026, đã lệch thực tế |
| `Understand-Anything` | 🟡 Là gitlink nhưng không có mapping trong `.gitmodules` → luôn hiện dirty |

**Why:** Theo dõi sprint giúp không làm trùng việc và biết baseline nào đang
đóng băng.

**How to apply:** Đọc file này trước khi plan sprint mới. Cập nhật bảng khi
đóng một lô hoặc một sprint.
