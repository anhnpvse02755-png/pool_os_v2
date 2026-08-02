import { Page, Locator } from '@playwright/test';
import { BasePage } from './BasePage';

export class HomePage extends BasePage {
  readonly trainingButton: Locator;
  readonly playButton: Locator;
  readonly coachButton: Locator;
  readonly profileButton: Locator;
  readonly quickStartCard: Locator;
  readonly statsCard: Locator;
  readonly recommendationsSection: Locator;

  constructor(page: Page) {
    super(page, '/home');
    this.trainingButton = page.locator('[data-testid="training-nav"]');
    this.playButton = page.locator('[data-testid="play-nav"]');
    this.coachButton = page.locator('[data-testid="coach-nav"]');
    this.profileButton = page.locator('[data-testid="profile-nav"]');
    this.quickStartCard = page.locator('[data-testid="quick-start"]');
    this.statsCard = page.locator('[data-testid="stats-card"]');
    this.recommendationsSection = page.locator('[data-testid="recommendations"]');
  }

  async navigateToTraining(): Promise<void> {
    await this.trainingButton.click();
  }

  async navigateToPlay(): Promise<void> {
    await this.playButton.click();
  }

  async navigateToCoach(): Promise<void> {
    await this.coachButton.click();
  }

  async navigateToProfile(): Promise<void> {
    await this.profileButton.click();
  }

  async isHomePageVisible(): Promise<boolean> {
    return this.statsCard.isVisible();
  }

  async getWelcomeText(): Promise<string> {
    return this.page.locator('[data-testid="welcome-text"]').textContent() ?? '';
  }
}
