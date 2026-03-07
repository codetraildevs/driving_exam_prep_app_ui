import 'package:flutter/material.dart';
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 48 : 100,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLogo(size: 72, isLight: true),
                const SizedBox(height: 32),
                _heroText(isMobile, l10n),
                const SizedBox(height: 32),
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
                      _buildLogo(size: 120, isLight: true),
                      const SizedBox(height: 40),
                      _heroButtons(context, l10n, isLight: true),
                    ],
                  ),
                ),
              ],
            ),
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
            color: AppColors.textInverse.withOpacity(0.9),
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
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            l10n.landingWhyUseApp,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          Wrap(
            spacing: 40,
            runSpacing: 40,
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
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(icon, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          Text(
            desc,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
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
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      color: AppColors.primary.withOpacity(0.05),
      child: Column(
        children: [
          Text(
            l10n.landingHowItWorks,
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 50),
          Wrap(
            spacing: 50,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              _StepItem(number: "1", text: l10n.landingStep1),
              _StepItem(number: "2", text: l10n.landingStep2),
              _StepItem(number: "3", text: l10n.landingStep3),
              _StepItem(number: "4", text: l10n.landingStep4),
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
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            l10n.landingReadyTitle,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
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

  // ================= LOGO =================

  Widget _buildLogo({double size = 64, bool isLight = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isLight
            ? AppColors.textInverse.withOpacity(0.15)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        Icons.traffic,
        size: size * 0.5,
        color: isLight ? AppColors.textInverse : AppColors.primary,
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String text;

  const _StepItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary,
            child: Text(
              number,
              style: const TextStyle(color: AppColors.textInverse, fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}