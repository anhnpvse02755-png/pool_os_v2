import { Page, Locator } from '@playwright/test';
import { BasePage } from './BasePage';

/**
 * Training Center — `lib/presentation/screens/training/training_center_screen.dart`.
 *
 * The screen offers a QUICK START pair (All Drills, Knowledge) and a category
 * grid. Every one of these navigates with `context.push`, which does NOT
 * update the browser URL, so assert on the destination screen's content
 * rather than on `page.url()`.
 *
 * The screen has no learning-path or AI-coach entry point; `/training/path`
 * and `/coach` exist as routes but nothing here links to them.
 */
export class TrainingCenterPage extends BasePage {
  readonly allDrillsButton: Locator;
  readonly knowledgeButton: Locator;
  readonly drillCategories: Locator;
  readonly aimingCategory: Locator;

  constructor(page: Page) {
    super(page, '/training');
    this.allDrillsButton = page.getByRole('button', {
      name: /all drills/i,
    });
    this.knowledgeButton = page.getByRole('button', { name: /knowledge/i });
    this.drillCategories = page.getByRole('button', { name: /\d+ drills/i });
    this.aimingCategory = page.getByRole('button', { name: /ngắm đánh/i });
  }

  async clickAllDrills(): Promise<void> {
    await this.allDrillsButton.first().click();
  }

  async clickKnowledge(): Promise<void> {
    await this.knowledgeButton.first().click();
  }

  async isTrainingCenterVisible(): Promise<boolean> {
    return this.allDrillsButton.first().isVisible();
  }
}
