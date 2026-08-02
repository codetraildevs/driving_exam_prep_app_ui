import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/locale/locale_notifier.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import '../../../../shared/subscription/subscription_notifier.dart';
import '../../../../shared/widgets/app_page_header.dart';

const _kHelpNumber = '0788659575';
const _kTigoCashNumber = '0728877442';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String? _loadingTier;
  String _selectedTier = '3_MONTHS'; // Default to popular plan

  List<Map<String, dynamic>> _getPlans(String langCode, AppLocalizations l10n) {
    return [
      {
        'tier': '1_MONTH',
        'durationDays': 30,
        'label': l10n.subscriptionMonth1,
        'popular': false,
      },
      {
        'tier': '3_MONTHS',
        'durationDays': 90,
        'label': l10n.subscriptionMonth3,
        'popular': true,
      },
      {
        'tier': '6_MONTHS',
        'durationDays': 180,
        'label': l10n.subscriptionMonth6,
        'popular': false,
      },
    ];
  }

  Future<void> _callNumber() async {
    final uri = Uri(scheme: 'tel', path: _kHelpNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _callTigoNumber() async {
    final uri = Uri(scheme: 'tel', path: _kTigoCashNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String message) async {
    final uri = Uri.parse(
      'https://wa.me/250${_kHelpNumber.substring(1)}?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final container = ProviderScope.containerOf(context, listen: false);
    final langCode = container
        .read(localeProvider)
        .effectiveLocale
        .languageCode;
    final subscription = container.read(subscriptionProvider);
    final plans = _getPlans(langCode, l10n);

    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(
            title: l10n.subscriptionTitle,
            subtitle: l10n.subscriptionSubtitle,
            showBack: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              // Scroll view already applies 20px side padding; only cap
              // the width so plan cards stay comfortable on desktop.
              child: ConstrainedContent(
                maxWidth: AppContentWidths.compact,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Active subscription banner ──
                    if (subscription.hasActiveAccess) ...[
                      _ActiveAccessBanner(
                        l10n: l10n,
                        subscription: subscription,
                      ),
                      const SizedBox(height: 10),
                    ],

                    // ── Plan selection ──
                    Text(
                      l10n.subscriptionChoosePlan,
                      style: AppTextStyles.heading5,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.subscriptionCurrency,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryFor(Theme.of(context).brightness),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...plans.map(
                      (plan) => _PlanCard(
                        plan: plan,
                        loadingTier: _loadingTier,
                        selectedTier: _selectedTier,
                        onSelect: (tier) =>
                            setState(() => _selectedTier = tier),
                        l10n: l10n,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // ── Learning Support Message ──
                    _TrafficRulesSupportCard(l10n: l10n),
                    const SizedBox(height: 20),

                    // ── Need Help ──
                    _SectionHeader(
                      icon: Icons.headset_mic_rounded,
                      title: l10n.subscriptionNeedHelp,
                    ),
                    const SizedBox(height: 10),
                    _NeedHelpCard(
                      l10n: l10n,
                      onCall: _callNumber,
                      onTigoCall: _callTigoNumber,
                      onWhatsApp: () =>
                          _openWhatsApp(l10n.paymentWhatsAppMessage),
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

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _ActiveAccessBanner extends StatelessWidget {
  final AppLocalizations l10n;
  final SubscriptionState subscription;

  const _ActiveAccessBanner({required this.l10n, required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.subscriptionAccessActive,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                    fontSize: 15,
                  ),
                ),
                if (subscription.expiresAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      l10n.subscriptionExpires(
                        subscription.expiresAt!.toLocal().toString().split(
                          ' ',
                        )[0],
                      ),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryFor(Theme.of(context).brightness),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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
            color: AppColors.primaryFor(Theme.of(context).brightness).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryFor(Theme.of(context).brightness), size: 18),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.heading5),
      ],
    );
  }
}

// _UssdCodeCard removed for Play Store compliance.

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
                color: AppColors.primaryFor(Theme.of(context).brightness),
                onTap: onCall,
              ),
              const SizedBox(height: 10),
              _ContactButton(
                icon: Icons.phone_rounded,
                label: l10n.paymentCallTigoNumber,
                color: AppColors.textSecondaryFor(Theme.of(context).brightness),
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
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final String? loadingTier;
  final String selectedTier;
  final ValueChanged<String> onSelect;
  final AppLocalizations l10n;

  const _PlanCard({
    required this.plan,
    required this.loadingTier,
    required this.selectedTier,
    required this.onSelect,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final tier = plan['tier'] as String;
    final label = plan['label'] as String;
    final days = plan['durationDays'] as int;
    final isPopular = plan['popular'] as bool;
    final isSelected = selectedTier == tier;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onSelect(tier),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryFor(Theme.of(context).brightness)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // Radio indicator
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryFor(Theme.of(context).brightness)
                            : AppColors.textSecondaryFor(Theme.of(context).brightness).withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryFor(Theme.of(context).brightness),
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: AppTextStyles.heading6),
                        const SizedBox(height: 2),
                        Text(
                          l10n.subscriptionDays(days),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryFor(Theme.of(context).brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: AppColors.primaryFor(Theme.of(context).brightness)),
                ],
              ),
            ),
            // Popular badge
            if (isPopular)
              Positioned(
                top: 0,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.subscriptionPopular,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrafficRulesSupportCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _TrafficRulesSupportCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryFor(Theme.of(context).brightness), AppColors.primaryFor(Theme.of(context).brightness).withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryFor(Theme.of(context).brightness).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.school_rounded, color: Colors.white, size: 30),
          const SizedBox(height: 8),
          Text(
            l10n.subscriptionTrafficRulesMsg,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 2.0,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
