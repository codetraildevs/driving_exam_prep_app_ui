/// Owner-provided payment destinations. Build-time dart-defines can override
/// these defaults; an explicitly empty override disables that payment method.
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
    momoPayCode: String.fromEnvironment('MOMO_PAY_CODE', defaultValue: '329494'),
    mtnNumber: String.fromEnvironment('MTN_NUMBER', defaultValue: '0788659575'),
    tigoNumber: String.fromEnvironment('TIGO_NUMBER', defaultValue: '0728877442'),
  );
}
