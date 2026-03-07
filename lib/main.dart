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
import 'shared/session/app_launch_session.dart';
import 'shared/session/auth_session.dart';
import 'shared/subscription/subscription_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isFirstLaunch = await AppLaunchSession().consumeFirstLaunch();
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  // Check cached session to determine the initial route without waiting for
  // a network round-trip — prevents the login-page flash for returning users.
  final cachedUser = await AuthSession().getUser();

  final authBloc = AuthBloc()..add(const CheckAuthStatusEvent());

  runApp(TrafficRulesApp(
    authBloc: authBloc,
    isFirstLaunch: isFirstLaunch,
    localeProvider: localeProvider,
    cachedUserRole: cachedUser?.role,
  ));
}

class TrafficRulesApp extends StatefulWidget {
  final AuthBloc authBloc;
  final bool isFirstLaunch;
  final LocaleProvider localeProvider;
  /// Role from the locally-cached user — used to set the correct initial route.
  final String? cachedUserRole;

  const TrafficRulesApp({
    required this.authBloc,
    required this.isFirstLaunch,
    required this.localeProvider,
    this.cachedUserRole,
    Key? key,
  }) : super(key: key);

  @override
  State<TrafficRulesApp> createState() => _TrafficRulesAppState();
}

class _TrafficRulesAppState extends State<TrafficRulesApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(
      authBloc: widget.authBloc,
      isFirstLaunch: widget.isFirstLaunch,
      hasLocaleSelected: widget.localeProvider.hasLocaleSelected,
      cachedUserRole: widget.cachedUserRole,
    );
  }

  @override
  void dispose() {
    widget.authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.localeProvider),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: BlocProvider.value(
        value: widget.authBloc,
        child: Consumer<LocaleProvider>(
          builder: (context, localeProvider, _) {
            return MaterialApp.router(
              title: 'Traffic Rules Learning App',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,
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
