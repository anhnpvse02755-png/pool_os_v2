import { test, expect } from '../fixtures/app.fixture';

test.describe('Home Screen', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/home');
  });

  test('should display home screen with navigation', async ({ homePage }) => {
    await expect(homePage.statsCard).toBeVisible();
  });

  test('should navigate to training center', async ({ page, homePage }) => {
    await homePage.navigateToTraining();
    await page.waitForURL(/\/training/);
  });

  test('should navigate to play screen', async ({ page, homePage }) => {
    await homePage.navigateToPlay();
    await page.waitForURL(/\/play/);
  });

  test('should navigate to coach', async ({ page, homePage }) => {
    await homePage.navigateToCoach();
    await page.waitForURL(/\/coach/);
  });

  test('should navigate to profile', async ({ page, homePage }) => {
    await homePage.navigateToProfile();
    await page.waitForURL(/\/profile/);
  });
});
