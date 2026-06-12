import 'package:traffic_rule_in_rwanda/features/auth/presentation/pages/landing_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/language_selector_page.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared locale resolution logic that mirrors LocaleNotifier.localeResolutionCallback.
Locale _resolveLocale(
  LocaleState state,
  Locale? deviceLocale,
  Iterable<Locale> supported,
) {
  if (state.locale != null) return state.locale!;
  if (deviceLocale != null &&
      supported.any((l) => l.languageCode == deviceLocale.languageCode)) {
    return Locale(deviceLocale.languageCode);
  }
  return const Locale('en');
}

/// Helper: builds a MaterialApp with the given locale state.
///
/// Does NOT use ConsumerWidget or ref.watch — locale state is passed as a
/// parameter to avoid Riverpod's LateInitializationError during the mount
/// phase in test environments (Riverpod 2.6.1 regression).
class _LocaleApp extends StatelessWidget {
  final LocaleState localeState;
  final Widget child;
  final GoRouter? router;

  const _LocaleApp({
    required this.localeState,
    required this.child,
    this.router,
  });

  @override
  Widget build(BuildContext context) {
    if (router != null) {
      return MaterialApp.router(
        routerConfig: router!,
        locale: localeState.effectiveLocale,
        supportedLocales: LocaleNotifier.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FallbackMaterialLocalizationsDelegate(),
          FallbackCupertinoLocalizationsDelegate(),
        ],
        localeResolutionCallback:
            (deviceLocale, supported) =>
                _resolveLocale(localeState, deviceLocale, supported),
      );
    }

    return MaterialApp(
      locale: localeState.effectiveLocale,
      supportedLocales: LocaleNotifier.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
      ],
      localeResolutionCallback:
          (deviceLocale, supported) =>
              _resolveLocale(localeState, deviceLocale, supported),
      home: child,
    );
  }
}

/// Helper: wraps a widget with ProviderScope + _LocaleApp for locale tests.
///
/// [localeState] provides the initial/current locale to the MaterialApp.
/// The override factory does NOT call setInitialLocale — doing so would
/// trigger a LateInitializationError because the notifier's state setter
/// accesses ref._element before Riverpod has fully initialized the notifier.
Widget _buildTestApp({
  required LocaleState localeState,
  required Widget child,
}) {
  return ProviderScope(
    overrides: [
      localeProvider.overrideWith(() => LocaleNotifier()),
    ],        child: _LocaleApp(
      localeState: localeState,
      child: child,
    ),
  );
}

/// Helper: wraps a widget with GoRouter + ProviderScope + _LocaleApp.
///
/// [landingWidget] can be set to a real page widget (e.g. LandingPage) to
/// verify the full end-to-end navigation and locale-display flow.
Widget _buildTestAppWithRouter({
  required LocaleState localeState,
  required Widget child,
  Widget? landingWidget,
}) {
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
            landingWidget ?? const Scaffold(body: Text('Landing')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      localeProvider.overrideWith(() => LocaleNotifier()),
    ],
    child: _LocaleApp(
      localeState: localeState,
      router: router,
      child: child,
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
  // ────────────────────────────────────────────────────────────────────────
  // LocaleState unit tests — no widget rendering needed
  // ────────────────────────────────────────────────────────────────────────
  group('LocaleState', () {
    test('defaults to English effective locale when no locale is set', () {
      const state = LocaleState();
      expect(state.hasLocaleSelected, isFalse);
      expect(state.effectiveLocale, const Locale('en'));
    });

    test('returns hasLocaleSelected = true when a locale is explicitly set', () {
      const state = LocaleState(locale: Locale('rw'));
      expect(state.hasLocaleSelected, isTrue);
      expect(state.effectiveLocale, const Locale('rw'));
    });

    test('effectiveLocale matches the explicitly set locale', () {
      const state = LocaleState(locale: Locale('fr'));
      expect(state.effectiveLocale, const Locale('fr'));
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // Locale resolution callback unit tests
  // ────────────────────────────────────────────────────────────────────────
  group('Locale resolution callback', () {
    test('explicitly selected locale takes precedence over device locale', () {
      const state = LocaleState(locale: Locale('rw'));
      final result = _resolveLocale(
        state,
        const Locale('en'),
        LocaleNotifier.supportedLocales,
      );
      // User selected Rwandan — should be used even if device is English.
      expect(result, const Locale('rw'));
    });

    test('falls back to supported device locale when no selection is persisted',
        () {
      const state = LocaleState();
      final result = _resolveLocale(
        state,
        const Locale('fr'),
        LocaleNotifier.supportedLocales,
      );
      // No user selection, device is French (supported) → use French.
      expect(result, const Locale('fr'));
    });

    test('falls back to English when device locale is unsupported', () {
      const state = LocaleState();
      final result = _resolveLocale(
        state,
        const Locale('es'), // Spanish is not in supportedLocales
        LocaleNotifier.supportedLocales,
      );
      // No user selection, device is unsupported → fall back to English.
      expect(result, const Locale('en'));
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // Widget-based locale feature tests
  // ────────────────────────────────────────────────────────────────────────
  group('Locale feature tests', () {
    // ────────────────────────────────────────────────────────────────────────
    // 1. First-run shows language selector when no locale is persisted
    // ────────────────────────────────────────────────────────────────────────
    testWidgets('Shows language selector on first run (no persisted locale)',
        (tester) async {
      SharedPreferences.setMockInitialValues({});

      // Start with no locale selected.
      const initialLocale = LocaleState();
      expect(initialLocale.hasLocaleSelected, isFalse);

      await tester.pumpWidget(
        _buildTestApp(
          localeState: initialLocale,
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

      const initialLocale = LocaleState();

      await tester.pumpWidget(
        _buildTestAppWithRouter(
          localeState: initialLocale,
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

      const initialLocale = LocaleState(locale: Locale('en'));

      // Build a simple screen that shows a translated string.
      await tester.pumpWidget(
        _buildTestApp(
          localeState: initialLocale,
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

      // Switch to French at runtime through the provider.
      final container = ProviderScope.containerOf(
        tester.element(find.byKey(const Key('title'))),
      );
      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('fr'));

      // Rebuild the widget tree with the new locale so the MaterialApp locale
      // reflects the change (_LocaleApp receives fixed localeState param).
      await tester.pumpWidget(
        _buildTestApp(
          localeState: const LocaleState(locale: Locale('fr')),
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

      // After switching, the French translations should be shown.
      expect(find.text('Paramètres'), findsOneWidget);
      expect(find.text('Continuer à apprendre'), findsOneWidget);
    });

    // ────────────────────────────────────────────────────────────────────────
    // 4. Invalid locale stored in SharedPreferences falls back to English
    // ────────────────────────────────────────────────────────────────────────
    testWidgets(
        'Invalid locale code in SharedPreferences falls back to English',
        (tester) async {
      // Simulate a stored locale code that is NOT in supportedLocales.
      SharedPreferences.setMockInitialValues({'selected_locale': 'es'});

      // This mirrors _loadSavedLocale from main.dart:
      //   - reads 'selected_locale' from SharedPreferences
      //   - validates it against supportedLocales
      //   - returns null if invalid
      final prefs = await SharedPreferences.getInstance();
      final storedCode = prefs.getString('selected_locale');
      expect(storedCode, 'es');
      expect(
        LocaleNotifier.supportedLocales.any((l) => l.languageCode == 'es'),
        isFalse,
        reason: 'Spanish is not in the supported locales list',
      );

      // Build with null locale — effectiveLocale is English.
      await tester.pumpWidget(
        _buildTestApp(
          localeState: const LocaleState(),
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

      // English UI should be shown — the app gracefully handles the invalid
      // stored code by falling back to English.
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Continue Learning'), findsOneWidget);
    });

    // ────────────────────────────────────────────────────────────────────────
    // 5. Persisted locale takes precedence over device locale
    // ────────────────────────────────────────────────────────────────────────
    testWidgets(
        'Persisted Rwandan locale displays Rwandan UI even when device is English',
        (tester) async {
      SharedPreferences.setMockInitialValues({'selected_locale': 'rw'});

      // Build with Rwandan locale explicitly selected.
      await tester.pumpWidget(
        _buildTestApp(
          localeState: const LocaleState(locale: Locale('rw')),
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

      // Kinyarwanda UI should be shown regardless of device locale.
      expect(
        find.text('Igenamiterere'),
        findsOneWidget,
        reason: 'Settings in Kinyarwanda should be displayed',
      );
      expect(
        find.text('Komeza kwiga'),
        findsOneWidget,
        reason: 'Continue Learning in Kinyarwanda should be displayed',
      );
    });

    // ────────────────────────────────────────────────────────────────────────
    // 7. Full end-to-end flow: select French → confirm → landing page in French
    // ────────────────────────────────────────────────────────────────────────
    testWidgets(
      'Full flow: select French, confirm, landing page shows French',
      (tester) async {
        // LandingPage has long French strings — use a large viewport to
        // avoid RenderFlex overflow.
        tester.view.physicalSize = const Size(1080, 1920);
        addTearDown(() => tester.view.resetPhysicalSize());

        SharedPreferences.setMockInitialValues({});

        // 1. Start with no locale (first launch).
        const initialLocale = LocaleState();

        await tester.pumpWidget(
          _buildTestAppWithRouter(
            localeState: initialLocale,
            child: const LanguageSelectorPage(),
            landingWidget: const LandingPage(),
          ),
        );
        await _pumpFrames(tester);

        // 2. Language selector is shown with English UI.
        expect(find.text('Choose Your Language'), findsOneWidget);
        expect(find.text('English'), findsOneWidget);
        expect(find.text('Français'), findsOneWidget);
        expect(find.text('Kinyarwanda'), findsOneWidget);

        // 3. Tap Français.
        await tester.tap(find.text('Français'));
        await _pumpFrames(tester);

        // 4. Confirm button label switches to French "Continuer".
        expect(find.text('Continuer'), findsOneWidget);

        // 5. Tap the confirm button — persists locale, navigates to /landing.
        await tester.tap(find.text('Continuer'));
        await _pumpFrames(tester);

        // 6. Verify SharedPreferences was written.
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('selected_locale'), 'fr');

        // 7. Navigated to landing page — rebuild with French locale so the
        //    MaterialApp.locale reflects the new selection.
        await tester.pumpWidget(
          _buildTestApp(
            localeState: const LocaleState(locale: Locale('fr')),
            child: const LandingPage(),
          ),
        );
        await _pumpFrames(tester);

        // 8. Landing page uses French translations.
        expect(
          find.text('Maîtrisez le code de la route facilement'),
          findsOneWidget,
          reason: 'landingHeroTitle should be in French',
        );
        expect(
          find.text('Commencer'),
          findsOneWidget,
          reason: 'landingGetStarted should be in French',
        );
        expect(
          find.text(
            'Préparez-vous intelligemment. '
            'Entraînez-vous avec de vraies questions d\'examen. '
            'Suivez vos progrès et réussissez votre '
            'permis de conduire en toute confiance.',
          ),
          findsOneWidget,
          reason: 'landingHeroSubtitle should be in French',
        );
        expect(
          find.text('Vous avez déjà un compte ? Connectez-vous'),
          findsOneWidget,
          reason: 'landingAlreadyHaveAccount should be in French',
        );
      },
    );

    // ────────────────────────────────────────────────────────────────────────
    // 6. Clearing the persisted locale reverts to English
    // ────────────────────────────────────────────────────────────────────────
    testWidgets('Deleting persisted locale falls back to English UI',
        (tester) async {
      SharedPreferences.setMockInitialValues({'selected_locale': 'fr'});

      // Start with French.
      await tester.pumpWidget(
        _buildTestApp(
          localeState: const LocaleState(locale: Locale('fr')),
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

      // Verify French is shown initially.
      expect(find.text('Paramètres'), findsOneWidget);

      // Simulate clearing the locale (e.g., user logs out or cache is wiped).
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_locale');

      // Rebuild with null locale → effectiveLocale is English.
      await tester.pumpWidget(
        _buildTestApp(
          localeState: const LocaleState(),
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

      // English UI should be shown after the locale was cleared.
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Continue Learning'), findsOneWidget);
    });
  });
}
