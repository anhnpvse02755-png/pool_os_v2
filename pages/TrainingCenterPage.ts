import { Page, Locator } from '@playwright/test';
import { BasePage } from './BasePage';

export class TrainingCenterPage extends BasePage {
  readonly learningPathCard: Locator;
  readonly allDrillsButton: Locator;
  readonly knowledgeButton: Locator;
  readonly aiCoachCard: Locator;
  readonly progressCard: Locator;
  readonly drillCategories: Locator;

  constructor(page: Page) {
    super(page, '/training');
    this.learningPathCard = page.locator('[data-testid="learning-path-card"]');
    this.allDrillsButton = page.locator('text=All Drills, text=Tất cả bài tập').first();
    this.knowledgeButton = page.locator('text=Knowledge, text=Kiến thức').first();
    this.aiCoachCard = page.locator('[data-testid="ai-coach-card"]');
    this.progressCard = page.locator('[data-testid="progress-card"]');
    this.drillCategories = page.locator('[data-testid="drill-category"]');
  }

  async clickLearningPath(): Promise<void> {
    await this.learningPathCard.click();
  }

  async clickAllDrills(): Promise<void> {
    await this.allDrillsButton.click();
  }

  async clickKnowledge(): Promise<void> {
    await this.knowledgeButton.click();
  }

  async clickAICoach(): Promise<void> {
    await this.aiCoachCard.click();
  }

  async isTrainingCenterVisible(): Promise<boolean> {
    return this.learningPathCard.isVisible();
  }
}
