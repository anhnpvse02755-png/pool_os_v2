import { test as base, Page } from '@playwright/test';
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

export const test = base.extend<AppFixtures>({
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
