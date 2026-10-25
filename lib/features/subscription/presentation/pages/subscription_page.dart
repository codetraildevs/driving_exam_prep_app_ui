import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../config/payment_config.dart';
import '../../domain/payment_preparation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import '../../../../shared/subscription/subscription_notifier.dart';
import '../../../../shared/widgets/app_page_header.dart';

const _kHelpNumber = '0788659575';
const _kTigoCashNumber = '0728877442';

class SubscriptionPage extends ConsumerStatefulWidget {
  final PaymentConfiguration paymentConfiguration;
  final PaymentPreparationHandler paymentHandler;
  const SubscriptionPage({super.key,
    this.paymentConfiguration = PaymentConfiguration.environment,
    this.paymentHandler = prepareSubscriptionPayment,
  });

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  ExamLanguage _examLanguage = ExamLanguage.rw;
  SubscriptionDuration _duration = SubscriptionDuration.threeMonths;
  PaymentMethod? _paymentMethod;
  bool _preparing = false;

  PreparedPayment? get _prepared => PreparedPayment.tryCreate(
    examLanguage: _examLanguage, duration: _duration, method: _paymentMethod,
    configuration: widget.paymentConfiguration,
  );

  void _feedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyCode() async {
    final payment = _prepared;
    if (payment == null) return;
    final l10n = AppLocalizations.of(context);
    try {
      await Clipboard.setData(ClipboardData(text: payment.ussdCode));
      _feedback(l10n.paymentCodeCopied);
    } catch (_) {
      _feedback(l10n.paymentCopyFailed);
    }
  }

  Future<void> _handlePayNow() async {
    final payment = _prepared;
    if (payment == null || _preparing) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _preparing = true);
    try {
      await widget.paymentHandler(
        examLanguage: payment.examLanguage,
        durationMonths: payment.duration.months,
        paymentMethod: payment.method,
        amount: payment.amount,
        ussdCode: payment.ussdCode,
      );
      _feedback(l10n.paymentIntegrationPending);
    } catch (_) {
      _feedback(l10n.paymentPreparationFailed);
    } finally {
      if (mounted) setState(() => _preparing = false);
    }
  }

  List<Map<String, dynamic>> _getPlans(AppLocalizations l10n) {
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
    final subscription = ref.watch(subscriptionProvider);
    final plans = _getPlans(l10n);
    final payment = _prepared;
    final hasConfiguredMethod = PaymentMethod.values.any((method) => PreparedPayment.tryCreate(
      examLanguage: _examLanguage, duration: _duration, method: method,
      configuration: widget.paymentConfiguration,
    ) != null);
    final amount = subscriptionPrice(_examLanguage, _duration);
    final formattedAmount = NumberFormat('#,##0', l10n.localeName).format(amount);
    final showActive = subscription.hasActiveAccess &&
        (subscription.expiresAt == null || subscription.expiresAt!.isAfter(DateTime.now()));

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
                    if (showActive) ...[
                      _ActiveAccessBanner(
                        l10n: l10n,
                        subscription: subscription,
                      ),
                      const SizedBox(height: 10),
                    ],

                    Text(l10n.paymentExamLanguage, style: AppTextStyles.heading5),
                    const SizedBox(height: 4),
                    Text(l10n.paymentExamLanguageHint, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: ExamLanguage.values.map((language) {
                      final name = switch (language) {
                        ExamLanguage.rw => 'Kinyarwanda',
                        ExamLanguage.en => 'English',
                        ExamLanguage.fr => 'Français',
                      };
                      return ChoiceChip(
                        key: ValueKey('exam-language-${language.name}'),
                        label: Text(name), selected: _examLanguage == language,
                        onSelected: _preparing ? null : (_) => setState(() => _examLanguage = language),
                        selectedColor: AppColors.primary.withValues(alpha: 0.12),
                        side: BorderSide(color: _examLanguage == language ? AppColors.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      );
                    }).toList()),
                    const SizedBox(height: 16),
                    // ── Plan selection ──
                    Text(
                      l10n.subscriptionChoosePlan,
                      style: AppTextStyles.heading5,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.subscriptionCurrency,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...plans.map(
                      (plan) => _PlanCard(
                        plan: plan,
                        selectedTier: _duration.tier,
                        onSelect: _preparing ? null : (tier) => setState(() =>
                          _duration = SubscriptionDuration.values.firstWhere((value) => value.tier == tier)),
                        l10n: l10n,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Semantics(liveRegion: true, child: Text(
                      l10n.paymentAmountToPay(formattedAmount),
                      key: const ValueKey('payment-amount'),
                      style: AppTextStyles.heading5.copyWith(color: AppColors.primary),
                    )),
                    const SizedBox(height: 18),
                    _SectionHeader(icon: Icons.payments_outlined, title: l10n.paymentMethodLabel),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: PaymentMethod.values.map((method) {
                      final name = switch (method) {
                        PaymentMethod.momoPay => 'MoMo Pay',
                        PaymentMethod.mtn => 'MTN',
                        PaymentMethod.tigo => 'Tigo',
                      };
                      return ChoiceChip(
                        key: ValueKey('payment-method-${method.name}'),
                        label: Text(name), selected: _paymentMethod == method,
                        onSelected: _preparing ? null : (_) => setState(() => _paymentMethod = method),
                        selectedColor: AppColors.primary.withValues(alpha: 0.12),
                        side: BorderSide(color: _paymentMethod == method ? AppColors.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      );
                    }).toList()),
                    const SizedBox(height: 12),
                    if (payment == null) ...[
                      if (_paymentMethod == null) Text(l10n.paymentChooseMethod, style: AppTextStyles.bodySmall),
                      if (_paymentMethod != null || !hasConfiguredMethod)
                        Text(l10n.paymentNotConfigured, key: const ValueKey('payment-validation'), style: AppTextStyles.bodySmall),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(16)),
                        child: LayoutBuilder(builder: (context, constraints) {
                          final code = Semantics(label: l10n.paymentUssdLabel,
                            child: SelectableText(payment.ussdCode, key: const ValueKey('payment-ussd'),
                              style: AppTextStyles.bodyLarge));
                          final copy = TextButton.icon(
                            key: const ValueKey('copy-payment-code'),
                            onPressed: _preparing ? null : _copyCode,
                            icon: const Icon(Icons.copy_outlined), label: Text(l10n.paymentCopyCode),
                            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                          );
                          if (constraints.maxWidth < 420 || MediaQuery.textScalerOf(context).scale(1) > 1.3) {
                            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              code, const SizedBox(height: 4), Align(alignment: Alignment.centerRight, child: copy),
                            ]);
                          }
                          return Row(children: [Expanded(child: code), const SizedBox(width: 8), copy]);
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.paymentUssdInstruction, style: AppTextStyles.bodySmall),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const ValueKey('pay-now'),
                      onPressed: payment == null || _preparing ? null : _handlePayNow,
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: _preparing ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(l10n.paymentPayNow),
                    ),
                    const SizedBox(height: 20),
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
                        color: AppColors.textSecondary,
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
  final String selectedTier;
  final ValueChanged<String>? onSelect;
  final AppLocalizations l10n;

  const _PlanCard({required this.plan, required this.selectedTier, required this.onSelect, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final tier = plan['tier'] as String;
    final selected = selectedTier == tier;
    final theme = Theme.of(context);
    return Padding(padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(selected: selected, button: true,
        child: Material(color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: selected ? AppColors.primary : theme.colorScheme.outline.withValues(alpha: 0.2), width: selected ? 2 : 1)),
          child: InkWell(key: ValueKey('plan-$tier'),
            onTap: onSelect == null ? null : () => onSelect!(tier),
            borderRadius: BorderRadius.circular(16),
            child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(plan['label'] as String, style: AppTextStyles.heading6),
                Text(l10n.subscriptionDays(plan['durationDays'] as int), style: AppTextStyles.bodySmall),
                if (plan['popular'] == true) Text(l10n.subscriptionPopular,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
              ])),
              if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
            ])),
          ),
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
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
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
