import { test, expect } from '../fixtures/app.fixture';

test.describe('Training Center', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/training');
  });

  test('should display training center screen', async ({
    trainingCenterPage,
  }) => {
    await expect(trainingCenterPage.allDrillsButton.first()).toBeVisible();
    await expect(trainingCenterPage.knowledgeButton.first()).toBeVisible();
  });

  // These navigate with context.push, which does not change the browser URL,
  // so each test asserts the destination screen rendered.
  test('should navigate to all drills', async ({ page, trainingCenterPage }) => {
    await trainingCenterPage.clickAllDrills();
    await expect(
      page.getByRole('button', { name: /ngắm đánh/i }).first(),
    ).toBeVisible();
  });

  test('should navigate to knowledge', async ({ page, trainingCenterPage }) => {
    await trainingCenterPage.clickKnowledge();
    await expect(
      page.getByRole('checkbox', { name: 'Nền Tảng', exact: true }).first(),
    ).toBeVisible();
  });

  test.fixme(
    'should navigate to learning path',
    async () => {
      // training_center_screen.dart has no entry point to /training/path.
      // The route and the screen exist, but nothing links to them.
    },
  );

  test.fixme(
    'should navigate to AI coach',
    async () => {
      // Likewise, no AI-coach card exists on this screen; its only
      // navigations are /training/history, /training/drills and
      // /training/knowledge.
    },
  );
});
