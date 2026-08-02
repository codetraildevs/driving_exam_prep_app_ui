import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import 'app_menu_button.dart';

/// Reusable curved gradient page header used across all logged-in pages.
///
/// Mirrors the compact header on [HomePage] so every protected page shares the
/// same primary-gradient curved bottom appearance.
class AppPageHeader extends StatelessWidget {
  /// Title shown in the centre / left of the header.
  final String title;

  /// Optional subtitle shown below the title.
  final String? subtitle;

  /// When true a back-arrow is shown on the left; tapping it calls
  /// [Navigator.pop]. Set to false on shell-route pages that already have
  /// bottom-navigation (home, practice, progress, profile …).
  final bool showBack;

  /// Optional widget placed on the right side of the header (e.g. an icon
  /// button). Ignored when [showBack] is true and no [trailing] is supplied.
  final Widget? trailing;

  const AppPageHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          showBack ? 4 : 20,
          topPadding + 12,
          12,
          18,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradientFor(Theme.of(context).brightness),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        child: Row(
          children: [
            if (showBack)
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textInverse,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            else
              // Shell pages (showBack: false) get the drawer hamburger on
              // desktop; it's hidden on mobile where bottom nav is used.
              const AppMenuButton(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textInverse,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textInverse.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
