---
name: auth-account
description: Tầng đăng nhập/tài khoản trên Directus — 7 lỗi đã sửa 11/9/2026 và ranh giới guard
metadata:
  type: project
---

Backend là **Directus**, không phải Supabase (xem [[backend-directus]]).
Supabase đã bị thay hẳn — đừng tin memory cũ nào còn nhắc tới nó.

## Đường đi

`DirectusConfig` (URL, có mặc định nên không cần `--dart-define`) →
`DirectusClient` (dio mỏng) → `AuthService` (dịch lỗi sang tiếng Việt) →
`AuthNotifier`/`authProvider`. Phiên lưu ở `PrefsTokenStore` (SharedPreferences).

## Bảy lỗi đã sửa 11/9/2026

1. **Token không bao giờ gia hạn** — `refresh()` có sẵn nhưng không ai gọi.
   Server không đặt TTL nên access token sống **15 phút**; qua mốc đó mọi
   thao tác 401 trong khi UI vẫn báo đã đăng nhập. Nay `_send` gặp 401 thì gia
   hạn một lần rồi thử lại.
2. **Hạn token không kiểm được** — `expiresInMs` là *thời lượng*, không ai ghi
   mốc cấp. Nay đọc claim `exp` của JWT. Token không đọc được thì **coi như còn
   hạn** — đoán bừa sẽ đăng xuất oan.
3. **Router không có guard.** Nay chặn theo tiền tố, khớp **trọn đoạn** đường
   dẫn (nếu so chuỗi trần thì `/playbook` bị chặn oan vì trùng `/play`).
4. **Nút Đăng xuất không đăng xuất** — chỉ điều hướng, token còn nguyên.
5. **Họ tên khi đăng ký bị vứt** — màn thu thập rồi không truyền xuống.
6. **UI vứt thông báo lỗi thật** — màn đăng nhập hardcode *"Email hoặc mật khẩu
   không đúng"* cho mọi lỗi, đúng câu mà `AuthService` được viết lại để loại
   bỏ. Màn đăng ký còn phơi `e.toString()`.
7. **`AuthNotifier` gán `state` sau `await` mà không kiểm `mounted`** → "Tried
   to use AuthNotifier after dispose".

## Ranh giới guard (`requiresAuth` trong `app_router.dart`)

**Chặn** — đọc/ghi dữ liệu riêng: `/profile` `/notifications` `/community`
`/session` `/coach` `/play` `/settings` `/training/progress`
`/training/history` `/training/session`.

**Tự do** — mọi thứ còn lại, gồm `/home`, thư viện bài tập và từ điển kiến
thức. Lý do: giá trị của app phải nhìn thấy được **trước** khi quyết định đăng ký.

Bị chặn thì guard gắn `?from=` và đăng nhập xong quay lại đúng chỗ.

**Why:** Sáu trong bảy lỗi đều "im lặng" — không crash, không log, giao diện
vẫn bình thường, chỉ là mọi thứ hỏng sau 15 phút hoặc đăng xuất không thật.

**How to apply:** Đổi ranh giới chặn thì sửa `_privatePrefixes` rồi cập nhật
`test/router/auth_guard_test.dart`. Đừng thay thông báo lỗi bằng chuỗi cứng ở
UI — `AuthService` đã dịch sẵn.
