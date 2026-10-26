# Branch update review

Implemented against `feat/app-updates-1.2.0` (source head `4dd8aff700d17854478845cfa1e3d89579d13eda`).

- Privacy consent: header and content now scroll together, with acceptance outside the scrolling region, improving short-screen support.
- Kinyarwanda: existing startup fallback was already implemented; aligned registration defaults.
- Demo account: the existing Play Store account signs in without a password and works across devices. Only this account's phone number is hidden on the user dashboard; its name remains visible. Public registration still grants USER only; the demo number remains reserved.
- Purple: requested RGB(96,44,145) and related palette were already implemented.
- Phone lookup: canonicalized Rwanda number formats in authentication, matched legacy country-code records, and broadened admin phone search. This does not prove that 0739914099 exists in production. A genuinely absent account must register; no account or subscription was fabricated.
- WhatsApp: authenticated directory and admin/manager create/edit/delete APIs, with matching user and admin screens. Users fetch current groups when opening the directory or refreshing. An empty directory is shown until an administrator adds groups; the previous hardcoded link is no longer used.
- Dashboard: pinned access card, numeric remaining days in the ring, rounded up partial days, and compact action button to give plan/status text room.

## Required deployment configuration

Deploy `backend/src/handlers/auth.php` and `backend/src/init.php` together, then install the updated Flutter app to remove the password popup and hide the demo phone on the dashboard. `DEMO_OWNER_PASSWORD_HASH` is no longer used and may be removed from the server environment. Existing valid demo refresh tokens remain supported. Other accounts retain their existing device checks.

## Verification

`git diff --check` passed. Tree-sitter parsed all 104 downloaded/new Dart and PHP files without syntax errors. Flutter/Dart/PHP runtimes are not installed in the supplied environment, and Docker access is unavailable. Compilation, PHP execution, DB integration, and device layout tests remain unverified.

Before deployment, run:

```sh
flutter pub get
flutter analyze
flutter test
php backend/tests/phone_normalization_test.php
```

Lint PHP files with `php -l`. Exercise group CRUD as admin and verify ordinary users cannot mutate groups; test password-free demo login, existing refresh tokens, and device checks for ordinary accounts; verify consent on short screens/large text; test dashboard at narrow widths and near expiry.

The account-specific production investigation still requires database access. Check the reported number in both local and +250 formats and confirm the app and admin use the same API/database.
