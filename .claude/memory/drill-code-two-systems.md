---
name: drill-code-two-systems
description: Hai hệ mã bài tập song song — knowledge graph (BANK_SHOT…) và DrillLibrary (BT01–BT24); mọi điều hướng tới màn tập phải đi qua resolveDrillCode
metadata:
  type: project
---

App có **hai hệ mã bài tập** không trùng nhau:

| Hệ | Ví dụ | Dùng ở đâu |
|---|---|---|
| Knowledge graph (`DrillNode.code`) | `BANK_SHOT`, `POSITION_CONTROL`, `STUN_SHOT` | nguồn ra quyết định: lộ trình, điểm yếu, buổi tập đề xuất |
| `DrillLibrary` (`Drill.code`) | `BT01`…`BT24` | mọi màn TẬP thật (`DrillSessionScreen`) |

Cầu nối là `lib/knowledge/drill_code_bridge.dart` → `resolveDrillCode()`.
**Điều hướng tới `/training/session/new?drill=…` bằng mã chưa resolve sẽ ra màn
lỗi "Bài tập với mã ... không tồn tại".**

Tháng 9/2026 cầu nối mới phủ 2/13 DrillNode; 11 bài còn lại dẫn thẳng vào màn
lỗi. Nay đã phủ đủ, và `test/knowledge/drill_code_bridge_coverage_test.dart`
duyệt MỌI DrillNode để chặn việc thêm node mới mà quên map.

**Why:** Hai hệ sinh ra ở hai thời điểm khác nhau (knowledge graph cho Coach AI,
DrillLibrary cho màn tập) và không ai ép chúng khớp. Lỗi chỉ lộ khi bấm đúng bài
không map được, nên nó sống sót qua nhiều vòng kiểm thủ công.

**How to apply:** Thêm `DrillNode` mới thì thêm luôn một `case` trong
`v1ToV2Code`, nếu không test phủ sẽ đỏ. Thấy màn "bài tập không tồn tại" thì
nghi ngay mã chưa resolve chứ đừng nghi `DrillLibrary` thiếu bài. Xem
[[kg-service-duality]] cho cái bẫy trùng tên class ở cùng khu vực.
