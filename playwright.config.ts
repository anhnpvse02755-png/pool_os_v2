import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  // Moi test boot mot instance Flutter web (canvas + engine ~5s). De
  // Playwright tu chon so worker theo so CPU thi may bi qua tai va boot vuot
  // han 30s — firefox do rai rac, chay rieng lai xanh. Gioi han 2 worker doi
  // lai vai chuc giay tong thoi gian, nhung het do flaky.
  workers: process.env.CI ? 1 : 2,
  reporter: [
    ['html', { outputFolder: 'playwright-report' }],
    ['list']
  ],
  use: {
    baseURL: 'http://localhost:8080',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 10000,
    navigationTimeout: 30000,
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
  ],
  timeout: 30000,

  // Without this, `npx playwright test` runs against nothing and every spec
  // fails on connection refused. The server needs SPA fallback because the
  // app's routes (/welcome, /home, ...) are not real files on disk.
  webServer: {
    command: 'node tools/e2e-server.js 8080',
    url: 'http://localhost:8080/',
    reuseExistingServer: !process.env.CI,
    timeout: 60_000,
  },
});
