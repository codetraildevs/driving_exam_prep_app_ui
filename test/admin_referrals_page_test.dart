import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:traffic_rule_in_rwanda/features/admin/presentation/pages/admin_referrals_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';

class FakeAdminReferrals extends AdminReferralRepository {
  final requests = <(String?, String, int)>[];
  final slow = Completer<Map<String, dynamic>>();
  bool fail = false;

  Map<String, dynamic> result(String name) => {
    'items': [{'id': 'inviter', 'fullName': name, 'phoneNumber': '0788111111',
      'code': 'RW0123456789ABCDEF', 'invitedCount': 2}],
    'total': 21, 'nextOffset': 20,
  };

  @override
  Future<Map<String, dynamic>> load({String? userId, String search = '', int offset = 0}) async {
    requests.add((userId, search, offset));
    if (fail) throw Exception('offline');
    if (search == 'slow') return slow.future;
    if (userId != null) {
      return {
        'user': {'fullName': 'Inviter', 'phoneNumber': '0788111111', 'code': 'RW0123456789ABCDEF'},
        'items': [{'id': 'r1', 'fullName': 'Invited Driver', 'phoneNumber': '0788222222',
          'createdAt': '2026-10-29 12:00:00', 'status': 'confirmed'}],
        'total': 1, 'nextOffset': null,
      };
    }
    if (offset == 20) return {'items': [], 'total': 21, 'nextOffset': null};
    return result(search.isEmpty ? 'Inviter' : search);
  }
}

Future<void> showPage(WidgetTester tester, FakeAdminReferrals repository, String locale) async {
  final router = GoRouter(initialLocation: '/admin/referrals', routes: [
    GoRoute(path: '/admin/referrals', builder: (_, __) => AdminReferralsPage(repository: repository)),
    GoRoute(path: '/admin/referrals/:userId', builder: (_, state) => AdminReferralsPage(
      repository: repository, userId: state.pathParameters['userId'])),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(
    routerConfig: router, locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [...AppLocalizations.localizationsDelegates,
      FallbackMaterialLocalizationsDelegate(), FallbackCupertinoLocalizationsDelegate()],
  ));
  await tester.pumpAndSettle();
}

void main() {
  for (final locale in ['en', 'fr', 'rw']) {
    testWidgets('admin search opens invitees without overflow in $locale', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = FakeAdminReferrals();
      await showPage(tester, repository, locale);
      await tester.enterText(find.byType(TextField), '0788111111');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(repository.requests.last, (null, '0788111111', 0));
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();
      expect(repository.requests.last.$1, 'inviter');
      expect(find.text('Invited Driver'), findsOneWidget);
      expect(find.textContaining('0788222222'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('stale search cannot replace newer results; pagination and retry work', (tester) async {
    final repository = FakeAdminReferrals();
    await showPage(tester, repository, 'en');
    await tester.enterText(find.byType(TextField), 'slow');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField), 'latest');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    repository.slow.complete(repository.result('Stale User'));
    await tester.pumpAndSettle();
    expect(find.text('Stale User'), findsNothing);
    expect(find.text('latest'), findsWidgets);
    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    expect(repository.requests.last.$3, 20);
    repository.fail = true;
    await tester.tap(find.byTooltip('Previous page'));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(AdminReferralsPage)));
    expect(find.text(l10n.referralLoadError), findsOneWidget);
    repository.fail = false;
    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();
    expect(repository.requests.last.$3, 0);
    expect(find.text(l10n.referralLoadError), findsNothing);
  });
}
