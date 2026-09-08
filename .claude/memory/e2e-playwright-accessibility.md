---
name: e2e-playwright-accessibility
description: Four things that break Playwright against this Flutter Web app - hash routing, boot race, canvas semantics, and data-testid selectors
metadata:
  type: project
---

**Trạng thái: ✅ ĐÃ SỬA** (commit `ce2391f`, 8/9/2026). Suite: 5 pass → 22 pass
(44 khi tính cả Chromium + Firefox), 4 skip có chủ đích.

Ghi chú cũ của memory này ("2 test fail, click nút Enable accessibility là
xong") **sai ở cả quy mô lẫn cách sửa**. Thực tế 22/27 test fail, và
`locator.click()` lên placeholder luôn ném *"Element is outside of the
viewport"*.

## Bốn thứ làm Playwright không chạy được với app này

**1. Hash routing.** App dùng hash strategy (không có `usePathUrlStrategy`
trong `main.dart`). `page.goto('/home')` → server trả index.html → router
boot ở `initialLocation: '/welcome'` → URL thành `/home#/welcome`, hiển thị
màn **Welcome**. Phải đi `/#/home`.

**2. Boot race.** `goto` trả về trước khi Flutter khởi động ~4-6s. Trong lúc
đó `document.title` vẫn là `pool_os_v2` (index.html), chỉ sau khi boot mới
thành `PoolOS`.

**3. Canvas semantics.** `getByRole`/`getByText` không thấy gì cho tới khi
kích hoạt `flt-semantics-placeholder`. Nút đó nằm ngoài viewport → phải
`dispatchEvent('click')`, không dùng `.click()`. Tín hiệu "đã sẵn sàng":
`flt-semantics-host` có `childElementCount > 0`.

**4. `data-testid` không tồn tại.** Flutter chỉ phát ra semantics node. App
không dùng `Semantics(identifier:)` ở đâu, nên mọi selector `[data-testid]`
vĩnh viễn không khớp. Dùng role + accessible name.

Cả bốn đã xử lý trong `fixtures/app.fixture.ts` (bọc `page.goto`) và
`pages/*.ts`.

## `push` không đồng bộ URL — đừng assert `page.url()` bừa

| Điều hướng | Màn đổi | URL đổi |
|---|---|---|
| Bottom nav (`context.go`) | ✅ | ✅ |
| Training / Play / welcome→onboarding (`context.push`) | ✅ | ❌ |

Nơi app dùng `context.push`, hãy kiểm tra **nội dung màn đích**, không phải
URL. Lưu ý bottom nav "Progress" đi tới `/coach/analysis`, không phải
`/progress`.

## Còn 4 test `test.fixme` — chờ quyết định sản phẩm

Không phải lỗi test, mà là UI chưa tồn tại: onboarding không có nút Skip;
Home không có đường vào `/play`; Training Center không có entry point tới
`/training/path` và `/coach`.

**Why:** Triệu chứng ("không tìm thấy nút") trông hệt lỗi UI hoặc lỗi đổi
label sau redesign — rất dễ đi sửa nhầm screen thay vì sửa test harness.

**How to apply:** Trước khi debug E2E fail của app này, kiểm tra 4 nguyên
nhân trên trước. Chạy `npx playwright test` là đủ — `webServer` trong
`playwright.config.ts` tự build-serve, nhưng cần `flutter build web
--release --base-href /` trước. Xem [[sprint-status]].
