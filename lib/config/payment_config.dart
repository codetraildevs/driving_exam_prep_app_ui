/// Payment destinations are intentionally unset. Configure these through
/// --dart-define or supply a configuration when constructing SubscriptionPage.
/// Existing support contacts are not payment destinations.
class PaymentConfiguration {
  final String momoPayCode;
  final String mtnNumber;
  final String tigoNumber;

  const PaymentConfiguration({
    this.momoPayCode = '',
    this.mtnNumber = '',
    this.tigoNumber = '',
  });

  static const environment = PaymentConfiguration(
    momoPayCode: String.fromEnvironment('MOMO_PAY_CODE'),
    mtnNumber: String.fromEnvironment('MTN_NUMBER'),
    tigoNumber: String.fromEnvironment('TIGO_NUMBER'),
  );
}
