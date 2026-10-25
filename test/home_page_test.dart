import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/home/data/models/dashboard_notices.dart';
import 'package:traffic_rule_in_rwanda/features/home/presentation/pages/home_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:traffic_rule_in_rwanda/shared/subscription/subscription_notifier.dart';

class _Subscription extends SubscriptionNotifier {
  final SubscriptionState initial;
  final SubscriptionState? refreshed;
  int calls = 0;
  _Subscription(this.initial, this.refreshed);
  @override
  SubscriptionState build() => initial;
  @override
  Future<void> refreshStatus(String userId) async {
    calls++;
    if (calls > 1 && refreshed != null) state = refreshed!;
  }
}

class _Locale extends LocaleNotifier {
  final String code;
  _Locale(this.code);
  @override
  LocaleState build() => LocaleState(locale: Locale(code));
}

Future<void> _pump(WidgetTester tester, {
  Size size = const Size(390, 844),
  String language = 'rw',
  double scale = 1,
  SubscriptionState sub = const SubscriptionState(hasLoaded: true),
  DashboardNotices notices = const DashboardNotices([]),
  SubscriptionState? refreshed,
}) async {
  SharedPreferences.setMockInitialValues({});
  GoogleFonts.config.allowRuntimeFetching = false;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  final now = DateTime.now();
  final bloc = AuthBloc()..emit(AuthAuthenticated(UserModel(id: 'u1', name: 'Test Driver',
    phoneNumber: '0788123456', createdAt: now, updatedAt: now)));
  final router = GoRouter(initialLocation: '/home', routes: [
    GoRoute(path: '/home', builder: (_, __) => const HomePage()),
    for (final path in ['practice', 'progress', 'subscription'])
      GoRoute(path: '/$path', builder: (_, __) => Scaffold(body: Text('route-$path'))),
  ]);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    await bloc.close();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(BlocProvider<AuthBloc>.value(value: bloc,
    child: ProviderScope(overrides: [
      subscriptionProvider.overrideWith(() => _Subscription(sub, refreshed)),
      localeProvider.overrideWith(() => _Locale(language)),
      dashboardNoticesProvider('u1').overrideWith((ref) async => notices),
    ], child: Consumer(builder: (context, ref, _) => MaterialApp.router(
      routerConfig: router,
      locale: ref.watch(localeProvider).effectiveLocale,
      supportedLocales: LocaleNotifier.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate, GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, GlobalWidgetsLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(), FallbackCupertinoLocalizationsDelegate(),
      ],
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
    ))),
  ));
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [const Size(320, 640), const Size(390, 844), const Size(1200, 900)]) {
    for (final language in ['rw', 'en', 'fr']) {
      testWidgets('six ordered cards and profile at $size in $language', (tester) async {
        await _pump(tester, size: size, language: language);
        final grid = tester.widget<GridView>(find.byType(GridView));
        expect((grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount, 2);
        expect(find.text('Test Driver'), findsOneWidget);
        expect(find.text('0788123456'), findsOneWidget);
        final ids = ['practice', 'whatsapp', 'gazette', 'irembo', 'progress', 'share'];
        final positions = ids.map((id) => tester.getTopLeft(find.byKey(ValueKey('shortcut-$id')))).toList();
        for (var row = 0; row < 3; row++) {
          expect(positions[row * 2].dy, positions[row * 2 + 1].dy);
          expect(positions[row * 2].dx, lessThan(positions[row * 2 + 1].dx));
          if (row > 0) expect(positions[row * 2].dy, greaterThan(positions[row * 2 - 2].dy));
        }
        expect(tester.getSize(find.byType(GridView)).width, lessThanOrEqualTo(720));
        final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
        for (final text in [l10n.dashboardGazetteSubtitle, l10n.dashboardIremboSubtitle,
          l10n.homeProgressSubtitle, l10n.homeShareAppSubtitle]) {
          expect(find.text(text), findsOneWidget);
        }
        final help = find.byKey(const ValueKey('dashboard-help'));
        expect(tester.getTopLeft(help).dy,
          greaterThan(tester.getBottomLeft(find.byKey(const ValueKey('shortcut-progress'))).dy));
        expect(find.text(l10n.subscriptionNeedHelp), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('large text has no overflow on a narrow screen', (tester) async {
    await _pump(tester, size: const Size(320, 640), language: 'fr', scale: 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('active access rounds a partial day up and translates the tier', (tester) async {
    await _pump(tester, language: 'en', sub: SubscriptionState(hasLoaded: true,
      hasActiveAccess: true, expiresAt: DateTime.now().add(const Duration(hours: 2)), paymentTier: '1_MONTH'));
    expect(find.text('1 days'), findsOneWidget);
    expect(find.text('Duration: 1 Month'), findsOneWidget);
  });

  testWidgets('expired access is not rendered as active', (tester) async {
    await _pump(tester, language: 'en', sub: SubscriptionState(hasLoaded: true,
      hasActiveAccess: true, expiresAt: DateTime.now().subtract(const Duration(seconds: 1))));
    expect(find.text('Your learning access has expired'), findsOneWidget);
  });

  testWidgets('missing subscription and unavailable status are different', (tester) async {
    await _pump(tester, language: 'en', sub: const SubscriptionState(hasError: true));
    expect(find.textContaining('Subscription unavailable.'), findsOneWidget);
    expect(find.text('No active plan'), findsNothing);
  });

  for (final id in ['gazette', 'irembo']) {
    testWidgets('$id opens the localized coming-soon page', (tester) async {
      await _pump(tester, language: 'fr');
      final card = find.byKey(ValueKey('shortcut-$id'));
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.text('Bientôt disponible'), findsOneWidget);
      expect(find.text('Cette fonctionnalité est en cours de développement.'), findsOneWidget);
    });
  }

  testWidgets('practice preserves the existing route', (tester) async {
    await _pump(tester);
    final card = find.byKey(const ValueKey('shortcut-practice'));
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.text('route-practice'), findsOneWidget);
  });

  testWidgets('notifications display real unread data', (tester) async {
    await _pump(tester, language: 'en', notices: const DashboardNotices([
      DashboardNotice(title: 'Test notice', body: 'Details', unread: true),
    ]));
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.text('NOTICES'));
    await tester.pumpAndSettle();
    final notifications = find.text('Notifications');
    await tester.ensureVisible(notifications);
    await tester.tap(notifications);
    await tester.pumpAndSettle();
    expect(find.text('Test notice'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
  });
  testWidgets('dashboard support opens the existing phone and WhatsApp destinations', (tester) async {
    final urls = <String>[];
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'launch') {
        urls.add((call.arguments as Map)['url'] as String);
        return true;
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));
    await _pump(tester, language: 'en');
    final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
    for (final label in [l10n.paymentCallNumber, l10n.paymentCallTigoNumber, l10n.paymentWhatsApp]) {
      final target = find.text(label);
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }
    expect(urls.take(2), ['tel:0788659575', 'tel:0728877442']);
    final whatsapp = Uri.parse(urls.last);
    expect(whatsapp.host, 'wa.me');
    expect(whatsapp.path, '/250788659575');
    expect(whatsapp.queryParameters['text'], l10n.paymentWhatsAppMessage);
  });

  testWidgets('refresh arrows recheck shared access without navigating away', (tester) async {
    await _pump(tester, language: 'en', refreshed: SubscriptionState(
      hasLoaded: true, hasActiveAccess: true,
      expiresAt: DateTime.now().add(const Duration(days: 30)), paymentTier: '1_MONTH'));
    final container = ProviderScope.containerOf(tester.element(find.byType(HomePage)));
    expect(container.read(subscriptionProvider).hasActiveAccess, isFalse);
    final refresh = find.byTooltip('Refresh app access');
    expect(refresh, findsNWidgets(2));
    await tester.tap(refresh.first);
    await tester.pumpAndSettle();
    expect(container.read(subscriptionProvider).hasActiveAccess, isTrue);
    expect(find.text('Duration: 1 Month'), findsOneWidget);
    expect(find.text('Access status refreshed.'), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('failed refresh reports failure and retains known access', (tester) async {
    await _pump(tester, language: 'en',
      sub: const SubscriptionState(hasLoaded: true, hasActiveAccess: true),
      refreshed: const SubscriptionState(hasLoaded: true, hasActiveAccess: true, hasError: true));
    await tester.tap(find.byTooltip('Refresh app access').last);
    await tester.pumpAndSettle();
    expect(find.text('Could not refresh access. Check your internet connection and try again.'), findsOneWidget);
    final container = ProviderScope.containerOf(tester.element(find.byType(HomePage)));
    expect(container.read(subscriptionProvider).hasActiveAccess, isTrue);
  });

  for (final language in ['rw', 'fr', 'en']) {
    testWidgets('instructions page is localized and readable in $language', (tester) async {
      await _pump(tester, language: language, size: const Size(320, 740), scale: 1.6);
      final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
      await tester.tap(find.text(l10n.dashboardNotices));
      await tester.pumpAndSettle();
      expect(find.text(l10n.guideWelcome), findsOneWidget);
      for (final title in [l10n.guideAboutTitle, l10n.guideUseTitle, l10n.guideExamTitle,
        l10n.guidePaymentTitle, l10n.guideOpenAccess]) {
        final target = find.text(title);
        await tester.ensureVisible(target);
        expect(target, findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(l10n.guideOpenAccess));
      await tester.pumpAndSettle();
      expect(find.text('route-subscription'), findsOneWidget);
    });
  }

}
