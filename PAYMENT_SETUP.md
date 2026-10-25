# Subscription payment preparation

The access page retains its existing typography, colors, support links and active-access banner. Pricing and payment details automatically use the current app language (Kinyarwanda, English or French); there is no separate exam-language selector. Changing the app language recalculates the price and USSD code while keeping the selected plan and payment method. The local payment preparation model and `/api/pricing` use the requested nine prices.

## Configuration

`lib/config/payment_config.dart` defines `momoPayCode`, `mtnNumber` and `tigoNumber`. The app environment configuration uses the owner's supplied destinations. The plain constructor remains empty for explicit unavailable-configuration states. Override the app values using `MOMO_PAY_CODE`, `MTN_NUMBER`, and `TIGO_NUMBER` build-time dart-defines, or inject a `PaymentConfiguration` into `SubscriptionPage`.

Destinations contain digits only: MoMo merchant codes accept 4–12 digits (not all zero); telephone destinations accept Rwanda local `07…` or country-code `2507…` format. Spaces, USSD delimiters and placeholder text are rejected. These are formatting checks, not provider/account verification. Do not place provider secrets in the Flutter app. Existing support contact numbers are deliberately not used as payment configuration.

## Integration point

`prepareSubscriptionPayment` in `lib/features/subscription/domain/payment_preparation.dart` opens the prepared USSD code in the phone dialer. PAY NOW first copies the full code to the clipboard, then opens the dialer; the user completes the payment on their phone. If opening the dialer fails, the code remains available to copy and dial manually. The page freezes selections during initiation. Opening the dialer never verifies payment or grants access.

When integrating a real payment service, calculate/validate prices on your server and use verified server-side payment events to grant access. The current feedback confirms copying only, never payment success.

The only backend edit is `backend/src/handlers/pricing.php`, aligning English/French 1-month and 6-month prices to 4,000 and 6,000 RWF. Upload it when deploying this change.

## Tests

`flutter test test/payment_preparation_test.dart test/subscription_payment_page_test.dart`

Test destination numbers/codes are synthetic fixtures only and are not shipped as configuration defaults.
