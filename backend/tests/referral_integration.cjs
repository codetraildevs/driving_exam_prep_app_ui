// Local disposable MySQL only. Configure REFERRAL_TEST_DB_PORT/PASSWORD as needed.
const {spawn, execFileSync} = require('node:child_process');
const {randomBytes} = require('node:crypto');
const assert = require('node:assert/strict');
const env = {...process.env, REFERRAL_TEST_MODE: '1'};
const php = process.env.PHP_BINARY || 'php';
const port = 18137;
execFileSync(php, ['backend/tests/referral_setup.php'], {env, stdio: 'inherit'});
const server = spawn(php, ['-S', `127.0.0.1:${port}`, 'backend/tests/referral_router.php'], {env, stdio: 'ignore', windowsHide: true});
const base = `http://127.0.0.1:${port}`;
async function request(path, body, token, expected = 200) {
  const response = await fetch(base + path, {method: body ? 'POST' : 'GET', headers: {'Content-Type':'application/json', ...(token ? {Authorization:`Bearer ${token}`} : {})}, body: body ? JSON.stringify(body) : undefined});
  const text = await response.text();
  assert.equal(response.status, expected, text);
  return JSON.parse(text).data;
}
function signup(phone, device, referralCode) {
  return {phoneNumber: phone, fullName: 'Test Referral', deviceId: device, preferredLanguage:'en', registrationKey:randomBytes(32).toString('hex'), referralCode};
}
(async () => {
  try {
    for (let i = 0; i < 60; i++) {
      try { await fetch(base); break; } catch { await new Promise(r => setTimeout(r, 100)); }
    }
    await request('/api/referrals/me', null, null, 401);
    const inviter = await request('/api/auth/login', {phoneNumber:'0788111111',deviceId:'device-inviter'});
    const dashboard = await request('/api/referrals/me', null, inviter.token);
    assert.match(dashboard.code, /^RW[A-F0-9]{16}$/);
    assert.equal(dashboard.link, `https://backendapi.rwandatraffic.rw/referral?code=${dashboard.code}`);
    assert.equal(dashboard.rewardsConfigured, false);
    const firstBody = signup('0788333333', 'new-device-1', dashboard.code);
    firstBody.referrerId = 'existing'; // Client-controlled ownership is ignored.
    const first = await request('/api/auth/register', firstBody, null, 201);
    assert.equal(first.referralStatus, 'confirmed');
    const retry = await request('/api/auth/register', firstBody, null, 201);
    assert.equal(first.id, retry.id);
    await request('/api/auth/register', {...firstBody, referralCode:'RWAAAAAAAAAAAAAAAA'}, null, 409);
    await request('/api/auth/register', {...firstBody, registrationKey:randomBytes(32).toString('hex')}, null, 409);
    const own = await request('/api/referrals/me', null, first.token);
    assert.notEqual(own.code, dashboard.code);
    assert.equal((await request('/api/referrals/me', null, first.token)).code, own.code);
    const history = await request('/api/referrals/me?userId=existing', null, inviter.token);
    assert.equal(history.confirmed, 1);
    assert.equal(history.history[0].rewardStatus, 'not_configured');
    assert.deepEqual(Object.keys(history.history[0]).sort(), ['id','status','rewardStatus','createdAt'].sort());
    // Existing-user login and registration cannot attach a referral.
    const existing = await request('/api/auth/login', {phoneNumber:'0788222222',deviceId:'device-existing',referralCode:dashboard.code});
    await request('/api/auth/register', signup('0788222222','device-existing',dashboard.code), null, 409);
    await request('/api/auth/register', signup('0788444444','device-inviter',dashboard.code), null, 409);
    assert.equal((await request('/api/referrals/me', null, existing.token)).total, 0);
    for (const [index, invalid] of ['RWAAAAAAAAAAAAAAAA', 'bad-code', {code: dashboard.code}].entries()) {
      const created = await request('/api/auth/register', signup(`078855555${index}`, `invalid-device-${index}`, invalid), null, 201);
      assert.equal(created.referralStatus, 'rejected');
    }
    const duplicate = signup('0788666666','concurrent-device',dashboard.code);
    const responses = await Promise.all([request('/api/auth/register', duplicate, null, 201),request('/api/auth/register', duplicate, null, 201)]);
    assert.equal(responses[0].id, responses[1].id);
    assert.equal((await request('/api/referrals/me', null, inviter.token)).total, 2);
    await request('/api/admin/referrals', null, null, 401);
    await request('/api/admin/referrals', null, inviter.token, 403);
    await request('/api/admin/referrals/inviter', null, inviter.token, 403);
    const admin = await request('/api/auth/login', {phoneNumber:'0788999999',deviceId:'device-admin'});
    for (const query of ['Inviter', dashboard.code.toLowerCase(), '0788111111', '+250788111111']) {
      const found = await request('/api/admin/referrals?search='+encodeURIComponent(query), null, admin.token);
      assert.equal(found.total, 1);
      assert.equal(found.items[0].id, 'inviter');
      assert.equal(found.items[0].invitedCount, 2);
    }
    assert.equal((await request('/api/admin/referrals?search=%25', null, admin.token)).total, 0);
    assert.equal((await request('/api/admin/referrals?search=NoSuchUser', null, admin.token)).total, 0);
    await request('/api/admin/referrals/missing', null, admin.token, 404);
    const invitees = await request('/api/admin/referrals/inviter', null, admin.token);
    assert.equal(invitees.user.code, dashboard.code);
    assert.equal(invitees.total, 2);
    assert.deepEqual(invitees.items.map(x=>x.phoneNumber).sort(), ['0788333333','0788666666']);
    assert.equal((await request('/api/admin/referrals/existing', null, admin.token)).total, 0);
    for (let i = 0; i < 20; i++) {
      await request('/api/auth/register', signup('07887777'+String(i).padStart(2,'0'), 'pagination-device-'+i, dashboard.code), null, 201);
    }
    const pageOne = await request('/api/admin/referrals/inviter', null, admin.token);
    const pageTwo = await request('/api/admin/referrals/inviter?offset=20', null, admin.token);
    assert.equal(pageOne.total, 22);
    assert.equal(pageOne.items.length, 20);
    assert.equal(pageOne.nextOffset, 20);
    assert.equal(pageTwo.items.length, 2);
    assert.equal(pageTwo.nextOffset, null);
    assert.equal(new Set([...pageOne.items,...pageTwo.items].map(x=>x.id)).size, 22);
    const usersPage = await request('/api/admin/referrals', null, admin.token);
    assert.equal(usersPage.items.length, 20);
    assert.equal(usersPage.nextOffset, 20);
    for (const lang of ['en','fr','rw']) {
      const landing = await fetch(`${base}/referral?code=${dashboard.code}&lang=${lang}`);
      assert.equal(landing.status, 200);
      const html = await landing.text();
      assert.ok(html.includes(`lang="${lang}"`));
      assert.ok(html.includes(`referrer=referral_code%3D${dashboard.code}`));
      assert.ok(!html.includes('0788111111'));
    }
    assert.equal((await fetch(base+'/referral?code=invalid')).status, 404);
    const assets = await (await fetch(base+'/.well-known/assetlinks.json')).json();
    assert.equal(assets[0].target.package_name, 'com.trafficrules.rwanda.app');
    console.log('Referral integration passed: unique codes, registration retries, ownership, invalid codes, existing accounts, history privacy, landing pages, and asset links.');
  } finally { server.kill(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
