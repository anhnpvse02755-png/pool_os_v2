import { test, expect } from '../fixtures/app.fixture';

test.describe('Play Screen', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/play');
  });

  test('should display play screen', async ({ playPage }) => {
    await expect(playPage.quickMatchButton).toBeVisible();
  });

  test('should navigate to quick match', async ({ page, playPage }) => {
    await playPage.clickQuickMatch();
    await page.waitForURL(/\/play\/quick/);
  });

  test('should navigate to friendly match', async ({ page, playPage }) => {
    await playPage.clickFriendlyMatch();
    await page.waitForURL(/\/play\/friendly/);
  });

  test('should navigate to match history', async ({ page, playPage }) => {
    await playPage.clickMatchHistory();
    await page.waitForURL(/\/play\/history/);
  });
});
