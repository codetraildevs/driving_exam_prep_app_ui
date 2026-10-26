# Irembo service requests

This is an internal service-request module. It does not call official Irembo APIs, take payments, reserve an exam date, or confirm official registration. Existing exams and offline study are unchanged.

## Confirmed policies
- Admins and managers can view/process all requests and assign/reassign to active staff.
- Only USER accounts create requests; applicants see only their own requests and applicant-visible messages.
- National ID is exactly 16 digits, kept as text. Full national ID/provisoire code are returned only to authorized staff; list responses mask them.
- Provisoire has no category/code/option; Permis Manual requires exactly A, B or F; Automatic is fixed to A. Server and client validate and clear conditional values.
- Only the supplied 24 districts are accepted. Preferred dates are requests, not confirmed bookings.

## Server deployment
Back up your database and existing backend files first. Run `backend/migrations/20261026_irembo.sql` in the **existing application database** using cPanel/phpMyAdmin. It adds three InnoDB tables and does not alter exam or user tables. Runtime credentials need SELECT/INSERT/UPDATE on the new tables; DDL can be run with your deployment account.

Upload, retaining folder structure:
- `backend/src/IremboValidation.php` (new)
- `backend/src/handlers/irembo.php` (new)
- `backend/src/routes.php` (updated)
- `backend/src/init.php` (updated)

Do not upload `backend/tests/`. No new credentials or `.env` values are required. Rebuild/install the Flutter app after deploying the migration and handlers. If schema is missing, only the Irembo endpoint reports unavailable; other endpoints continue unchanged.

## API
All endpoints require the existing Bearer authentication:
- GET/POST `/api/irembo-requests`
- GET/PUT `/api/irembo-requests/{id}`
- GET `/api/irembo-requests/staff` (staff only)

Creation requires a UUID v4 `requestKey`, reused across retries. Unique `(userId, requestKey)` plus a payload hash prevents repeated delivery from creating duplicates. Updates require the last loaded integer `version`; row locking and optimistic conflict checks prevent silent overwrites. Updates, messages and audit entries commit together. Reasons for Needs Information/Rejected are applicant-visible. Internal notes and audit entries are staff-only. Role/blocked status is read from the database for every request.

Search/filter values are parameterized. Sort fields are allowlisted. Staff page size is 20. Applicants receive their own requests without pagination. Submitted-date range is inclusive, evaluated in UTC. Staff can correct fields in the detail page, and manage status/assignment/messages separately. Calling uses the submitted phone number through `tel:`; copying never converts identifiers to numbers.

## Verification
CI exercises PHP syntax, MySQL integration, all registration variants, invalid categories/IDs/districts/dates, retry safety, scope and role revocation, private notes, audit history, search/filter pagination, Flutter validation, responsive/localized screens and clipboard behavior. Test the device dialer and a complete applicant/staff flow on staging before production rollout.

Rollback: restore prior Flutter/backend code. Keep the new tables to preserve submitted requests; do not drop production data as part of rollback.
