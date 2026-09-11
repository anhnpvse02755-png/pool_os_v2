import { test, expect } from '@playwright/test';
import { toHashRoute, waitForAppReady } from '../fixtures/app.fixture';
import { luminanceOf } from './helpers/png-luminance';

/**
 * Nhìn THẬT chế độ tối.
 *
 * Mọi tỉ lệ tương phản ghi trong bốn plan redesign đến giờ đều là **tính
 * toán**: đọc hex trong `colors.dart` rồi nhân chia. Chưa lần nào ai dựng app
 * ở chế độ tối để xem nó ra cái gì. Hygiene 68/68 chỉ chứng minh không còn
 * token khoá-sáng trong MÃ NGUỒN — nó không chứng minh màn hình vẽ ra đúng.
 *
 * Spec này dựng app thật rồi đo ảnh chụp:
 *   1. Nền có TỐI thật không (màn quên đọc brightness sẽ sáng trắng).
 *   2. Ảnh có nội dung không (không phải khung trống một màu).
 */

// `colorScheme: 'dark'` khiến trình duyệt báo prefers-color-scheme: dark —
// đúng thứ mà `ThemeMode.system` đọc.
test.use({ colorScheme: 'dark' });

/** Màn đại diện, trải các nhóm đã quét. */
const screens = [
  { route: '/welcome', name: 'welcome' },
  { route: '/home', name: 'home' },
  { route: '/training', name: 'training' },
  { route: '/training/knowledge', name: 'knowledge' },
  { route: '/training/drills', name: 'drills' },
  { route: '/auth/login', name: 'login' },
];

for (const { route, name } of screens) {
  test(`${name}: nền tối thật, không phải nền sáng lọt lưới`, async ({ page }) => {
    await page.goto(toHashRoute(route));
    await waitForAppReady(page);
    // Cho hiệu ứng fade/slide chạy xong, nếu không sẽ chụp giữa chừng.
    await page.waitForTimeout(1200);

    const shot = await page.screenshot({
      path: `test-results/dark-mode/${name}.png`,
    });
    const { avg, min, max } = luminanceOf(shot);

    // Nền kem bản sáng (#F7F4EC) sáng ~243; nền tối (#121715) ~22.
    // Lấy 110 làm ranh giới — rộng rãi, chỉ bắt màn RÕ RÀNG sáng.
    expect(
      avg,
      `Màn ${name} sáng trung bình ${avg.toFixed(0)} — nhiều khả năng nó không ` +
        `đọc brightness và đang vẽ bằng token bản sáng.`,
    ).toBeLessThan(110);

    // Một màu duy nhất nghĩa là app chưa vẽ gì, và phép đo "nền tối" ở trên
    // sẽ đạt một cách vô nghĩa.
    expect(
      max - min,
      `Màn ${name} chỉ có một màu — chưa vẽ nội dung.`,
    ).toBeGreaterThan(20);
  });
}
