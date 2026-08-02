import { test, expect } from '../fixtures/app.fixture';

test.describe('Onboarding Flow', () => {
  test('should display onboarding screen', async ({ onboardingPage }) => {
    await onboardingPage.navigate();
    await expect(onboardingPage.continueButton).toBeVisible();
  });

  test('should navigate to home after onboarding', async ({ page, onboardingPage }) => {
    await onboardingPage.navigate();
    await onboardingPage.clickContinue();
    await page.waitForURL(/\/home/);
  });

  test('should skip onboarding and go to home', async ({ page, onboardingPage }) => {
    await onboardingPage.navigate();
    await onboardingPage.clickSkip();
    await page.waitForURL(/\/home/);
  });
});
