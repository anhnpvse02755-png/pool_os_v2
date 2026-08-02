import { Page, Locator, expect } from '@playwright/test';

export class BasePage {
  protected page: Page;
  protected url: string;

  constructor(page: Page, url: string = '') {
    this.page = page;
    this.url = url;
  }

  async navigate(): Promise<void> {
    await this.page.goto(this.url, { waitUntil: 'networkidle' });
  }

  async waitForLoadState(): Promise<void> {
    await this.page.waitForLoadState('domcontentloaded');
  }

  async getByRole(role: string, options?: { name?: string | RegExp; exact?: boolean }): Promise<Locator> {
    return this.page.getByRole(role as any, options);
  }

  async getByLabel(label: string | RegExp, options?: { exact?: boolean }): Promise<Locator> {
    return this.page.getByLabel(label, options);
  }

  async getByPlaceholder(placeholder: string | RegExp, options?: { exact?: boolean }): Promise<Locator> {
    return this.page.getByPlaceholder(placeholder, options);
  }

  async getByText(text: string | RegExp, options?: { exact?: boolean }): Promise<Locator> {
    return this.page.getByText(text, options);
  }

  async click(selector: string): Promise<void> {
    await this.page.click(selector);
  }

  async fill(selector: string, value: string): Promise<void> {
    await this.page.fill(selector, value);
  }

  async getText(selector: string): Promise<string> {
    return this.page.textContent(selector) ?? '';
  }

  async isVisible(selector: string): Promise<boolean> {
    return this.page.isVisible(selector);
  }

  async waitForSelector(selector: string, options?: { timeout?: number; state?: 'visible' | 'hidden' | 'attached' | 'detached' }): Promise<void> {
    await this.page.waitForSelector(selector, options);
  }

  async takeScreenshot(name: string): Promise<void> {
    await this.page.screenshot({ path: `screenshots/${name}.png` });
  }
}
