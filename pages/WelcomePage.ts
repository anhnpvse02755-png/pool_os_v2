import { Page, Locator } from '@playwright/test';
import { BasePage } from './BasePage';

export class WelcomePage extends BasePage {
  readonly getStartedButton: Locator;
  readonly logo: Locator;
  readonly title: Locator;
  readonly subtitle: Locator;

  constructor(page: Page) {
    super(page, '/welcome');
    this.getStartedButton = page.getByRole('button', { name: /bắt đầu|get started/i });
    this.logo = page.locator('app-logo, [data-testid="logo"]');
    this.title = page.locator('h1, [data-testid="title"]');
    this.subtitle = page.locator('[data-testid="subtitle"]');
  }

  async clickGetStarted(): Promise<void> {
    await this.getStartedButton.click();
  }

  async isWelcomeScreenVisible(): Promise<boolean> {
    return this.title.isVisible();
  }
}
