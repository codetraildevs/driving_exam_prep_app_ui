import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traffic_rule_in_rwanda/config/payment_config.dart';
import 'package:traffic_rule_in_rwanda/features/subscription/domain/payment_preparation.dart';
import 'package:traffic_rule_in_rwanda/features/subscription/presentation/pages/subscription_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:traffic_rule_in_rwanda/shared/subscription/subscription_notifier.dart';

class _Subscription extends SubscriptionNotifier {
  @override
  SubscriptionState build() => const SubscriptionState(hasLoaded: true);
}
const fixture = PaymentConfiguration(momoPayCode: '123456', mtnNumber: '0780000001', tigoNumber: '0720000001');
Future<void> pumpPage(WidgetTester tester, {
  PaymentConfiguration config = fixture,
  PaymentPreparationHandler handler = prepareSubscriptionPayment,
  String language = 'en',
  double scale = 1,
  ValueNotifier<Locale>? appLocale,
}) async {
  SharedPreferences.setMockInitialValues({});
  GoogleFonts.config.allowRuntimeFetching = false;
  tester.view.physicalSize = const Size(320, 740);
  tester.view.devicePixelRatio = 1;
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(ProviderScope(overrides: [subscriptionProvider.overrideWith(_Subscription.new)],
    child: ValueListenableBuilder<Locale>(
      valueListenable: appLocale ?? ValueNotifier(Locale(language)),
      builder: (context, locale, _) => MaterialApp(locale: locale, supportedLocales: LocaleNotifier.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, GlobalWidgetsLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(), FallbackCupertinoLocalizationsDelegate()],
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
      home: SubscriptionPage(paymentConfiguration: config, paymentHandler: handler),
    )),
  ));
  await tester.pumpAndSettle();
}
Future<void> tapKey(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}
void main() {
  for (final language in ['rw', 'fr', 'en']) {
    testWidgets('localized payment page has no overflow at large text: $language', (tester) async {
      await pumpPage(tester, language: language, scale: 1.6);
      final cards = ['1_MONTH', '3_MONTHS', '6_MONTHS']
          .map((tier) => tester.getRect(find.byKey(ValueKey('plan-$tier')))).toList();
      expect(cards[0].top, cards[1].top);
      expect(cards[1].top, cards[2].top);
      expect(cards[0].right, lessThan(cards[1].left));
      expect(cards[1].right, lessThan(cards[2].left));
      expect(cards[0].width, closeTo(cards[2].width, 0.01));
      await tapKey(tester, 'payment-method-momoPay');
      expect(find.text('*182*8*1*123456*${language == 'rw' ? 3000 : 5000}#'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('app language updates price and code while retaining plan and method', (tester) async {
    final locale = ValueNotifier(const Locale('en'));
    addTearDown(locale.dispose);
    await pumpPage(tester, appLocale: locale);
    expect(find.byKey(const ValueKey('exam-language-en')), findsNothing);
    expect(find.text('Amount to pay: 5,000 RWF'), findsOneWidget);
    await tapKey(tester, 'plan-1_MONTH');
    await tapKey(tester, 'payment-method-mtn');
    expect(find.text('Amount to pay: 4,000 RWF'), findsOneWidget);
    expect(find.text('*182*1*1*0780000001*4000#'), findsOneWidget);
    locale.value = const Locale('rw');
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const ValueKey('payment-amount'))).data, contains('1,500 RWF'));
    expect(find.text('*182*1*1*0780000001*1500#'), findsOneWidget);
    locale.value = const Locale('fr');
    await tester.pumpAndSettle();
    expect(find.text('*182*1*1*0780000001*4000#'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const ValueKey('pay-now'))).onPressed, isNotNull);
  });
  testWidgets('missing configuration never shows a code or enables payment', (tester) async {
    await pumpPage(tester, config: const PaymentConfiguration());
    await tapKey(tester, 'payment-method-tigo');
    expect(find.text('Payment details are not configured yet.'), findsOneWidget);
    expect(find.byKey(const ValueKey('payment-ussd')), findsNothing);
    expect(find.byKey(const ValueKey('copy-payment-code')), findsNothing);
    expect(tester.widget<FilledButton>(find.byKey(const ValueKey('pay-now'))).onPressed, isNull);
  });
  testWidgets('configured app destinations enable PAY NOW for each method', (tester) async {
    await pumpPage(tester, config: PaymentConfiguration.environment);
    for (final method in PaymentMethod.values) {
      await tapKey(tester, 'payment-method-${method.name}');
      expect(tester.widget<FilledButton>(find.byKey(const ValueKey('pay-now'))).onPressed, isNotNull);
      expect(find.byKey(const ValueKey('payment-ussd')), findsOneWidget);
      expect(find.byKey(const ValueKey('payment-validation')), findsNothing);
    }
  });
  testWidgets('copy preserves delimiters and reports clipboard failure', (tester) async {
    await pumpPage(tester);
    String? copied;
    bool fail = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        if (fail) throw PlatformException(code: 'clipboard');
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await tapKey(tester, 'payment-method-momoPay');
    await tapKey(tester, 'copy-payment-code');
    expect(copied, '*182*8*1*123456*5000#');
    expect(find.text('Code copied'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    fail = true;
    await tapKey(tester, 'copy-payment-code');
    expect(find.text('Could not copy the code. Please try again or copy it manually.'), findsOneWidget);
  });
  testWidgets('handler receives displayed values without activating a subscription', (tester) async {
    Map<String, Object>? captured;
    await pumpPage(tester, handler: ({required examLanguage, required durationMonths, required paymentMethod, required amount, required ussdCode}) async {
      captured = {'language': examLanguage, 'months': durationMonths, 'method': paymentMethod, 'amount': amount, 'code': ussdCode};
    });
    await tapKey(tester, 'plan-6_MONTHS');
    await tapKey(tester, 'payment-method-tigo');
    expect(find.text('Amount to pay: 6,000 RWF'), findsOneWidget);
    expect(find.text('*182*1*1*0720000001*6000#'), findsOneWidget);
    await tapKey(tester, 'pay-now');
    expect(captured, {'language': ExamLanguage.en, 'months': 6, 'method': PaymentMethod.tigo, 'amount': 6000, 'code': '*182*1*1*0720000001*6000#'});
    final container = ProviderScope.containerOf(tester.element(find.byType(SubscriptionPage)));
    expect(container.read(subscriptionProvider).hasActiveAccess, isFalse);
    expect(find.textContaining('no payment has been confirmed'), findsOneWidget);
  });
}
