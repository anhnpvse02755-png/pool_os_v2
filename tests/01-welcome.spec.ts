import { test, expect } from '../fixtures/app.fixture';

test.describe('Welcome Screen', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/welcome');
  });

  test('should display welcome screen', async ({ page }) => {
    // Check page title
    await expect(page).toHaveTitle(/PoolOS/i);
  });

  test('should have get started button', async ({ welcomePage }) => {
    await expect(welcomePage.getStartedButton).toBeVisible();
  });

  test('should navigate to onboarding when clicking get started', async ({ page, welcomePage }) => {
    await welcomePage.clickGetStarted();
    await page.waitForURL(/\/onboarding/);
  });
});
