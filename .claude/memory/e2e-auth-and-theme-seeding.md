---
name: e2e-auth-and-theme-seeding
description: E2E Playwright — seed phiên và chế độ tối vào localStorage thay vì đăng nhập/emulateMedia; và bẫy thứ tự fixture vs beforeEach
metadata:
  type: reference
---

Hai thứ E2E **phải seed vào localStorage**, không làm được bằng cách khác:

## 1. Phiên đăng nhập

`/play`, `/profile`, `/coach`, `/session`, `/notifications`, `/community`,
`/settings` nằm trong `_privatePrefixes` của router → chưa đăng nhập là bị đẩy
về `/auth/login`. Triệu chứng đánh lừa: test báo *"không tìm thấy nút Đấu
nhanh"* trong khi thật ra đang đứng ở màn đăng nhập.

**Không đăng nhập qua giao diện được:** Directus trả
`Access-Control-Allow-Origin: https://poolos.kjdybl.easypanel.host`, nên mọi
lời gọi từ `localhost:8080` bị CORS chặn. (`curl` vẫn 200 vì không phải trình
duyệt — đừng để điều đó đánh lừa.)

Dùng `seedSession(page)` trong `fixtures/app.fixture.ts`. Guard chỉ hỏi "có
token không" nên token giả là đủ. 120s timeout → 6.7s.

## 2. Chế độ tối

`test.use({ colorScheme: 'dark' })` **không đủ**. `ThemeNotifier` mặc định
`ThemeMode.light` và chỉ đọc lựa chọn đã lưu, nên app bỏ qua
`prefers-color-scheme`. Không seed `flutter.poolos_v2.theme` thì cả lượt chạy ở
chế độ SÁNG, và test báo hàng loạt màn "không đọc brightness" — sai hoàn toàn.

Tiền tố `flutter.` là của SharedPreferences bản web; giá trị String bị
JSON-encode **hai lần**.

## ⚠️ Bẫy thứ tự: fixture chạy SAU beforeEach

Fixture (`playPage`…) chỉ khởi tạo khi **thân test** chạy — tức sau mọi
`beforeEach`. Seed trong fixture là quá muộn nếu hook đã `goto`. Seed phải nằm
trong `beforeEach`, trước lời gọi điều hướng.

## Flaky firefox

Mỗi test boot một instance Flutter web (~5s). Để Playwright tự chọn worker theo
số CPU thì máy quá tải, boot vượt hạn 30s và firefox đỏ rải rác — chạy riêng
lại xanh. `workers: 2` trong `playwright.config.ts` xử lý việc này.

**Why:** Cả ba nguyên nhân đều biểu hiện thành "màn hình sai", trong khi không
màn nào sai cả. Mất nhiều vòng mới tách được.

**How to apply:** E2E đỏ ở một route riêng tư → nghi seed phiên trước. Test
dark-mode đỏ hàng loạt → nghi seed theme trước khi nghi 40 màn chưa quét. Xem
[[e2e-playwright-accessibility]].
