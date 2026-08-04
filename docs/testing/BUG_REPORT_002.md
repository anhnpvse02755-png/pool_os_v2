# Bug Report: Navigation Tests Timing Out

## Metadata
- **Report ID**: BUG_002
- **Created**: 2026-08-02
- **Severity**: Medium
- **Category**: Test Flakiness

## Title
Navigation tests timeout when waiting for page load after button click

## Affected Screens
- Auth Flow (Welcome → Onboarding, Welcome → Login)
- Home Screen navigation tests
- Training Center navigation tests
- Play Screen navigation tests

## Reproduction Steps
1. Run Playwright navigation tests
2. Click a button to navigate
3. `page.waitForURL()` times out after 15 seconds

## Expected Result
- Button click triggers navigation
- URL changes to expected pattern
- Test passes

## Actual Result
- Button click may not trigger navigation
- URL does not change within timeout
- Test fails with TimeoutError

## Root Cause
**Likely Root Causes (to investigate):**
1. **Button not visible/clickable** - Element exists but is covered by another element or not in viewport
2. **Navigation not implemented** - Button click doesn't trigger actual navigation
3. **JavaScript error** - Click handler throws error preventing navigation
4. **Race condition** - Navigation happens but before Playwright captures it

## Suggested Investigation
1. Check if buttons have proper click handlers
2. Verify button is not disabled or hidden
3. Check browser console for JavaScript errors
4. Add more specific selectors if button text matching is unreliable

## Artifacts
- Screenshots: Multiple in `test-results/` folder
- Videos: Multiple `.webm` files in `test-results/` folder

## Example Failing Test
```
tests/00-navigation.spec.ts:16
await page.getByRole('button', { name: /bắt đầu|get started/i }).click();
```

## Status
**Requires Investigation - Could be Test Issue or App Issue**
