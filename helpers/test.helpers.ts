import { Page } from '@playwright/test';

export async function waitForPageLoad(page: Page, timeout: number = 30000): Promise<void> {
  await page.waitForLoadState('domcontentloaded', { timeout });
  await page.waitForLoadState('networkidle', { timeout }).catch(() => {
    // Ignore networkidle timeout
  });
}

export async function takeScreenshot(page: Page, name: string): Promise<void> {
  await page.screenshot({
    path: `screenshots/${name}-${Date.now()}.png`,
    fullPage: true
  });
}

export async function waitForElementVisible(page: Page, selector: string, timeout: number = 10000): Promise<void> {
  await page.waitForSelector(selector, { state: 'visible', timeout });
}

export async function clickAndWaitForNavigation(page: Page, selector: string): Promise<void> {
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'domcontentloaded' }),
    page.click(selector)
  ]);
}

export function generateTestEmail(): string {
  return `test_${Date.now()}@poolos.test`;
}

export function generateTestName(): string {
  const names = ['Nguyen Van A', 'Tran Van B', 'Le Van C', 'Pham Van D'];
  return names[Math.floor(Math.random() * names.length)];
}
