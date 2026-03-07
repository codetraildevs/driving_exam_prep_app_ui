import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/main_layout.dart';
import '../../shared/locale/language_selector_page.dart';

import '../../features/practice/presentation/pages/practice_page.dart';
import '../../features/practice/presentation/pages/quiz_page.dart';
import '../../features/exam/presentation/pages/exam_intro_page.dart';
import '../../features/exam/presentation/pages/exam_page.dart';
import '../../features/exam/presentation/pages/exam_result_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/my_certificates_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';

class AppRouter {
  final AuthBloc authBloc;
  final bool isFirstLaunch;
  final bool hasLocaleSelected;

  AppRouter({
    required this.authBloc,
    required this.isFirstLaunch,
    required this.hasLocaleSelected,
  });

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: !hasLocaleSelected
        ? '/language-select'
        : isFirstLaunch
            ? '/landing'
            : '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAuthenticated = authState is AuthAuthenticated;
      final location = state.matchedLocation;

      final isAuthPage =
          location == '/landing' ||
          location == '/login' ||
          location == '/register' ||
          location == '/forgot-password' ||
          location == '/language-select';

      final isProtectedPage =
          location.startsWith('/home') ||
          location.startsWith('/practice') ||
          location.startsWith('/exam') ||
          location.startsWith('/progress') ||
          location.startsWith('/profile') ||
          location.startsWith('/settings') ||
          location.startsWith('/certificates') ||
          location.startsWith('/subscription');

      if (isAuthenticated && isAuthPage) {
        return '/home';
      }

      if (!isAuthenticated && isProtectedPage) {
        return '/login';
      }

      if (!isFirstLaunch && !isAuthenticated && location == '/landing') {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/language-select',
        pageBuilder: (context, state) => const MaterialPage(
          child: LanguageSelectorPage(),
        ),
      ),
      GoRoute(
        path: '/landing',
        pageBuilder: (context, state) => const MaterialPage(
          child: LandingPage(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const MaterialPage(
          child: LoginPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => const MaterialPage(
          child: RegisterPage(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => const MaterialPage(
          child: ForgotPasswordPage(),
        ),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const MaterialPage(
              child: HomePage(),
            ),
          ),

          GoRoute(
            path: '/practice',
            name: 'practice',
            pageBuilder: (context, state) => const MaterialPage(
              child: PracticePage(),
            ),
            routes: [
              GoRoute(
                path: 'quiz/:quizId',
                pageBuilder: (context, state) {
                  final quizId = state.pathParameters['quizId']!;
                  return MaterialPage(
                    child: QuizPage(quizId: quizId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/exam',
            name: 'exam',
            pageBuilder: (context, state) => const MaterialPage(
              child: ExamIntroPage(),
            ),
            routes: [
              GoRoute(
                path: 'start',
                pageBuilder: (context, state) => const MaterialPage(
                  child: ExamPage(),
                ),
              ),
              GoRoute(
                path: 'result/:attemptId',
                pageBuilder: (context, state) {
                  final attemptId = state.pathParameters['attemptId']!;
                  return MaterialPage(
                    child: ExamResultPage(attemptId: attemptId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/progress',
            name: 'progress',
            pageBuilder: (context, state) => const MaterialPage(
              child: ProgressPage(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const MaterialPage(
              child: ProfilePage(),
            ),
          ),
          GoRoute(
            path: '/certificates',
            builder: (context, state) => const MyCertificatesPage(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const MaterialPage(
              child: SettingsPage(),
            ),
          ),
          GoRoute(
            path: '/subscription',
            name: 'subscription',
            pageBuilder: (context, state) => const MaterialPage(
              child: SubscriptionPage(),
            ),
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(state.error.toString()),
        ),
      ),
    ),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
