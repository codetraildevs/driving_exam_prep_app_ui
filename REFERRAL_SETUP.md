# Referral rollout and verification

## Implemented flow

Authenticated users open Refer & Earn to share their permanent personal link,
copy it, and view registration counts and history in English, French or
Kinyarwanda. Rewards are not configured and no subscription benefits are granted.

Links use `https://backendapi.rwandatraffic.rw/referral?code=...`. Android captures
installed-app invitations and stores pending attribution encrypted with Keystore.
The web landing page links to `com.trafficrules.rwanda.app` on Google Play with
an install referrer. First launch recovers it automatically; registration sends
the pending code and a persisted random retry key. The backend validates the
inviter and writes account, code, attribution and retry receipt in one transaction.
Existing-account login cannot create referral credit. Receipts expire after 24 hours.

## Deployment

### Exact upload list for the referral update

Paths below are relative to your existing backend folder on the server. Replace
files in that folder; do not create an extra nested `backend/backend` directory.

- `public/index.php` (entry point)
- `src/init.php` (loads the referral handlers and public routes)
- `src/routes.php` (registers `/api/referrals/me`)
- `src/ReferralService.php` (new)
- `src/handlers/referrals.php` (new)
- `src/handlers/auth.php` (registration attribution)
- `src/views/referral.php` (new landing page)
- `.htaccess`
- `public/.htaccess`

Import `backend/migrations/20261028_referrals.sql` into the existing application
database using phpMyAdmin's Import tab before replacing the PHP files. It is a
database script, not a PHP endpoint. Preserve the production `.env`; do not
replace it with `.env.example`.

### Troubleshooting GET /api/referrals/me returning 404

The local route is registered in `src/routes.php` and its handler is loaded by
`src/init.php`. An authenticated 404 generally indicates an older route file,
an upload into the wrong backend directory, or a web-server rewrite mismatch.
Upload the entire list above to the backend serving the app's configured API
domain. If PHP OPcache does not check file changes, restart PHP through the host.
Retry Refer & Earn while logged in: the expected response is HTTP 200. A 503
after upload requires checking the migration and backend logs. Missing referral
tables do not explain a route-not-found 404. A 401 without a login token is
expected and by itself does not prove the referral route was deployed.

The Android `Sending viewport metrics to the engine` message is routine layout
logging and needs no fix. App-signing fingerprints are needed for Android link
verification, but are not needed to load the referral dashboard API.

1. Back up the database and run `backend/migrations/20261028_referrals.sql`
   before deploying the updated registration handler. Verify `users` uses InnoDB
   and has unique phoneNumber and deviceId constraints. The migration backfills
   permanent invitation codes for existing users and creates three referral tables.
2. Deploy the updated backend files and Apache rewrite configuration. Exclude
   `backend/tests` from deployment.
3. Set `ANDROID_APP_SIGNING_SHA256` in the backend environment to the Play app
   signing certificate SHA-256 fingerprint (colon-separated bytes). Multiple
   signing certificates may be comma-separated. Use the app signing certificate,
   not merely the upload certificate.
4. Verify `https://backendapi.rwandatraffic.rw/.well-known/assetlinks.json`
   returns HTTP 200 with the production package and fingerprint. Missing
   fingerprints deliberately return HTTP 503. Check `/referral` renders the
   localized landing page and points to the correct published Play listing.
5. Publish the Android build containing ReferralBridge and the Install Referrer
   dependency. No Firebase Dynamic Links configuration is used.

## Local checks

### Admin referral lookup

The admin dashboard now includes Referrals. Admins and managers can search users
by name, referral code (case-insensitive), or phone number, then open a user's
invited-account list with names, phone numbers, registration dates and statuses.
Both lists are paginated. Ordinary users cannot access these personal details.

For this update, replace `src/routes.php` and `src/handlers/referrals.php` in
`/home/rwandatr/public_html/backendapi/` and rebuild the Flutter app. No additional
database migration is needed if the referral migration was already imported.
`src/ReferralService.php` must remain installed. The admin endpoints are
`GET /api/admin/referrals?search=...` and `GET /api/admin/referrals/:userId`.
Both accept `offset` and return at most 20 rows.

Admin lookup, access denial, phone/code/name search, inviter ownership and
pagination passed the local MySQL integration suite. The test runner accepts an
explicit empty test password for local XAMPP instances; production credentials
are never used by the runner.

```powershell
flutter test test/referral_session_test.dart test/referral_page_test.dart
flutter analyze --no-pub lib/features/referrals test/referral_session_test.dart test/referral_page_test.dart
$env:REFERRAL_TEST_DB_PORT = '3306'
$env:REFERRAL_TEST_DB_PASSWORD = '<disposable local MySQL password>'
node backend/tests/referral_integration.cjs
```

The integration runner resets tables only in the local `referral_test` database.
Use a disposable MySQL instance. Its PHP development server processes requests
serially, so the parallel HTTP retry check is not proof of database concurrency.

## Device acceptance checks still required

- Open invitations from WhatsApp, SMS and a browser with the app installed.
- Follow the landing-page Play button without the app installed; install, launch
  and register, then confirm the inviter's count increases once.
- Cancel registration, restart the app, and resume with the same invitation.
- Retry after a lost registration response; verify one account and referral.
- Test an existing account, invalid links, offline use, and duplicate clicks.
- Verify Android supported-link association using the actual release certificate.

Deferred attribution depends on installation through the referral-bearing Play
link and the Play referrer service. Sideloading, other stores or searching Play
separately cannot guarantee recovery. Reopening the original invitation after
installation and before registration provides the fallback without manual code
entry. A registration already sent without attribution is kept unchanged on retry.

## Review status (2026-10-29)

Fixed Kinyarwanda referral-history date formatting, transient platform referrer
errors, overlapping recovery calls, post-authentication cleanup failures, and
receipt rechecks when another registration commits during duplicate checks.
All 15 referral Flutter tests and PHP syntax checks passed. Targeted Flutter
analysis reports no issues. Backend integration passed using the local XAMPP
test database, including the new admin endpoints. Production association and real-device
installation/sharing checks have not been performed.
