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
| API (Directus 12.3.1) | https://poolos-api.kjdybl.easypanel.host |
| Hộp thư test (Mailpit) | https://poolos-mail.kjdybl.easypanel.host |

Service: `directus` + `db` (postgis 17-3.5, database `poolos`) + `redis:7` +
`mailpit` + `poolos` (nginx phục vụ bundle web).

Secrets ở `deploy/directus/.env.generated` (**không commit**).

## 🔴 NỢ KỸ THUẬT — phải trả TRƯỚC khi có người dùng thật

**Directus bản này khoá bộ lọc quyền theo chủ sở hữu.** Đã cô lập bằng thực
nghiệm:

```
read KHÔNG bộ lọc                          -> tạo được
read CÓ  bộ lọc user_created=$CURRENT_USER -> "custom_permission_rules_enabled
                                               is a restricted resource"
```

Hệ quả: **24 quyền hiện tại đều KHÔNG có bộ lọc**, nên mọi người chơi đăng
nhập đều đọc/sửa được dữ liệu của nhau. Chấp nhận tạm vì đang giai đoạn phát
triển, chưa có người dùng thật.

Hướng xử lý (chưa chọn): trả phí Directus để mở custom permission rules · ép
quyền sở hữu bằng Flows/extension · hoặc đổi tầng dữ liệu sang thứ có RLS thật.

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
