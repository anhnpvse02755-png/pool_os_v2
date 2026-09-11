import { test, expect } from '@playwright/test';
import { toHashRoute, waitForAppReady } from '../fixtures/app.fixture';
import { luminanceOf } from './helpers/png-luminance';

/**
 * Nhìn THẬT chế độ tối, trên TOÀN BỘ màn và CẢ HAI kích thước.
 *
 * Mọi tỉ lệ tương phản ghi trong bốn plan redesign đều là **tính toán**: đọc
 * hex trong `colors.dart` rồi nhân chia. Hygiene 68/68 chỉ chứng minh không còn
 * token khoá-sáng trong MÃ NGUỒN — nó không chứng minh màn hình vẽ ra đúng.
 *
 * Spec này dựng app thật rồi đo ảnh chụp. Nó bắt được đúng một loại lỗi, nhưng
 * là loại tệ nhất: màn quên đọc `brightness` và vẽ nền sáng giữa chế độ tối.
 */

test.use({ colorScheme: 'dark' });

/** Phiên giả để qua guard — 29/46 màn đòi đăng nhập. */
const JWT =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9' +
  '.eyJpZCI6ImUyZS11c2VyIiwicm9sZSI6ImUyZS1yb2xlIiwiZXhwIjoxNzkxNzEyOTk1LCJpc3MiOiJkaXJlY3R1cyJ9' +
  '.chu-ky-gia';

/**
 * Màn cần kiểm. Route có tham số được điền id THẬT lấy từ dữ liệu đang ship.
 * Ba route còn lại (`:certId`, `:matchId`, `:sessionId`) bỏ qua vì chưa có bản
 * ghi nào để trỏ tới.
 */
const routes = [
  // Công khai
  '/welcome',
  '/onboarding',
  '/onboarding/interests',
  '/auth/login',
  '/auth/register',
  '/reset-password',
  '/home',
  '/training',
  '/training/assessment',
  '/training/recommended',
  '/training/drills',
  '/training/path',
  '/training/knowledge',
  '/training/certification',
  '/training/drills/fundamentals',
  '/training/drill/BT01',
  '/training/knowledge/bridge',
  // Riêng tư
  '/notifications',
  '/community',
  '/session/create',
  '/profile',
  '/profile/settings',
  '/profile/edit',
  '/profile/equipment',
  '/settings/black-box',
  '/training/progress',
  '/training/history',
  '/training/session/ready',
  '/training/session/new',
  '/training/session/active',
  '/training/session/complete',
  '/coach',
  '/coach/analysis',
  '/coach/plan',
  '/coach/survey',
  '/coach/chat',
  '/coach/timeline',
  '/play',
  '/play/quick',
  '/play/friendly',
  '/play/recording',
  '/play/log',
  '/play/history',
  '/play/tournament',
  '/play/tournament/create',
  '/play/vision',
];

const viewports = [
  { name: 'desktop', width: 1280, height: 720 },
  // iPhone 14 — kích thước điện thoại phổ biến; đây là chỗ bố cục hay vỡ nhất.
  { name: 'phone', width: 390, height: 844 },
];

/** Nền kem bản sáng sáng ~243; nền tối ~22. 110 là ranh giới rộng rãi. */
const NGUONG_SANG = 110;

for (const vp of viewports) {
  test(`${vp.name}: mọi màn đều vẽ nền tối`, async ({ page }) => {
    test.setTimeout(6 * 60 * 1000);
    await page.setViewportSize({ width: vp.width, height: vp.height });

    await page.addInitScript(
      ([s]) => {
        localStorage.setItem('flutter.directus_session', JSON.stringify(s));
      },
      [
        JSON.stringify({
          access_token: JWT,
          refresh_token: 'refresh-e2e',
          expires: 900000,
        }),
      ],
    );

    const quaSang: string[] = [];
    const trong: string[] = [];

    // Khởi động app MỘT LẦN rồi chuyển màn bằng hash. `goto` cho từng route sẽ
    // bắt chờ Flutter boot lại (~4-6s mỗi lần) và cả lượt vượt quá mọi hạn giờ.
    await page.goto(toHashRoute(routes[0]));
    await waitForAppReady(page);

    for (const route of routes) {
      await page.evaluate((r) => {
        window.location.hash = `#${r}`;
      }, route);
      await page.waitForTimeout(700);

      const ten = route.replace(/\//g, '_').replace(/^_/, '') || 'root';
      const shot = await page.screenshot({
        path: `test-results/dark-mode/${vp.name}/${ten}.png`,
      });
      const { avg, min, max } = luminanceOf(shot);

      if (avg >= NGUONG_SANG) quaSang.push(`${route} (sáng ${avg.toFixed(0)})`);
      // Một màu duy nhất = chưa vẽ gì, phép đo "nền tối" ở trên vô nghĩa.
      if (max - min <= 20) trong.push(route);
    }

    expect(
      quaSang,
      'Những màn sau vẽ nền SÁNG giữa chế độ tối — nhiều khả năng chúng không '
        + `đọc brightness:\n${quaSang.join('\n')}`,
    ).toEqual([]);

    expect(
      trong,
      `Những màn sau chỉ có một màu, chưa vẽ nội dung:\n${trong.join('\n')}`,
    ).toEqual([]);
  });
}
