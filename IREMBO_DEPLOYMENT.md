# Irembo service requests

This is an internal service-request module. Its service-fee button opens the phone dialer; it does not verify payment, call official Irembo APIs, reserve an exam date, or confirm official registration.

## Confirmed policies
- Admins and managers can view/process all requests and assign/reassign to active staff.
- Only USER accounts create requests; applicants see only their own requests and applicant-visible messages.
- One request per account per service: Provisoire, Permis · Manual and Permis · Automatic are separate slots, so an applicant can submit all three. Reopening a form or changing devices cannot create a second request for the same service. The applicant page lists the submitted details (reference, full name, phone, national ID as returned by the server, service, option, category, exam language, district and dates) without a detail-page button.
- The applicant page keeps the service/option selection interactive, so the fee and USSD code follow the current selection. A service that is already submitted shows the received notice instead of the continue button, and the page preselects a service that is still open when one exists.
- A fixed payment bar stays visible on the applicant page and registration form. Provisoire and Permis Manual cost 1,000 RWF; Permis Automatic costs 5,000 RWF. The bar shows the full USSD request, `*182*8*1*644203*1000#` or `*182*8*1*644203*5000#`, with a copy icon underneath the pay button, and the pay button dials that exact code. `644203` is the MoMo Pay merchant code for Irembo service fees only and is separate from the subscription destinations in `lib/config/payment_config.dart`. Opening the dialer does not mark a request paid.
- National ID is exactly 16 digits, kept as text. Full national ID/provisoire code are returned only to authorized staff; list responses mask them.
- Provisoire has no category/code/option; Permis Manual requires exactly A, B or F; Automatic is fixed to A. Server and client validate and clear conditional values.
- Only the supplied 24 districts are accepted. Preferred dates are requests, not confirmed bookings.

## Server deployment
### Delete HTTP 404, bulk deletion and offline reading
Deploy **both** `backend/src/routes.php` and `backend/src/handlers/irembo.php` together, then rebuild the Flutter app. A Flutter-only update cannot add a missing server endpoint. The runtime database account also needs DELETE privileges on `irembo_requests`, `irembo_messages`, and `irembo_audit`. No new migration is required.

The app tries DELETE `/api/irembo-requests/{id}` and falls back on HTTP 404/405 to POST `/api/irembo-requests/{id}/delete`. Both endpoints authorize the current database role, remove dependent messages/audit rows in a transaction, and accept retries when a record has already been deleted. POST `/api/irembo-requests/bulk-delete` accepts `{"ids":["uuid", "uuid"]}` (1–100 IDs), authorizes ADMIN/MANAGER, validates all IDs before deleting, and commits the entire batch atomically. The UI selects individual requests or the current page; changing the result set clears selection. No deletion is queued offline.

Request lists are cached by account, role, filters and page. Previously loaded detail pages can also be read offline. Lists show saved data immediately while refreshing and fall back to saved data for network timeouts/server outages, with an offline notice. Submission and deletion require a server connection. A first visit without saved data cannot show requests. Authorization failures do not fall back to cached data; logout clears Irembo caches. The cache does not fix a server timeout or missing route: investigate hosting/database latency if GET timeouts continue after deployment.

Verify with `php backend/tests/irembo_schema_test.php` against a disposable local database and `flutter test test/irembo_test.dart test/irembo_page_test.dart test/irembo_offline_test.dart`. Never deploy test files.

Back up your database and existing backend files first. Run `backend/migrations/20261026_irembo.sql` in the **existing application database** using cPanel/phpMyAdmin. It adds three InnoDB tables and does not alter exam or user tables. Runtime credentials need SELECT/INSERT/UPDATE on the new tables; DDL can be run with your deployment account.

Upload, retaining folder structure:
- `backend/src/IremboValidation.php` (new)
- `backend/src/handlers/irembo.php` (new)
- `backend/src/routes.php` (updated)
- `backend/src/init.php` (updated)

Do not upload `backend/tests/`. No new credentials or `.env` values are required. Rebuild/install the Flutter app after deploying the migration and handlers. If schema is missing, only the Irembo endpoint reports unavailable; other endpoints continue unchanged.

## API
Creation locks the user's database row and checks for any existing request within the same transaction. A new request key for an account with a request returns HTTP 409 `alreadySubmitted`; a retry of the original unchanged payload returns the existing request. This requires InnoDB tables, as in the supplied schema. Deploy the updated handler and rebuild Flutter for the compact page/payment changes; no new migration is required.

All endpoints require the existing Bearer authentication:
- GET/POST `/api/irembo-requests`
- GET/PUT `/api/irembo-requests/{id}`
- GET `/api/irembo-requests/staff` (staff only)

Creation requires a UUID v4 `requestKey`, reused across retries. Unique `(userId, requestKey)` plus a payload hash prevents repeated delivery from creating duplicates. Updates require the last loaded integer `version`; row locking and optimistic conflict checks prevent silent overwrites. Updates, messages and audit entries commit together. Reasons for Needs Information/Rejected are applicant-visible. Internal notes and audit entries are staff-only. Role/blocked status is read from the database for every request.

Search/filter values are parameterized. Sort fields are allowlisted. Staff page size is 20. Applicants receive their own requests without pagination. Submitted-date range is inclusive, evaluated in UTC. Staff can correct fields in the detail page, and manage status/assignment/messages separately. Calling uses the submitted phone number through `tel:`; copying never converts identifiers to numbers.

## Verification
### Fix for access denied after successful login
Irembo now checks `users.isActive`, matching login and the admin block/unblock controls. The legacy `isBlocked` column defaults to `1` even for active users and must not be used to deny Irembo access. The same correction applies to staff lookup and assignment. Upload the corrected `backend/src/handlers/irembo.php`; no database changes or Flutter rebuild are required for this server fix. Active USER accounts can submit and load their own requests; inactive accounts remain denied, and ADMIN/MANAGER accounts retain their processing roles.

### Fix for submission and request-list HTTP 503
The application's user-name column is `users.fullName`. Earlier Irembo handlers queried `users.name`, including during the initial account lookup, causing both submission and request loading to fail with HTTP 503. Upload the corrected `backend/src/handlers/irembo.php` to the matching server folder. The handler preserves the `name`, `assignedStaffName`, `staffName`, and `actorName` response fields using SQL aliases. No additional migration or user-table alteration is needed for this fix.

After upload, submit as a USER, refresh My Irembo Requests, then check the request and staff assignment in the admin/manager workspace. `php backend/tests/irembo_schema_test.php` tests these flows in a disposable database using the actual users DDL from the repository. It defaults to the CI MySQL password; for a local passwordless test server set `IREMBO_TEST_EMPTY_PASSWORD=1`. Never upload test files.

CI exercises PHP syntax, MySQL integration, all registration variants, invalid categories/IDs/districts/dates, retry safety, scope and role revocation, private notes, audit history, search/filter pagination, Flutter validation, responsive/localized screens and clipboard behavior. Test the device dialer and a complete applicant/staff flow on staging before production rollout.

Rollback: restore prior Flutter/backend code. Keep the new tables to preserve submitted requests; do not drop production data as part of rollback.
