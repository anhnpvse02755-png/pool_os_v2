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

## Tach Stop/Follow/Draw va danh so lai (16/9/2026)

`knowledge_graph_service` tung khai khoa `'BT07'` **ba lan** trong cung mot map
literal — Stop Ball, Follow Shot, Draw Shot. Dart lay ban cuoi, nen hai bai bi
nuot im lang va ban song sot con khai chinh no lam dieu kien tien quyet. Cung
lan thay the hang loat do con de lai `nextDrills: ['BT07','BT07','BT07']` o bon
node khac, va mot chu thich trong `drill_code_bridge` ghi "e.g. BT07" o CA HAI
ve cua cau "V1 dung ma X, V2 dung ma Y".

Quyet dinh (nguoi dung chot): **tach ba bai, khong gop** — stop/follow/draw la
ba ky nang nen tang cua nguoi moi, gop lai thi he goi y chi noi duoc "hong o
bai gop" chu khong noi duoc "hong o draw".

Da danh so lai: **BT08..BT24 doi thanh BT10..BT26**, BT08/BT09 danh cho Follow
va Draw. Thu vien tu 24 len **26 bai**. Anh huong 8 tep (~300 tham chieu), gom
ca `assets/knowledge/knowledge.json` va cau noi.

Cau noi nay: `STOP → BT07 · FOLLOW → BT08 · DRAW → BT09`, `STUN_SHOT → BT07`.

Hai danh sach `prerequisites: ['BT07','BT07']` (SAFETY_PLAY, BREAK_SHOT) khong
khoi phuc duoc y goc — cho thu hai von la bai nao thi khong biet — nen chi khu
trung lap va ghi chu ngay tai cho.

Luat chan tai pham: `test/knowledge/drill_codes_integrity_test.dart` (ma duy
nhat, danh so lien tuc khong thung lo, khong node tu tro vao chinh no, moi ma
duoc nhac toi deu ton tai, knowledge.json khong tro vao bai ma).
