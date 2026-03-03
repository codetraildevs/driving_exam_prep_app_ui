import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/main_layout.dart';
import '../../features/signs/presentation/pages/signs_page.dart';
import '../../features/signs/presentation/pages/sign_detail_page.dart';
import '../../features/practice/presentation/pages/practice_page.dart';
import '../../features/practice/presentation/pages/quiz_page.dart';
import '../../features/exam/presentation/pages/exam_intro_page.dart';
import '../../features/exam/presentation/pages/exam_page.dart';
import '../../features/exam/presentation/pages/exam_result_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter get router => GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/landing',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAuthenticated = authState is AuthAuthenticated;

      if (isAuthenticated && state.matchedLocation == '/landing') {
        return '/home';
      }

      if (!isAuthenticated &&
          (state.matchedLocation.startsWith('/home') ||
              state.matchedLocation.startsWith('/signs') ||
              state.matchedLocation.startsWith('/practice') ||
              state.matchedLocation.startsWith('/exam') ||
              state.matchedLocation.startsWith('/progress') ||
              state.matchedLocation.startsWith('/profile') ||
              state.matchedLocation.startsWith('/settings'))) {
        return '/login';
      }

      return null;
    },
    routes: [
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
            path: '/signs',
            name: 'signs',
            pageBuilder: (context, state) => const MaterialPage(
              child: SignsPage(),
            ),
            routes: [
              GoRoute(
                path: ':signId',
                pageBuilder: (context, state) {
                  final signId = state.pathParameters['signId']!;
                  return MaterialPage(
                    child: SignDetailPage(signId: signId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/practice',
            name: 'practice',
            pageBuilder: (context, state) => const MaterialPage(
              child: PracticePage(),
            ),
            routes: [
              GoRoute(
                path: 'quiz/:categoryId',
                pageBuilder: (context, state) {
                  final categoryId = state.pathParameters['categoryId']!;
                  return MaterialPage(
                    child: QuizPage(categoryId: categoryId),
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
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const MaterialPage(
              child: SettingsPage(),
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
