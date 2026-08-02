import 'package:flutter/material.dart';

/// Central breakpoints used across the app for responsive layouts.
///
/// Mobile stays the default; anything at or above [desktop] gets the
/// desktop layout (navigation rail + wide, centered content).
abstract final class AppBreakpoints {
  /// Width at/above which the desktop layout (NavigationRail + centered,
  /// width-capped content) is used.
  static const double desktop = 900;

  /// Width at/above which tablet-style grids kick in.
  static const double tablet = 600;
}

/// True when the current window is wide enough for the desktop layout.
bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= AppBreakpoints.desktop;

/// Named content-width presets for [ConstrainedContent] so future pages stay
/// consistent instead of re-introducing magic numbers.
///
/// | Constant  | Width | Typical use                                    |
/// |-----------|------:|------------------------------------------------|
/// | form      |   640 | Single-column forms (exam intro)               |
/// | tablet    |   560 | Tablet content column (profile page)           |
/// | compact   |   720 | Pricing / results pages                        |
/// | narrow    |   800 | Settings, quiz, exam, sign detail              |
/// | medium    |  1100 | Certificates, admin progress                   |
/// | wide      |  1200 | Dashboards, signs, admin pages (default)       |
/// | gridDense |   650 | Grids drop to fewer columns below this width   |
abstract final class AppContentWidths {
  /// Single-column forms (e.g. exam intro).
  static const double form = 640;

  /// Tablet-width content column (profile page).
  static const double tablet = 560;

  /// Compact pricing / results pages.
  static const double compact = 720;

  /// Comfortable reading width for text-heavy pages.
  static const double narrow = 800;

  /// Medium dashboards / content grids.
  static const double medium = 1100;

  /// Wide dashboards, signs and admin pages.
  static const double wide = 1200;

  /// Grid density breakpoint: responsive grids (signs, practice) switch to
  /// fewer columns when the available content width drops below this.
  static const double gridDense = 650;
}

/// Centers [child] and caps its width so content doesn't stretch
/// edge-to-edge on desktop screens. On mobile it degrades to a plain
/// [Padding] — the child just fills the available width.
///
/// Pages that are already full-bleed (gradient headers) are intentionally
/// left outside this wrapper.
class ConstrainedContent extends StatelessWidget {
  /// Maximum content width on wide screens (keeps lines readable).
  final double maxWidth;

  /// Outer padding applied on all screen sizes.
  final EdgeInsets padding;

  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = AppContentWidths.wide,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
