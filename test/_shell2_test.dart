import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/home/presentation/pages/main_layout.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:traffic_rule_in_rwanda/features/resources/presentation/pages/resources_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';

Widget app(String language, Widget home) => MaterialApp(
  locale: Locale(language),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    FallbackMaterialLocalizationsDelegate(),
    FallbackCupertinoLocalizationsDelegate(),
  ],
  home: home,
);

Future<void> waitForPage(WidgetTester tester, String text) async {
  for (var i = 0; i < 200; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 100));
    if (find.text(text).evaluate().isNotEmpty) return;
  }
  fail('Reader did not display $text');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await pdfrxInitialize();
  });

  testWidgets('shell second open', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final bloc = AuthBloc();
    final navigatorKey = GlobalKey<NavigatorState>();
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          navigatorKey: navigatorKey,
          builder: (_, __, child) => MainLayout(navigatorKey: navigatorKey, child: child),
          routes: [GoRoute(path: '/home', builder: (_, __) => const SizedBox())],
        ),
      ],
    );
    addTearDown(bloc.close);
    addTearDown(router.dispose);
    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await tester.pumpAndSettle();
    navigatorKey.currentState!.push(MaterialPageRoute<void>(builder: (_) => const ResourcesPage()));
    await tester.pumpAndSettle();

    // First open + back via arrow
    await tester.tap(find.byKey(const ValueKey('resource-roadSigns')));
    await waitForPage(tester, 'Page 1 of 18');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(ResourcesPage), findsOneWidget);

    // Second open + back via system back
    await tester.tap(find.byKey(const ValueKey('resource-roadSigns')));
    await waitForPage(tester, 'Page 1 of 18');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ResourcesPage), findsOneWidget);
  });
}
