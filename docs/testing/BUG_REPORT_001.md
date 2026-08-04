# Bug Report: SPA Routes Return 404

## Metadata
- **Report ID**: BUG_001
- **Created**: 2026-08-02
- **Severity**: High
- **Category**: Infrastructure / Testing Setup

## Title
Static server does not support SPA routing - routes return 404 error

## Affected Screens
- /welcome
- /onboarding
- /auth/login
- /auth/register
- /home
- All application routes (except those that match physical files)

## Reproduction Steps
1. Build Flutter web app with `flutter build web`
2. Serve the build directory with Python SimpleHTTPServer
3. Navigate to any application route (e.g., /welcome)
4. Server returns: `404 Not Found`

## Expected Result
- All application routes should be served by returning `index.html`
- Client-side routing should handle the route resolution

## Actual Result
- Python SimpleHTTPServer returns 404 for all routes that don't match physical files
- Only `/index.html` or `/` works, but not `/welcome`, `/home`, etc.

## Root Cause
Python's `http.server` module does not support SPA (Single Page Application) routing by default. It requires configuration to redirect all 404 responses to `index.html`.

## Solution
Replace SimpleHTTPServer with a proper static server that supports SPA routing:

### Option 1: Use http-server with SPA mode
```bash
npx http-server -p 8080 -c-1 --SPA
```

### Option 2: Use serve
```bash
npx serve -s build/web -l 8080
```

### Option 3: Configure Python server
Add a custom handler to redirect all routes to index.html.

## Artifacts
- Screenshot: `test-results/01-welcome-Welcome-Screen-should-have-get-started-button-chromium/test-failed-1.png`
- Video: `test-results/01-welcome-Welcome-Screen-should-have-get-started-button-chromium/video.webm`

## Status
**Test Environment Issue - Not an Application Bug**

The PoolOS Flutter application itself is working correctly. This is a testing infrastructure issue.
