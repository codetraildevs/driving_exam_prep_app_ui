import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/home/presentation/pages/main_layout.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:traffic_rule_in_rwanda/features/resources/domain/study_document.dart';
import 'package:traffic_rule_in_rwanda/features/resources/presentation/pages/resources_page.dart';
import 'package:traffic_rule_in_rwanda/features/resources/presentation/pages/document_reader_page.dart';
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
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
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

  for (final document in StudyDocument.values) {
    test(
      'bundled ${document.name} opens, renders first page and opens viewer',
      () async {
        final bytes = await rootBundle.load(document.assetPath);
        expect(bytes.lengthInBytes, greaterThan(0));
        final pdf = await PdfDocument.openData(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
          sourceName: document.assetPath,
        );
        try {
          expect(
            pdf.pages.length,
            document == StudyDocument.gazette ? 235 : 18,
          );
          expect(
            await pdf.pages.first.waitForLoaded(
              timeout: const Duration(seconds: 30),
            ),
            isNotNull,
          );
        } finally {
          await pdf.dispose();
        }
      },
    );
  }

  for (final language in ['rw', 'en', 'fr']) {
    testWidgets('resource list is localized in $language with large text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(
          language,
          const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.8)),
            child: ResourcesPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(ResourcesPage)),
      );
      expect(find.text(l10n.resourcesTitle), findsOneWidget);
      expect(find.text(l10n.resourcesGazette), findsOneWidget);
      expect(find.text(l10n.resourcesRoadSigns), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('document opens inside app with page navigation and back', (
    tester,
  ) async {
    await tester.pumpWidget(app('en', const ResourcesPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('resource-roadSigns')));
    await waitForPage(tester, 'Page 1 of 18');
    expect(find.byType(DocumentReaderPage), findsOneWidget);
    expect(find.byType(PdfViewer), findsOneWidget);
    await tester.tap(find.byTooltip('Next page'));
    await waitForPage(tester, 'Page 2 of 18');
    await tester.tap(find.byTooltip('Previous page'));
    await waitForPage(tester, 'Page 1 of 18');
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(ResourcesPage), findsOneWidget);
    expect(find.byType(DocumentReaderPage), findsNothing);
  });

  testWidgets(
    'road signs reader supports header and system back inside shell',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final bloc = AuthBloc();
      final navigatorKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          ShellRoute(
            navigatorKey: navigatorKey,
            builder: (_, __, child) =>
                MainLayout(navigatorKey: navigatorKey, child: child),
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const SizedBox()),
            ],
          ),
        ],
      );
      addTearDown(bloc.close);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const ResourcesPage()),
      );
      await tester.pumpAndSettle();
      for (final systemBack in [false, true]) {
        await tester.tap(find.byKey(const ValueKey('resource-roadSigns')));
        await waitForPage(tester, 'Page 1 of 18');
        if (systemBack) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(find.byIcon(Icons.arrow_back));
        }
        await tester.pumpAndSettle();
        expect(find.byType(ResourcesPage), findsOneWidget);
        expect(find.byType(DocumentReaderPage), findsNothing);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
