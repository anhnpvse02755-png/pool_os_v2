#!/usr/bin/env node
/**
 * Static file server for the Playwright suite.
 *
 * Serves `build/web` with SPA fallback: any path that isn't a real file
 * returns index.html. Without the fallback, `/welcome` 404s and the page
 * loads with an empty body, which looks exactly like a broken app.
 *
 * Dependency-free on purpose — the E2E job should not need an npm install
 * beyond Playwright itself.
 *
 *   node tools/e2e-server.js [port]
 */

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = Number(process.argv[2] || process.env.PORT || 8080);
const ROOT = path.resolve(__dirname, '..', 'build', 'web');

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.bin': 'application/octet-stream',
  '.map': 'application/json; charset=utf-8',
};

if (!fs.existsSync(path.join(ROOT, 'index.html'))) {
  console.error(
    `[e2e-server] ${ROOT}/index.html not found.\n` +
      `Build the web app first:\n` +
      `  flutter build web --release --base-href /`,
  );
  process.exit(1);
}

const server = http.createServer((req, res) => {
  const urlPath = decodeURIComponent((req.url || '/').split('?')[0]);
  let file = path.join(ROOT, urlPath);

  // Reject traversal, then fall back to index.html for SPA routes.
  const isRealFile =
    file.startsWith(ROOT) && fs.existsSync(file) && fs.statSync(file).isFile();
  if (!isRealFile) {
    file = path.join(ROOT, 'index.html');
  }

  res.writeHead(200, {
    'Content-Type': MIME[path.extname(file)] || 'application/octet-stream',
    'Cache-Control': 'no-store',
  });
  fs.createReadStream(file).pipe(res);
});

server.listen(PORT, () => {
  console.log(`[e2e-server] serving ${ROOT} on http://localhost:${PORT}`);
});
