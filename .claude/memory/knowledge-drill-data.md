---
name: knowledge-drill-data
description: Thư viện kiến thức & bài tập — nguồn thật, cách sinh lại, và ba hệ chết đã gỡ
metadata:
  type: project
---

Dọn sạch 11/9/2026. Trước đó có **nhiều nguồn song song**, phần lớn là chết.

## Nguồn thật (chỉ hai)

| Thư viện | Nguồn | Đích | Số mục |
|---|---|---|---|
| Kiến thức | `Tu-Dien-Kien-Thuc-Billiard-Pool.md` | `assets/knowledge/knowledge.json` | 36 |
| Bài tập | `new knowledge/Danh-Sach-Bai-Tap-Billiard.md` | `lib/core/utils/drills_library.dart` | 24 (BT01–BT24) |

**Bài tập SINH TỰ ĐỘNG** bằng `tools/gen_drills.py` — sửa file .md rồi chạy lại,
đừng sửa tay `drills_library.dart`.

## Liên kết hai chiều — từng hỏng, nay liền mạch

- drill → kiến thức: **24/24** giải được, 0 gãy.
- kiến thức → drill: **33/36**. Ba mục chưa có bài: `kn_aiming_method_selection`,
  `kn_masse_shot`, `kn_rules_one_pocket`.

**Lỗi cũ đáng nhớ:** `drill.knowledgeIds` từng dùng quy ước thứ ba (`'aiming'`,
`'bridge'`) không khớp cả `kn_*` lẫn `bridge.*` — hỏng **0/50**. Màn chi tiết bài
tập vẫn vẽ chip bấm được, điều hướng tới ID không tồn tại. Test có kiểm nhưng chỉ
`print` cảnh báo thay vì fail nên nó trôi qua nhiều sprint.

## Thang cấp độ: 50 cú mỗi cấp, tỉ lệ tăng dần

Tính bằng phân phối nhị thức. Ở n=10 **không** ngưỡng nào tách được người 80%
khỏi người 90% — cổng "9/10" để lọt 37,6% người chỉ đạt 80%.

| Hạng | Cấp 1 → 2 → 3 |
|---|---|
| A (đánh thẳng, ngắm, tư thế, luật) | 27/50 → 35/50 → 42/50 |
| B (vị trí, safety, english) | 22/50 → 30/50 → 37/50 |
| C (bank, jump, kick) | 8/30 → 12/30 → 16/30 |

Hạng C dùng **30 cú** — đánh 50 cú nhảy bi liên tục là kiểm tra thể lực. Giá phải
trả: người chưa đủ sức lọt tăng 13% → 23%.

Ngưỡng đặt **dưới** tỉ lệ mục tiêu để chừa biến động: đòi đúng 90% từ người trung
bình 90% thì họ trượt gần một nửa số lần.

## Không bịa dữ liệu

Bài nào nguồn không nêu ngưỡng số → `passCount = 0`, `criteriaVi` giữ nguyên văn.
Mục **"Lỗi thường gặp" hiện để RỖNG** (nguồn chưa có) và UI ẩn hẳn mục đó —
chủ dự án sẽ bổ sung vào file .md sau. Trước đây chỗ này rơi về `_genericMistakes`
("Đánh quá mạnh hoặc quá nhẹ") dùng chung cho mọi bài.

## Đã gỡ, đừng dựng lại

`knowledgeArticlesVi` · `DrillService` · `DrillLibraryService` (cả hai nạp
`assets/data/drills_data.json` — **file không tồn tại**, lỗi bị catch nuốt) ·
`LocalKnowledgeRepository` · 7 provider chết · 102 mục kiến thức khuôn rỗng.

**Giữ lại:** `drillRepositoryProvider`, `trainingHistoryProvider` — phục vụ tiến
độ người dùng tự sinh, có nơi dùng thật.

## Hai bộ từ vựng độ khó song song (nợ chưa xử)

UI bài tập switch trên `easy/medium/hard/expert`; kiến thức dùng
`beginner/intermediate/advanced/expert`. Generator phát ra bộ của UI bài tập.
Chưa hợp nhất — cần một task riêng.

**Why:** Cả hai thư viện từng có nhiều nguồn giả, và liên kết giữa chúng hỏng
hoàn toàn mà mọi tầng đều báo "xanh".

**How to apply:** Muốn đổi bài tập thì sửa file .md rồi chạy `tools/gen_drills.py`.
Xem [[warm-green-redesign]] cho tầng giao diện.
