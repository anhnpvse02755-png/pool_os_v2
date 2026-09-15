---
name: kg-service-duality
description: Hai class KnowledgeGraphService trùng tên ở lib/domain và lib/knowledge — chọn nhầm provider là lỗi argument_type_not_assignable
metadata:
  type: project
---

Repo có **hai** class tên `KnowledgeGraphService` ở hai đường dẫn khác nhau, và
analyzer báo lỗi kiểu rất khó đọc khi trộn nhầm (`argument_type_not_assignable`
với hai vế trông y hệt nhau, chỉ khác đường dẫn trong ngoặc).

| Class | Provider | Khởi tạo |
|---|---|---|
| `lib/domain/services/knowledge_graph_service.dart` | `knowledgeGraphServiceProvider` (`repository_providers.dart:182`) | nhận `cacheRepositoryProvider` |
| `lib/knowledge/knowledge_graph_service.dart` | `knowledgeGraphProvider` (`coach_provider.dart:36`) | singleton `.instance`, constructor private |

Bên tiêu thụ chính — `SessionBuilderService`, `CoachProvider`, `coach_screen`,
`player_intelligence_service` — đều dùng **bản `lib/knowledge/`**, tức
`knowledgeGraphProvider`. Tên provider dài hơn (`…ServiceProvider`) lại là bản
ít dùng hơn; đó chính là cái bẫy.

**Why:** Tên class giống hệt nên IDE tự động import nhầm, và thông báo lỗi của
Dart không nêu rõ vế nào là vế cần.

**How to apply:** Cần drill/skill/tactic node → `knowledgeGraphProvider`. Thấy
lỗi gán `KnowledgeGraphService` sang `KnowledgeGraphService`, đọc đường dẫn
trong ngoặc trước khi sửa import. Xem thêm [[coach-design]].
