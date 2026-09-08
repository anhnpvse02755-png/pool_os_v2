import { test, expect } from '../fixtures/app.fixture';

test.describe('Onboarding Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/onboarding');
  });

  test('should display onboarding screen', async ({ onboardingPage }) => {
    await expect(onboardingPage.continueButton.first()).toBeVisible();
  });

  test('should navigate to home after completing onboarding', async ({
    page,
    onboardingPage,
  }) => {
    // Ten steps, each waiting on a real re-render: give it room.
    test.slow();

    // The wizard is an intro, a ranking explainer and seven questions; only
    // the last step calls context.go('/home'). Every question has a default
    // answer, so walking it with "Tiếp tục" is enough.
    await onboardingPage.completeFlow();
    await expect(page).toHaveURL(/\/home/);
  });

  test.fixme(
    'should skip onboarding and go to home',
    async () => {
      // onboarding_screen.dart has no skip control — only "Tiếp tục" and
      // "Quay lại". Either the screen needs a skip button or this test
      // should be dropped; it cannot pass as written.
    },
  );
});
