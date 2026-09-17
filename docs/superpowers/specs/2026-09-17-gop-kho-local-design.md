# Gộp hai kho local & hợp nhất bản ghi buổi tập

**Ngày:** 17/9/2026
**Trạng thái:** đã duyệt thiết kế, chờ lập plan

---

## 1. Vì sao có việc này — và vì sao tiền đề ban đầu sai

`BACKLOG.md` (mục Sprint 5) ghi việc này là *"Hợp nhất 2 kho local —
`LocalStorageService` và `LocalStorageDataSource` đang đụng key
`knowledge_progress`"*, và xếp nó là rủi ro dữ liệu.

**Khảo sát cho thấy key đụng nhau đó không phải bug đang sống.** Không bên nào
GHI vào `knowledge_progress`:

| Method | Caller |
|---|---|
| `LocalStorageService.saveKnowledgeProgress` | 0 |
| `LocalStorageService.markKnowledgeAsRead` | 0 |
| `LocalStorageDataSource.saveKnowledgeProgress` | 0 |
| `LocalStorageDataSource.getKnowledgeProgress` | 0 |

Đường duy nhất còn sống là **đọc**: `KnowledgeProgressSection` (màn Profile) →
`cacheRepository.getKnowledgeProgress()` → `LocalStorageService`
(`cache_repository.dart:44-45`). Hai kho khai trùng một key nhưng chưa ai bấm
cò.

**Bug thật nằm ở chỗ khác và không có trong BACKLOG:** buổi tập đang được ghi
vào **hai bản ghi tách rời**, writer và reader không giao nhau.

> **Đính chính 17/9/2026 (sau khi thi hành Task 3).** Bản spec đầu tiên tả sai
> mức độ, ghi rằng hai bên "không thấy của nhau". Đo lại trong mã thì nặng hơn
> thế: `LocalDrillRepository.saveTrainingSession()` có **0 nơi gọi trong
> `lib/`**, nên `training_history` **chưa bao giờ được ghi** một lần nào. Không
> có chiều ngược lại để mà mất — mọi bên đọc nó luôn nhận danh sách rỗng, từ
> ngày nó ra đời. Bảng dưới đã sửa theo thực đo.

| Key | Ai ghi | Ai đọc |
|---|---|---|
| `drill_sessions` | `training_provider` (`addSession`) | chỉ `training_provider` |
| `training_history` | **không ai** — `saveTrainingSession()` tồn tại nhưng 0 nơi gọi | `dashboard_provider`, `coach_ai_provider`, `repository_providers`, `training_history_screen`, `trend_dashboard_screen`, `unified_timeline_screen`, `SessionBuilderService` |

Cùng là "một buổi tập đã xong". Hệ quả thật: buổi tập ghi qua
`training_provider` chỉ nằm ở `drill_sessions` và chỉ chính nó đọc được; còn
`training_history` — thứ mà dashboard, Coach và ba màn lịch sử đều đọc — **rỗng
vĩnh viễn**. Giao diện lịch sử tập không phải là "thiếu vài buổi", nó chưa bao
giờ có gì.

Đây là lý do thật sự để làm việc này. Key đụng nhau chỉ là triệu chứng bề mặt
của cùng một nguyên nhân: hai tầng lưu trữ song song mọc lên ở hai thời điểm
khác nhau.

---

## 2. Mục tiêu

1. Còn **một** kho local duy nhất: `LocalStorageDataSource`.
2. Buổi tập có **một** model, **một** key, **một** đường ghi — mọi bên đọc thấy
   cùng dữ liệu.
3. Mọi lượt ghi buổi tập đi qua `DrillRepository`, để Sprint 3 (nối Directus)
   chỉ phải đổi một dòng trong `repository_providers.dart`.

### Ngoài phạm vi

- **Không** sửa `lib/core/models/training_session.dart` — nó là khái niệm KHÁC
  (buổi tập chứa nhiều `DrillRun`), không phải bản trùng.
- **Không** sửa `TrainingSessionData` ở `lib/knowledge/player_intelligence.dart`
  — đầu vào riêng của Coach AI.
- **Không** nối Directus. Việc đó là Sprint 3.
- **Không** sửa lỗi "tiến độ kiến thức luôn rỗng" (xem mục 7).

---

## 3. Hiện trạng

### Hai kho

| | `LocalStorageService` | `LocalStorageDataSource` |
|---|---|---|
| Đường dẫn | `lib/core/services/` | `lib/data/datasources/local/` |
| Dòng | 224 | 349 |
| Số key | 7 | 18 |
| Tiêu thụ | `coach_provider`, `training_provider`, `cache_repository` | 8 repo impl + `warmup_provider` |

Cả hai đều `init()` trong `main.dart:74-75`.

Chỉ **một** key trùng tên: `knowledge_progress`. Các key khác đều khác nhau
(`settings` vs `app_settings`, `user_profile` vs `player_data`…).

`LocalStorageService` có 21 method, **11 cái không ai gọi**: `getMatchRecords`,
`saveMatchRecord`, `updateMatchRecord`, `deleteMatchRecord`, `getUserProfile`,
`saveUserProfile`, `getSettings`, `saveSettings`, `getStats`,
`saveKnowledgeProgress`, `markKnowledgeAsRead`.

Mười method còn sống: `getDrillSessions`, `saveDrillSession`,
`updateDrillSession`, `deleteDrillSession`, `getKnowledgeProgress`,
`get`/`save`/`clearLatestMatchAnalysis`, `get`/`savePlayerIntelligence`.

Trong đó `updateDrillSession` và `deleteDrillSession` **chết gián tiếp**:
caller duy nhất của chúng là `TrainingNotifier.updateSession`/`deleteSession`,
mà hai method đó lại không ai gọi (xem 5.3).

### Ba class trùng tên `TrainingSession`

| Định nghĩa | Trường | Đi vào |
|---|---|---|
| `core/providers/training_provider.dart:33` (inline) | id, drillCode, drillName, level, score, **shotsAttempted**, shotsMade, duration, **date**, **improvement** | `drill_sessions` |
| `data/models/training_session.dart:2` | id, drillCode, drillName, level, score, shotsMade, **shotsMissed**, duration, **completedAt** | `training_history` |
| `core/models/training_session.dart:2` | id, playerId, startedAt, completedAt, durationMinutes, notes, **drillRuns[]** | khái niệm khác, không đụng |

Hai bản đầu chuyển đổi được: `shotsAttempted = shotsMade + shotsMissed`,
`date` ↔ `completedAt`. `improvement` chỉ có ở bản inline.

### Interface đã sẵn sàng

`DrillRepository` (`lib/data/repositories/drill_repository.dart`) **đã có đủ**:

```dart
Future<List<TrainingSession>> getTrainingHistory({int? limit});
Future<void> saveTrainingSession(TrainingSession session);
```

Hai method này dùng đúng model đích. **Không phải mở rộng interface.**

---

## 4. Thiết kế — Phần A: gộp kho

Chuyển ba nhóm key còn sống sang `LocalStorageDataSource`, **giữ nguyên tên
key** nên không cần di trú dữ liệu:

| Key | Method | Ai dùng |
|---|---|---|
| `latest_match_analysis` | get / save / clear | `coach_provider` |
| `player_intelligence` | get / save | `coach_provider` |
| `knowledge_progress` | chỉ `get` | `cache_repository` |

Key `drill_sessions` **không chuyển** — nó biến mất ở phần B.

**Xoá:**

- File `lib/core/services/local_storage_service.dart`
- Dòng `LocalStorageService.init()` ở `main.dart:75`
- 11 method chết (không port sang kho mới)
- Cặp `get/saveKnowledgeProgress` sẵn có của `LocalStorageDataSource` — không ai
  gọi; giữ đúng một đường đọc sau khi nhận method từ `LocalStorageService`

**Sửa:** `cache_repository.dart:44-45` trỏ sang `LocalStorageDataSource`.

---

## 5. Thiết kế — Phần B: hợp nhất bản ghi buổi tập

### 5.1 Model

`data/models/training_session.dart` là `TrainingSession` **duy nhất**. Thêm một
getter tính toán:

```dart
int get shotsAttempted => shotsMade + shotsMissed;
```

Đây là dữ liệu **dẫn xuất**, không phải trường lưu trữ. Nhờ nó, hơn 20 chỗ đọc
`session.shotsAttempted` trong `coach_provider` không phải sửa dòng nào.

Xoá class `TrainingSession` khai inline ở `training_provider.dart:33`.

**Bỏ trường `improvement`.** Đã truy toàn repo: nó chỉ xuất hiện ở khai báo
(`training_provider.dart:55`) và `fromJson` (`:69`) của chính class đó. Không
nơi nào đọc.

### 5.2 Đổi tên tại chỗ gọi

`session.date` → `session.completedAt`, **6 chỗ**:

| File | Dòng |
|---|---|
| `coach_provider.dart` | 168, 242, 746, 759 |
| `dashboard_provider.dart` | 265 |
| `training_provider.dart` | 170 |

### 5.3 Đường ghi

`TrainingNotifier` thôi chạm `LocalStorageService`, đi qua `DrillRepository`:

```
_loadData()   → repo.getTrainingHistory()
addSession()  → repo.saveTrainingSession()
```

**Xoá `updateSession` và `deleteSession`** — đã truy, không ai gọi. Chỉ
`addSession` được dùng, từ `drill_session_screen.dart:245`. Nhờ vậy không phải
thêm method nào vào `DrillRepository`.

Kết quả: **một key `training_history`, một đường ghi, mọi bên đọc cùng dữ liệu.**

### 5.4 Khe test cho `TrainingNotifier`

Hiện tại `TrainingNotifier()` không nhận `ref` và gọi `_loadData()` bất đồng bộ
ngay trong constructor (`training_provider.dart:88`). Muốn đi qua repository thì
phải nhận `ref` — và đúng lúc đó nó vấp lại cái bẫy đã ghi trong
`.claude/memory/poolos.md` mục 9 về `CoachStateNotifier`: trạng thái test vừa
đặt xong đã bị ghi đè.

Mở khe y hệt, cho nhất quán:

```dart
TrainingNotifier(this._ref, {bool autoStart = true, TrainingState? initialState})
```

Mặc định giữ nguyên hành vi cũ, mã chạy thật không đổi.

---

## 6. Kiểm chứng

Làm theo TDD — viết test đỏ trước, rồi mới sửa.

**Test hồi quy cho đúng cái bug:** buổi tập lưu qua `trainingNotifier.addSession()`
phải hiện ra ở `drillRepo.getTrainingHistory()` **và** ở `todayGoalsProvider`.
Hôm nay test này phải **ĐỎ** — đó là bằng chứng bug có thật. Nếu nó xanh ngay
từ đầu thì giả thuyết sai, phải dừng lại xem lại.

Ba file test cần cập nhật:

- `test/unit/coach_integration_test.dart`
- `test/unit/sprint14_product_verification_test.dart`
- `test/widget/today_goals_clickable_test.dart`

Chốt bằng `flutter analyze` (0 error) và `flutter test` toàn bộ suite.

**Theo bài học đã ghi trong memory mục 9:** kiểm test mới bằng **đột biến** —
tắt nhánh đang kiểm, xem test có đỏ không — trước khi tin nó. Một test khẳng
định hằng số thì vẫn xanh khi đường đi thật còn hỏng.

---

## 7. Phát hiện kèm theo — KHÔNG sửa trong phạm vi này

**Mục "Tiến độ kiến thức" ở màn Profile vốn đã luôn rỗng.** Không có gì ghi vào
`knowledge_progress`, nên `KnowledgeProgressSection` luôn đọc ra `{}`. Sau khi
xoá `markKnowledgeAsRead` và `saveKnowledgeProgress`, tình trạng **không đổi** —
nó đã như vậy từ trước.

Ghi lại đây để quyết định riêng: hoặc nối `markKnowledgeAsRead` vào màn đọc
kiến thức, hoặc gỡ hẳn mục đó khỏi Profile. Không gộp vào đợt này vì đó là
quyết định sản phẩm, không phải refactor.

---

## 8. Rủi ro

| Rủi ro | Giảm nhẹ |
|---|---|
| Đổi constructor `TrainingNotifier` làm vỡ test | Khe `autoStart`/`initialState` giữ mặc định như cũ; 3 file test đã xác định trước |
| `dashboard_provider.dart:265` đang ép kiểu `session.date as DateTime?` | Xem lại kiểu thật tại đó khi sửa, đừng đổi tên máy móc |
| Bỏ sót một chỗ đọc `shotsAttempted` | Getter dẫn xuất giữ nguyên tên nên không có chỗ nào phải đổi |
| Dữ liệu test cũ ở key `drill_sessions` mồ côi | Chấp nhận — chưa có người dùng thật, chỉ máy dev |

---

## 9. Vì sao thiết kế này, không phải cách khác

Đã cân nhắc hai phương án thay thế:

**Giữ hai key, ghi vào cả hai.** Thay đổi ít nhất, không phải sửa bên đọc nào.
Bị loại: không sửa bug mà dán băng lên nó, dữ liệu nhân đôi, và tới lúc nối
mạng thì phải đồng bộ hai bản ghi.

**Hợp nhất model nhưng để `training_provider` gọi thẳng `LocalStorageDataSource`.**
Diff nhỏ hơn. Bị loại: giữ nguyên chỗ phạm tầng — provider thò tay vào
datasource, bỏ qua repository. Tới Sprint 3 sẽ có hai đường ghi phải sửa thay
vì một, tức trả giá lần nữa ở đúng chỗ vừa đụng.
