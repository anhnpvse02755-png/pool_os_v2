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
| API (Directus **11.9.3**) | https://poolos-api.kjdybl.easypanel.host |
| Hộp thư test (Mailpit) | https://poolos-mail.kjdybl.easypanel.host |

Service: `directus` + `db` (postgis 17-3.5, database `poolos`) + `redis:7` +
`mailpit` + `poolos` (nginx phục vụ bundle web).

Secrets ở `deploy/directus/.env.generated` (**không commit**).

## ✅ Row-level security — ĐÃ GỠ (09/09), chạy trên Directus **11.9.3**

**Nguyên nhân gốc:** Directus 12 đổi license BSL 1.1 -> MSCL 1.0 và bật cưỡng
chế. Core tier giới hạn 25 collection · 3 seat · 5 Flows · KHÔNG có custom
permission rules. Cả hai chặn từng gặp đều từ đây (`cms` 49 collection ->
LIMIT_EXCEEDED; bộ lọc quyền -> restricted resource).

**Cách gỡ đã dùng:** hạ `poolos-api` về **11.9.3**. v11 dùng BSL 1.1, chưa có
cưỡng chế — `/server/info` không còn khối `license`. Hợp lệ: BSL cho tự host
miễn phí dưới 5 triệu USD doanh thu.

**Đã kiểm chứng runtime với 2 user thật:** A chỉ thấy dữ liệu A, B chỉ thấy
dữ liệu B, B sửa bản ghi của A bị chặn.

### ⚠️ Bẫy: quyền Directus là CỘNG DỒN, không ghi đè

Thêm permission có bộ lọc mà **vẫn rò rỉ**, vì permission không lọc cũ vẫn
còn hiệu lực, hai cái cộng lại thành "đọc tất". **Phải xoá cái không lọc.**
"Tạo được permission" KHÁC "cách ly hoạt động" — chỉ test runtime 2 user mới
phát hiện.

### Đánh đổi

Ở lại v11 = không nhận vá bảo mật dòng v12+. Muốn lên v12 thì cần license key
Open Innovation Grant (miễn phí, dưới 5 triệu USD doanh thu và dưới 50 nhân
sự, đăng ký tại directus.com/oig).

## 🔴 RỦI RO PRODUCTION: `cms` vẫn ở v12 và vượt hạn mức

`cms.nexthome.com.vn` chạy 12.3.1 với **49 collection** (hạn mức Core 25).
Hết ân hạn 30 ngày: endpoint /items bị chặn, GraphQL/WebSocket/MCP tắt, login
của người không phải admin bị từ chối. **Không xoá dữ liệu**, cắm key vào là
phục hồi. Cần license key OIG cho instance này.

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
