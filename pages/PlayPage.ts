import { Page, Locator } from '@playwright/test';
import { BasePage } from './BasePage';

/**
 * Play screen — `lib/presentation/screens/play/play_screen.dart`.
 *
 * Like the Training Center, every destination here is reached with
 * `context.push`, so the browser URL stays put. Assert on the destination
 * screen's content instead.
 */
export class PlayPage extends BasePage {
  readonly quickMatchButton: Locator;
  readonly friendlyMatchButton: Locator;
  readonly matchRecordingButton: Locator;
  readonly matchHistoryButton: Locator;
  readonly tournamentButton: Locator;

  constructor(page: Page) {
    super(page, '/play');
    this.quickMatchButton = page.getByRole('button', { name: /đấu nhanh/i });
    this.friendlyMatchButton = page.getByRole('button', { name: /giao lưu/i });
    this.matchRecordingButton = page.getByRole('button', {
      name: /match recording/i,
    });
    this.matchHistoryButton = page.getByRole('button', {
      name: /lịch sử đấu/i,
    });
    this.tournamentButton = page.getByRole('button', { name: /giải đấu/i });
  }

  async clickQuickMatch(): Promise<void> {
    await this.quickMatchButton.first().click();
  }

  async clickFriendlyMatch(): Promise<void> {
    await this.friendlyMatchButton.first().click();
  }

  async clickMatchHistory(): Promise<void> {
    await this.matchHistoryButton.first().click();
  }

  async isPlayPageVisible(): Promise<boolean> {
    return this.quickMatchButton.first().isVisible();
  }
}
