import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';

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
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(context, isMobile, l10n),
              _buildFeaturesSection(isMobile, l10n),
              _buildHowItWorksSection(isMobile, l10n),
              _buildCallToAction(context, isMobile, l10n),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HERO SECTION =================

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
              top: isMobile ? 30 : 60,
              bottom: isMobile ? 40 : 80,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                  const Color(0xFF1A237E), // Deep indigo
                ],
              ),
            ),
            child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // _buildLogo(size: 80, isLight: true),
                    const SizedBox(height: 32),
                    _heroText(isMobile, l10n),
                    const SizedBox(height: 30),
                    _heroButtons(context, l10n, isLight: true),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _heroText(false, l10n)),
                    const SizedBox(width: 60),
                    Expanded(
                      child: Column(
                        children: [
                          //_buildLogo(size: 140, isLight: true),
                          const SizedBox(height: 30),
                          _heroButtons(context, l10n, isLight: true),
                        ],
                      ),
                    ),
                  ],
                ),
          ),
        ),
        // Decorative elements
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
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.textInverse,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 20),
        Text(
          l10n.landingHeroSubtitle,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textInverse.withValues(alpha: 0.9),
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
      ],
    );
  }

  Widget _heroButtons(BuildContext context, AppLocalizations l10n, {required bool isLight}) {
    return Column(
      children: [
        SizedBox(
          height: 56,
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
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.push('/login'),
          child: Text(
            l10n.landingAlreadyHaveAccount,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textInverse,
            ),
          ),
        )
      ],
    );
  }

  // ================= FEATURES =================

  Widget _buildFeaturesSection(bool isMobile, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 24,
      ),
      child: Column(
        children: [
          Text(
            l10n.landingWhyUseApp,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          //const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _featureCard(Icons.menu_book, l10n.landingLearnRules,
                  l10n.landingLearnRulesDesc),
              _featureCard(Icons.quiz, l10n.landingPracticeExams,
                  l10n.landingPracticeExamsDesc),
              _featureCard(Icons.show_chart, l10n.landingTrackProgress,
                  l10n.landingTrackProgressDesc),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String desc) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ================= HOW IT WORKS =================

  Widget _buildHowItWorksSection(bool isMobile, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.03),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Text(
            l10n.landingHowItWorks,
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          if (isMobile)
            Column(
              children: [
                _StepItem(number: "1", text: l10n.landingStep1, isLast: false),
                _StepItem(number: "2", text: l10n.landingStep2, isLast: false),
                _StepItem(number: "3", text: l10n.landingStep3, isLast: false),
                _StepItem(number: "4", text: l10n.landingStep4, isLast: true),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepItem(number: "1", text: l10n.landingStep1, isLast: false),
                _StepItem(number: "2", text: l10n.landingStep2, isLast: false),
                _StepItem(number: "3", text: l10n.landingStep3, isLast: false),
                _StepItem(number: "4", text: l10n.landingStep4, isLast: true),
              ],
            )
        ],
      ),
    );
  }

  // ================= CTA =================

  Widget _buildCallToAction(BuildContext context, bool isMobile, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 24,
      ),
      child: Column(
        children: [
          Text(
            l10n.landingReadyTitle,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 56,
            width: 240,
            child: ElevatedButton(
              onPressed: () => context.push('/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n.landingStartLearning,
                style: AppTextStyles.buttonLarge,
              ),
            ),
          )
        ],
      ),
    );
  }

}

class _StepItem extends StatelessWidget {
  final String number;
  final String text;
  final bool isLast;

  const _StepItem({required this.number, required this.text, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SizedBox(
      width: isMobile ? double.infinity : 200,
      child: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                children: [
                  _builderStepCircle(),
                  const SizedBox(width: 20),
                  Expanded(child: Text(text, style: AppTextStyles.labelLarge)),
                ],
              ),
            )
          : Column(
              children: [
                _builderStepCircle(),
                const SizedBox(height: 16),
                Text(text, textAlign: TextAlign.center, style: AppTextStyles.labelMedium),
              ],
            ),
    );
  }

  Widget _builderStepCircle() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
      ..quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 40)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}