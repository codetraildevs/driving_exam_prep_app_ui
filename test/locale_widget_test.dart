import 'package:driveprep_rwanda/l10n/generated/app_localizations.dart';
import 'package:driveprep_rwanda/shared/locale/fallback_localizations.dart';
import 'package:driveprep_rwanda/shared/locale/language_selector_page.dart';
import 'package:driveprep_rwanda/shared/locale/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
/// Helper: wraps a widget with the providers needed for locale tests.
Widget _buildTestApp({
  required LocaleProvider localeProvider,
  required Widget child,
}) {
  return ChangeNotifierProvider.value(
    value: localeProvider,
    child: Consumer<LocaleProvider>(
      builder: (context, lp, _) {
        return MaterialApp(
          locale: lp.effectiveLocale,
          supportedLocales: LocaleProvider.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FallbackMaterialLocalizationsDelegate(),
            FallbackCupertinoLocalizationsDelegate(),
          ],
          localeResolutionCallback: lp.localeResolutionCallback,
          home: child,
        );
      },
    ),
  );
}

/// Helper: wraps a widget with GoRouter so context.go() works in tests.
Widget _buildTestAppWithRouter({
  required LocaleProvider localeProvider,
  required Widget child,
}) {
  return ChangeNotifierProvider.value(
    value: localeProvider,
    child: Consumer<LocaleProvider>(
      builder: (context, lp, _) {
        final router = GoRouter(
          initialLocation: '/language-select',
          routes: [
            GoRoute(
              path: '/language-select',
              builder: (_, __) => child,
            ),
            GoRoute(
              path: '/landing',
              builder: (_, __) =>
                  const Scaffold(body: Text('Landing')),
            ),
          ],
        );
        return MaterialApp.router(
          routerConfig: router,
          locale: lp.effectiveLocale,
          supportedLocales: LocaleProvider.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FallbackMaterialLocalizationsDelegate(),
            FallbackCupertinoLocalizationsDelegate(),
          ],
          localeResolutionCallback: lp.localeResolutionCallback,
        );
      },
    ),
  );
}

/// Pump enough frames for localization delegates to load and animations to run.
Future<void> _pumpFrames(WidgetTester tester) async {
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('Locale feature tests', () {
    // ────────────────────────────────────────────────────────────────────────
    // 1. First-run shows language selector when no locale is persisted
    // ────────────────────────────────────────────────────────────────────────
    testWidgets('Shows language selector on first run (no persisted locale)',
        (tester) async {
      SharedPreferences.setMockInitialValues({});

      final provider = LocaleProvider();
      await provider.loadSavedLocale();

      // No locale has been selected yet.
      expect(provider.hasLocaleSelected, isFalse);

      await tester.pumpWidget(
        _buildTestApp(
          localeProvider: provider,
          child: const LanguageSelectorPage(),
        ),
      );
      await _pumpFrames(tester);

      // The selector screen is shown with the three language options.
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
      expect(find.text('Kinyarwanda'), findsOneWidget);
      expect(find.text('Choose Your Language'), findsOneWidget);
    });

    // ────────────────────────────────────────────────────────────────────────
    // 2. Selecting a language persists the selection in SharedPreferences
    // ────────────────────────────────────────────────────────────────────────
    testWidgets('Selecting a language persists it in SharedPreferences',
        (tester) async {
      SharedPreferences.setMockInitialValues({});

      final provider = LocaleProvider();
      await provider.loadSavedLocale();

      await tester.pumpWidget(
        _buildTestAppWithRouter(
          localeProvider: provider,
          child: const LanguageSelectorPage(),
        ),
      );
      await _pumpFrames(tester);

      // Tap Français, then tap Continuer (the confirm button updates its label).
      await tester.tap(find.text('Français'));
      await _pumpFrames(tester);

      // The confirm button now shows "Continuer" (French label).
      expect(find.text('Continuer'), findsOneWidget);

      // Tap the confirm button — this persists the locale.
      await tester.tap(find.text('Continuer'));
      await _pumpFrames(tester);

      // Verify: the provider picked up the French locale.
      expect(provider.effectiveLocale.languageCode, 'fr');

      // Verify: SharedPreferences was written.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_locale'), 'fr');
    });

    // ────────────────────────────────────────────────────────────────────────
    // 3. Changing language at runtime updates the UI immediately
    // ────────────────────────────────────────────────────────────────────────
    testWidgets('Changing language at runtime updates UI strings immediately',
        (tester) async {
      SharedPreferences.setMockInitialValues({'selected_locale': 'en'});

      final provider = LocaleProvider();
      await provider.loadSavedLocale();
      expect(provider.effectiveLocale.languageCode, 'en');

      // Build a simple screen that shows a translated string.
      await tester.pumpWidget(
        _buildTestApp(
          localeProvider: provider,
          child: Builder(builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.settingsTitle, key: const Key('title')),
                Text(l10n.homeContinueLearning, key: const Key('cta')),
              ],
            );
          }),
        ),
      );
      await _pumpFrames(tester);

      // Initially English.
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Continue Learning'), findsOneWidget);

      // Switch to French at runtime.
      await provider.setLocale(const Locale('fr'));
      await _pumpFrames(tester);

      // After switching, the French translations should be shown.
      expect(find.text('Paramètres'), findsOneWidget);
      expect(find.text('Continuer à apprendre'), findsOneWidget);

      // Provider locale should be French.
      expect(provider.effectiveLocale.languageCode, 'fr');
    });
  });
}
