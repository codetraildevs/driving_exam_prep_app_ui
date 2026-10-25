import '../../../config/payment_config.dart';

enum ExamLanguage { en, fr, rw }
enum SubscriptionDuration {
  oneMonth(1, '1_MONTH'),
  threeMonths(3, '3_MONTHS'),
  sixMonths(6, '6_MONTHS');

  final int months;
  final String tier;
  const SubscriptionDuration(this.months, this.tier);
}
enum PaymentMethod { momoPay, mtn, tigo }

int subscriptionPrice(ExamLanguage language, SubscriptionDuration duration) {
  final prices = language == ExamLanguage.rw
      ? const [1500, 3000, 5000]
      : const [4000, 5000, 6000];
  return prices[duration.index];
}

/// A validated, immutable snapshot used by both the display and payment handler.
class PreparedPayment {
  final ExamLanguage examLanguage;
  final SubscriptionDuration duration;
  final PaymentMethod method;
  final int amount;
  final String ussdCode;
  const PreparedPayment._(this.examLanguage, this.duration, this.method, this.amount, this.ussdCode);

  static PreparedPayment? tryCreate({
    required ExamLanguage examLanguage,
    required SubscriptionDuration duration,
    required PaymentMethod? method,
    required PaymentConfiguration configuration,
  }) {
    if (method == null) return null;
    final destination = switch (method) {
      PaymentMethod.momoPay => configuration.momoPayCode.trim(),
      PaymentMethod.mtn => configuration.mtnNumber.trim(),
      PaymentMethod.tigo => configuration.tigoNumber.trim(),
    };
    // Accept digits only; never allow USSD delimiters, placeholders or dial actions.
    final valid = method == PaymentMethod.momoPay
        ? RegExp(r'^[0-9]{4,12}$').hasMatch(destination) && !RegExp(r'^0+$').hasMatch(destination)
        : RegExp(r'^(?:0|250)7[2389][0-9]{7}$').hasMatch(destination);
    if (!valid) return null;
    final amount = subscriptionPrice(examLanguage, duration);
    final prefix = method == PaymentMethod.momoPay ? '*182*8*1*' : '*182*1*1*';
    return PreparedPayment._(examLanguage, duration, method, amount, '$prefix$destination*$amount#');
  }
}

typedef PaymentPreparationHandler = Future<void> Function({
  required ExamLanguage examLanguage,
  required int durationMonths,
  required PaymentMethod paymentMethod,
  required int amount,
  required String ussdCode,
});

/// Integration boundary only. No network request, dialer launch, success message,
/// subscription mutation or payment verification is performed here.
Future<void> prepareSubscriptionPayment({
  required ExamLanguage examLanguage,
  required int durationMonths,
  required PaymentMethod paymentMethod,
  required int amount,
  required String ussdCode,
}) async {
  // TODO: Implement payment initiation using the selected payment details.
}
