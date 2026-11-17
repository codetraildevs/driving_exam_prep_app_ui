import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/features/referrals/data/referral_repository.dart';
import 'package:traffic_rule_in_rwanda/features/referrals/presentation/referral_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';

class FakeReferrals extends ReferralRepository {
  bool fail = false;
  @override
  Future<ReferralSummary> load({int offset = 0}) async {
    if (fail) throw Exception('offline');
    return ReferralSummary.fromJson({
      'code': 'RW0123456789ABCDEF',
      'link':
          'https://backendapi.rwandatraffic.rw/referral?code=RW0123456789ABCDEF',
      'total': 1,
      'confirmed': 1,
      'pending': 0,
      'nextOffset': null,
      'history': [
        {'id': 'r1', 'status': 'confirmed', 'createdAt': '2026-10-28 12:00:00'},
      ],
    });
  }
}

void main() {
  for (final language in ['en', 'fr', 'rw']) {
    testWidgets('referrals fit narrow screens with large text in $language', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = FakeReferrals();
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            FallbackMaterialLocalizationsDelegate(),
            FallbackCupertinoLocalizationsDelegate(),
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.8)),
            child: child!,
          ),
          home: ReferralPage(repository: repository),
        ),
      );
      await tester.pumpAndSettle();
      final l = AppLocalizations.of(tester.element(find.byType(ReferralPage)));
      expect(find.text(l.referralRewardsDisabled), findsOneWidget);
      expect(find.text('RW0123456789ABCDEF'), findsOneWidget);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.ensureVisible(find.text(l.referralCopy));
      await tester.tap(find.text(l.referralCopy));
      await tester.pumpAndSettle();
      expect(
        copied,
        'https://backendapi.rwandatraffic.rw/referral?code=RW0123456789ABCDEF&lang=$language',
      );
      expect(tester.takeException(), isNull);
    });
  }
}
