import { test, expect } from '../fixtures/app.fixture';

test.describe('Knowledge Screen', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/training/knowledge');
  });

  test('should display knowledge screen', async ({ page }) => {
    await expect(page.getByText(/kiến thức/i).first()).toBeVisible();
  });

  test('should display category filters', async ({ page }) => {
    // The categories render as Flutter FilterChips, which map to the
    // checkbox role — not a tablist.
    const filters = page.getByRole('checkbox');
    await expect(filters.first()).toBeVisible();
    expect(await filters.count()).toBeGreaterThan(5);
  });

  test('should expose the categories filled by the dictionary import', async ({
    page,
  }) => {
    // cat_rules and cat_equipment held no articles before the import.
    await expect(
      page.getByRole('checkbox', { name: 'Luật Chơi', exact: true }).first(),
    ).toBeVisible();
    await expect(
      page.getByRole('checkbox', { name: 'Dụng Cụ', exact: true }).first(),
    ).toBeVisible();
  });

  test('should display knowledge cards', async ({ page }) => {
    await expect(page.getByRole('button').first()).toBeVisible();
  });
});
