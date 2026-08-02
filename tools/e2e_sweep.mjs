#!/usr/bin/env node
// Stale-account sweeper — defense in depth for the live E2E smoke test.
//
// The E2E script deletes its own throwaway account at the end of every run,
// but if a run is force-killed (CI timeout, machine loss) that account is left
// in the production database. This sweeper finds E2E throwaway accounts
// ("E2E Test User", role USER) older than E2E_MAX_AGE_HOURS and deletes them.
//
// Requires admin credentials via env (stored as GitHub secrets in CI):
//   E2E_SWEEP_ENABLED=1            — opt-in (this deletes production accounts)
//   E2E_ADMIN_PHONE                — admin/manager account phone (required)
//   E2E_ADMIN_DEVICE_ID            — optional (admin logins skip device binding)
//   E2E_MAX_AGE_HOURS              — optional, default 24
//
// Safety: only users whose name matches the E2E pattern, role USER, and older
// than the age threshold are touched. ADMIN/MANAGER and the demo account
// (0787012615) are never touched.
import { env } from 'node:process';

const BASE = 'https://backendapi.rwandatraffic.rw';
const DEMO_PHONE = '0787012615';

const enabled = env.E2E_SWEEP_ENABLED === '1';
const adminPhone = env.E2E_ADMIN_PHONE || '';
const adminDevice = env.E2E_ADMIN_DEVICE_ID || 'e2e-sweep-cli';
const maxAgeMs =
  (Number.parseFloat(env.E2E_MAX_AGE_HOURS || '24') || 24) * 60 * 60 * 1000;

if (!enabled) {
  console.error(
    '❌ Refusing to run without E2E_SWEEP_ENABLED=1 (this deletes production accounts).',
  );
  process.exit(2);
}
if (!adminPhone) {
  console.error('❌ E2E_ADMIN_PHONE is required.');
  process.exit(2);
}

console.log(`⚠️  Sweeping for E2E accounts older than ${maxAgeMs / 3_600_000}h...`);

async function api(path, { method = 'GET', token, body } = {}) {
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  let json = null;
  try {
    json = await res.json();
  } catch (_) {
    json = null;
  }
  return { status: res.status, json };
}

// 1. Admin login
console.log('🔑 Logging in as admin...');
const login = await api('/api/auth/login', {
  method: 'POST',
  body: { phoneNumber: adminPhone, deviceId: adminDevice },
});
const token = login.json?.data?.token;
const role = login.json?.data?.role;
if (!token) {
  console.error('❌ Admin login failed:', JSON.stringify(login.json).slice(0, 200));
  process.exit(1);
}
if (role !== 'ADMIN' && role !== 'MANAGER') {
  console.error(`❌ Account role is ${role} — ADMIN/MANAGER required.`);
  process.exit(1);
}
console.log(`✅ Logged in (role=${role})`);

// 2. Find stale E2E accounts (search by name, paginate)
const stale = [];
const now = Date.now();
for (let page = 1; page <= 10; page++) {
  const res = await api(`/api/admin/users?search=E2E&limit=100&page=${page}`, {
    token,
  });
  // Fail loudly instead of silently reporting "nothing to delete" when the
  // list call fails (expired token, server error) — a false-success sweep
  // would leave the DB dirty while the job passes.
  if (res.status !== 200) {
    console.error(
      `❌ Failed to list users (HTTP ${res.status}): ${JSON.stringify(res.json).slice(0, 200)}`,
    );
    process.exit(1);
  }
  const users = res.json?.data?.users ?? [];
  const total = res.json?.data?.total ?? users.length;
  for (const u of users) {
    const name = (u.fullName ?? '').toLowerCase();
    const userRole = (u.role ?? '').toUpperCase();
    const phone = u.phoneNumber ?? '';
    const isE2E = name.includes('e2e') && (name.includes('test') || name.includes('user'));
    const isProtected = userRole === 'ADMIN' || userRole === 'MANAGER' || phone === DEMO_PHONE;
    if (!isE2E || isProtected) {
      if (isE2E) console.log(`  ⛔ skip protected: ${phone} (${userRole})`);
      continue;
    }
    // MySQL DATETIME like 'YYYY-MM-DD HH:MM:SS' is parsed as local time; the
    // server may store UTC, so age can skew by a few hours. Irrelevant at the
    // 24h threshold (E2E accounts are minutes old), noted for future readers.
    const created = Date.parse(String(u.createdAt ?? '').replace(' ', 'T'));
    const age = Number.isNaN(created) ? NaN : now - created;
    if (Number.isNaN(age) || age < maxAgeMs) {
      console.log(`  ⏭ skip (younger than threshold): ${phone} created=${u.createdAt}`);
      continue;
    }
    stale.push({ ...u, ageHours: (age / 3_600_000).toFixed(1) });
  }
  if (users.length < 100 || page * 100 >= total) break;
}

if (stale.length === 0) {
  console.log('✅ No stale E2E accounts found — nothing to delete.');
  process.exit(0);
}

console.log(`\n🧹 Deleting ${stale.length} stale E2E account(s):`);
let failed = 0;
for (const u of stale) {
  console.log(`  - ${u.phoneNumber} (${u.fullName}, ${u.ageHours}h old)`);
  const blocked = await api(`/api/admin/users/${u.id}/block`, {
    method: 'PATCH',
    token,
    body: { isActive: 0 },
  });
  if (blocked.status !== 200) {
    console.error(`    ❌ block failed (${blocked.status}): ${JSON.stringify(blocked.json).slice(0, 120)}`);
    failed++;
    continue;
  }
  const deleted = await api(`/api/admin/users/${u.id}`, { method: 'DELETE', token });
  if (deleted.status !== 200) {
    console.error(`    ❌ delete failed (${deleted.status}): ${JSON.stringify(deleted.json).slice(0, 120)}`);
    failed++;
  } else {
    console.log(`    ✅ deleted`);
  }
}

if (failed > 0) {
  console.error(`\n❌ ${failed} account(s) failed to clean up.`);
  process.exit(1);
}
console.log('\n✅ Sweep complete.');
