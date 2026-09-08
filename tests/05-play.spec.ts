import { test, expect } from '../fixtures/app.fixture';

test.describe('Play Screen', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/play');
  });

  test('should display play screen', async ({ playPage }) => {
    await expect(playPage.quickMatchButton.first()).toBeVisible();
    await expect(playPage.friendlyMatchButton.first()).toBeVisible();
  });

  // play_screen.dart navigates with context.push throughout, so assert on
  // destination content rather than the URL.
  test('should navigate to quick match', async ({ page, playPage }) => {
    await playPage.clickQuickMatch();
    await expect(
      page.getByRole('button', { name: '9-Ball', exact: true }).first(),
    ).toBeVisible();
  });

  test('should navigate to friendly match', async ({ page, playPage }) => {
    await playPage.clickFriendlyMatch();
    await expect(
      page.getByRole('button', { name: /tạo phòng/i }).first(),
    ).toBeVisible();
  });

  test('should navigate to match history', async ({ page, playPage }) => {
    await playPage.clickMatchHistory();
    await expect(page.getByRole('tab', { name: /^thắng$/i }).first()).toBeVisible();
  });
});
