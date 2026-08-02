import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import '../../../../shared/widgets/app_page_header.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final sections = [
      _TermSection(
        icon: Icons.check_circle_outline_rounded,
        title: l10n.termsAcceptance,
        body: l10n.termsAcceptanceBody,
      ),
      _TermSection(
        icon: Icons.person_outline_rounded,
        title: l10n.termsUserAccount,
        body: l10n.termsUserAccountBody,
      ),
      _TermSection(
        icon: Icons.menu_book_rounded,
        title: l10n.termsContent,
        body: l10n.termsContentBody,
      ),
      _TermSection(
        icon: Icons.payment_rounded,
        title: l10n.termsPayment,
        body: l10n.termsPaymentBody,
      ),
      _TermSection(
        icon: Icons.block_rounded,
        title: l10n.termsTermination,
        body: l10n.termsTerminationBody,
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(title: l10n.settingsTermsOfService, showBack: true),
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
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.gavel_rounded,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.termsLastUpdated,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.termsIntro,
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    ...sections.asMap().entries.map((entry) {
                      final i = entry.key;
                      final s = entry.value;
                      return _TermCard(
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

class _TermSection {
  final IconData icon;
  final String title;
  final String body;

  const _TermSection({
    required this.icon,
    required this.title,
    required this.body,
  });
}

class _TermCard extends StatelessWidget {
  final int index;
  final IconData icon;
  final String title;
  final String body;
  final ColorScheme cs;

  const _TermCard({
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
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.warning, size: 18),
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
