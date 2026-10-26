import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      'bundled ${document.name} opens and renders first and last pages',
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
          for (final page in [pdf.pages.first, pdf.pages.last]) {
            final image = await page.render(
              width: 80,
              height: 100,
              fullWidth: 80,
              fullHeight: 100,
            );
            expect(image, isNotNull);
            expect(image!.pixels, isNotEmpty);
            image.dispose();
          }
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
}
