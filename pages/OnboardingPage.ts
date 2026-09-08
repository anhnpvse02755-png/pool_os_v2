import { Page, Locator } from '@playwright/test';
import { BasePage } from './BasePage';

/**
 * Onboarding — `lib/presentation/screens/onboarding/onboarding_screen.dart`.
 *
 * A multi-step wizard: an intro, a ranking explainer, then seven profile
 * questions. Every step advances with the same "Tiếp tục" button and each
 * question carries a default answer, so the flow can be walked without
 * choosing anything. Only the final step calls `context.go('/home')`.
 *
 * There is no skip control on this screen.
 */
export class OnboardingPage extends BasePage {
  readonly continueButton: Locator;
  readonly finishButton: Locator;
  /** Whichever of the two advances the current step. */
  readonly advanceButton: Locator;
  readonly backButton: Locator;

  /** Intro + ranking + assessment + 7 questions, with re-render headroom. */
  private static readonly MAX_STEPS = 20;

  constructor(page: Page) {
    super(page, '/onboarding');
    this.continueButton = page.getByRole('button', {
      name: /tiếp tục|continue/i,
    });
    // The last question swaps the label to "Bắt đầu" rather than "Tiếp tục".
    this.finishButton = page.getByRole('button', { name: /^bắt đầu$/i });
    this.advanceButton = this.continueButton.or(this.finishButton);
    this.backButton = page.getByRole('button', { name: /quay lại|back/i });
  }

  async clickContinue(): Promise<void> {
    await this.continueButton.first().click();
  }

  /**
   * Walk every step until the app lands on Home.
   *
   * Returns once the URL reports `/home` — the last step navigates with
   * `context.go`, which does update the browser URL.
   *
   * Between clicks it waits for the rendered semantics to actually change
   * rather than sleeping a fixed amount: the steps re-render at uneven
   * speeds, and a fixed delay is either flaky or needlessly slow.
   */
  async completeFlow(): Promise<void> {
    for (let step = 0; step < OnboardingPage.MAX_STEPS; step++) {
      if (this.page.url().includes('/home')) return;

      // The button drops out of the semantics tree while a step re-renders,
      // so a bare count check would give up mid-flow. Wait for it to come
      // back and only stop if it genuinely never does.
      try {
        await this.advanceButton
          .first()
          .waitFor({ state: 'visible', timeout: 5_000 });
      } catch {
        break;
      }

      const before = await this.semanticsText();
      await this.advanceButton.first().click();

      await this.page
        .waitForFunction(
          (previous) => {
            if (location.hash.includes('/home')) return true;
            const host = document.querySelector('flt-semantics-host');
            return !!host && host.textContent !== previous;
          },
          before,
          { timeout: 10_000 },
        )
        .catch(() => undefined);
    }

    await this.page.waitForURL(/\/home/, { timeout: 15_000 });
  }

  /** Whole accessibility subtree as text — a cheap "did the step change" key. */
  private semanticsText(): Promise<string> {
    return this.page.evaluate(
      () => document.querySelector('flt-semantics-host')?.textContent ?? '',
    );
  }

  async isOnboardingVisible(): Promise<boolean> {
    return this.continueButton.first().isVisible();
  }
}
