import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/pages/register_page.dart';
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
        initialLocation: '/register',
        routes: [
          GoRoute(path: '/register', builder: (_, __) => child),
          GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('LoginPage'))),
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
  group('RegisterPage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    // ──────────────────────────────────────────────────────────────────────
    // 1. Renders the registration form correctly
    // ──────────────────────────────────────────────────────────────────────
    testWidgets('renders the registration form with all key elements',
        (tester) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await tester.pumpWidget(
        _buildTestApp(
          child: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const RegisterPage(),
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
      expect(find.text('Create Your Account'), findsOneWidget);
      expect(
        find.text(
          'Register using your full name and phone number to begin learning.',
        ),
        findsOneWidget,
      );

      // Input fields
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Enter your full name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('07** *** ***'), findsOneWidget);

      // Sign Up button
      expect(find.text('Sign Up'), findsOneWidget);

      // Login link
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);

      // Secure tag
      expect(find.text('Secure • Fast • Pass'), findsOneWidget);
    });

    // ──────────────────────────────────────────────────────────────────────
    // 2. Shows validation error when both fields are empty
    // ──────────────────────────────────────────────────────────────────────
    testWidgets('shows error when Sign Up is tapped with empty fields',
        (tester) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await tester.pumpWidget(
        _buildTestApp(
          child: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const RegisterPage(),
          ),
        ),
      );
      await _pumpFrames(tester);

      // Tap Sign Up without entering anything
      await tester.tap(find.text('Sign Up'));
      await _pumpFrames(tester);

      // Snackbar with validation error
      expect(find.text('Please fill all fields'), findsOneWidget);
    });

    // ──────────────────────────────────────────────────────────────────────
    // 3. Name field blocks digits via input formatter
    // ──────────────────────────────────────────────────────────────────────
    testWidgets('name field strips digits from input',
        (tester) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await tester.pumpWidget(
        _buildTestApp(
          child: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const RegisterPage(),
          ),
        ),
      );
      await _pumpFrames(tester);

      final nameFields = find.byType(TextField);
      expect(nameFields, findsNWidgets(2));

      await tester.enterText(nameFields.at(0), 'John123');
      await _pumpFrames(tester);

      expect(find.text('John'), findsOneWidget);
      expect(find.text('John123'), findsNothing);
    });

    // ──────────────────────────────────────────────────────────────────────
    // 4. Shows validation error when phone is invalid
    // ──────────────────────────────────────────────────────────────────────
    testWidgets('shows error when phone number format is invalid',
        (tester) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await tester.pumpWidget(
        _buildTestApp(
          child: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const RegisterPage(),
          ),
        ),
      );
      await _pumpFrames(tester);

      // Enter valid name but invalid phone
      final nameFields = find.byType(TextField);
      await tester.enterText(nameFields.at(0), 'John Doe');
      await tester.enterText(nameFields.at(1), '123');
      await _pumpFrames(tester);

      // Tap Sign Up
      await tester.tap(find.text('Sign Up'));
      await _pumpFrames(tester);

      // Snackbar with invalid phone error
      expect(
        find.text('Enter a valid phone number (e.g. 078... or +250 78...)'),
        findsOneWidget,
      );
    });

    // ──────────────────────────────────────────────────────────────────────
    // 5. Shows loading spinner when AuthState is AuthLoading
    // ──────────────────────────────────────────────────────────────────────
    testWidgets('shows loading indicator while sign-up is in progress',
        (tester) async {
      final bloc = AuthBloc();
      addTearDown(() => bloc.close());

      await tester.pumpWidget(
        _buildTestApp(
          child: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const RegisterPage(),
          ),
        ),
      );
      await _pumpFrames(tester);

      // Emit loading state to simulate sign-up in progress
      bloc.emit(const AuthLoading());
      await _pumpFrames(tester);

      // The button should show a CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // The Sign Up text should not be visible while loading
      expect(find.text('Sign Up'), findsNothing);
    });
  });
}
