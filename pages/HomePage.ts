import { Page, Locator } from '@playwright/test';
import { BasePage } from './BasePage';

/**
 * Home screen plus the shell's bottom navigation
 * (`lib/presentation/screens/shell/main_shell.dart`).
 *
 * The bar has exactly four destinations — Home, Train, Progress, Profile —
 * and each uses `context.go`, so these navigations do update the browser URL.
 * Note that "Progress" routes to `/coach/analysis`, not `/progress`; there is
 * no bottom-nav entry for Play.
 */
export class HomePage extends BasePage {
  readonly homeTab: Locator;
  readonly trainingTab: Locator;
  readonly progressTab: Locator;
  readonly profileTab: Locator;

  readonly startTrainingButton: Locator;
  readonly startTrainingSessionButton: Locator;
  readonly trainingHistoryButton: Locator;
  readonly knowledgeArticleButton: Locator;
  readonly dailyChallengeButton: Locator;

  constructor(page: Page) {
    super(page, '/home');

    // `exact` matters: "Home" would otherwise also match "Home" inside longer
    // accessible names on the screen body.
    this.homeTab = page.getByRole('button', { name: 'Home', exact: true });
    this.trainingTab = page.getByRole('button', { name: 'Train', exact: true });
    this.progressTab = page.getByRole('button', {
      name: 'Progress',
      exact: true,
    });
    this.profileTab = page.getByRole('button', { name: 'Profile', exact: true });

    this.startTrainingButton = page.getByRole('button', {
      name: /^start training$/i,
    });
    this.startTrainingSessionButton = page.getByRole('button', {
      name: /start training session/i,
    });
    this.trainingHistoryButton = page.getByRole('button', {
      name: /view training history/i,
    });
    this.knowledgeArticleButton = page.getByRole('button', {
      name: /read knowledge article/i,
    });
    this.dailyChallengeButton = page.getByRole('button', {
      name: /daily challenge/i,
    });
  }

  async navigateToTraining(): Promise<void> {
    await this.trainingTab.click();
  }

  /** The Progress tab opens the coach analysis screen (`/coach/analysis`). */
  async navigateToProgress(): Promise<void> {
    await this.progressTab.click();
  }

  async navigateToProfile(): Promise<void> {
    await this.profileTab.click();
  }

  async isHomePageVisible(): Promise<boolean> {
    return this.startTrainingButton.isVisible();
  }
}
