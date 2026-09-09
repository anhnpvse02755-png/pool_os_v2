---
name: backend-directus
description: PoolOS backend on EasyPanel - Directus stack, live URLs, and the row-level security debt that must be paid before real users
metadata:
  type: project
---

**Dựng ngày 9/9/2026.** Backend PoolOS chạy trên VPS `195.35.7.42` (EasyPanel,
panel `vps.nexthome.com.vn`), project **`test-va`**.

## URL đang sống

| | |
|---|---|
| App (Flutter web) | https://poolos.kjdybl.easypanel.host |
| API (Directus **12.3.1** + license OIG) | https://poolos-api.kjdybl.easypanel.host |
| Hộp thư test (Mailpit) | https://poolos-mail.kjdybl.easypanel.host |

Service: `directus` + `db` (postgis 17-3.5, database `poolos`) + `redis:7` +
`mailpit` + `poolos` (nginx phục vụ bundle web).

Secrets ở `deploy/directus/.env.generated` (**không commit**).

## ✅ Row-level security — ĐÃ GỠ (09/09), Directus **12.3.1** + license OIG

**Nguyên nhân gốc:** Directus 12 đổi license BSL 1.1 -> MSCL 1.0 và bật cưỡng
chế. Core tier giới hạn 25 collection · 3 seat · 5 Flows · KHÔNG có custom
permission rules. Cả hai chặn từng gặp đều từ đây (`cms` 49 collection ->
LIMIT_EXCEEDED; bộ lọc quyền -> restricted resource).

**Cách gỡ đã dùng:** kích hoạt **license Open Innovation Grant (miễn phí)**
qua `POST /license {"license_key": "..."}`. Sau đó mọi hạn mức về `-1` và
`custom_permission_rules_enabled: true`. Đã áp cho CẢ HAI instance (2/5
activation).

*(Đã thử hạ về v11.9.3 trước đó và chạy được — v11 chưa có cưỡng chế. Giữ lại
làm phương án dự phòng nếu key có vấn đề.)*

**Đã kiểm chứng runtime với 2 user thật:** A chỉ thấy dữ liệu A, B chỉ thấy
dữ liệu B, B sửa bản ghi của A bị chặn.

### ⚠️ Bẫy: quyền Directus là CỘNG DỒN, không ghi đè

Thêm permission có bộ lọc mà **vẫn rò rỉ**, vì permission không lọc cũ vẫn
còn hiệu lực, hai cái cộng lại thành "đọc tất". **Phải xoá cái không lọc.**
"Tạo được permission" KHÁC "cách ly hoạt động" — chỉ test runtime 2 user mới
phát hiện.

### ⚠️ Bẫy 2: nâng v11 -> v12 XOÁ ÂM THẦM bộ lọc quyền

Nâng poolos-api 11.9.3 -> 12.3.1: dữ liệu và collection còn nguyên nhưng
**toàn bộ bộ lọc quyền biến mất** (v12 chưa có license thì không được phép có
custom permission rules, nó lặng lẽ gỡ). Bảo mật thụt về hở toang, KHÔNG có
cảnh báo nào.

**Quy tắc: mỗi lần đổi phiên bản Directus hoặc đổi trạng thái license, PHẢI
chạy lại test cách ly hai user.**

## ✅ `cms` production — đã gỡ, suýt muộn

Trước khi xử lý: `name: Core · status: grace · expires_at: 09/09/2026 09:36`,
usage 40 collection / 2 seat / 5 flow. **Ân hạn đã hết trước đó ~2,4 giờ** —
đứng ngay trước luồng khoá (chặn /items, tắt GraphQL/WebSocket/MCP, từ chối
login người không phải admin; `website` lấy nội dung từ đây cũng hỏng theo).
Kích hoạt OIG xong: `active`, mọi hạn mức `-1`.

**License key nằm ở đâu:** đã nhập vào Settings của cả hai instance
(`source: settings`). KHÔNG đặt qua env `LICENSE_KEY` — làm vậy Studio khoá
editor. Kích hoạt bằng `POST /license`, không PATCH được `/settings`
trực tiếp ("You can't change the license_key value manually").

## Bẫy đã gặp, đừng vấp lại

**1. `#` trong file .env cắt cụt giá trị.** `PASSWORD_RESET_URL_ALLOW_LIST` đặt
là `.../#/reset-password` bị cắt thành `.../` nên link đặt lại mất fragment.
Dùng đường dẫn **không có `#`** (`/reset-password`) — nginx đã có SPA fallback,
app đọc token từ query string.

**2. Cloudflare chặn user-agent lạ.** `cms.nexthome.com.vn` trả `error code:
1010` với urllib/python. Tưởng sai mật khẩu nhưng không phải — gửi UA trình
duyệt là qua.

**3. Đường Compose của EasyPanel hỏng.** `createComposeService` luôn báo
`ENOENT: docker-compose.override.yml` kể cả compose 3 dòng sạch. **Dùng app
service gốc** (`createAppService`/`createPostgresService`/`createRedisService`),
chúng chạy tốt.

**4. `cms` Directus đã chạm trần collection** (49 collection, `LIMIT_EXCEEDED`),
không thêm được cái nào. Đó là lý do phải dựng instance riêng.

**5. `resources` trong createPostgresService** bắt buộc đủ 4 trường
(cpuLimit, cpuReservation, memoryLimit, memoryReservation) hoặc bỏ hẳn.

**6. Git Bash biến `/` thành đường dẫn Windows.** `flutter build web
--base-href /` hỏng; dùng PowerShell cho lệnh có tham số `/`.

## Đã sửa trên `cms` production

Thêm service `mailpit` và bật cấu hình email (trước đó khối SendGrid bị
comment). Vô hại, CMS giờ gửi được mail. Backup env trước khi sửa ở
`deploy/backups/cms-app-env.backup`.

**Why:** Ba chặn ở trên (compose hỏng, trần collection, khoá bộ lọc quyền) đều
chỉ lộ ra khi chạy thật, không có trong tài liệu — mất nhiều giờ để tìm.

**How to apply:** Đọc file này trước khi động vào backend hoặc EasyPanel. Xem
[[sprint-status]].
