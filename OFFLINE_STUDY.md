# Offline study behavior

- A previously signed-in account opens from local storage while online refresh runs in the background. First login and registration still require the server.
- English, French and Kinyarwanda practice questions and question images are bundled with the app. Gazette and Ibyapa PDFs are bundled and read inside the app.
- Free practice remains available offline. Paid practice uses the signed-in account's saved, server-verified access until its expiry. A failed request does not erase that access.
- This update replaces device-wide access flags with per-account records. Connect once after installing the update to populate the verified record for the current account.
- Completed practice attempts are written to a durable local outbox before upload. Progress and certificates show saved results immediately and retain pending attempts when refreshing from the server.
- Synchronization is single-flight, retries periodically, and sends only the current account's attempts. Each attempt has a stable ID; the server treats repeated delivery as the same record.
- The Signs screen also offers the bundled Ibyapa PDF. Its online gallery, WhatsApp group directory, new access activation and payment verification still require connectivity.
- Keep the app's local storage when updating. Clearing app data or uninstalling removes unsynchronized attempts.

## Deployment

Upload the updated `backend/src/handlers/exam_results.php` to the existing backend's `src/handlers/exam_results.php` before releasing the new app. It accepts optional `clientResultId` values and uses the existing primary key; no database migration is required. Older clients remain supported.

The Flutter app must also be rebuilt and installed. Do not upload backend test harnesses.

## Verification

Automated checks cover bundled content, offline persistence, concurrent saves, account-specific synchronization, retries, cached startup, cached certificates, access expiry and MySQL duplicate-delivery handling. Physical-device airplane-mode testing is still recommended before a Play Store release.
