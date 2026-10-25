import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shared support contacts used by the dashboard and subscription page.
class NeedHelpSection extends StatelessWidget {
  const NeedHelpSection({super.key});

  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) { /* Show the same localized failure for unsupported devices. */ }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).dashboardOpenFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _SectionHeader(icon: Icons.headset_mic_rounded, title: l10n.subscriptionNeedHelp),
      const SizedBox(height: 10),
      _NeedHelpCard(
        l10n: l10n,
        onCall: () => _open(context, Uri(scheme: 'tel', path: '0788659575')),
        onTigoCall: () => _open(context, Uri(scheme: 'tel', path: '0728877442')),
        onWhatsApp: () => _open(context, Uri.https('wa.me', '/250788659575',
          {'text': l10n.paymentWhatsAppMessage})),
      ),
    ]);
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: AppTextStyles.heading5)),
      ],
    );
  }
}


class _NeedHelpCard extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onCall;
  final VoidCallback onTigoCall;
  final VoidCallback onWhatsApp;

  const _NeedHelpCard({
    required this.l10n,
    required this.onCall,
    required this.onTigoCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action buttons
          Column(
            children: [
              _ContactButton(
                icon: Icons.phone_rounded,
                label: l10n.paymentCallNumber,
                color: AppColors.primary,
                onTap: onCall,
              ),
              const SizedBox(height: 10),
              _ContactButton(
                icon: Icons.phone_rounded,
                label: l10n.paymentCallTigoNumber,
                color: AppColors.textSecondary,
                onTap: onTigoCall,
              ),

              const SizedBox(height: 10),
              _ContactButton(
                icon: Icons.chat_rounded,
                label: l10n.paymentWhatsApp,
                color: const Color(0xFF25D366),
                onTap: onWhatsApp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

