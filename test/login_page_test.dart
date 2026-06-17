import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/pages/login_page.dart';
import 'package:traffic_rule_in_rwanda/l10n/generated/app_localizations.dart';
import 'package:traffic_rule_in_rwanda/shared/locale/locale_notifier.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Helper: builds a MaterialApp.router with BlocProvider + locale setup.
Widget _buildTestApp({
  required Widget child,
  GoRouter? router,
  LocaleState localeState = const LocaleState(),
}) {
  final effectiveRouter = router ??
      GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(path: '/login', builder: (_, __) => child),
          GoRoute(path: '/register', builder: (_, __) => const Scaffold(body: Text('RegisterPage'))),
          GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('HomePage'))),
          GoRoute(path: '/admin', builder: (_, __) => const Scaffold(body: Text('AdminPage'))),
        ],
      );

  return ProviderScope(
    overrides: [
      localeProvider.overrideWith(() => LocaleNotifier()),
    ],
    child: MaterialApp.router(
      routerConfig: effectiveRouter,
      locale: localeState.effectiveLocale,
      supportedLocales: LocaleNotifier.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback:
          (deviceLocale, supported) =>
              _resolveLocale(localeState, deviceLocale, supported),
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
  group('LoginPage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    // ──────────────────────────────────────────────────────────────────────
    // 1. Renders the login form correctly
    // ──────────────────────────────────────────────────────────────────────
    testWidgets('renders the login form with all key elements',
        (tester) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await tester.pumpWidget(
        _buildTestApp(
          child: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const LoginPage(),
          ),
        ),
      );
      await _pumpFrames(tester);

      // Header
      expect(find.text('Rwanda Traffic Rule'), findsOneWidget);
      expect(
        find.text('Prepare for Your Provisional Driving Licence'),
        findsOneWidget,
      );

      // Form title & subtitle
      expect(find.text('Login to Your Account'), findsOneWidget);
      expect(
        find.text('Enter your registered phone number to continue.'),
        findsOneWidget,
      );

      // Phone input field
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('07** *** ***'), findsOneWidget);

      // Continue button
      expect(find.text('Continue'), findsOneWidget);

      // Sign up link
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);

      // Secure tag
      expect(find.text('Secure • Fast • Pass'), findsOneWidget);

      // Support numbers
      expect(find.textContaining('+250788659575'), findsOneWidget);
      expect(find.textContaining('+250728877442'), findsOneWidget);
    });

    // ──────────────────────────────────────────────────────────────────────
    // 2. Shows validation error when phone is empty
    // ──────────────────────────────────────────────────────────────────────
    testWidgets('shows error when Continue is tapped with empty phone',
        (tester) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await tester.pumpWidget(
        _buildTestApp(
          child: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const LoginPage(),
          ),
        ),
      );
      await _pumpFrames(tester);

      // Tap Continue without entering a phone number
      await tester.tap(find.text('Continue'));
      await _pumpFrames(tester);

      // Snackbar with validation error should appear
      expect(find.text('Please enter your phone number'), findsOneWidget);
    });

    // ──────────────────────────────────────────────────────────────────────
    // 3. Shows validation error when phone is invalid
    // ──────────────────────────────────────────────────────────────────────
    testWidgets('shows error when phone number format is invalid',
        (tester) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await tester.pumpWidget(
        _buildTestApp(
          child: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const LoginPage(),
          ),
        ),
      );
      await _pumpFrames(tester);

      // Enter an invalid phone number (too short)
      await tester.enterText(find.byType(TextField), '123');
      await _pumpFrames(tester);

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await _pumpFrames(tester);

      // Snackbar with invalid phone error
      expect(
        find.text('Enter a valid phone number (e.g. 078... or +250 78...)'),
        findsOneWidget,
      );
    });

    // ──────────────────────────────────────────────────────────────────────
    // 4. Shows loading spinner when AuthState is AuthLoading
    // ──────────────────────────────────────────────────────────────────────
    testWidgets('shows loading indicator while sign-in is in progress',
        (tester) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await tester.pumpWidget(
        _buildTestApp(
          child: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const LoginPage(),
          ),
        ),
      );
      await _pumpFrames(tester);

      // Enter a valid Rwandan phone number
      await tester.enterText(find.byType(TextField), '0788123456');
      await _pumpFrames(tester);

      // Emit loading state to simulate sign-in in progress
      bloc.emit(const AuthLoading());
      await _pumpFrames(tester);

      // The button should show a CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // The Continue text should not be visible while loading
      expect(find.text('Continue'), findsNothing);
    });

    // ──────────────────────────────────────────────────────────────────────
    // 5. Input accepts valid phone characters
    // ──────────────────────────────────────────────────────────────────────
    testWidgets('phone input accepts digits, +, spaces, and dashes',
        (tester) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await tester.pumpWidget(
        _buildTestApp(
          child: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const LoginPage(),
          ),
        ),
      );
      await _pumpFrames(tester);

      final textField = tester.widget<TextField>(find.byType(TextField));
      final inputFormatters = textField.inputFormatters;
      expect(inputFormatters, isNotNull);
      expect(inputFormatters!.length, 1);

      // The input should allow numeric + symbols
      await tester.enterText(find.byType(TextField), '+250 788 123 456');
      await _pumpFrames(tester);
      expect(find.text('+250 788 123 456'), findsOneWidget);
    });
  });
}
