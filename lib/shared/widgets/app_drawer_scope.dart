import 'package:flutter/widgets.dart';

/// Exposes a way to open the shell's navigation drawer from page headers.
///
/// [MainLayout] registers itself here; page headers use [AppMenuButton] to
/// open the drawer on desktop.
class AppDrawerScope extends InheritedWidget {
  const AppDrawerScope({
    super.key,
    required this.openDrawer,
    required super.child,
  });

  /// Opens the shell's navigation drawer.
  final VoidCallback openDrawer;

  /// The nearest [AppDrawerScope] ancestor, if any.
  static AppDrawerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppDrawerScope>();

  @override
  bool updateShouldNotify(AppDrawerScope oldWidget) =>
      openDrawer != oldWidget.openDrawer;
}
