import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/interactive_card.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final l10n = AppLocalizations.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            _buildHeroSection(context, isMobile, l10n),
            Expanded(
              child: _buildFeaturesSection(context, isMobile, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile, AppLocalizations l10n) {
    return Stack(
      children: [
        ClipPath(
          clipper: _CurvedHeaderClipper(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: isMobile ? 20 : 60,
              right: isMobile ? 20 : 60,
              top: isMobile ? MediaQuery.of(context).padding.top + 16 : 60,
              bottom: isMobile ? 28 : 80,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryFor(Theme.of(context).brightness),
                  AppColors.primaryFor(Theme.of(context).brightness).withValues(alpha: 0.8),
                  const Color(0xFF1A237E),
                ],
              ),
            ),
            // The gradient stays full-bleed; the content is capped so the
            // hero doesn't stretch edge-to-edge on ultra-wide monitors.
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _heroText(isMobile, l10n),
                          const SizedBox(height: 20),
                          _heroButtons(context, l10n),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: _heroText(false, l10n)),
                          const SizedBox(width: 60),
                          Expanded(child: _heroButtons(context, l10n)),
                        ],
                      ),
              ),
            ),
          ),
        ),
        const Positioned(
          top: -20,
          right: -20,
          child: Opacity(
            opacity: 0.1,
            child: Icon(Icons.traffic_rounded, size: 150, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _heroText(bool isMobile, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          l10n.landingHeroTitle,
          style: (isMobile ? AppTextStyles.heading2 : AppTextStyles.heading1)
              .copyWith(color: AppColors.textInverse),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 10),
        Text(
          l10n.landingHeroSubtitle,
          style: (isMobile ? AppTextStyles.bodyMedium : AppTextStyles.bodyLarge)
              .copyWith(color: AppColors.textInverse.withValues(alpha: 0.9)),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
      ],
    );
  }

  Widget _heroButtons(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          width: 220,
          child: ElevatedButton(
            onPressed: () => context.push('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textInverse,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              l10n.landingGetStarted,
              style: AppTextStyles.buttonLarge.copyWith(
                color: AppColors.primaryFor(Theme.of(context).brightness),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => context.push('/login'),
          child: Text(
            l10n.landingAlreadyHaveAccount,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textInverse,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(
    BuildContext context,
    bool isMobile,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 60,
        vertical: isMobile ? 12 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isMobile) ...[
                Text(
                  l10n.landingWhyUseApp,
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              Wrap(
            spacing: isMobile ? 10 : 16,
            runSpacing: isMobile ? 10 : 16,
            alignment: WrapAlignment.center,
            children: [
              _featureCard(
                context,
                Icons.menu_book,
                l10n.landingLearnRules,
                l10n.landingLearnRulesDesc,
                isMobile,
              ),
              _featureCard(
                context,
                Icons.quiz,
                l10n.landingPracticeExams,
                l10n.landingPracticeExamsDesc,
                isMobile,
              ),
              _featureCard(
                context,
                Icons.show_chart,
                l10n.landingTrackProgress,
                l10n.landingTrackProgressDesc,
                isMobile,
              ),
            ],
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
    bool isMobile,
  ) {
    // Informational cards: hover lift + pointer cursor so desktop visitors
    // get the same responsive feel as the home service cards, without a tap
    // action (they simply describe the app's features).
    return InteractiveCard(
      hoverFeedback: true,
      builder: (context, cardState) => AnimatedScale(
        scale: cardState.hovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: isMobile ? 100 : 320,
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(Theme.of(context).brightness),
            borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(
                  alpha: cardState.hovered ? 0.14 : 0.08,
                ),
                blurRadius: cardState.hovered ? 26 : 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: AppColors.primaryFor(
                Theme.of(context).brightness,
              ).withValues(alpha: 0.05),
            ),
          ),
          child: isMobile
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 24, color: AppColors.primaryFor(Theme.of(context).brightness)),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFor(Theme.of(context).brightness).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 28, color: AppColors.primaryFor(Theme.of(context).brightness)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      desc,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryFor(Theme.of(context).brightness),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Clips the bottom edge of a container into a smooth downward curve.
class _CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + 20,
        size.width,
        size.height - 40,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
