import { test, expect } from '../fixtures/app.fixture';

test.describe('Welcome Screen', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/welcome');
  });

  test('should display welcome screen', async ({ page }) => {
    await expect(page).toHaveTitle(/PoolOS/i);
  });

  test('should have get started button', async ({ welcomePage }) => {
    await expect(welcomePage.getStartedButton).toBeVisible();
  });

  test('should navigate to onboarding when clicking get started', async ({
    welcomePage,
    onboardingPage,
  }) => {
    await welcomePage.clickGetStarted();

    // welcome_screen.dart uses `context.push('/onboarding')`, and GoRouter's
    // imperative push leaves the browser URL on /welcome. Assert the screen
    // actually changed instead of waiting for a URL that never updates.
    await expect(onboardingPage.continueButton.first()).toBeVisible();
    await expect(welcomePage.getStartedButton).toBeHidden();
  });
});
