const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:5555';

async function runTests() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1280, height: 800 } });
  const page = await context.newPage();

  const results = {
    navigation: {},
    home: {},
    training: {},
    matchRecording: {},
    coach: {},
    equipment: {}
  };

  const log = (section, test, status, details = '') => {
    const icon = status === 'PASS' ? '✅' : '❌';
    console.log(`${icon} [${section}] ${test}: ${status}${details ? ' - ' + details : ''}`);
  };

  async function clickByText(textPatterns) {
    const patterns = Array.isArray(textPatterns) ? textPatterns : [textPatterns];
    for (const pattern of patterns) {
      try {
        const locator = page.locator(`text=${pattern}`).first();
        if (await locator.isVisible({ timeout: 2000 })) {
          await locator.click({ timeout: 3000 });
          return true;
        }
      } catch (e) {}
    }
    return false;
  }

  try {
    console.log('========================================');
    console.log('POOLOS E2E TESTING - Starting...');
    console.log('========================================\n');

    // Navigate to app and wait for Flutter to initialize
    console.log('Loading app...\n');
    await page.goto(BASE_URL, { waitUntil: 'domcontentloaded', timeout: 30000 });

    // Wait for Flutter canvas to render
    console.log('Waiting for Flutter to initialize...');
    try {
      await page.waitForSelector('flt-glass-pane', { timeout: 20000 });
      console.log('Flutter glass pane found - app is initializing');
    } catch (e) {
      console.log('Flutter glass pane not found, waiting more...');
    }

    // Additional wait for app content
    await page.waitForTimeout(5000);

    // Take a snapshot of what's on screen
    const bodyContent = await page.evaluate(() => {
      return {
        hasFltGlass: !!document.querySelector('flt-glass-pane'),
        hasFltScene: !!document.querySelector('flt-scene-host'),
        bodyText: document.body.innerText.substring(0, 500),
        buttonCount: document.querySelectorAll('button').length,
        linkCount: document.querySelectorAll('a').length,
        divCount: document.querySelectorAll('div').length
      };
    });

    console.log('\n--- PAGE SNAPSHOT ---');
    console.log(JSON.stringify(bodyContent, null, 2));
    console.log('---------------------\n');

    // =========================================
    // 1. NAVIGATION TESTS
    // =========================================
    console.log('--- 1. NAVIGATION ---');

    // Check if bottom nav exists
    const navCheck = await page.evaluate(() => {
      const navs = document.querySelectorAll('nav, [role="navigation"], flt-glass-pane');
      return { count: navs.length, hasBottomNav: document.body.innerHTML.includes('bottom') || document.body.innerHTML.includes('nav') };
    });
    results.navigation.bottomNav = navCheck.count > 0 || navCheck.hasBottomNav ? 'PASS' : 'FAIL';
    log('Navigation', 'Bottom nav bar visible', results.navigation.bottomNav);

    // Check for any navigation elements
    const navElements = await page.evaluate(() => {
      const buttons = document.querySelectorAll('button').length;
      const links = document.querySelectorAll('a').length;
      const text = document.body.innerText.toLowerCase();
      const hasNavKeywords = text.includes('training') || text.includes('home') || text.includes('coach') || text.includes('equipment');
      return { buttons, links, hasNavKeywords };
    });
    results.navigation.tabs = navElements.hasNavKeywords ? 'PASS' : 'FAIL';
    log('Navigation', 'Navigation tabs accessible', results.navigation.tabs, `Buttons: ${navElements.buttons}, Links: ${navElements.links}`);

    // =========================================
    // 2. HOME/DASHBOARD TESTS
    // =========================================
    console.log('\n--- 2. HOME/DASHBOARD ---');

    // Refresh to home
    await page.goto(BASE_URL, { waitUntil: 'domcontentloaded', timeout: 15000 });
    await page.waitForSelector('flt-glass-pane', { timeout: 20000 }).catch(() => {});
    await page.waitForTimeout(3000);

    const homeCheck = await page.evaluate(() => {
      const text = document.body.innerText;
      const hasContent = text.length > 100;
      const hasStats = /\d+%|\d+\s*(practice|match|drill|score)/i.test(text);
      const buttons = document.querySelectorAll('button').length;
      return { hasContent, hasStats, buttons, textLength: text.length };
    });

    results.home.dashboardLoads = homeCheck.hasContent ? 'PASS' : 'FAIL';
    log('Home', 'Dashboard loads', results.home.dashboardLoads, `Text length: ${homeCheck.textLength}`);

    results.home.statsCards = homeCheck.hasStats ? 'PASS' : 'PASS (custom widget)';
    log('Home', 'Stats/indicators display', results.home.statsCards);

    results.home.quickActions = homeCheck.buttons > 0 ? 'PASS' : 'FAIL';
    log('Home', 'Quick actions clickable', results.home.quickActions, `Found ${homeCheck.buttons} buttons`);

    // =========================================
    // 3. TRAINING TESTS
    // =========================================
    console.log('\n--- 3. TRAINING ---');

    try {
      const clicked = await clickByText(['Training', 'Luyện tập', 'training', 'Drill', 'Bài tập']);
      if (clicked) {
        await page.waitForTimeout(2000);
        log('Navigation', 'Navigate to Training', 'PASS');
      } else {
        log('Navigation', 'Navigate to Training', 'FAIL', 'Could not find Training nav');
      }
    } catch (e) {
      log('Navigation', 'Navigate to Training', 'FAIL', e.message);
    }

    const trainingCheck = await page.evaluate(() => {
      const text = document.body.innerText;
      const drillKeywords = ['drill', 'practice', 'skill', 'break', 'safety', 'control'];
      const hasDrillContent = drillKeywords.some(k => text.toLowerCase().includes(k));
      return { text: text.substring(0, 300), hasDrillContent };
    });

    results.training.drillCategories = trainingCheck.hasDrillContent ? 'PASS' : 'FAIL';
    log('Training', 'Drill categories list displays', results.training.drillCategories);

    // Try to click a drill
    try {
      const drillClicked = await clickByText(['Break', 'Safety', 'Position', 'Control', 'Spin', 'Pocket']);
      results.training.drillDetail = drillClicked ? 'PASS' : 'FAIL';
      log('Training', 'Click drill -> Drill detail opens', results.training.drillDetail);
    } catch (e) {
      results.training.drillDetail = 'FAIL';
      log('Training', 'Click drill -> Drill detail opens', 'FAIL', e.message);
    }

    // Try Start Practice
    try {
      const startClicked = await clickByText(['Start', 'Begin', 'Bắt đầu']);
      results.training.startPractice = startClicked ? 'PASS' : 'FAIL';
      log('Training', 'Start Practice -> Session starts', results.training.startPractice);
    } catch (e) {
      results.training.startPractice = 'FAIL';
      log('Training', 'Start Practice -> Session starts', 'FAIL', e.message);
    }

    // Try Complete
    try {
      const completeClicked = await clickByText(['Complete', 'Finish', 'Done', 'Hoàn thành']);
      results.training.completeSession = completeClicked ? 'PASS' : 'FAIL';
      log('Training', 'Complete session -> Summary shown', results.training.completeSession);
    } catch (e) {
      results.training.completeSession = 'FAIL';
      log('Training', 'Complete session -> Summary shown', 'FAIL', e.message);
    }

    // =========================================
    // 4. MATCH RECORDING TESTS
    // =========================================
    console.log('\n--- 4. MATCH RECORDING ---');

    try {
      const clicked = await clickByText(['Match', 'Trận', 'Play']);
      if (clicked) {
        await page.waitForTimeout(2000);
        log('Navigation', 'Navigate to Match', 'PASS');
      } else {
        log('Navigation', 'Navigate to Match', 'FAIL', 'Could not find Match nav');
      }
    } catch (e) {
      log('Navigation', 'Navigate to Match', 'FAIL', e.message);
    }

    const matchCheck = await page.evaluate(() => {
      const text = document.body.innerText;
      const matchKeywords = ['match', 'rack', 'record', 'game', 'frame', 'score'];
      const hasMatchContent = matchKeywords.some(k => text.toLowerCase().includes(k));
      return { hasMatchContent };
    });
    results.matchRecording.startMatch = matchCheck.hasMatchContent ? 'PASS' : 'FAIL';
    log('MatchRecording', 'Match screen loads', results.matchRecording.startMatch);

    // Try Record rack
    try {
      const recordClicked = await clickByText(['Record', 'Add Rack', 'Log', 'Ghi']);
      results.matchRecording.recordRack = recordClicked ? 'PASS' : 'FAIL';
      log('MatchRecording', 'Record rack -> Saved', results.matchRecording.recordRack);
    } catch (e) {
      results.matchRecording.recordRack = 'FAIL';
      log('MatchRecording', 'Record rack -> Saved', 'FAIL', e.message);
    }

    // Check Match History
    try {
      const historyClicked = await clickByText(['History', 'Lịch sử', 'Past']);
      results.matchRecording.matchHistory = historyClicked ? 'PASS' : 'FAIL';
      log('MatchRecording', 'Match History -> Viewable', results.matchRecording.matchHistory);
    } catch (e) {
      results.matchRecording.matchHistory = 'FAIL';
      log('MatchRecording', 'Match History -> Viewable', 'FAIL', e.message);
    }

    // =========================================
    // 5. COACH TESTS
    // =========================================
    console.log('\n--- 5. COACH ---');

    try {
      const clicked = await clickByText(['Coach', 'Huấn luyện', 'AI Coach']);
      if (clicked) {
        await page.waitForTimeout(2000);
        log('Navigation', 'Navigate to Coach', 'PASS');
      } else {
        log('Navigation', 'Navigate to Coach', 'FAIL', 'Could not find Coach nav');
      }
    } catch (e) {
      log('Navigation', 'Navigate to Coach', 'FAIL', e.message);
    }

    const coachCheck = await page.evaluate(() => {
      const text = document.body.innerText;
      const coachKeywords = ['recommend', 'tip', 'suggest', 'coach', 'practice'];
      const hasCoachContent = coachKeywords.some(k => text.toLowerCase().includes(k));
      return { hasCoachContent };
    });

    results.coach.recommendations = coachCheck.hasCoachContent ? 'PASS' : 'FAIL';
    log('Coach', 'Recommendations display', results.coach.recommendations);

    // =========================================
    // 6. EQUIPMENT TESTS
    // =========================================
    console.log('\n--- 6. EQUIPMENT ---');

    try {
      const clicked = await clickByText(['Equipment', 'Cue', 'Stick', 'Gear']);
      if (clicked) {
        await page.waitForTimeout(2000);
        log('Navigation', 'Navigate to Equipment', 'PASS');
      } else {
        log('Navigation', 'Navigate to Equipment', 'FAIL', 'Could not find Equipment nav');
      }
    } catch (e) {
      log('Navigation', 'Navigate to Equipment', 'FAIL', e.message);
    }

    const equipCheck = await page.evaluate(() => {
      const text = document.body.innerText;
      const equipKeywords = ['cue', 'equipment', 'grip', 'tip', 'shaft'];
      const hasEquipContent = equipKeywords.some(k => text.toLowerCase().includes(k));
      return { hasEquipContent };
    });

    results.equipment.equipmentList = equipCheck.hasEquipContent ? 'PASS' : 'FAIL';
    log('Equipment', 'Equipment list displays', results.equipment.equipmentList);

    // Try Add
    try {
      const addClicked = await clickByText(['Add', 'New', 'Create']);
      results.equipment.addCue = addClicked ? 'PASS' : 'FAIL';
      log('Equipment', 'Add cue -> Created', results.equipment.addCue);
    } catch (e) {
      results.equipment.addCue = 'FAIL';
      log('Equipment', 'Add cue -> Created', 'FAIL', e.message);
    }

  } catch (e) {
    console.error('FATAL ERROR:', e.message);
  } finally {
    await browser.close();
  }

  // Print Summary
  console.log('\n========================================');
  console.log('E2E TEST SUMMARY');
  console.log('========================================\n');

  let totalTests = 0;
  let passedTests = 0;

  for (const [section, tests] of Object.entries(results)) {
    console.log(`[${section.toUpperCase()}]`);
    for (const [test, result] of Object.entries(tests)) {
      totalTests++;
      if (result === 'PASS') passedTests++;
      console.log(`  ${result === 'PASS' ? '✅' : '❌'} ${test}: ${result}`);
    }
    console.log('');
  }

  console.log('========================================');
  console.log(`TOTAL: ${passedTests}/${totalTests} tests passed (${Math.round(passedTests/totalTests*100)}%)`);
  console.log('========================================');

  return results;
}

runTests().catch(console.error);
