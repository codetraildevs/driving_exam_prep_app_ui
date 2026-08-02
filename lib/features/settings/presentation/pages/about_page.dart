import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import '../../../../shared/widgets/app_page_header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(title: l10n.aboutTitle, showBack: true),
          Expanded(
            child: SingleChildScrollView(
              // Scroll view already applies 24px side padding; only cap the
              // content width so cards don't stretch edge-to-edge on desktop.
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedContent(
                maxWidth: AppContentWidths.narrow,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // App icon hero
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradientFor(
                          Theme.of(context).brightness,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.aboutAppName,
                      style: AppTextStyles.heading4,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.settingsVersion('1.0.0'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description card
                    _InfoCard(
                      icon: Icons.info_outline_rounded,
                      title: l10n.aboutDescription,
                      cs: cs,
                    ),
                    const SizedBox(height: 16),

                    // Features grid
                    Text(l10n.aboutFeatures, style: AppTextStyles.heading5),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _FeatureChip(
                            icon: Icons.quiz_rounded,
                            label: l10n.aboutFeaturePractice,
                            color: AppColors.primary,
                            cs: cs,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _FeatureChip(
                            icon: Icons.bar_chart_rounded,
                            label: l10n.aboutFeatureProgress,
                            color: AppColors.success,
                            cs: cs,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _FeatureChip(
                            icon: Icons.language_rounded,
                            label: l10n.aboutFeatureMultilingual,
                            color: AppColors.warning,
                            cs: cs,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _FeatureChip(
                            icon: Icons.verified_rounded,
                            label: l10n.aboutFeatureCertificate,
                            color: AppColors.error,
                            cs: cs,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Contact section
                    _SectionCard(
                      icon: Icons.email_rounded,
                      title: l10n.aboutContact,
                      body: l10n.aboutContactInfo,
                      cs: cs,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.copyright_rounded,
                      title: l10n.aboutCopyright,
                      body: l10n.aboutCopyrightText,
                      cs: cs,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.warning_amber_rounded,
                      title: l10n.aboutDisclaimer,
                      body: l10n.aboutDisclaimerText,
                      cs: cs,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final ColorScheme cs;

  const _InfoCard({required this.icon, required this.title, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ColorScheme cs;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final ColorScheme cs;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.heading6),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
