import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme/app_theme.dart';
import 'config/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'l10n/generated/app_localizations.dart';
import 'shared/locale/fallback_localizations.dart';
import 'shared/locale/locale_notifier.dart';
import 'shared/network/sync_service.dart';
import 'shared/session/app_launch_session.dart';
import 'shared/session/auth_session.dart';
import 'shared/session/last_route_session.dart';
import 'shared/subscription/subscription_notifier.dart';
import 'shared/theme/theme_notifier.dart';
import 'shared/widgets/data_consent_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() => _runApp();

Future<void> _runApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent google_fonts from downloading fonts at runtime in production.
  // Fonts are bundled via the app's asset pipeline.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Kick off the auth-status check immediately (it never blocks the first
  // frame) so its network round-trip overlaps with the prefs reads below.
  final authBloc = AuthBloc()..add(const CheckAuthStatusEvent());

  // Resolve all persisted preferences in parallel so the first frame is
  // painted as quickly as possible. Previously these ran sequentially, which
  // delayed runApp on every launch.
  final (
    isFirstLaunch,
    initialLocale,
    initialThemeMode,
    cachedUser,
    lastRoute,
  ) = await (
    AppLaunchSession().consumeFirstLaunch(),
    _loadSavedLocale(),
    _loadSavedTheme(),
    AuthSession().getUser(),
    LastRouteSession().getSavedRoute(),
  ).wait;

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
  // No explicit user choice yet — follow the OS (light/dark) so first-time
  // visitors on a dark OS get a dark app instead of a bright flash.
  return ThemeMode.system;
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
        _refreshSubscriptionInBackground(authState.user.id);
        // Sync any pending results queued while offline.
        SyncService().syncPendingResults();
      } else if (authState is AuthUnauthenticated) {
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
