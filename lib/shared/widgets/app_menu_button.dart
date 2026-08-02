import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../responsive/responsive_layout.dart';
import 'app_drawer_scope.dart';

/// Hamburger button that opens the shell navigation drawer on desktop.
///
/// Hidden on mobile (where the bottom navigation bar is used) and whenever no
/// [AppDrawerScope] is registered above it (e.g. pushed pages).
class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isDesktop(context)) return const SizedBox.shrink();
    final scope = AppDrawerScope.maybeOf(context);
    if (scope == null) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.menu, color: AppColors.textInverse),
      tooltip: 'Menu',
      onPressed: scope.openDrawer,
    );
  }
}
