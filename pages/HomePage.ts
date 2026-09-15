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

    // `exact` matters: "Trang chủ" would otherwise also match inside longer
    // accessible names on the screen body.
    this.homeTab = page.getByRole('button', { name: 'Trang chủ', exact: true });
    this.trainingTab = page.getByRole('button', { name: 'Luyện tập', exact: true });
    this.progressTab = page.getByRole('button', {
      name: 'Tiến độ',
      exact: true,
    });
    this.profileTab = page.getByRole('button', { name: 'Hồ sơ', exact: true });

    // CTA chinh cua the hero tro ve man "Buoi tap hom nay". Nhan
    // "Bắt đầu luyện tập" chi con o hai nut empty-state, khong hien khi
    // nguoi dung da co du lieu — bam vao do thi test do o moi tai khoan that.
    this.startTrainingButton = page.getByRole('button', {
      name: /^buổi tập hôm nay$/i,
    });
    this.startTrainingSessionButton = page.getByRole('button', {
      name: /bắt đầu buổi tập/i,
    });
    this.trainingHistoryButton = page.getByRole('button', {
      name: /xem lịch sử luyện tập/i,
    });
    this.knowledgeArticleButton = page.getByRole('button', {
      name: /đọc bài kiến thức/i,
    });
    this.dailyChallengeButton = page.getByRole('button', {
      name: /thử thách hôm nay/i,
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
