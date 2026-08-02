import { test, expect } from '../fixtures/app.fixture';

test.describe('Training Center', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/training');
  });

  test('should display training center screen', async ({ trainingCenterPage }) => {
    await expect(trainingCenterPage.learningPathCard).toBeVisible();
  });

  test('should navigate to learning path', async ({ page, trainingCenterPage }) => {
    await trainingCenterPage.clickLearningPath();
    await page.waitForURL(/\/training\/path/);
  });

  test('should navigate to all drills', async ({ page, trainingCenterPage }) => {
    await trainingCenterPage.clickAllDrills();
    await page.waitForURL(/\/training\/drills/);
  });

  test('should navigate to knowledge', async ({ page, trainingCenterPage }) => {
    await trainingCenterPage.clickKnowledge();
    await page.waitForURL(/\/training\/knowledge/);
  });

  test('should navigate to AI coach', async ({ page, trainingCenterPage }) => {
    await trainingCenterPage.clickAICoach();
    await page.waitForURL(/\/coach/);
  });
});
