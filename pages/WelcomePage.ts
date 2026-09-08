import { Page, Locator } from '@playwright/test';
import { BasePage } from './BasePage';

/**
 * Welcome screen — `lib/presentation/screens/onboarding/welcome_screen.dart`.
 *
 * Flutter draws to a canvas, so the only things Playwright can address are
 * nodes in the accessibility tree. Locators here use roles and accessible
 * names; CSS/`data-testid` selectors cannot work because Flutter emits no
 * such attributes (the app sets no `Semantics(identifier:)` anywhere).
 */
export class WelcomePage extends BasePage {
  readonly getStartedButton: Locator;
  readonly existingAccountButton: Locator;

  constructor(page: Page) {
    super(page, '/welcome');
    this.getStartedButton = page.getByRole('button', {
      name: /bắt đầu ngay|get started/i,
    });
    this.existingAccountButton = page.getByRole('button', {
      name: /tôi đã có tài khoản/i,
    });
  }

  async clickGetStarted(): Promise<void> {
    await this.getStartedButton.click();
  }

  async isWelcomeScreenVisible(): Promise<boolean> {
    return this.getStartedButton.isVisible();
  }
}
