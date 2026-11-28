import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme/app_theme.dart';
import 'config/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/referrals/data/referral_session.dart';
import 'l10n/generated/app_localizations.dart';
import 'shared/locale/fallback_localizations.dart';
import 'shared/locale/locale_notifier.dart';
import 'shared/locale/language_selector_page.dart';
import 'shared/network/sync_service.dart';
import 'shared/observability/crash_reporting.dart';
import 'shared/session/app_launch_session.dart';
import 'shared/session/auth_session.dart';
import 'shared/session/last_route_session.dart';
import 'shared/subscription/subscription_notifier.dart';
import 'shared/theme/theme_notifier.dart';
import 'shared/widgets/data_consent_dialog.dart';
import 'shared/widgets/app_status_bar.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Install the global error handlers and Crashlytics before anything else,
  // so failures during startup are reported too.
  await CrashReporting.instance.initialize();

  try {
    await _runApp();
  } catch (error, stack) {
    // Last resort: booting must never leave the user with a blank window.
    await CrashReporting.instance.record(
      error,
      stack,
      reason: 'startup',
      fatal: true,
    );
    runApp(const _StartupFailureApp());
  }
}

Future<void> _runApp() async {
  // Startup timing hook: reports how the pre-runApp work splits between the
  // persisted-preference reads and building the first frame. Only printed in
  // debug/profile so release builds stay silent.
  final startupWatch = Stopwatch()..start();

  // Prevent google_fonts from downloading fonts at runtime in production.
  // Fonts are bundled via the app's asset pipeline.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Kick off the auth-status check immediately (it never blocks the first
  // frame) so its network round-trip overlaps with the prefs reads below.
  final authBloc = AuthBloc()..add(const CheckAuthStatusEvent());

  // Resolve all persisted preferences in parallel so the app can be attached
  // with the saved language, theme and screen already in place. On low-end
  // devices this round-trip is the largest part of Dart startup.
  final (
    isFirstLaunch,
    initialLocale,
    initialThemeMode,
    cachedUser,
    lastRoute,
    consentAccepted,
  ) = await (
    _startupValue('first launch', AppLaunchSession().consumeFirstLaunch(), false),
    _startupValue('locale', _loadSavedLocale(), null),
    _startupValue('theme', _loadSavedTheme(), ThemeMode.light),
    _startupValue('cached user', AuthSession().getUser(), null),
    _startupValue('last route', LastRouteSession().getSavedRoute(), null),
    _startupValue('consent', DataConsentDialog.hasAccepted(), false),
  ).wait;
  final prefsElapsed = startupWatch.elapsed;

  // Crash reports are only collected while the user's data consent stands.
  unawaited(CrashReporting.instance.setCollectionEnabled(consentAccepted));

  runApp(
    // Riverpod must wrap the entire app to provide the ProviderScope.
    ProviderScope(
      overrides: [
        localeProvider.overrideWith(() {
          final n = LocaleNotifier();
          n.setInitialLocale(initialLocale);
          return n;
        }),
        themeProvider.overrideWith(() {
          final n = ThemeNotifier();
          n.setInitialThemeMode(initialThemeMode);
          return n;
        }),
      ],
      child: TrafficRulesApp(
        authBloc: authBloc,
        isFirstLaunch: isFirstLaunch,
        initialLocale: initialLocale,
        cachedUserRole: cachedUser?.role,
        restoredRoute: lastRoute,
      ),
    ),
  );
  final runAppElapsed = startupWatch.elapsed;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (kReleaseMode) return;
    final firstFrameElapsed = startupWatch.elapsed;
    debugPrint(
      '[startup] prefs=${prefsElapsed.inMilliseconds}ms '
      'runApp=${(runAppElapsed - prefsElapsed).inMilliseconds}ms '
      'runAppToFirstFrame='
      '${(firstFrameElapsed - runAppElapsed).inMilliseconds}ms '
      'total=${firstFrameElapsed.inMilliseconds}ms',
    );
  });
}

/// Awaits a startup read and falls back to [fallback] when it fails, so one
/// broken preference or platform channel cannot abort the launch.
Future<T> _startupValue<T>(String label, Future<T> future, T fallback) async {
  try {
    return await future;
  } catch (error, stack) {
    await CrashReporting.instance.record(
      error,
      stack,
      reason: 'startup: $label',
    );
    return fallback;
  }
}

/// Minimal screen shown when even startup fails, instead of a blank window.
class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'The app could not start correctly.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please close and open the app again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: const Text('Close app'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reads the saved locale from SharedPreferences.
Future<Locale?> _loadSavedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('selected_locale');
  if (code != null &&
      LocaleNotifier.supportedLocales.any((l) => l.languageCode == code)) {
    return Locale(code);
  }
  return null;
}

/// Reads the saved theme mode from SharedPreferences.
Future<ThemeMode> _loadSavedTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('selected_theme_mode');
  if (saved != null) {
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
    }
  }
  // Default to Light when no valid theme preference has been saved.
  return ThemeMode.light;
}

class TrafficRulesApp extends ConsumerStatefulWidget {
  final AuthBloc authBloc;
  final bool isFirstLaunch;

  /// Pre-loaded locale so the router can determine if a locale was selected
  /// without reading from Riverpod during initState.
  final Locale? initialLocale;

  /// Role from the locally-cached user — used to set the correct initial route.
  final String? cachedUserRole;
  final String? restoredRoute;

  const TrafficRulesApp({
    required this.authBloc,
    required this.isFirstLaunch,
    this.initialLocale,
    this.cachedUserRole,
    this.restoredRoute,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<TrafficRulesApp> createState() => _TrafficRulesAppState();
}

class _TrafficRulesAppState extends ConsumerState<TrafficRulesApp> {
  late final AppRouter _appRouter;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    unawaited(ReferralSession.instance.initialize().catchError((Object _) {
      // Onboarding remains available if the platform service is temporarily unavailable.
    }));
    // Use the pre-loaded initialLocale to determine if a locale was selected,
    // avoiding a ref.read() call during initState which would trigger the
    // Riverpod provider's lazy creation before the element tree is fully mounted.
    final hasLocaleSelected = widget.initialLocale != null;
    _appRouter = AppRouter(
      authBloc: widget.authBloc,
      isFirstLaunch: widget.isFirstLaunch,
      hasLocaleSelected: hasLocaleSelected,
      cachedUserRole: widget.cachedUserRole,
      restoredRoute: widget.restoredRoute,
    );

    // Start background connectivity watcher & auto-sync.
    SyncService().start();

    // Show consent dialog after the first frame has been rendered and
    // the navigator/localizations are fully available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showConsentIfNeeded();
    });

    // Listen to auth state changes and refresh subscription status in the
    // background whenever the user signs in. This keeps the app offline-first:
    // cached data is used immediately, and network data updates the UI silently.
    _authSubscription = widget.authBloc.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        // Tie crash reports to the signed-in account for easier triage.
        unawaited(CrashReporting.instance.setUserIdentifier(authState.user.id));
        _refreshSubscriptionInBackground(authState.user.id);
        // Sync the locally selected language to the backend so the admin
        // dashboard and DB stay in sync after login.
        unawaited(syncLanguageToBackend(
          ref.read(localeProvider).effectiveLocale.languageCode,
          userId: authState.user.id,
        ));
        // Sync any pending results queued while offline.
        SyncService().syncPendingResults();
      } else if (authState is AuthUnauthenticated) {
        unawaited(CrashReporting.instance.setUserIdentifier(null));
        ref.read(subscriptionProvider.notifier).clearStatus();
        LastRouteSession().clear();
      }
    });
  }

  Future<void> _showConsentIfNeeded() async {
    // Small delay so the navigator and localizations are fully settled.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final ctx = AppRouter.rootNavigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      await DataConsentDialog.showIfNeeded(ctx);
    }
  }

  void _refreshSubscriptionInBackground(String userId) {
    ref.read(subscriptionProvider.notifier).refreshStatus(userId);
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    SyncService().dispose();
    widget.authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeState = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);

    return BlocProvider.value(
      value: widget.authBloc,
      child: MaterialApp.router(
        title: 'Rwanda Traffic Rule',
        builder: (context, child) => SystemBarInsets(
          child: AppStatusBar(child: child ?? const SizedBox.shrink()),
        ),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: _appRouter.router,
        debugShowCheckedModeBanner: false,
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
        localeResolutionCallback: ref
            .read(localeProvider.notifier)
            .localeResolutionCallback,
      ),
    );
  }
}
