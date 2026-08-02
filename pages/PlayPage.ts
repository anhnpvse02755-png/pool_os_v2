import { Page, Locator } from '@playwright/test';
import { BasePage } from './BasePage';

export class PlayPage extends BasePage {
  readonly quickMatchButton: Locator;
  readonly friendlyMatchButton: Locator;
  readonly matchRecordingCard: Locator;
  readonly matchHistoryCard: Locator;
  readonly tournamentCard: Locator;

  constructor(page: Page) {
    super(page, '/play');
    this.quickMatchButton = page.locator('text=Đấu nhanh, text=Quick Match').first();
    this.friendlyMatchButton = page.locator('text=Giao lưu, text=Friendly').first();
    this.matchRecordingCard = page.locator('[data-testid="match-recording"]');
    this.matchHistoryCard = page.locator('text=Lịch sử đấu, text=Match History').first();
    this.tournamentCard = page.locator('text=Giải đấu, text=Tournament').first();
  }

  async clickQuickMatch(): Promise<void> {
    await this.quickMatchButton.click();
  }

  async clickFriendlyMatch(): Promise<void> {
    await this.friendlyMatchButton.click();
  }

  async clickMatchRecording(): Promise<void> {
    await this.matchRecordingCard.click();
  }

  async clickMatchHistory(): Promise<void> {
    await this.matchHistoryCard.click();
  }

  async isPlayPageVisible(): Promise<boolean> {
    return this.quickMatchButton.isVisible();
  }
}
