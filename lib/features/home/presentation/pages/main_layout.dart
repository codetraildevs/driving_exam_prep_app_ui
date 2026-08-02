import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import '../../../../shared/widgets/app_drawer_scope.dart';
import '../../../../shared/widgets/app_logo_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

bool _isAdminOrManager(String role) => role == 'ADMIN' || role == 'MANAGER';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({required this.child, Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  /// Owned by the shell so page headers can open the drawer via
  /// [AppDrawerScope] + [AppMenuButton].
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthBloc>().state;
    final userRole = authState is AuthAuthenticated
        ? authState.user.role
        : 'USER';
    final isAdmin = _isAdminOrManager(userRole);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog(context, l10n);
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: AppDrawerScope(
        openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        child: Scaffold(
          key: _scaffoldKey,
          // Desktop gets a slide-out hamburger drawer; mobile keeps the
          // bottom navigation bar.
          drawer: isDesktop(context)
              ? _buildDrawer(context, l10n, isAdmin)
              : null,
          body: widget.child,
          bottomNavigationBar: isDesktop(context)
              ? null
              : isAdmin
              ? _buildAdminNav(context, l10n)
              : _buildUserNav(context, l10n),
        ),
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    AppLocalizations l10n,
    bool isAdmin,
  ) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ── Brand header ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradientFor(theme.brightness),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const AppLogoWidget(size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.appTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textInverse,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Navigation destinations ─────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: isAdmin
                    ? _adminDrawerTiles(context, l10n)
                    : _userDrawerTiles(context, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _userDrawerTiles(BuildContext context, AppLocalizations l10n) {
    return [
      _drawerTile(
        context: context,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: l10n.navHome,
        index: 0,
        isAdmin: false,
      ),
      _drawerTile(
        context: context,
        icon: Icons.quiz_outlined,
        selectedIcon: Icons.quiz,
        label: l10n.navPractice,
        index: 1,
        isAdmin: false,
      ),
      _drawerTile(
        context: context,
        icon: Icons.assessment_outlined,
        selectedIcon: Icons.assessment,
        label: l10n.navProgress,
        index: 2,
        isAdmin: false,
      ),
      _drawerTile(
        context: context,
        icon: Icons.person_outlined,
        selectedIcon: Icons.person,
        label: l10n.navProfile,
        index: 3,
        isAdmin: false,
      ),
    ];
  }

  List<Widget> _adminDrawerTiles(BuildContext context, AppLocalizations l10n) {
    return [
      _drawerTile(
        context: context,
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: l10n.adminDashboard,
        index: 0,
        isAdmin: true,
      ),
      _drawerTile(
        context: context,
        icon: Icons.people_outlined,
        selectedIcon: Icons.people,
        label: l10n.adminUsers,
        index: 1,
        isAdmin: true,
      ),
      _drawerTile(
        context: context,
        icon: Icons.key_outlined,
        selectedIcon: Icons.key,
        label: l10n.adminAccess,
        index: 2,
        isAdmin: true,
      ),
      _drawerTile(
        context: context,
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics,
        label: 'Analytics',
        index: 3,
        isAdmin: true,
      ),
      _drawerTile(
        context: context,
        icon: Icons.person_outlined,
        selectedIcon: Icons.person,
        label: l10n.navProfile,
        index: 4,
        isAdmin: true,
      ),
    ];
  }

  Widget _drawerTile({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required bool isAdmin,
  }) {
    final selected = isAdmin
        ? _getAdminSelectedIndex(context) == index
        : _getUserSelectedIndex(context) == index;
    return ListTile(
      leading: Icon(selected ? selectedIcon : icon),
      title: Text(label),
      selected: selected,
      selectedColor: AppColors.primary,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.of(context).pop(); // close the drawer
        if (isAdmin) {
          _onAdminNavTapped(context, index);
        } else {
          _onUserNavTapped(context, index);
        }
      },
    );
  }

  Future<bool?> _showExitDialog(BuildContext context, AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.exitAppTitle),
        content: Text(l10n.exitAppMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.exitAppNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.exitAppYes,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserNav(BuildContext context, AppLocalizations l10n) {
    return BottomNavigationBar(
      currentIndex: _getUserSelectedIndex(context),
      onTap: (index) => _onUserNavTapped(context, index),
      type: BottomNavigationBarType.fixed,
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
      type: BottomNavigationBarType.fixed,
      items: [
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
        const BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Analytics',
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
    if (location.startsWith('/admin/users')) return 1;
    if (location.startsWith('/admin/access')) return 2;
    if (location.startsWith('/admin/analytics')) return 3;
    if (location.startsWith('/admin')) return 0;
    if (location.startsWith('/profile')) return 4;
    return 0; // /admin
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
        context.go('/admin');
        break;
      case 1:
        context.go('/admin/users');
        break;
      case 2:
        context.go('/admin/access');
        break;
      case 3:
        context.go('/admin/analytics');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
