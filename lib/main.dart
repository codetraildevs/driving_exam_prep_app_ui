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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isFirstLaunch = await AppLaunchSession().consumeFirstLaunch();
  final authBloc = AuthBloc()..add(const CheckAuthStatusEvent());
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  runApp(TrafficRulesApp(
    authBloc: authBloc,
    isFirstLaunch: isFirstLaunch,
    localeProvider: localeProvider,
  ));
}

class TrafficRulesApp extends StatefulWidget {
  final AuthBloc authBloc;
  final bool isFirstLaunch;
  final LocaleProvider localeProvider;

  const TrafficRulesApp({
    required this.authBloc,
    required this.isFirstLaunch,
    required this.localeProvider,
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
    );
  }

  @override
  void dispose() {
    widget.authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.localeProvider,
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
