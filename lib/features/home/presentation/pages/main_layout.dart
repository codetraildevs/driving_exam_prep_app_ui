import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

bool _isAdminOrManager(String role) =>
    role == 'ADMIN' || role == 'MANAGER';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({required this.child, Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthBloc>().state;
    final userRole = authState is AuthAuthenticated
        ? authState.user.role
        : 'USER';
    final isAdmin = _isAdminOrManager(userRole);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: isAdmin
          ? _buildAdminNav(context, l10n)
          : _buildUserNav(context, l10n),
    );
  }

  Widget _buildUserNav(BuildContext context, AppLocalizations l10n) {
    return BottomNavigationBar(
      currentIndex: _getUserSelectedIndex(context),
      onTap: (index) => _onUserNavTapped(context, index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: l10n.navHome,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.quiz_outlined),
          activeIcon: const Icon(Icons.quiz),
          label: l10n.navPractice,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.assessment_outlined),
          activeIcon: const Icon(Icons.assessment),
          label: l10n.navProgress,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outlined),
          activeIcon: const Icon(Icons.person),
          label: l10n.navProfile,
        ),
      ],
    );
  }

  Widget _buildAdminNav(BuildContext context, AppLocalizations l10n) {
    return BottomNavigationBar(
      currentIndex: _getAdminSelectedIndex(context),
      onTap: (index) => _onAdminNavTapped(context, index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: l10n.navHome,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_outlined),
          activeIcon: const Icon(Icons.dashboard),
          label: l10n.adminDashboard,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people_outlined),
          activeIcon: const Icon(Icons.people),
          label: l10n.adminUsers,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.key_outlined),
          activeIcon: const Icon(Icons.key),
          label: l10n.adminAccess,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outlined),
          activeIcon: const Icon(Icons.person),
          label: l10n.navProfile,
        ),
      ],
    );
  }

  int _getUserSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/practice')) return 1;
    if (location.startsWith('/progress')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  int _getAdminSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/admin/users')) return 2;
    if (location.startsWith('/admin/access')) return 3;
    if (location.startsWith('/admin')) return 1;
    if (location.startsWith('/profile')) return 4;
    return 0; // /home
  }

  void _onUserNavTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/practice');
        break;
      case 2:
        context.go('/progress');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  void _onAdminNavTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/admin');
        break;
      case 2:
        context.go('/admin/users');
        break;
      case 3:
        context.go('/admin/access');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
