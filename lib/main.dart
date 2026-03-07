import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'config/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'l10n/generated/app_localizations.dart';
import 'shared/locale/fallback_localizations.dart';
import 'shared/locale/locale_provider.dart';
import 'shared/network/api_config.dart';
import 'shared/session/app_launch_session.dart';
import 'shared/session/auth_session.dart';
import 'shared/subscription/subscription_provider.dart';
import 'shared/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isFirstLaunch = await AppLaunchSession().consumeFirstLaunch();
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  // Load saved theme before runApp so the first frame is already correct.
  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedTheme();

  // Check cached session to determine the initial route without waiting for
  // a network round-trip — prevents the login-page flash for returning users.
  final cachedUser = await AuthSession().getUser();

  final authBloc = AuthBloc()..add(const CheckAuthStatusEvent());

  runApp(TrafficRulesApp(
    authBloc: authBloc,
    isFirstLaunch: isFirstLaunch,
    localeProvider: localeProvider,
    themeProvider: themeProvider,
    cachedUserRole: cachedUser?.role,
  ));
}

class TrafficRulesApp extends StatefulWidget {
  final AuthBloc authBloc;
  final bool isFirstLaunch;
  final LocaleProvider localeProvider;
  final ThemeProvider themeProvider;
  /// Role from the locally-cached user — used to set the correct initial route.
  final String? cachedUserRole;

  const TrafficRulesApp({
    required this.authBloc,
    required this.isFirstLaunch,
    required this.localeProvider,
    required this.themeProvider,
    this.cachedUserRole,
    Key? key,
  }) : super(key: key);

  @override
  State<TrafficRulesApp> createState() => _TrafficRulesAppState();
}

class _TrafficRulesAppState extends State<TrafficRulesApp> {
  late final AppRouter _appRouter;
  late final SubscriptionProvider _subscriptionProvider;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(
      authBloc: widget.authBloc,
      isFirstLaunch: widget.isFirstLaunch,
      hasLocaleSelected: widget.localeProvider.hasLocaleSelected,
      cachedUserRole: widget.cachedUserRole,
    );
    _subscriptionProvider = SubscriptionProvider();

    // Listen to auth state changes and refresh subscription status in the
    // background whenever the user signs in. This keeps the app offline-first:
    // cached data is used immediately, and network data updates the UI silently.
    _authSubscription = widget.authBloc.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        _refreshSubscriptionInBackground(authState.user.id);
      } else if (authState is AuthUnauthenticated) {
        _subscriptionProvider.clearStatus();
      }
    });
  }

  void _refreshSubscriptionInBackground(String userId) {
    AuthSession().getToken().then((token) {
      if (token != null && token.isNotEmpty) {
        _subscriptionProvider.refreshStatus(
          userId,
          ApiConfig.baseUrl,
          token,
        );
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    widget.authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.localeProvider),
        ChangeNotifierProvider.value(value: widget.themeProvider),
        ChangeNotifierProvider.value(value: _subscriptionProvider),
      ],
      child: BlocProvider.value(
        value: widget.authBloc,
        child: Consumer2<LocaleProvider, ThemeProvider>(
          builder: (context, localeProvider, themeProvider, _) {
            return MaterialApp.router(
              title: 'Traffic Rules Learning App',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              // ThemeMode.system = follow device; user can override via settings.
              themeMode: themeProvider.themeMode,
              routerConfig: _appRouter.router,
              debugShowCheckedModeBanner: false,
              locale: localeProvider.effectiveLocale,
              supportedLocales: LocaleProvider.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                // Fallbacks for locales not in GlobalMaterial/Cupertino (e.g. rw)
                FallbackMaterialLocalizationsDelegate(),
                FallbackCupertinoLocalizationsDelegate(),
              ],
              localeResolutionCallback:
                  localeProvider.localeResolutionCallback,
            );
          },
        ),
      ),
    );
  }
}
