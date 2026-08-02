import 'package:flutter/material.dart';

/// Subtle fade + slight upward slide used for web page transitions.
///
/// Keeps navigation feeling composed on desktop without the heavier
/// platform-native zoom/slide animations used on mobile.
class WebFadeSlideTransitionsBuilder extends PageTransitionsBuilder {
  const WebFadeSlideTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// A [PageTransitionsTheme] that applies the web fade/slide builder to every
/// platform. Only used when running on the web, so mobile keeps the native
/// platform transitions.
PageTransitionsTheme webPageTransitionsTheme() => PageTransitionsTheme(
  builders: {
    for (final platform in TargetPlatform.values)
      platform: const WebFadeSlideTransitionsBuilder(),
  },
);
