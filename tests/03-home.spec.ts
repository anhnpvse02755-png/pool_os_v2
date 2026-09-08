import { test, expect } from '../fixtures/app.fixture';

test.describe('Home Screen', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/home');
  });

  test('should display home screen with navigation', async ({ homePage }) => {
    await expect(homePage.startTrainingButton).toBeVisible();
    await expect(homePage.homeTab).toBeVisible();
    await expect(homePage.trainingTab).toBeVisible();
  });

  // The bottom nav uses context.go, so these do update the browser URL.
  test('should navigate to training center', async ({ page, homePage }) => {
    await homePage.navigateToTraining();
    await expect(page).toHaveURL(/\/training/);
  });

  test('should navigate to profile', async ({ page, homePage }) => {
    await homePage.navigateToProfile();
    await expect(page).toHaveURL(/\/profile/);
  });

  test('progress tab should open coach analysis', async ({ page, homePage }) => {
    // main_shell.dart maps the "Progress" destination to /coach/analysis.
    await homePage.navigateToProgress();
    await expect(page).toHaveURL(/\/coach\/analysis/);
  });

  test.fixme(
    'should navigate to play screen',
    async () => {
      // There is no route to /play from Home. The bottom nav has only
      // Home, Train, Progress and Profile, and no card on the Home body
      // links to Play either. Needs a product decision, not a test fix.
    },
  );
});
