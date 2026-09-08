import { test as base, Page, Response } from '@playwright/test';
import { WelcomePage } from '../pages/WelcomePage';
import { OnboardingPage } from '../pages/OnboardingPage';
import { HomePage } from '../pages/HomePage';
import { TrainingCenterPage } from '../pages/TrainingCenterPage';
import { PlayPage } from '../pages/PlayPage';

type AppFixtures = {
  welcomePage: WelcomePage;
  onboardingPage: OnboardingPage;
  homePage: HomePage;
  trainingCenterPage: TrainingCenterPage;
  playPage: PlayPage;
};

/** Flutter's engine and first frame can take several seconds in a release build. */
const APP_BOOT_TIMEOUT = 30_000;

/**
 * Rewrite a path URL into the hash form GoRouter actually reads.
 *
 * The app runs on Flutter's default hash URL strategy (no `usePathUrlStrategy`
 * in main.dart), so the route lives in the fragment. Navigating to `/home`
 * makes the static server return index.html and the router then boots at its
 * own `initialLocation` — `/welcome` — leaving you on the wrong screen with a
 * URL of `/home#/welcome`. `/#/home` is what actually opens Home.
 */
export function toHashRoute(url: string): string {
  if (url.includes('#')) return url;
  const match = /^(https?:\/\/[^/]+)?(\/.*)?$/.exec(url);
  if (!match) return url;
  return `${match[1] ?? ''}/#${match[2] ?? '/'}`;
}

/**
 * Block until the Flutter app is genuinely interrogable by Playwright.
 *
 * Two things have to happen after `goto` resolves, and neither is implied by
 * the `load` event:
 *
 *  1. The engine boots and paints. Until then `document.title` is still the
 *     static `pool_os_v2` from index.html rather than the app's `PoolOS`.
 *  2. The accessibility tree is built. Flutter renders into a canvas, so
 *     `getByRole` / `getByText` see nothing at all until the semantics tree
 *     exists — and Flutter only builds it once the `flt-semantics-placeholder`
 *     element is activated.
 *
 * The placeholder is deliberately positioned outside the viewport, so
 * `locator.click()` fails its actionability check ("Element is outside of the
 * viewport"). `dispatchEvent` bypasses that check.
 */
export async function waitForAppReady(page: Page): Promise<void> {
  await page.waitForSelector('flutter-view', {
    state: 'attached',
    timeout: APP_BOOT_TIMEOUT,
  });

  const placeholder = page.locator('flt-semantics-placeholder');
  await placeholder
    .waitFor({ state: 'attached', timeout: APP_BOOT_TIMEOUT })
    // Already activated by an earlier navigation in the same page — fine.
    .catch(() => undefined);

  if ((await placeholder.count()) > 0) {
    await placeholder.dispatchEvent('click');
  }

  // `flt-semantics-host` exists from the start but stays empty; it gains an
  // `flt-semantics` child only once a frame has been described. That makes a
  // non-zero child count a reliable "app is rendered and readable" signal.
  await page.waitForFunction(
    () => {
      const host = document.querySelector('flt-semantics-host');
      return !!host && host.childElementCount > 0;
    },
    undefined,
    { timeout: APP_BOOT_TIMEOUT },
  );
}

export const test = base.extend<AppFixtures>({
  // Wrap `goto` so every spec gets hash-correct routing and a booted app
  // without repeating the boilerplate. Fixing it here covers all specs.
  page: async ({ page }, use) => {
    const nativeGoto = page.goto.bind(page);

    page.goto = async (
      url: string,
      options?: Parameters<Page['goto']>[1],
    ): Promise<Response | null> => {
      const response = await nativeGoto(toHashRoute(url), options);
      await waitForAppReady(page);
      return response;
    };

    await use(page);
  },

  welcomePage: async ({ page }, use) => {
    const welcomePage = new WelcomePage(page);
    await use(welcomePage);
  },

  onboardingPage: async ({ page }, use) => {
    const onboardingPage = new OnboardingPage(page);
    await use(onboardingPage);
  },

  homePage: async ({ page }, use) => {
    const homePage = new HomePage(page);
    await use(homePage);
  },

  trainingCenterPage: async ({ page }, use) => {
    const trainingCenterPage = new TrainingCenterPage(page);
    await use(trainingCenterPage);
  },

  playPage: async ({ page }, use) => {
    const playPage = new PlayPage(page);
    await use(playPage);
  },
});

export { expect } from '@playwright/test';
