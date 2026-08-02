import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/fallback_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:traffic_rule_in_rwanda/shared/widgets/data_consent_dialog.dart';

/// Host app that exposes a button wired to [DataConsentDialog.showIfNeeded],
/// so the dialog can be opened from the test with the same entry point the
/// app uses on first launch.
Widget _buildTestApp() {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: LocaleNotifier.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      FallbackMaterialLocalizationsDelegate(),
      FallbackCupertinoLocalizationsDelegate(),
    ],
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => TextButton(
            key: const Key('open-consent'),
            onPressed: () => DataConsentDialog.showIfNeeded(context),
            child: const Text('Open consent dialog'),
          ),
        ),
      ),
    ),
  );
}

/// Pump enough frames for localization delegates to load and animations to run
/// (same convention as the other widget tests in this repo).
Future<void> _pumpFrames(WidgetTester tester) async {
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Returns `true` if any scrollable in the tree overflows — i.e. its content
/// extends beyond its viewport. On the consent dialog the scrollable body is
/// the one expected to overflow at a short viewport.
bool _hasOverflowingScrollable(WidgetTester tester) {
  for (final element in tester.elementList(find.byType(Scrollable))) {
    final state = (element as StatefulElement).state as ScrollableState;
    if (state.position.maxScrollExtent > 0) return true;
  }
  return false;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DataConsentDialog', () {
    testWidgets(
      'Accept button stays visible without scrolling on a short viewport',
      (tester) async {
        // Simulate a short browser window / small phone (logical pixels).
        tester.view.physicalSize = const Size(400, 500);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_buildTestApp());
        await tester.pump();

        // Open the consent dialog (no consent persisted yet).
        await tester.tap(find.byKey(const Key('open-consent')));
        await _pumpFrames(tester);
        // The dialog's entrance animation runs for 500ms after the route is
        // pushed — settle it fully before asserting geometry.
        await tester.pump(const Duration(milliseconds: 200));

        final dialogFinder = find.byType(Dialog);
        expect(dialogFinder, findsOneWidget);
        final l10n = AppLocalizations.of(tester.element(dialogFinder));

        // The Accept button is fully inside the viewport — no scrolling needed.
        final acceptFinder = find.widgetWithText(
          ElevatedButton,
          l10n.consentAccept,
        );
        expect(acceptFinder, findsOneWidget);
        final acceptRect = tester.getRect(acceptFinder);
        final screenRect =
            Offset.zero &
            (tester.view.physicalSize / tester.view.devicePixelRatio);
        expect(acceptRect.top, greaterThanOrEqualTo(screenRect.top));
        expect(acceptRect.bottom, lessThanOrEqualTo(screenRect.bottom));
        expect(acceptRect.left, greaterThanOrEqualTo(screenRect.left));
        expect(acceptRect.right, lessThanOrEqualTo(screenRect.right));

        // Sanity check the test is meaningful: at this viewport the dialog
        // body really overflows, so content requires scrolling — yet the
        // pinned Accept button is still on screen.
        expect(
          _hasOverflowingScrollable(tester),
          isTrue,
          reason: 'The dialog body should overflow at a 400x500 viewport so '
              'the pinned-footer behavior is actually exercised.',
        );

        // Tap it: proves the button is hit-testable without scrolling, and
        // confirms the acceptance flow persists consent and closes the dialog.
        await tester.tap(acceptFinder);
        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsNothing);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('data_consent_accepted'), isTrue);
      },
    );

    testWidgets('does not show the dialog when consent was already accepted',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'data_consent_accepted': true,
      });

      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      await tester.tap(find.byKey(const Key('open-consent')));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });
  });
}
