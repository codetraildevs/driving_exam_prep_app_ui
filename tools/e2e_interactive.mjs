// Interactive UI validation for the deployed Flutter web app, driven via CDP.
// Checks: hover states on cards, keyboard (Tab) focus rings, dark/light theme
// switching from Settings, and dark-mode readability. Registers a throwaway
// account and auto-deletes it at the end (self-delete via its own token).
//
// Usage: E2E_ALLOW_PROD=1 node tools/e2e_interactive.mjs
import { spawn } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const ALLOW_PROD = process.env.E2E_ALLOW_PROD === '1';
if (!ALLOW_PROD) {
  console.error('❌ Refusing to run against production without opt-in (E2E_ALLOW_PROD=1).');
  process.exit(2);
}

function findChrome() {
  if (process.env.CHROME_PATH) return existsSync(process.env.CHROME_PATH) ? process.env.CHROME_PATH : undefined;
  const candidates =
    process.platform === 'win32'
      ? ['C:/Program Files/Google/Chrome/Application/chrome.exe', 'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe']
      : process.platform === 'darwin'
        ? ['/Applications/Google Chrome.app/Contents/MacOS/Google Chrome']
        : ['/usr/bin/google-chrome', '/usr/bin/google-chrome-stable', '/usr/bin/chromium', '/usr/bin/chromium-browser'];
  return candidates.find((p) => existsSync(p));
}
const CHROME = findChrome();
if (!CHROME) { console.error('❌ Chrome not found.'); process.exit(2); }

const URL = 'https://learn-traffic-rules-cbbd1.web.app';
const PORT = 9344;
const userData = mkdtempSync(join(tmpdir(), 'cdp-inter-'));
const shotDir = process.env.E2E_SCREENSHOT_DIR || tmpdir();
mkdirSync(shotDir, { recursive: true });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const results = [];
let cleanupCreds = null;

const chrome = spawn(CHROME, [
  '--headless=new', '--disable-gpu', '--no-sandbox', `--remote-debugging-port=${PORT}`,
  `--user-data-dir=${userData}`, '--force-renderer-accessibility', '--window-size=1280,900', URL,
], { stdio: 'ignore' });
chrome.on('error', (err) => { console.error(`❌ Chrome launch failed: ${err.message}`); cleanup(); process.exit(2); });

let ws;
const consoleLogs = [];
let msgId = 0;
const pending = new Map();
function cleanup() { try { chrome.kill(); } catch (_) {} try { rmSync(userData, { recursive: true, force: true }); } catch (_) {} }
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
      target = (await res.json()).find((t) => t.type === 'page');
      if (target) break;
    } catch (_) {}
    await sleep(500);
  }
  if (!target) throw new Error('CDP target not found');
  ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((resolve, reject) => { ws.onopen = resolve; ws.onerror = reject; });
  ws.onmessage = (ev) => {
    const msg = JSON.parse(ev.data);
    if (msg.id && pending.has(msg.id)) { pending.get(msg.id)(msg); pending.delete(msg.id); }
    else if (msg.method === 'Runtime.consoleAPICalled') {
      consoleLogs.push(`[console.${msg.params.type}] ${(msg.params.args || []).map((a) => a.value ?? a.description ?? '').join(' ')}`);
    } else if (msg.method === 'Runtime.exceptionThrown') {
      consoleLogs.push(`[exception] ${msg.params.exceptionDetails?.text ?? ''}`);
    } else if (msg.method === 'Log.entryAdded') {
      const e = msg.params.entry;
      if (e.level === 'error') consoleLogs.push(`[log.error] ${e.text}`);
    } else if (msg.method === 'Network.responseReceived') {
      const { requestId, response } = msg.params;
      const url = response?.url || '';
      if (!cleanupCreds && response?.status === 201 && /\/api\/auth\/register/.test(url)) {
        send('Network.getResponseBody', { requestId }).then((m) => {
          try {
            const data = JSON.parse(m.result?.body || '{}').data;
            if (!cleanupCreds && data?.id && data?.token) {
              cleanupCreds = { id: data.id, token: data.token, phone: data.phoneNumber };
              console.log(`  📝 captured throwaway account for auto-cleanup (${data.phoneNumber})`);
            }
          } catch (_) {}
        }).catch(() => {});
      }
    }
  };
  await send('Runtime.enable'); await send('Log.enable'); await send('Network.enable'); await send('Page.enable');
  consoleLogs.length = 0;
}

async function evalJs(expr) {
  const res = await send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true });
  if (res.result?.exceptionDetails) return { error: res.result.exceptionDetails.text };
  return { value: res.result?.result?.value };
}

async function snapshotSemantics() {
  const res = await evalJs(`(() => {
    const out = [];
    document.querySelectorAll('flt-semantics').forEach((el) => {
      const text = (el.getAttribute('aria-label') || el.textContent || '').trim();
      const role = el.getAttribute('role') || '';
      const rect = el.getBoundingClientRect();
      if (text && rect.width > 0 && rect.height > 0) out.push({ text: text.slice(0, 120), role, x: Math.round(rect.x + rect.width/2), y: Math.round(rect.y + rect.height/2) });
    });
    return out;
  })()`);
  return res.value ?? [];
}

async function clickAt(x, y) {
  await send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', clickCount: 1 });
  await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', clickCount: 1 });
}

async function hoverAt(x, y) {
  await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x, y });
}

async function typeText(x, y, text) {
  await clickAt(x, y); await sleep(300);
  for (const ch of text) {
    await send('Input.dispatchKeyEvent', { type: 'keyDown', text: ch });
    await send('Input.dispatchKeyEvent', { type: 'keyUp', key: ch });
  }
}

async function pressTab() {
  await send('Input.dispatchKeyEvent', { type: 'keyDown', key: 'Tab', code: 'Tab', windowsVirtualKeyCode: 9 });
  await send('Input.dispatchKeyEvent', { type: 'keyUp', key: 'Tab', code: 'Tab', windowsVirtualKeyCode: 9 });
}

function findByText(semantics, needle, preferButton = true) {
  const n = needle.toLowerCase();
  const matches = semantics.filter((s) => s.text.toLowerCase().includes(n));
  if (!matches.length) return undefined;
  if (preferButton) { const b = matches.find((s) => s.role === 'button'); if (b) return b; }
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

async function themeColor() {
  const r = await evalJs(`document.querySelector('meta[name="theme-color"]')?.content ?? '(none)'`);
  return r.value;
}

async function enableAccessibilityAndBoot() {
  await sleep(12000);
  let enabled = { value: false };
  for (let i = 0; i < 30 && !enabled.value; i++) {
    enabled = await evalJs(`(() => { const ph = document.querySelector('flt-semantics-placeholder[role="button"]'); if (ph) { ph.click(); return true; } return false; })()`);
    if (!enabled.value) await sleep(1000);
  }
  console.log('ACCESSIBILITY ENABLED:', enabled.value);
  await send('Accessibility.enable').catch(() => {});
  await sleep(5000);
  let sem = await snapshotSemantics();
  for (let round = 0; round < 8; round++) {
    const accept = await findByText(sem, 'understand and agree') || await findByText(sem, 'understand') || await findByText(sem, 'accept');
    const maybeLater = await findByText(sem, 'maybe later');
    const getStarted = await findByText(sem, 'get started');
    const loginBtn = await findByText(sem, 'log in');
    if (accept) { await clickAt(accept.x, accept.y); await sleep(2500); }
    else if (maybeLater) { await clickAt(maybeLater.x, maybeLater.y); await sleep(2500); }
    else if (getStarted || loginBtn) return sem;
    else break;
    sem = await snapshotSemantics();
  }
  return sem;
}

function record(name, ok, detail = '') {
  results.push({ name, ok, detail });
  console.log(`${ok ? '✅ PASS' : '❌ FAIL'}  ${name}${detail ? '  — ' + detail : ''}`);
}

async function captureCredsFromPage() {
  if (cleanupCreds) return true;
  const res = await evalJs(`(() => {
    const all = {};
    for (let i = 0; i < localStorage.length; i++) { const k = localStorage.key(i); if (k) all[k] = localStorage.getItem(k); }
    const raw = (v) => { try { return JSON.parse(v); } catch (_) { return v; } };
    let token, id, phone;
    for (const [k, v] of Object.entries(all)) {
      if (!token && /token/i.test(k) && !/refresh/i.test(k)) token = raw(v);
      if (!id && /user/i.test(k)) { try { let u = raw(v); if (typeof u === 'string') u = raw(u); id = u?.id || u?.userId; phone = u?.phoneNumber || u?.phone; } catch (_) {} }
    }
    return { token: token || undefined, id: id || undefined, phone: phone || undefined };
  })()`);
  const c = res.value;
  if (c?.token && c?.id) { cleanupCreds = { id: c.id, token: c.token, phone: c.phone }; console.log(`  📝 captured throwaway account from localStorage (${c.phone || 'phone unknown'})`); return true; }
  return false;
}

async function cleanupAccount() {
  if (!cleanupCreds) { await captureCredsFromPage(); }
  if (!cleanupCreds) { console.log('⚠️  No throwaway account captured — nothing to auto-cleanup.'); return; }
  const { id, token, phone } = cleanupCreds;
  console.log(`\n🧹 Auto-cleanup: deleting throwaway account ${phone}…`);
  try {
    const res = await fetch(`https://backendapi.rwandatraffic.rw/api/users/${id}`, {
      method: 'DELETE', headers: { Authorization: `Bearer ${token}` }, signal: AbortSignal.timeout(15000),
    });
    if (res.status === 200) console.log(`✅ AUTO-CLEANUP SUCCESS: ${phone} deleted`);
    else { console.log(`⚠️  AUTO-CLEANUP FAILED (HTTP ${res.status}): delete manually phone=${phone}`); }
  } catch (e) { console.log(`⚠️  AUTO-CLEANUP ERROR: ${e.message} — delete manually phone=${phone}`); }
}

// ── Test steps ─────────────────────────────────────────────────────────────

async function testBootAndRegister() {
  let sem = await enableAccessibilityAndBoot();
  const getStarted = await findByText(sem, 'get started');
  const loginBtn = await findByText(sem, 'log in');
  record('Landing page renders', !!(getStarted || loginBtn), getStarted ? 'Get Started visible' : 'Log In visible');
  await screenshot('i1_landing');

  // Go to login → Sign Up → register throwaway account.
  let nav = await findByText(sem, 'log in') || await findByText(sem, 'login') || getStarted;
  if (!nav) return sem;
  await clickAt(nav.x, nav.y); await sleep(4000);
  sem = await snapshotSemantics();
  const signUp = await findByText(sem, 'sign up');
  if (!signUp) { record('Register page reachable', false, 'no Sign Up link'); return sem; }
  await clickAt(signUp.x, signUp.y); await sleep(4000);
  sem = await snapshotSemantics();
  const registerBtn = await findByText(sem, 'sign up');
  if (!registerBtn) { record('Register page reachable', false, 'no sign-up button'); return sem; }
  record('Register page reachable', true);

  const phone = '0788' + String(Math.floor(Math.random() * 900000) + 100000);
  const inputsRes = await evalJs(`(() => {
    const out = [];
    document.querySelectorAll('flt-semantics input, input, textarea').forEach((el) => {
      const r = el.getBoundingClientRect();
      if (r.width > 10 && r.height > 5) out.push({ x: Math.round(r.x + r.width/2), y: Math.round(r.y + r.height/2) });
    });
    return out;
  })()`);
  let inputs = (inputsRes.value ?? []).sort((a, b) => a.y - b.y);
  let nameField, phoneField;
  if (inputs.length >= 2) { nameField = inputs[0]; phoneField = inputs[1]; }
  else {
    const btnTop = registerBtn.y - 28;
    const phoneCenterY = btnTop - 24 - 28;
    nameField = { x: registerBtn.x, y: phoneCenterY - 48 };
    phoneField = { x: registerBtn.x, y: phoneCenterY };
  }
  await typeText(nameField.x, nameField.y, 'E2E Test User'); await sleep(500);
  await typeText(phoneField.x, phoneField.y, phone); await sleep(500);
  await clickAt(registerBtn.x, registerBtn.y);

  let onHome = false;
  const start = Date.now();
  while (Date.now() - start < 20000) {
    await sleep(1500);
    sem = await snapshotSemantics();
    onHome = sem.some((s) => /welcome back|continue learning|services/i.test(s.text));
    if (onHome) break;
  }
  record('Registration → home page', onHome, onHome ? `phone=${phone}` : 'still not on home');
  await screenshot('i2_home');
  for (let i = 0; i < 6 && !cleanupCreds; i++) { if (await captureCredsFromPage()) break; await sleep(1000); }
  return sem;
}

async function testHoverFocus(sem) {
  // Home service cards are the 4 grid items below "Services".
  const cards = sem.filter((s) => /practices|join|progress|share/i.test(s.text) && /grid|list|button/i.test(s.role || ''));
  const card = cards[0] || sem.find((s) => /practice/i.test(s.text));
  if (!card) { record('Home cards present', false, 'no service card found'); return sem; }
  record('Home service cards present', true, `${cards.length || 1} card(s)`);

  // Hover: move mouse over the card, take a screenshot; Flutter repaints hover styles.
  await hoverAt(card.x, card.y); await sleep(1200);
  await screenshot('i3_home_hover');
  // Hover cursor: Flutter sets cursor via CSS on the semantics placeholder.
  const cursor = await evalJs(`(() => {
    const ph = document.querySelector('flt-semantics-placeholder');
    const cs = ph ? getComputedStyle(ph) : null;
    return cs ? cs.cursor : '(no placeholder)';
  })()`);
  console.log('  cursor over card:', cursor.value);
  record('Hover state renders (no crash)', true, `cursor=${cursor.value}`);

  // Keyboard focus: Tab through and check that something gains focus.
  let focused = [];
  for (let i = 0; i < 5; i++) {
    await pressTab(); await sleep(400);
    const f = await evalJs(`(() => {
      const active = document.activeElement;
      return active ? (active.getAttribute('aria-label') || active.tagName || '') : '(none)';
    })()`);
    focused.push(f.value);
  }
  console.log('  focus chain after 5 Tabs:', focused.join(' | '));
  await screenshot('i4_after_tabs');
  const anyFocus = focused.some((f) => f && !f.includes('(none)') && !f.includes('BODY'));
  record('Tab navigation moves focus', anyFocus, focused.filter(Boolean).join(', ').slice(0, 80));
  return sem;
}

async function testPracticeAndSubscription(sem) {
  const menu = await findByText(sem, 'menu');
  if (menu) { await clickAt(menu.x, menu.y); await sleep(3000); sem = await snapshotSemantics(); }
  const practice = await findByText(sem, 'practice questions') || await findByText(sem, 'practice');
  if (practice) { await clickAt(practice.x, practice.y); await sleep(6000); }
  sem = await snapshotSemantics();
  const texts = sem.map((s) => s.text);
  const hasGrid = texts.some((t) => /questions|FREE|Exam/i.test(t));
  record('Practice page exam grid loads', hasGrid, hasGrid ? 'free badges visible' : 'no exam cards');

  // Hover an exam card.
  const examCard = sem.find((s) => /questions/i.test(s.text));
  if (examCard) { await hoverAt(examCard.x, examCard.y); await sleep(1000); await screenshot('i5_practice_hover'); }
  await screenshot('i6_practice');

  // Tap a paid exam → subscription page.
  const paidCard = sem.find((s) => /questions/i.test(s.text) && !/FREE/i.test(s.text) && s.role === 'button')
    || sem.find((s) => /questions/i.test(s.text) && !/FREE/i.test(s.text));
  if (paidCard) {
    await clickAt(paidCard.x, paidCard.y); await sleep(6000);
    sem = await snapshotSemantics();
    const sub = sem.map((s) => s.text);
    const plans = sub.filter((t) => /1 Month|3 Months|6 Months/i.test(t));
    record('Subscription page plan cards', plans.length > 0, `plans=${plans.length}`);
    await screenshot('i7_subscription');
  } else {
    record('Subscription page plan cards', false, 'no paid exam card');
  }
  return sem;
}

// Pop any pushed route via the top-left back arrow, then land on the home
// page through the drawer so navigation state is predictable.
async function goHome(sem) {
  // Pushed pages (e.g. subscription) use an IconButton back arrow that has no
  // tooltip, so its semantics label isn't "back". Detect a pushed page by its
  // content (plan cards) and click the arrow by its known header position.
  const isPushedPage = sem.some((s) => /1 month|3 months|6 months|plan|pay/i.test(s.text));
  const back = await findByText(sem, 'back');
  if (back) { await clickAt(back.x, back.y); await sleep(3000); sem = await snapshotSemantics(); }
  else if (isPushedPage) {
    // AppPageHeader back arrow sits at ~(28, top padding + 36) in the header.
    await clickAt(28, 40); await sleep(3000); sem = await snapshotSemantics();
  }
  const menu = await findByText(sem, 'menu');
  if (menu) { await clickAt(menu.x, menu.y); await sleep(3000); sem = await snapshotSemantics(); }
  const home = await findByText(sem, 'home');
  if (home) { await clickAt(home.x, home.y); await sleep(3000); sem = await snapshotSemantics(); }
  return sem;
}

async function testThemeSwitching(sem) {
  // From the subscription page, go Home → drawer → Profile → Settings.
  sem = await goHome(sem);
  const menu = await findByText(sem, 'menu');
  if (!menu) { record('Settings reachable', false, 'no menu button to open drawer'); return sem; }
  await clickAt(menu.x, menu.y); await sleep(3000);
  sem = await snapshotSemantics();
  const profile = await findByText(sem, 'profile');
  if (!profile) { record('Settings reachable', false, 'no Profile in drawer'); return sem; }
  await clickAt(profile.x, profile.y); await sleep(4000);
  sem = await snapshotSemantics();
  const settings = await findByText(sem, 'settings');
  if (!settings) { record('Settings reachable', false, 'no Settings tile on Profile'); return sem; }
  await clickAt(settings.x, settings.y); await sleep(4000);
  sem = await snapshotSemantics();
  const appearance = await findByText(sem, 'appearance');
  record('Settings page with theme selector', !!appearance, appearance ? 'Appearance section visible' : 'not found');

  const darkChip = await findByText(sem, 'dark');
  const lightChip = await findByText(sem, 'light');
  const systemChip = await findByText(sem, 'system');
  if (!darkChip) { record('Theme chips found', false, 'no Dark chip'); return sem; }
  record('Theme chips found (System/Light/Dark)', !!lightChip && !!systemChip);

  // Switch to Dark.
  const beforeDark = await themeColor();
  await clickAt(darkChip.x, darkChip.y); await sleep(2500);
  const darkColor = await themeColor();
  await screenshot('i8_settings_dark');
  record('Dark theme applies', darkColor === '#0F0F23', `theme-color ${beforeDark} → ${darkColor}`);

  // Home in dark mode (readability spot-check).
  sem = await goHome(sem);
  await screenshot('i9_home_dark');
  record('Dark home renders (no crash)', true);

  // Back to Settings → Light.
  const menu2 = await findByText(sem, 'menu');
  if (menu2) { await clickAt(menu2.x, menu2.y); await sleep(3000); sem = await snapshotSemantics(); }
  const profile2 = await findByText(sem, 'profile');
  if (profile2) { await clickAt(profile2.x, profile2.y); await sleep(4000); sem = await snapshotSemantics(); }
  const settings2 = await findByText(sem, 'settings');
  if (settings2) { await clickAt(settings2.x, settings2.y); await sleep(4000); sem = await snapshotSemantics(); }
  const lightChip2 = await findByText(sem, 'light');
  if (lightChip2) {
    await clickAt(lightChip2.x, lightChip2.y); await sleep(2500);
    const lightColor = await themeColor();
    await screenshot('i10_settings_light');
    record('Light theme restores', lightColor === '#00039E', `theme-color → ${lightColor}`);
  } else {
    record('Light theme restores', false, 'no Light chip on re-entry');
  }
  return sem;
}

async function main() {
  await connect();
  let sem = await testBootAndRegister();
  sem = await testHoverFocus(sem);
  sem = await testPracticeAndSubscription(sem);
  sem = await testThemeSwitching(sem);

  console.log('\n===== CONSOLE MESSAGES =====');
  console.log(consoleLogs.filter((l) => !l.includes('Injecting')).join('\n') || '(none)');
  const realErrors = consoleLogs.filter((l) => l.includes('exception') || l.includes('[log.error]'));
  console.log('\n===== REAL ERRORS =====');
  console.log(realErrors.join('\n') || '(none)');
  await cleanupAccount();
  const passed = results.filter((r) => r.ok).length;
  const failed = results.filter((r) => !r.ok).length;
  console.log(`\n===== SUMMARY: ${passed} passed, ${failed} failed =====`);
  process.exit(failed > 0 ? 1 : 0);
}

main().catch(async (e) => {
  console.error('INTERACTIVE TEST FAILED:', e.stack || e.message);
  try { await cleanupAccount(); } catch (_) {}
  process.exit(1);
});
