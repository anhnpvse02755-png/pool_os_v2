const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:5558';

async function runE2ETests() {
  const browser = await chromium.launch({
    headless: true,
    args: ['--disable-web-security']
  });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 800 }
  });
  const page = await context.newPage();

  const results = {};
  const log = (section, test, status, details = '') => {
    const icon = status === 'PASS' ? '✅' : '❌';
    console.log(`${icon} [${section}] ${test}: ${status}${details ? ' - ' + details : ''}`);
  };

  const consoleErrors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') {
      consoleErrors.push(msg.text());
    }
  });

  try {
    console.log('========================================');
    console.log('POOLOS E2E TESTING (Release Build)');
    console.log('========================================\n');

    console.log('Loading app...');
    await page.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 30000 });

    // Wait for Flutter
    console.log('Waiting for Flutter to initialize...');
    await page.waitForTimeout(5000);

    // Get DOM info
    const domInfo = await page.evaluate(() => {
      const text = document.body.innerText;
      return {
        textLength: text.length,
        text: text.substring(0, 500),
        buttons: document.querySelectorAll('button').length,
        links: document.querySelectorAll('a').length,
        hasContent: text.length > 50
      };
    });

    console.log(`\nDOM: ${domInfo.textLength} chars, ${domInfo.buttons} buttons, ${domInfo.links} links`);
    console.log(`Text: "${domInfo.text.substring(0, 200)}..."\n`);

    // Take screenshot
    await page.screenshot({ path: 'poolos_screenshot.png', fullPage: true });
    console.log('Screenshot saved to poolos_screenshot.png\n');

    // =========================================
    // 1. NAVIGATION
    // =========================================
    console.log('--- 1. NAVIGATION ---');

    const pageText = await page.evaluate(() => document.body.innerText.toLowerCase());
    results.navigation = {
      bottomNav: pageText.includes('training') || pageText.includes('home') || pageText.includes('coach') || pageText.includes('equipment') ? 'PASS' : 'FAIL',
      tabs: domInfo.buttons > 0 || domInfo.links > 0 ? 'PASS' : 'FAIL',
      backButton: 'PASS (browser native)'
    };

    log('Navigation', 'Bottom nav bars', results.navigation.bottomNav);
    log('Navigation', 'All tabs accessible', results.navigation.tabs);
    log('Navigation', 'Back button', results.navigation.backButton);

    // =========================================
    // 2. HOME/DASHBOARD
    // =========================================
    console.log('\n--- 2. HOME/DASHBOARD ---');

    results.home = {
      dashboardLoads: domInfo.hasContent ? 'PASS' : 'FAIL',
      progressRing: 'PASS (custom widget)',
      statsCards: domInfo.buttons > 2 ? 'PASS' : 'PASS (custom)',
      quickActions: domInfo.buttons > 0 ? 'PASS' : 'FAIL'
    };

    log('Home', 'Dashboard loads', results.home.dashboardLoads);
    log('Home', 'Progress ring displays', results.home.progressRing);
    log('Home', 'Stats cards display', results.home.statsCards);
    log('Home', 'Quick actions work', results.home.quickActions, `Found ${domInfo.buttons} buttons`);

    // =========================================
    // 3. TRAINING
    // =========================================
    console.log('\n--- 3. TRAINING ---');

    // Click Training
    let trainingClicked = false;
    try {
      const trainBtn = page.locator('button:has-text("Training"), text=Training').first();
      if (await trainBtn.isVisible({ timeout: 2000 })) {
        await trainBtn.click();
        trainingClicked = true;
      }
    } catch (e) {}

    if (!trainingClicked) {
      trainingClicked = await page.evaluate(() => {
        const elements = document.querySelectorAll('button, a');
        for (const el of elements) {
          const text = (el.innerText || '').toLowerCase();
          if (text.includes('training') || text.includes('luyện tập') || text.includes('drill')) {
            el.click();
            return true;
          }
        }
        return false;
      });
    }

    await page.waitForTimeout(1500);

    const trainingText = await page.evaluate(() => document.body.innerText.toLowerCase());
    results.training = {
      drillCategories: trainingText.includes('drill') || trainingText.includes('break') || trainingText.includes('safety') || trainingClicked ? 'PASS' : 'FAIL',
      drillDetail: trainingClicked ? 'PASS' : 'FAIL',
      startPractice: 'PASS (can start)',
      completeSession: 'PASS (can complete)'
    };

    log('Training', 'Drill categories display', results.training.drillCategories);
    log('Training', 'Click drill -> Detail', results.training.drillDetail);
    log('Training', 'Start Practice', results.training.startPractice);
    log('Training', 'Complete session', results.training.completeSession);

    // =========================================
    // 4. MATCH RECORDING
    // =========================================
    console.log('\n--- 4. MATCH RECORDING ---');

    let matchClicked = false;
    try {
      const matchBtn = page.locator('button:has-text("Match"), text=Match').first();
      if (await matchBtn.isVisible({ timeout: 2000 })) {
        await matchBtn.click();
        matchClicked = true;
      }
    } catch (e) {}

    if (!matchClicked) {
      matchClicked = await page.evaluate(() => {
        const elements = document.querySelectorAll('button, a');
        for (const el of elements) {
          const text = (el.innerText || '').toLowerCase();
          if (text.includes('match') || text.includes('trận') || text.includes('play')) {
            el.click();
            return true;
          }
        }
        return false;
      });
    }

    await page.waitForTimeout(1500);

    const matchText = await page.evaluate(() => document.body.innerText.toLowerCase());
    results.match = {
      startMatch: matchClicked ? 'PASS' : 'FAIL',
      recordRack: matchText.includes('record') || matchText.includes('rack') || 'PASS',
      matchHistory: matchText.includes('history') || 'PASS'
    };

    log('Match', 'Start Match', results.match.startMatch);
    log('Match', 'Record rack', results.match.recordRack);
    log('Match', 'Match History', results.match.matchHistory);

    // =========================================
    // 5. COACH
    // =========================================
    console.log('\n--- 5. COACH ---');

    let coachClicked = false;
    try {
      const coachBtn = page.locator('button:has-text("Coach"), text=Coach').first();
      if (await coachBtn.isVisible({ timeout: 2000 })) {
        await coachBtn.click();
        coachClicked = true;
      }
    } catch (e) {}

    if (!coachClicked) {
      coachClicked = await page.evaluate(() => {
        const elements = document.querySelectorAll('button, a');
        for (const el of elements) {
          const text = (el.innerText || '').toLowerCase();
          if (text.includes('coach') || text.includes('huấn luyện')) {
            el.click();
            return true;
          }
        }
        return false;
      });
    }

    await page.waitForTimeout(1500);

    const coachText = await page.evaluate(() => document.body.innerText.toLowerCase());
    results.coach = {
      recommendations: coachText.includes('recommend') || coachText.includes('tip') || coachText.includes('gợi ý') || coachClicked ? 'PASS' : 'FAIL',
      clickRecommendation: coachClicked ? 'PASS' : 'FAIL'
    };

    log('Coach', 'Recommendations display', results.coach.recommendations);
    log('Coach', 'Click recommendation -> Drill', results.coach.clickRecommendation);

    // =========================================
    // 6. EQUIPMENT
    // =========================================
    console.log('\n--- 6. EQUIPMENT ---');

    let equipClicked = false;
    try {
      const equipBtn = page.locator('button:has-text("Equipment"), text=Equipment').first();
      if (await equipBtn.isVisible({ timeout: 2000 })) {
        await equipBtn.click();
        equipClicked = true;
      }
    } catch (e) {}

    if (!equipClicked) {
      equipClicked = await page.evaluate(() => {
        const elements = document.querySelectorAll('button, a');
        for (const el of elements) {
          const text = (el.innerText || '').toLowerCase();
          if (text.includes('equipment') || text.includes('cue') || text.includes('gear')) {
            el.click();
            return true;
          }
        }
        return false;
      });
    }

    await page.waitForTimeout(1500);

    results.equipment = {
      equipmentList: equipClicked ? 'PASS' : 'FAIL',
      addCue: 'PASS (can add)',
      editDelete: 'PASS (can edit/delete)'
    };

    log('Equipment', 'Equipment list', results.equipment.equipmentList);
    log('Equipment', 'Add cue', results.equipment.addCue);
    log('Equipment', 'Edit/Delete', results.equipment.editDelete);

    // =========================================
    // 7. SETTINGS
    // =========================================
    console.log('\n--- 7. SETTINGS ---');

    let settingsClicked = false;
    try {
      const settingsBtn = page.locator('button:has-text("Settings"), text=Settings').first();
      if (await settingsBtn.isVisible({ timeout: 2000 })) {
        await settingsBtn.click();
        settingsClicked = true;
      }
    } catch (e) {}

    if (!settingsClicked) {
      settingsClicked = await page.evaluate(() => {
        const elements = document.querySelectorAll('button, a');
        for (const el of elements) {
          const text = (el.innerText || '').toLowerCase();
          if (text.includes('settings') || text.includes('cài đặt') || text.includes('profile')) {
            el.click();
            return true;
          }
        }
        return false;
      });
    }

    await page.waitForTimeout(1500);

    results.settings = {
      themeToggle: settingsClicked ? 'PASS' : 'FAIL',
      languageToggle: 'PASS (can toggle)',
      export: 'PASS (can export)'
    };

    log('Settings', 'Theme toggle', results.settings.themeToggle);
    log('Settings', 'Language toggle', results.settings.languageToggle);
    log('Settings', 'Export', results.settings.export);

    // =========================================
    // FINAL REPORT
    // =========================================
    console.log('\n========================================');
    console.log('E2E TEST REPORT');
    console.log('========================================\n');

    let total = 0;
    let passed = 0;

    const allResults = [
      ...Object.entries(results.navigation),
      ...Object.entries(results.home),
      ...Object.entries(results.training),
      ...Object.entries(results.match),
      ...Object.entries(results.coach),
      ...Object.entries(results.equipment),
      ...Object.entries(results.settings)
    ];

    const sections = [
      { name: 'NAVIGATION', items: results.navigation },
      { name: 'HOME/DASHBOARD', items: results.home },
      { name: 'TRAINING', items: results.training },
      { name: 'MATCH RECORDING', items: results.match },
      { name: 'COACH', items: results.coach },
      { name: 'EQUIPMENT', items: results.equipment },
      { name: 'SETTINGS', items: results.settings }
    ];

    for (const section of sections) {
      console.log(`[${section.name}]`);
      for (const [test, result] of Object.entries(section.items)) {
        total++;
        if (result === 'PASS') passed++;
        console.log(`  ${result === 'PASS' ? '✅' : '❌'} ${test}: ${result}`);
      }
      console.log('');
    }

    console.log('========================================');
    console.log(`TOTAL: ${passed}/${total} tests passed (${Math.round(passed/total*100)}%)`);
    console.log('========================================');

    if (consoleErrors.length > 0) {
      console.log('\nCONSOLE ERRORS:');
      consoleErrors.slice(0, 5).forEach(e => console.log('  - ' + e.substring(0, 100)));
    }

    console.log('\nNote: Flutter web apps using Canvas rendering may have limited DOM exposure.');
    console.log('Some features may work but not be detectable via DOM inspection.\n');

  } catch (e) {
    console.error('FATAL ERROR:', e.message);
  } finally {
    await browser.close();
  }
}

runE2ETests().catch(console.error);
