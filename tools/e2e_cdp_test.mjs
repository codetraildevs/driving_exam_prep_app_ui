// E2E smoke test for the deployed Flutter web app against the live backend.
// Drives the installed Chrome via the DevTools Protocol (no puppeteer needed).
//
// Covers:
//   1. App boots, consent + language dialogs dismissed
//   2. Login with an unregistered phone → server JSON error (CORS not blocked)
//   3. Registration with a THROWAWAY account (random phone) → lands on /home
//   4. Practice page → exam grid loads from bundled assets
//   5. Tapping a paid exam → subscription page renders with plan cards
//
// NOTE: step 3 creates a real account in the production database. At the end
// of the run the script auto-deletes that same account (self-delete via its own
// token), and the phone number is printed as a fallback for manual cleanup.
import { spawn } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

// ── SAFETY GATE ────────────────────────────────────────────────────────────
// Registration creates a REAL account in the PRODUCTION database. Refuse to
// run the registration phase unless explicitly opted in.
const ALLOW_PROD = process.env.E2E_ALLOW_PROD === '1';
if (!ALLOW_PROD) {
  console.error(
    '❌ Refusing to run against production without opt-in.\n' +
    '   Registration creates a real account in the production DB.\n' +
    '   Set E2E_ALLOW_PROD=1 to confirm you accept creating throwaway accounts.',
  );
  process.exit(2);
}
console.log('⚠️  E2E_ALLOW_PROD=1 — registration will create a throwaway account in production.');

// Chrome binary: allow an explicit override (CI), then detect per-platform.
function findChrome() {
  if (process.env.CHROME_PATH) return existsSync(process.env.CHROME_PATH) ? process.env.CHROME_PATH : undefined;
  const candidates =
    process.platform === 'win32'
      ? [
          'C:/Program Files/Google/Chrome/Application/chrome.exe',
          'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
        ]
      : process.platform === 'darwin'
        ? ['/Applications/Google Chrome.app/Contents/MacOS/Google Chrome']
        : [
            '/usr/bin/google-chrome',
            '/usr/bin/google-chrome-stable',
            '/usr/bin/chromium',
            '/usr/bin/chromium-browser',
          ];
  return candidates.find((p) => existsSync(p));
}
const CHROME = findChrome();
if (!CHROME) {
  console.error(
    '❌ Chrome/Chromium not found. Install it or point CHROME_PATH at the binary.',
  );
  process.exit(2);
}
const URL = 'https://learn-traffic-rules-cbbd1.web.app';
const PORT = 9333;
const userData = mkdtempSync(join(tmpdir(), 'cdp-e2e-'));
// Where stage screenshots are written (env override lets CI upload them).
const shotDir = process.env.E2E_SCREENSHOT_DIR || tmpdir();
mkdirSync(shotDir, { recursive: true });

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const results = [];
const apiCalls = new Set();
// Credentials of the throwaway account created in step 3, captured from the
// register response so the script can delete it at the end of the run.
let cleanupCreds = null;

function record(name, ok, detail = '') {
  results.push({ name, ok, detail });
  console.log(`${ok ? '✅ PASS' : '❌ FAIL'}  ${name}${detail ? '  — ' + detail : ''}`);
}

// ── Launch Chrome headless with remote debugging ──────────────────────────
const chrome = spawn(CHROME, [
  '--headless=new',
  '--disable-gpu',
  '--no-sandbox',
  `--remote-debugging-port=${PORT}`,
  `--user-data-dir=${userData}`,
  '--force-renderer-accessibility', // expose Flutter semantics tree
  '--window-size=1280,900',
  URL,
], { stdio: 'ignore' });
chrome.on('error', (err) => {
  console.error(`❌ Failed to launch Chrome (${CHROME}): ${err.message}`);
  cleanup();
  process.exit(2);
});

let ws;
const consoleLogs = [];
const networkFailures = [];
let msgId = 0;
const pending = new Map();

// Kill the spawned Chrome and remove its temp profile on exit.
function cleanup() {
  try { chrome.kill(); } catch (_) {}
  try { rmSync(userData, { recursive: true, force: true }); } catch (_) {}
}
process.on('exit', cleanup);

function send(method, params = {}) {
  return new Promise((resolve) => {
    const id = ++msgId;
    pending.set(id, resolve);
    ws.send(JSON.stringify({ id, method, params }));
  });
}

async function connect() {
  let target;
  for (let i = 0; i < 40; i++) {
    try {
      const res = await fetch(`http://127.0.0.1:${PORT}/json`);
      const targets = await res.json();
      target = targets.find((t) => t.type === 'page');
      if (target) break;
    } catch (_) {}
    await sleep(500);
  }
  if (!target) throw new Error('CDP target not found');

  ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((resolve, reject) => {
    ws.onopen = resolve;
    ws.onerror = reject;
  });
  ws.onmessage = (ev) => {
    const msg = JSON.parse(ev.data);
    if (msg.id && pending.has(msg.id)) {
      pending.get(msg.id)(msg);
      pending.delete(msg.id);
    } else if (msg.method === 'Runtime.consoleAPICalled') {
      const text = (msg.params.args || [])
        .map((a) => a.value ?? a.description ?? '')
        .join(' ');
      consoleLogs.push(`[console.${msg.params.type}] ${text}`);
    } else if (msg.method === 'Runtime.exceptionThrown') {
      consoleLogs.push(`[exception] ${msg.params.exceptionDetails?.text ?? ''}`);
    } else if (msg.method === 'Log.entryAdded') {
      const e = msg.params.entry;
      if (e.level === 'error') {
        consoleLogs.push(`[log.error] ${e.text}`);
        if (/cors|access-control|failed to fetch|network/i.test(e.text)) {
          networkFailures.push(e.text);
        }
      }
    } else if (msg.method === 'Network.loadingFailed') {
      const e = msg.params;
      networkFailures.push(
        `[network] ${e.type} ${e.errorText} (${e.blockedReason ?? ''})`,
      );
    } else if (msg.method === 'Network.requestWillBeSent') {
      const r = msg.params.request;
      if (/backendapi\.rwandatraffic\.rw/.test(r.url)) {
        apiCalls.add(`${r.method} ${r.url}`);
      }
    } else if (msg.method === 'Network.responseReceived') {
      // Capture the register response body (201) so we can self-delete the
      // throwaway account at the end of the run. OPTIONS preflight returns
      // 2xx but not 201, so it can't match by mistake.
      const { requestId, response } = msg.params;
      const url = response?.url || '';
      if (!cleanupCreds && response?.status === 201 && /\/api\/auth\/register/.test(url)) {
        send('Network.getResponseBody', { requestId }).then((m) => {
          try {
            const data = JSON.parse(m.result?.body || '{}').data;
            if (data?.id && data?.token) {
              cleanupCreds = { id: data.id, token: data.token, phone: data.phoneNumber };
              console.log(`  📝 captured throwaway account for auto-cleanup (${data.phoneNumber})`);
            }
          } catch (_) {}
        }).catch(() => {});
      }
    }
  };

  await send('Runtime.enable');
  await send('Log.enable');
  await send('Network.enable');
  await send('Page.enable');
  consoleLogs.length = 0;
  networkFailures.length = 0;
}

async function evalJs(expr) {
  const res = await send('Runtime.evaluate', {
    expression: expr,
    returnByValue: true,
    awaitPromise: true,
  });
  if (res.result?.exceptionDetails) {
    return { error: res.result.exceptionDetails.text };
  }
  return { value: res.result?.result?.value };
}

async function snapshotSemantics() {
  const res = await evalJs(`(() => {
    const out = [];
    document.querySelectorAll('flt-semantics').forEach((el) => {
      const text = (el.getAttribute('aria-label') || el.textContent || '').trim();
      const role = el.getAttribute('role') || '';
      const rect = el.getBoundingClientRect();
      if (text && rect.width > 0 && rect.height > 0) {
        out.push({ text: text.slice(0, 120), role, x: Math.round(rect.x + rect.width/2), y: Math.round(rect.y + rect.height/2) });
      }
    });
    return out;
  })()`);
  return res.value ?? [];
}

async function findInputs() {
  // Actual editable inputs Flutter web creates for text fields.
  const res = await evalJs(`(() => {
    const out = [];
    document.querySelectorAll('flt-semantics input, input, textarea').forEach((el) => {
      const rect = el.getBoundingClientRect();
      if (rect.width > 10 && rect.height > 5) {
        out.push({ x: Math.round(rect.x + rect.width/2), y: Math.round(rect.y + rect.height/2) });
      }
    });
    return out;
  })()`);
  return res.value ?? [];
}

async function clickAt(x, y) {
  await send('Input.dispatchMouseEvent', {
    type: 'mousePressed', x, y, button: 'left', clickCount: 1,
  });
  await send('Input.dispatchMouseEvent', {
    type: 'mouseReleased', x, y, button: 'left', clickCount: 1,
  });
}

async function typeText(x, y, text) {
  await clickAt(x, y);
  await sleep(300);
  for (const ch of text) {
    await send('Input.dispatchKeyEvent', { type: 'keyDown', text: ch });
    await send('Input.dispatchKeyEvent', { type: 'keyUp', key: ch });
  }
}

async function findByText(semantics, needle, preferButton = true) {
  const n = needle.toLowerCase();
  const matches = semantics.filter((s) => s.text.toLowerCase().includes(n));
  if (matches.length === 0) return undefined;
  if (preferButton) {
    const btn = matches.find((s) => s.role === 'button');
    if (btn) return btn;
  }
  return matches.sort((a, b) => a.text.length - b.text.length)[0];
}

async function screenshot(name) {
  const shot = await send('Page.captureScreenshot', { format: 'png' });
  if (shot.result?.data) {
    const file = join(shotDir, `${name}.png`);
    writeFileSync(file, Buffer.from(shot.result.data, 'base64'));
    console.log(`  📸 saved ${file}`);
  }
}

// ── Enable accessibility + dismiss first-launch dialogs ───────────────────
async function enableAccessibilityAndBoot() {
  await sleep(12000);
  const title = await evalJs('document.title');
  console.log('PAGE TITLE:', title.value);

  let enabled = { value: false };
  for (let i = 0; i < 30 && !enabled.value; i++) {
    enabled = await evalJs(`(() => {
      const ph = document.querySelector('flt-semantics-placeholder[role="button"]');
      if (ph) { ph.click(); return true; }
      return false;
    })()`);
    if (!enabled.value) await sleep(1000);
  }
  console.log('ACCESSIBILITY PLACEHOLDER CLICKED:', enabled.value);
  await send('Accessibility.enable').catch(() => {});
  await sleep(5000);

  // Verify the semantics tree actually populated; if not, retry the click.
  let bootSem = await snapshotSemantics();
  if (bootSem.length === 0) {
    for (let i = 0; i < 10 && bootSem.length === 0; i++) {
      await evalJs(`(() => {
        const ph = document.querySelector('flt-semantics-placeholder[role="button"]');
        if (ph) { ph.click(); return true; }
        return false;
      })()`);
      await sleep(1500);
      bootSem = await snapshotSemantics();
    }
  }
  console.log('SEMANTICS NODES AFTER BOOT:', bootSem.length);

  let sem = await snapshotSemantics();
  for (let round = 0; round < 8; round++) {
    const acceptBtn = await findByText(sem, 'understand and agree') ||
      await findByText(sem, 'understand') || await findByText(sem, 'accept');
    const maybeLater = await findByText(sem, 'maybe later');
    const getStarted = await findByText(sem, 'get started');
    const loginBtn = await findByText(sem, 'log in');
    if (acceptBtn) {
      await clickAt(acceptBtn.x, acceptBtn.y);
      await sleep(2500);
    } else if (maybeLater) {
      await clickAt(maybeLater.x, maybeLater.y);
      await sleep(2500);
    } else if (getStarted || loginBtn) {
      return sem;
    } else {
      break;
    }
    sem = await snapshotSemantics();
  }
  return sem;
}

// ── Test 1: boot + dialogs (with retries for flaky networks) ──────────────
async function testBootAndDialogs() {
  for (let attempt = 1; attempt <= 3; attempt++) {
    const sem = await enableAccessibilityAndBoot();
    const getStarted = await findByText(sem, 'get started');
    const login = await findByText(sem, 'log in');
    if (getStarted || login) {
      record('App boots to landing page (Get Started / Log In)', true);
      return sem;
    }
    if (attempt < 3) {
      console.log(`  ⚠️  boot attempt ${attempt} failed — reloading and retrying...`);
      await evalJs(`location.reload()`);
      await sleep(8000);
    }
  }
  const sem = await snapshotSemantics();
  record('App boots to landing page (Get Started / Log In)', false, 'landing not found after 3 attempts');
  return sem;
}

// ── Test 2: login with unregistered phone → server error ──────────────────
async function testLoginNegative(sem) {
  const loginBtn = await findByText(sem, 'log in') || await findByText(sem, 'login');
  if (loginBtn) {
    await clickAt(loginBtn.x, loginBtn.y);
    await sleep(4000);
    sem = await snapshotSemantics();
  }
  const cont = await findByText(sem, 'continue');
  const subtitle = await findByText(sem, 'enter your registered phone');
  if (!cont || !subtitle) {
    record('Login page reachable', false, 'no Continue/subtitle found');
    return sem;
  }
  record('Login page reachable', true);

  const fieldY = Math.round((subtitle.y + cont.y) / 2);
  await typeText(cont.x, fieldY, '0788000001');
  await sleep(1200);
  await clickAt(cont.x, cont.y);

  // The error snackbar shows for a few seconds — poll for the server message.
  let serverMsg, netMsg;
  const start = Date.now();
  while (Date.now() - start < 10000) {
    sem = await snapshotSemantics();
    const after = sem.map((s) => s.text);
    serverMsg = after.find((t) => /not registered|register first/i.test(t));
    netMsg = after.find((t) => /network|connect|fail/i.test(t));
    if (serverMsg || netMsg) break;
    await sleep(1000);
  }
  record(
    'Login (unregistered phone) shows server error',
    !!serverMsg,
    serverMsg || netMsg || 'no message found',
  );
  return sem;
}

// ── Test 3: registration with throwaway account ───────────────────────────
async function testRegistration(sem) {
  // From the login page, tap "Sign Up" to reach the register form.
  const signUp = await findByText(sem, 'sign up');
  if (!signUp) {
    record('Register page reachable', false, 'no Sign Up link on login page');
    return null;
  }
  await clickAt(signUp.x, signUp.y);
  await sleep(4000);
  sem = await snapshotSemantics();

  const registerTitle = await findByText(sem, 'create your account');
  const signUpBtn = await findByText(sem, 'sign up');
  if (!registerTitle || !signUpBtn) {
    record('Register page reachable', false, 'register title/button not found');
    return null;
  }
  record('Register page reachable', true);

  // Random throwaway phone: 0788 + 6 random digits (valid 07-8xx format).
  const phone = '0788' + String(Math.floor(Math.random() * 900000) + 100000);
  const name = 'E2E Test User';

  // Locate the two text fields. Flutter merges them into groups; use the
  // actual DOM inputs if present, otherwise fall back to layout math
  // (name field above the phone field above the Sign Up button).
  let inputs = await findInputs();
  let nameField, phoneField;
  if (inputs.length >= 2) {
    inputs.sort((a, b) => a.y - b.y);
    nameField = inputs[0];
    phoneField = inputs[1];
    console.log(`  DOM inputs found: name=${JSON.stringify(nameField)} phone=${JSON.stringify(phoneField)}`);
  } else {
    // Fallback: Sign Up button; fields sit above it (button h=56, gaps 24/20).
    const btnTop = signUpBtn.y - 28;
    const phoneCenterY = btnTop - 24 - 28;
    const nameCenterY = phoneCenterY - 20 - 28;
    nameField = { x: signUpBtn.x, y: nameCenterY };
    phoneField = { x: signUpBtn.x, y: phoneCenterY };
    console.log(`  Computed fields: name=${JSON.stringify(nameField)} phone=${JSON.stringify(phoneField)}`);
  }

  await typeText(nameField.x, nameField.y, name);
  await sleep(800);
  await typeText(phoneField.x, phoneField.y, phone);
  await sleep(800);

  // Submit — then poll until we either land on the home page (positive
  // markers: "Welcome back" / "Services") or see a clear server error.
  await clickAt(signUpBtn.x, signUpBtn.y);
  let onHome = false;
  let errMsg;
  const start = Date.now();
  while (Date.now() - start < 20000) {
    await sleep(1500);
    sem = await snapshotSemantics();
    const after = sem.map((s) => s.text);
    onHome = after.some((t) => /welcome back|continue learning|services/i.test(t));
    errMsg = after.find((t) =>
      /already registered|not registered|device|invalid|network|fail/i.test(t) &&
      !/Already have an account/i.test(t),
    );
    if (onHome || errMsg) break;
  }
  record(
    'Registration succeeds → home page (authenticated)',
    onHome,
    onHome ? `phone=${phone}` : (errMsg || 'still on register page'),
  );
  if (onHome) {
    console.log(`  THROWAWAY ACCOUNT PHONE: ${phone} — auto-cleanup will delete it at the end of the run (printed as a manual fallback).`);
  }
  return { sem, phone };
}

// ── Test 4: practice page loads exams from assets ─────────────────────────
async function testPractice(sem) {
  // On desktop the shell uses a hamburger drawer ("Menu"); on mobile the
  // bottom nav shows "Practice". Try the drawer first, then nav text.
  let navigated = false;
  const menuBtn = await findByText(sem, 'menu');
  if (menuBtn) {
    await clickAt(menuBtn.x, menuBtn.y);
    await sleep(3000);
    sem = await snapshotSemantics();
    const practiceTile = await findByText(sem, 'practice');
    if (practiceTile) {
      await clickAt(practiceTile.x, practiceTile.y);
      await sleep(6000);
      navigated = true;
    }
  }
  if (!navigated) {
    // Fall back: the practice service card on the home grid.
    const practiceText = await findByText(sem, 'practice questions') ||
      await findByText(sem, 'practice');
    if (practiceText) {
      await clickAt(practiceText.x, practiceText.y);
      await sleep(6000);
      navigated = true;
    }
  }
  sem = await snapshotSemantics();
  const texts = sem.map((s) => s.text);
  const hasGrid = texts.some((t) => /questions|FREE|Exam/i.test(t));
  const freeBadge = texts.some((t) => /FREE/i.test(t));
  record('Practice page shows exam grid (asset-based)', hasGrid && navigated, hasGrid ? `free badges=${freeBadge}` : 'no exam cards found');
  return sem;
}

// ── Test 5: tap a paid exam → subscription page ───────────────────────────
async function testSubscription(sem) {
  // Paid exams sort after free ones and lack the FREE badge. Pick a card
  // whose text has "questions" but no "FREE".
  const paidCard = sem.find(
    (s) => /questions/i.test(s.text) && !/FREE/i.test(s.text) && s.role === 'button',
  ) || sem.find((s) => /questions/i.test(s.text) && !/FREE/i.test(s.text));
  if (!paidCard) {
    record('Subscription page reachable via paid exam', false, 'no paid exam card found');
    return sem;
  }
  await clickAt(paidCard.x, paidCard.y);
  await sleep(6000);
  sem = await snapshotSemantics();
  const texts = sem.map((s) => s.text);
  const subTitle = texts.find((t) => /Practice Exam Access|Choose a Plan/i.test(t));
  const plans = texts.filter((t) => /1 Month|3 Months|6 Months/i.test(t));
  record(
    'Subscription page renders plan cards',
    !!subTitle && plans.length > 0,
    subTitle ? `plans=${plans.length}` : 'subscription page not reached',
  );
  return sem;
}

// ── Main ──────────────────────────────────────────────────────────────────
async function main() {
  await connect();
  let sem = await testBootAndDialogs();
  await screenshot('1_landing');

  sem = await testLoginNegative(sem);
  await screenshot('2_login_negative');

  const reg = await testRegistration(sem);
  await screenshot('3_after_registration');
  if (!reg) {
    console.log('\nSkipping practice/subscription (registration failed).');
    return finish();
  }
  sem = reg.sem;

  sem = await testPractice(sem);
  await screenshot('4_practice');

  sem = await testSubscription(sem);
  await screenshot('5_subscription');

  await finish();
}

// Delete the throwaway account created in step 3 using its own token
// (backend allows self-deletion via DELETE /api/users/:id). Best-effort:
// never fails the run, prints a manual fallback phone if it can't.
async function cleanupAccount() {
  if (!cleanupCreds) {
    console.log('\n⚠️  No throwaway account captured — nothing to auto-cleanup.');
    return;
  }
  const { id, token, phone } = cleanupCreds;
  console.log(`\n🧹 Auto-cleanup: deleting throwaway account ${phone}…`);
  try {
    const res = await fetch(`https://backendapi.rwandatraffic.rw/api/users/${id}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${token}` },
      signal: AbortSignal.timeout(15000), // don't stall exit on a hung network
    });
    const body = await res.text();
    if (res.status === 200) {
      console.log(`✅ AUTO-CLEANUP SUCCESS: ${phone} deleted (self-delete with its own token)`);
    } else {
      console.log(`⚠️  AUTO-CLEANUP FAILED (HTTP ${res.status}): ${body.slice(0, 150)}`);
      console.log(`    → delete manually: phone=${phone}`);
    }
  } catch (e) {
    console.log(`⚠️  AUTO-CLEANUP ERROR: ${e.message}`);
    console.log(`    → delete manually: phone=${phone}`);
  }
}

async function finish() {
  console.log('\n===== API CALLS SEEN (live backend) =====');
  console.log([...apiCalls].join('\n') || '(none)');
  console.log('\n===== CONSOLE MESSAGES =====');
  console.log(consoleLogs.filter((l) => !l.includes('Injecting')).join('\n') || '(none)');
  console.log('\n===== NETWORK FAILURES / CORS =====');
  console.log(networkFailures.join('\n') || '(none)');

  // Cross-origin fetch check
  const fetchCheck = await evalJs(`fetch('https://backendapi.rwandatraffic.rw/api/health', { headers: { 'Origin': location.origin } })
    .then(r => 'status=' + r.status)
    .catch(e => 'FETCH_ERROR: ' + e.message)`);
  console.log('\nCROSS-ORIGIN FETCH FROM PAGE:', fetchCheck.value);

  await cleanupAccount();

  const passed = results.filter((r) => r.ok).length;
  const failed = results.filter((r) => !r.ok).length;
  console.log(`\n===== SUMMARY: ${passed} passed, ${failed} failed =====`);
  process.exit(failed > 0 ? 1 : 0);
}

main().catch(async (e) => {
  console.error('E2E FAILED:', e.message);
  try { await cleanupAccount(); } catch (_) {}
  process.exit(1);
});
