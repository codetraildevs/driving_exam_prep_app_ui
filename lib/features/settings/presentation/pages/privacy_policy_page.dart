import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import '../../../../shared/widgets/app_page_header.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final sections = [
      _PolicySection(
        icon: Icons.storage_rounded,
        title: l10n.privacyDataCollection,
        body: l10n.privacyDataCollectionBody,
      ),
      _PolicySection(
        icon: Icons.visibility_rounded,
        title: l10n.privacyDataUsage,
        body: l10n.privacyDataUsageBody,
      ),
      _PolicySection(
        icon: Icons.shield_rounded,
        title: l10n.privacyDataProtection,
        body: l10n.privacyDataProtectionBody,
      ),
      _PolicySection(
        icon: Icons.share_rounded,
        title: l10n.privacyDataSharing,
        body: l10n.privacyDataSharingBody,
      ),
      _PolicySection(
        icon: Icons.person_rounded,
        title: l10n.privacyUserRights,
        body: l10n.privacyUserRightsBody,
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(title: l10n.settingsPrivacyPolicy, showBack: true),
          Expanded(
            child: SingleChildScrollView(
              // Scroll view already applies 24px side padding; only cap the
              // content width so cards don't stretch edge-to-edge on desktop.
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedContent(
                maxWidth: AppContentWidths.narrow,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.policy_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.privacyLastUpdated,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.privacyIntro,
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    ...sections.asMap().entries.map((entry) {
                      final i = entry.key;
                      final s = entry.value;
                      return _PolicyCard(
                        index: i + 1,
                        icon: s.icon,
                        title: s.title,
                        body: s.body,
                        cs: cs,
                      );
                    }),
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

class _PolicySection {
  final IconData icon;
  final String title;
  final String body;

  const _PolicySection({
    required this.icon,
    required this.title,
    required this.body,
  });
}

class _PolicyCard extends StatelessWidget {
  final int index;
  final IconData icon;
  final String title;
  final String body;
  final ColorScheme cs;

  const _PolicyCard({
    required this.index,
    required this.icon,
    required this.title,
    required this.body,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: AppTextStyles.heading6)),
            ],
          ),
          const SizedBox(height: 10),
          Text(body, style: AppTextStyles.bodySmall.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
