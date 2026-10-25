import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/need_help_section.dart';

class InstructionsPage extends StatelessWidget {
  final Future<void> Function(BuildContext) onShare;
  final VoidCallback? onNotices;
  const InstructionsPage({super.key, required this.onShare, this.onNotices});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = [
      (Icons.info_outline, l10n.guideAboutTitle, l10n.guideAboutBody),
      (Icons.touch_app_outlined, l10n.guideUseTitle, l10n.guideUseBody),
      (Icons.computer_outlined, l10n.guideExamTitle, l10n.guideExamBody),
      (Icons.payments_outlined, l10n.guidePaymentTitle, l10n.guidePaymentBody),
    ];
    return Scaffold(body: Column(children: [
      AppPageHeader(title: l10n.guideTitle),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l10n.guideWelcome, style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            for (final section in sections)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(section.$1, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(section.$2, style: AppTextStyles.heading5)),
                  ]),
                  const SizedBox(height: 12),
                  Text(section.$3, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
                ]),
              ),
            FilledButton.icon(
              onPressed: () => context.push('/subscription'),
              icon: const Icon(Icons.payments_outlined),
              label: Text(l10n.guideOpenAccess),
            ),
            const SizedBox(height: 20),
            const NeedHelpSection(),
            const SizedBox(height: 12),
            Builder(builder: (buttonContext) => OutlinedButton.icon(
              onPressed: () => onShare(buttonContext),
              icon: const Icon(Icons.share_outlined),
              label: Text(l10n.dashboardShare),
            )),
            if (onNotices != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(onPressed: onNotices,
                icon: const Icon(Icons.notifications_none),
                label: Text(l10n.settingsNotifications)),
            ],
          ]),
        )),
      )),
    ]));
  }
}
