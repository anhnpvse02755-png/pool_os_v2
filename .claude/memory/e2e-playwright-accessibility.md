---
name: e2e-playwright-accessibility
description: Playwright E2E fails because Flutter Web canvas hides semantics behind an "Enable accessibility" button
metadata:
  type: project
---

**Trạng thái: 🔴 CHƯA SỬA** (phát hiện 28/8/2026, `test-results/.last-run.json` → failed)

## Triệu chứng

`tests/01-welcome.spec.ts` fail 2 test:
- `should have get started button`
- `should navigate to onboarding when clicking get started`

```
Error: expect(locator).toBeVisible() failed
Locator: getByRole('button', { name: /bắt đầu|get started/i })
Error: element(s) not found
```

## Nguyên nhân gốc

Accessibility snapshot của trang chỉ chứa đúng một phần tử:
```yaml
- button "Enable accessibility"
```

Flutter Web render bằng **canvas** — semantics tree không được dựng cho tới khi có người bấm nút placeholder "Enable accessibility". Nên `getByRole()` không thấy widget nào.

**Đây KHÔNG phải lỗi UI.** Nút thật có trong code: `lib/presentation/screens/onboarding/welcome_screen.dart:110` → `label: 'Bắt đầu ngay'`, khớp regex của test.

## Hướng sửa

Click nút "Enable accessibility" trong `fixtures/app.fixture.ts` trước khi trả `page` cho test. Sửa một chỗ ở fixture thì cả 6 spec (`01`–`06`) đều được, vì tất cả đều dùng chung fixture này.

**Why:** Triệu chứng ("không tìm thấy nút") trông hệt như lỗi UI hoặc lỗi đổi label sau redesign Sprint-19 — dễ đi sửa nhầm screen thay vì sửa test harness.

**How to apply:** Trước khi debug bất kỳ E2E fail nào của app này, kiểm tra accessibility snapshot có chỉ chứa "Enable accessibility" không. Xem [[sprint-status]].
