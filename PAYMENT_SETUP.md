# Subscription payment preparation

The access page retains its existing typography, colors, support links and active-access banner. Its exam-language selection is separate from the app locale. The local payment preparation model and `/api/pricing` use the requested nine prices.

## Configuration

`lib/config/payment_config.dart` defines `momoPayCode`, `mtnNumber` and `tigoNumber`. All default to empty. Provide your real values using `MOMO_PAY_CODE`, `MTN_NUMBER`, and `TIGO_NUMBER` build-time dart-defines, or inject a `PaymentConfiguration` into `SubscriptionPage`.

Destinations contain digits only: MoMo merchant codes accept 4–12 digits (not all zero); telephone destinations accept Rwanda local `07…` or country-code `2507…` format. Spaces, USSD delimiters and placeholder text are rejected. These are formatting checks, not provider/account verification. Do not place provider secrets in the Flutter app. Existing support contact numbers are deliberately not used as payment configuration.

## Integration point

Implement `prepareSubscriptionPayment` in `lib/features/subscription/domain/payment_preparation.dart`. It receives selected exam language, duration in months, method, integer amount, and the exact USSD string. The page freezes selection while this handler runs. The current function does nothing and the UI explicitly says payment initiation is not connected; it does not call a payment API, launch the dialer, verify payment, or activate access.

When integrating a real payment service, calculate/validate prices on your server and use verified server-side payment events to grant access. Remove or replace the preparation-only feedback when connecting your implementation.

The only backend edit is `backend/src/handlers/pricing.php`, aligning English/French 1-month and 6-month prices to 4,000 and 6,000 RWF. Upload it when deploying this change.

## Tests

`flutter test test/payment_preparation_test.dart test/subscription_payment_page_test.dart`

Test destination numbers/codes are synthetic fixtures only and are not shipped as configuration defaults.
