import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({required this.child, Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getSelectedIndex(context),
        onTap: (index) => _onNavTapped(context, index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.traffic_outlined),
            activeIcon: const Icon(Icons.traffic),
            label: 'Signs',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.quiz_outlined),
            activeIcon: const Icon(Icons.quiz),
            label: 'Practice',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assessment_outlined),
            activeIcon: const Icon(Icons.assessment),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outlined),
            activeIcon: const Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/signs')) return 1;
    if (location.startsWith('/practice')) return 2;
    if (location.startsWith('/progress')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onNavTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/signs');
        break;
      case 2:
        context.go('/practice');
        break;
      case 3:
        context.go('/progress');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
