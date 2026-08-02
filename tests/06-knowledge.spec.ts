import { test, expect, Page } from '@playwright/test';

test.describe('Knowledge Screen', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/training/knowledge');
  });

  test('should display knowledge screen', async ({ page }) => {
    await expect(page.locator('text=Kiến thức')).toBeVisible();
  });

  test('should display category tabs', async ({ page }) => {
    await expect(page.locator('[role="tablist"], .category-tabs')).toBeVisible();
  });

  test('should display knowledge cards', async ({ page }) => {
    await expect(page.locator('.knowledge-card, [data-testid="knowledge-card"]').first()).toBeVisible();
  });

  test('should navigate to knowledge detail', async ({ page }) => {
    const firstCard = page.locator('[data-testid="knowledge-card"]').first();
    if (await firstCard.isVisible()) {
      await firstCard.click();
      await page.waitForURL(/\/training\/knowledge\/.+/);
    }
  });

  test('should search knowledge', async ({ page }) => {
    const searchButton = page.locator('[aria-label="search"], button:has-text("Tìm kiếm")').first();
    if (await searchButton.isVisible()) {
      await searchButton.click();
      await expect(page.locator('input[type="search"], [role="searchbox"]')).toBeVisible();
    }
  });
});
