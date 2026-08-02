import { Page, Locator } from '@playwright/test';
import { BasePage } from './BasePage';

export class OnboardingPage extends BasePage {
  readonly continueButton: Locator;
  readonly skipButton: Locator;
  readonly stepIndicator: Locator;
  readonly featureCards: Locator;

  constructor(page: Page) {
    super(page, '/onboarding');
    this.continueButton = page.getByRole('button', { name: /tiếp tục|continue|tiếp|theo/i });
    this.skipButton = page.getByRole('button', { name: /bỏ qua|skip/i });
    this.stepIndicator = page.locator('[data-testid="step-indicator"]');
    this.featureCards = page.locator('.feature-card, [data-testid="feature-card"]');
  }

  async clickContinue(): Promise<void> {
    await this.continueButton.click();
  }

  async clickSkip(): Promise<void> {
    await this.skipButton.click();
  }

  async isOnboardingVisible(): Promise<boolean> {
    return this.continueButton.isVisible();
  }
}
