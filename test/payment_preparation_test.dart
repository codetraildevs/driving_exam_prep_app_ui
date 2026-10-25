import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/config/payment_config.dart';
import 'package:traffic_rule_in_rwanda/features/subscription/domain/payment_preparation.dart';

// Synthetic destinations for unit tests only, never production defaults.
const fixture = PaymentConfiguration(momoPayCode: '123456', mtnNumber: '0780000001', tigoNumber: '0720000001');
void main() {
  for (final language in ExamLanguage.values) {
    final expected = language == ExamLanguage.rw ? [1500, 3000, 5000] : [4000, 5000, 6000];
    for (final duration in SubscriptionDuration.values) {
      test('${language.name} ${duration.months} months has the requested price', () {
        expect(subscriptionPrice(language, duration), expected[duration.index]);
      });
      for (final method in PaymentMethod.values) {
        test('${language.name}/${duration.name}/${method.name} has matching amount and code', () {
          final payment = PreparedPayment.tryCreate(examLanguage: language, duration: duration, method: method, configuration: fixture)!;
          final destination = switch(method) { PaymentMethod.momoPay => '123456', PaymentMethod.mtn => '0780000001', PaymentMethod.tigo => '0720000001' };
          final prefix = method == PaymentMethod.momoPay ? '*182*8*1*' : '*182*1*1*';
          expect(payment.amount, expected[duration.index]);
          expect(payment.ussdCode, '$prefix$destination*${payment.amount}#');
          expect(payment.examLanguage, language);
          expect(payment.duration, duration);
          expect(payment.method, method);
        });
      }
    }
  }
  test('missing method or configuration cannot prepare payment', () {
    for (final method in [null, ...PaymentMethod.values]) {
      expect(PreparedPayment.tryCreate(examLanguage: ExamLanguage.rw, duration: SubscriptionDuration.oneMonth, method: method, configuration: const PaymentConfiguration()), isNull);
    }
  });
  test('placeholder and USSD injection destinations are rejected', () {
    for (final invalid in ['', 'MOMO_PAY_CODE', '<number>', '000000', '1234#', '*1234', '07 80000001', '0780000001#']) {
      final config = PaymentConfiguration(momoPayCode: invalid, mtnNumber: invalid, tigoNumber: invalid);
      for (final method in PaymentMethod.values) {
        expect(PreparedPayment.tryCreate(examLanguage: ExamLanguage.en, duration: SubscriptionDuration.oneMonth, method: method, configuration: config), isNull);
      }
    }
  });
  test('only the selected destination is required', () {
    expect(PreparedPayment.tryCreate(examLanguage: ExamLanguage.en, duration: SubscriptionDuration.oneMonth, method: PaymentMethod.momoPay, configuration: const PaymentConfiguration(momoPayCode: '123456')), isNotNull);
    expect(PreparedPayment.tryCreate(examLanguage: ExamLanguage.en, duration: SubscriptionDuration.oneMonth, method: PaymentMethod.mtn, configuration: const PaymentConfiguration(momoPayCode: '123456')), isNull);
  });
}
