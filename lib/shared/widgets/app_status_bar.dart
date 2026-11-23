import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/app_colors.dart';

/// Paints behind the transparent system status bar, above every route/dialog.
/// Existing page insets are preserved so content never shifts or gets covered.
class AppStatusBar extends StatelessWidget {
  const AppStatusBar({super.key, required this.child});

  final Widget child;

  static const style = SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: false,
  );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.viewPaddingOf(context).top;
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (height > 0)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height,
            child: const IgnorePointer(
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: style,
                child: ColoredBox(color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
}

/// Keeps the app clear of the side system insets (landscape navigation bar,
/// display cutout) on every route, including pushed readers and dialogs.
///
/// The horizontal insets are consumed here and removed from the inherited
/// [MediaQuery] so pages that already use [SafeArea] do not pad twice.
class SystemBarInsets extends StatelessWidget {
  const SystemBarInsets({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final insets = media.padding;
    if (insets.left <= 0 && insets.right <= 0) return child;

    return MediaQuery(
      data: media.copyWith(
        padding: media.padding.copyWith(left: 0, right: 0),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: insets.left, right: insets.right),
        child: child,
      ),
    );
  }
}
