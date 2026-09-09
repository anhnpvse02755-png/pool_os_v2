# PoolOS v2 — Backlog & Nguồn sự thật

**Cập nhật:** 2026-09-09
**Vai trò:** Đây là **nguồn sự thật duy nhất** về trạng thái dự án. Mọi sprint
phải đọc file này trước.

---

## Bộ trạng thái

| Status | Ý nghĩa |
|---|---|
| ✅ **VERIFIED** | Đã kiểm chứng bằng code / test / runtime |
| 🟢 **IMPLEMENTED** | Có implementation nhưng chưa full verification |
| 🟡 **BACKEND READY** | Backend có, app chưa nối |
| 🔴 **BLOCKED** | Có blocker kiến trúc / security |
| ⬜ **TODO** | Chưa làm |
| ❌ **FALSE DONE** | Tracker cũ ghi Done nhưng thực tế chưa đạt |

**Cột "Bằng chứng"** ghi rõ trạng thái dựa trên đâu. `runtime` = đã chạy thật
và quan sát được; `test` = có test tự động phủ; `code` = đã đọc code xác nhận
tồn tại và không phải placeholder. Độ tin cậy giảm dần theo thứ tự đó — đừng
coi `code` ngang với `runtime`.

> **Vì sao file này được viết lại.** Bản 02/08 chứa cả false positive
> (Community ghi Done nhưng leaderboard là chữ cứng) lẫn false negative
> (Testing ghi chưa làm nhưng có 473 test). Nó cũng ghi khống 3 route không
> tồn tại và tuyên bố "Overall Progress 99.9%" trong khi app chưa nối backend.
> Tracker sai kiểu này khiến agent **làm lại thứ đã có** hoặc **bỏ qua thứ
> thực sự thiếu**.

---

## 🎯 Thứ tự sprint đã chốt

Không làm sync engine trước. Ownership phải chốt trước, nếu không sync sẽ
khuếch đại rủi ro rò rỉ dữ liệu.

| # | Sprint | Trạng thái đầu vào |
|---|---|---|
| 1 | **Chốt Row-Level Security / ownership trên Directus** — spike xong 09/09: nguyên nhân là license enforcement của Directus 12, gỡ được **miễn phí** bằng Open Innovation Grant. **Đang chờ người đăng ký lấy license key.** | 🔴 BLOCKED |
| 2 | **Nối Authentication app → Directus**, rồi gỡ `supabase_flutter` | 🟡 BACKEND READY |
| 3 | **Nối Drill Progress** — vertical slice đầu tiên chứng minh app đã online | 🟡 BACKEND READY |
| 4 | **Nối các repository còn lại** theo luồng người dùng: auth → profile → training → progress → match → analytics. **Không sửa 10 repository một lúc** | ⬜ TODO |
| 5 | **Drift + Sync Engine** — thiết kế local-first + sync, KHÔNG biến Directus thành dependency bắt buộc cho mọi thao tác | ⬜ TODO |
| 6 | **Community làm thật** | ❌ FALSE DONE |

---

## 🔴 BLOCKED — chặn sprint 5, phải xử lý ở sprint 1

| Việc | Bằng chứng |
|---|---|
| **Row-Level Security / ownership** | runtime |

Directus bản này khoá bộ lọc quyền theo chủ sở hữu. Đã cô lập bằng thực nghiệm:

```
POST /permissions  read KHÔNG bộ lọc                          -> tạo được
POST /permissions  read CÓ  bộ lọc user_created=$CURRENT_USER -> "custom_permission_rules_enabled
                                                                  is a restricted resource"
```

Gate này còn chặn **mọi quyền tuỳ chỉnh trên collection hệ thống** (`directus_*`),
kể cả khi không có bộ lọc — nên `/users/me` trả toàn `null`.

**Hệ quả hiện tại:** 24 quyền đều không lọc → **mọi người chơi đọc/sửa được dữ
liệu của nhau.** Chấp nhận tạm vì chưa có người dùng thật.

**Đã vòng được một phần:** `DirectusSession.userId`/`roleId` giải mã từ payload
JWT thay vì gọi `/users/me`.

### ✅ Spike 09/09 đã tìm ra nguyên nhân — và cách gỡ miễn phí

**Không phải lỗi cấu hình.** Directus 12 đổi license từ BSL 1.1 sang **MSCL
1.0** và bật cưỡng chế hạn mức. Instance tự host mặc định chạy **Core tier**:

| Core tier | Hạn mức |
|---|---|
| Collection | **25** |
| Seat | 3 |
| Flows | 5 |
| Custom permission rules | ❌ không có |

Bằng chứng trên chính hệ thống — `GET /server/info` của **cả hai** instance:

```json
"license": { "source": null, "entitlements": {
    "production_enabled": true,
    "ai_translations_enabled": false,
    "display_powered_by": "DIRECTUS" } }
```

`source: null` = chưa cài license → Core tier. Điều này giải thích trọn vẹn
**cả hai** chặn đã gặp: `cms` 49 collection vượt hạn mức 25 → `LIMIT_EXCEEDED`;
và bộ lọc quyền không nằm trong entitlement Core.

**Cách gỡ: Open Innovation Grant — miễn phí.** Dành cho tổ chức dưới 5 triệu
USD doanh thu **và** dưới 50 nhân sự, **gỡ bỏ toàn bộ hạn mức**. Điều kiện:
đăng ký + giữ telemetry cơ bản bật. Một key dùng được 5 activation, gắn theo
`PUBLIC_URL`.

- [ ] **CHỜ NGƯỜI:** đăng ký tại https://directus.io/pricing/self-hosted và lấy
      license key. Đây là khai báo pháp lý về doanh thu/quy mô công ty — agent
      không làm thay được.
- [ ] Áp key **qua Studio** (validate ngay, sửa được sau). KHÔNG dùng biến môi
      trường `LICENSE_KEY`: Studio sẽ khoá editor, muốn đổi phải sửa env +
      restart.
- [ ] Kiểm chứng lại bằng đúng thí nghiệm đã cô lập ra vấn đề: tạo permission
      `read` có bộ lọc `user_created = $CURRENT_USER`
- [ ] Thay 24 quyền không lọc bằng quyền có lọc theo chủ sở hữu

**Nếu KHÔNG đủ điều kiện** thì mới quay lại 3 phương án tốn kém: license
thương mại · BFF proxy ép ownership · đổi tầng dữ liệu sang thứ có RLS thật.

Sources: [v12 license change](https://directus.com/resources/directus-v12-license-change) ·
[Licensing overview](https://directus.com/docs/licensing/overview) ·
[Self-hosted pricing](https://directus.io/pricing/self-hosted)

---

## 🔴 RỦI RO PRODUCTION — `cms` đang vượt hạn mức Core

| Việc | Bằng chứng |
|---|---|
| **`cms` có 49 collection, hạn mức Core là 25** | runtime |

`cms.nexthome.com.vn` cũng chạy Core tier (`license.source: null`) và đang vượt
**gần gấp đôi** hạn mức.

Cơ chế cưỡng chế của v12: instance vượt hạn mức được **ân hạn 30 ngày** kèm
nhắc nhở khi admin đăng nhập, **sau đó kích hoạt luồng xử lý bắt buộc ở lần
đăng nhập admin kế tiếp**. Không rõ đồng hồ đã chạy bao lâu.

- [ ] Áp cùng license key đó cho `cms` — gỡ luôn rủi ro này

Đây là phát hiện phụ của spike RLS, không nằm trong kế hoạch ban đầu, nhưng
ảnh hưởng tới hệ thống đang chạy thật nên đặt cùng mức ưu tiên.

---

## 🟡 BACKEND READY — server xong, app chưa nối

| Hạng mục | Bằng chứng | Ghi chú |
|---|---|---|
| Directus 12.3.1 chạy | runtime | https://poolos-api.kjdybl.easypanel.host |
| Đăng nhập / đăng ký | runtime | curl vào API thật, trả token |
| Quên mật khẩu đầu-cuối | runtime | HTTP 204 → mail vào Mailpit → link `/reset-password?token=…` đúng domain app |
| `DirectusClient` (Flutter) | test + runtime | 11 unit test + đối chiếu API thật: login, CRUD item, reset, logout, sai mật khẩu → `INVALID_CREDENTIALS/401` |
| 6 collection `poolos_*` | runtime | players, drill_sessions, drill_progress, matches, personal_bests, equipment |
| 24 quyền + role + policy | runtime | **không có bộ lọc** — xem mục BLOCKED |
| Mailpit | runtime | https://poolos-mail.kjdybl.easypanel.host |

**Chưa nối:** `AuthService` và `auth_provider` vẫn trỏ Supabase. **10/10
repository provider vẫn trả `Local*`.** Dữ liệu nằm trong SharedPreferences.

Chi tiết hạ tầng + 6 bẫy đã vấp: `.claude/memory/backend-directus.md`

---

## ✅ VERIFIED

| Hạng mục | Bằng chứng |
|---|---|
| Test suite: 473 unit/widget pass | test |
| E2E Playwright: 22 pass (44 tính cả Firefox) | test |
| `flutter analyze` 0 lỗi | test |
| Thư viện kiến thức 138 mục, 8 category | test + runtime |
| Deploy web có link test | runtime |
| Hash routing + semantics của Flutter Web | runtime |
| Training Plan `/coach/plan` | code |
| Onboarding 10 bước → `/home` | runtime |
| Welcome, Home, Training Center, Play, Profile, Coach Analysis | runtime |
| Knowledge screen + bộ lọc category | runtime |
| Drill categories, Quick/Friendly match, Match history | runtime |

> `Training Plan` gắn `code` chứ không `runtime`: màn hình có thật (490 dòng,
> `ref.watch(learningPathProvider)`, không phải placeholder) nhưng **chưa có
> test phủ và chưa từng được load trong phiên kiểm chứng nào**.

---

## 🟢 IMPLEMENTED — có code, chưa verify đầy đủ

| Hạng mục | Ghi chú |
|---|---|
| Coach: chat, timeline, survey | chưa load runtime, chưa có test |
| Skill Certification | `/training/certification` + `:certId` |
| Tournament: list, create, detail | |
| Notifications, Session Create, Black Box | |
| Training assessment, recommended | |
| Thư viện drill: 8 category, 56 bài | |
| Lưu trữ local có schema versioning + write verification | |
| Match recording, analytics, weekly/monthly report | |

---

## ❌ FALSE DONE — tracker cũ ghi Done, thực tế chưa đạt

| Hạng mục | Thực tế | Bằng chứng |
|---|---|---|
| **Community: Leaderboard** | Chữ cứng trong widget: `{'name': 'Nguyễn Văn A', 'points': 2500}` tại `community_screen.dart:62` và `:333`. Không có dữ liệu thật nào | code |
| **Community: Social features** | Post lưu trong SharedPreferences của **chính máy người đăng** — không ai thấy của ai | code |
| **Community: Player profiles** | Không có nguồn dữ liệu người chơi khác | code |
| Route `/play/league` | **Không tồn tại** trong `app_router.dart` | code |
| Route `/coach/recommendations` | **Không tồn tại** | code |
| Route `/training/session/result` | **Không tồn tại** | code |
| "Overall Progress 99.9%" | Đếm màn hình đã vẽ, che mất việc app chưa nối backend | — |

---

## ⬜ TODO

### Sprint 2 — Auth (một mạch liền)

- [ ] `AuthService` + `auth_provider` chuyển sang `DirectusClient`
- [ ] Nối màn Login / Register
- [ ] Màn `/reset-password` đọc token từ query string
- [ ] `TokenStore` lưu bền vững qua SharedPreferences
- [ ] Gỡ `supabase_flutter` khỏi 7 file + `pubspec.yaml`
- [ ] Build lại, đẩy nhánh `deploy-easypanel`, kiểm tra đăng nhập trên link thật

### Sprint 3 — Drill Progress (vertical slice)

- [ ] `DirectusDrillProgressRepository` thay `Local*` tương ứng
- [ ] Chứng minh app đã thực sự online

### Sprint 4 — Repository còn lại

Theo luồng người dùng, **từng cái một**:

- [ ] profile → `poolos_players`
- [ ] training → `poolos_drill_sessions`
- [ ] match → `poolos_matches`
- [ ] equipment → `poolos_equipment`
- [ ] analytics → `poolos_personal_bests`

### Sprint 5 — Local-first + Sync

- [ ] Hợp nhất 2 kho local — `LocalStorageService` và `LocalStorageDataSource`
      đang **đụng key `knowledge_progress`**
- [ ] Đưa drift vào (đã spike: chạy được cả 6 nền tảng kể cả web, cần 2 asset
      `sqlite3.wasm` + `drift_worker.js` ~1.1 MB trong `web/`)
- [ ] Cột `dirty` / `updated_at` / tombstone
- [ ] Sync engine: append-only union theo id cho session/match; last-write-wins
      theo `updated_at` cho player/equipment
- [ ] Di trú dữ liệu SharedPreferences hiện có

### UI còn thiếu (đang là `test.fixme` trong E2E)

- [ ] Nút Skip ở Onboarding
- [ ] Đường vào `/play` từ Home — bottom nav chỉ có Home/Train/Progress/Profile
- [ ] Entry point tới `/training/path` và `/coach` từ Training Center — route
      tồn tại nhưng không gì link tới

### P3 — Vision Auto Recording (dự án riêng)

- [ ] ML training · ball detection · shot tracking
- 🟢 Camera integration UI (hiện là màn đăng ký beta)

---

## 📊 Tiến độ theo tầng

| Tầng | Trạng thái |
|---|---|
| Giao diện & điều hướng | ✅ ~100% |
| Nội dung (kiến thức, drill) | ✅ ~100% |
| Test & CI | ✅ 473 + 22 pass |
| Lưu trữ local | 🟢 chạy, nhưng 2 kho đụng key |
| Hạ tầng backend | ✅ đã dựng, đã kiểm chứng |
| **App ↔ Backend** | ❌ **0%** |
| **Đồng bộ đa thiết bị** | ❌ **0%** |
| **Community dữ liệu thật** | ❌ **0%** |
| Vision ML | ⬜ 0% (dự án riêng) |

**Cố ý không đặt một con số phần trăm tổng.** Bản trước ghi 99.9% và chính con
số đó che mất việc app đang chạy hoàn toàn offline — phần còn lại quan trọng
nhất.

---

## 🗂️ Route thật — 49 route, đã đối chiếu `app_router.dart`

### Training Center

| Màn hình | Route |
|---|---|
| Training Center Home | `/training` |
| AI Learning Path | `/training/path` |
| Đánh giá đầu vào · Drill đề xuất | `/training/assessment` · `/training/recommended` |
| Danh mục drill · theo category | `/training/drills` · `/training/drills/:categoryId` |
| Chi tiết drill | `/training/drill/:drillCode` |
| Phiên tập | `/training/session/ready` · `/new` · `/active` · `/complete` · `/:sessionId` |
| Kiến thức | `/training/knowledge` · `/training/knowledge/:slug` |
| Chứng chỉ | `/training/certification` · `/training/certification/:certId` |
| Lịch sử · Tiến độ | `/training/history` · `/training/progress` |

### Play

| Màn hình | Route |
|---|---|
| Play Home · Đấu nhanh · Giao lưu | `/play` · `/play/quick` · `/play/friendly` |
| Ghi trận · Nhập kết quả | `/play/recording` · `/play/log` |
| Lịch sử · Tổng kết trận | `/play/history` · `/play/match/:matchId/summary` |
| Giải đấu | `/play/tournament` · `/create` · `/:tournamentId` |
| Vision (beta) | `/play/vision` |

### Coach · Profile · Khác

| Màn hình | Route |
|---|---|
| Coach | `/coach` · `/coach/survey` · `/coach/chat` · `/coach/timeline` |
| Analysis · Training Plan | `/coach/analysis` · `/coach/plan` |
| Profile | `/profile` · `/edit` · `/equipment` · `/settings` |
| Auth | `/auth/login` · `/auth/register` |
| Onboarding | `/welcome` · `/onboarding` · `/onboarding/interests` |
| Khác | `/home` · `/community` · `/notifications` · `/session/create` · `/settings/black-box` |

---

## 🔗 Hạ tầng đang sống

| | |
|---|---|
| App | https://poolos.kjdybl.easypanel.host |
| API (Directus 12.3.1) | https://poolos-api.kjdybl.easypanel.host |
| Hộp thư test (Mailpit) | https://poolos-mail.kjdybl.easypanel.host |

EasyPanel project `test-va` trên `195.35.7.42`. Service: `directus` + `db`
(postgis 17-3.5) + `redis:7` + `mailpit` + `poolos` (nginx).

---

## 📌 Quy tắc giữ file này đúng

1. **Không đánh Done bằng "màn hình đã vẽ".** Chỉ đánh khi luồng chạy đầu-cuối.
2. **Luôn ghi cột Bằng chứng.** Không có bằng chứng thì cao nhất là 🟢.
3. **Phát hiện sai thì sửa ngay**, kể cả khi nó làm tiến độ nhìn xấu đi. Tracker
   sai đắt hơn tracker xấu.
4. **Không đặt phần trăm tổng.** Đi theo bảng tiến độ theo tầng.
