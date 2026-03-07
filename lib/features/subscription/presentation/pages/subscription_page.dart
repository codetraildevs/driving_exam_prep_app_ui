import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/locale/locale_provider.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/subscription/subscription_provider.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isRequesting = false;
  String? _successMessage;
  String? _errorMessage;
  String? _selectedTier;

  List<Map<String, dynamic>> _getPlans(String langCode, AppLocalizations l10n) {
    if (langCode == 'rw') {
      return [
        {'tier': '1_MONTH', 'durationDays': 30, 'price': 1500, 'label': l10n.subscriptionMonth1},
        {'tier': '3_MONTHS', 'durationDays': 90, 'price': 3000, 'label': l10n.subscriptionMonth3},
        {'tier': '6_MONTHS', 'durationDays': 180, 'price': 5000, 'label': l10n.subscriptionMonth6},
      ];
    } else {
      return [
        {'tier': '1_MONTH', 'durationDays': 30, 'price': 3000, 'label': l10n.subscriptionMonth1},
        {'tier': '3_MONTHS', 'durationDays': 90, 'price': 5000, 'label': l10n.subscriptionMonth3},
        {'tier': '6_MONTHS', 'durationDays': 180, 'price': 10000, 'label': l10n.subscriptionMonth6},
      ];
    }
  }

  Map<String, dynamic>? _getSelectedPlan(List<Map<String, dynamic>> plans) {
    if (_selectedTier == null) return null;
    return plans.cast<Map<String, dynamic>?>().firstWhere(
          (p) => p!['tier'] == _selectedTier,
          orElse: () => null,
        );
  }

  Future<void> _requestAccess(BuildContext context, String tier, int price) async {
    if (_isRequesting) return;

    setState(() {
      _isRequesting = true;
      _successMessage = null;
      _errorMessage = null;
    });

    final l10n = AppLocalizations.of(context);
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    if (userId == null || userId.isEmpty) {
      setState(() {
        _isRequesting = false;
        _errorMessage = l10n.commonError;
      });
      return;
    }

    try {
      final result = await ApiHelper().post('/api/payments/request', body: {
        'userId': userId,
        'paymentTier': tier,
        'amount': price,
        'currency': 'RWF',
      });

      if (result.isSuccess) {
        final isDuplicate = result.data is Map && result.data['duplicate'] == true;
        setState(() {
          _successMessage = isDuplicate
              ? (result.data['message'] as String? ?? l10n.subscriptionRequestSent)
              : l10n.subscriptionRequestSent;
        });
      } else {
        setState(() {
          _errorMessage = result.detailedError;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    } finally {
      setState(() => _isRequesting = false);
    }
  }

  Future<void> _dialUssd(String code) async {
    final uri = Uri(scheme: 'tel', path: code);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(AppLocalizations l10n) async {
    final message = Uri.encodeComponent(l10n.paymentWhatsAppMessage);
    final uri = Uri.parse('https://wa.me/250788657595?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(BuildContext context, String text, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.paymentCodeCopied),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langCode = context.watch<LocaleProvider>().effectiveLocale.languageCode;
    final subscription = context.watch<SubscriptionProvider>();
    final plans = _getPlans(langCode, l10n);
    final selectedPlan = _getSelectedPlan(plans);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            // Gradient header
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 12, 24),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.textInverse),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Text(
                            l10n.subscriptionTitle,
                            style: AppTextStyles.heading5.copyWith(color: AppColors.textInverse),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Icon(Icons.lock_open, size: 40, color: AppColors.textInverse),
                    const SizedBox(height: 8),
                    Text(
                      l10n.subscriptionSubtitle,
                      style: const TextStyle(color: AppColors.textInverse, fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.subscriptionGetAccess(langCode == 'rw' ? 12 : 20),
                      style: TextStyle(color: AppColors.textInverse.withOpacity(0.85), fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 ? 40 : 16,
                vertical: 16,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Current status
                  if (subscription.hasActiveAccess) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        border: Border.all(color: AppColors.success.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.subscriptionAccessActive,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 13)),
                                if (subscription.expiresAt != null)
                                  Text(
                                    l10n.subscriptionExpires(subscription.expiresAt!.toLocal().toString().split(' ')[0]),
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ===== PAYMENT INSTRUCTIONS (BEFORE plan selection) =====
                  _buildPaymentInstructions(context, l10n, selectedPlan),
                  const SizedBox(height: 20),

                  // ===== PLAN SELECTION =====
                  Text(l10n.subscriptionChoosePlan, style: AppTextStyles.heading5),
                  const SizedBox(height: 4),
                  Text(l10n.subscriptionCurrency,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),

                  ...plans.map((plan) {
                    final tier = plan['tier'] as String;
                    final isSelected = _selectedTier == tier;
                    return _buildPlanCard(context, plan, isSelected, l10n);
                  }),

                  const SizedBox(height: 16),

                  // ===== CONFIRM BUTTON =====
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_selectedTier == null || _isRequesting)
                          ? null
                          : () {
                              final plan = _getSelectedPlan(plans);
                              if (plan != null) {
                                _requestAccess(context, plan['tier'] as String, plan['price'] as int);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textInverse,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        disabledBackgroundColor: AppColors.disabled,
                      ),
                      child: _isRequesting
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textInverse),
                            )
                          : Text(
                              _selectedTier == null
                                  ? l10n.paymentSelectPlanFirst
                                  : l10n.paymentConfirmRequest,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  // Success / Error
                  if (_successMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        border: Border.all(color: AppColors.success.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_successMessage!,
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        border: Border.all(color: AppColors.error.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_errorMessage!,
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInstructions(BuildContext context, AppLocalizations l10n, Map<String, dynamic>? selectedPlan) {
    final amountStr = selectedPlan != null ? '${selectedPlan['price']}' : 'amount';
    final momoCode = '*182*1*1*323294*$amountStr#';
    final mobileCode = '*182*8*1*0788657595*$amountStr#';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payment, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(l10n.paymentInstructionsTitle,
                  style: AppTextStyles.heading6.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 14),

          // Steps
          Text(l10n.paymentStep1, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          Text(l10n.paymentStep2, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          Text(l10n.paymentStep3, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 14),

          // MoMo Pay dial card
          _buildDialCard(
            context: context,
            l10n: l10n,
            label: l10n.paymentDialMomoPay(amountStr),
            dialCode: momoCode,
            icon: Icons.phone_android,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),

          // Mobile Money dial card
          _buildDialCard(
            context: context,
            l10n: l10n,
            label: l10n.paymentDialMobileMoney(amountStr),
            dialCode: mobileCode,
            icon: Icons.mobile_friendly,
            color: AppColors.accent,
          ),

          const Divider(height: 24),

          // Help section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.help_outline, color: AppColors.warning, size: 18),
              ),
              const SizedBox(width: 10),
              Text(l10n.subscriptionNeedHelp,
                  style: AppTextStyles.heading6.copyWith(color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 10),

          // Call + WhatsApp buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _dialUssd('0788657595'),
                  icon: const Icon(Icons.phone, size: 16),
                  label: Text(l10n.subscriptionHelpCall, style: const TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openWhatsApp(l10n),
                  icon: const Icon(Icons.chat, size: 16, color: Color(0xFF25D366)),
                  label: Text(l10n.subscriptionHelpWhatsapp,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF25D366))),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF25D366),
                    side: const BorderSide(color: Color(0xFF25D366)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialCard({
    required BuildContext context,
    required AppLocalizations l10n,
    required String label,
    required String dialCode,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.neutral300),
                  ),
                  child: Text(dialCode,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => _copyToClipboard(context, dialCode, l10n),
                icon: const Icon(Icons.copy, size: 18),
                tooltip: l10n.paymentCopyCode,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                color: AppColors.textSecondary,
              ),
              IconButton(
                onPressed: () => _dialUssd(dialCode),
                icon: Icon(Icons.phone, size: 18, color: color),
                tooltip: l10n.paymentDialNow,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan, bool isSelected, AppLocalizations l10n) {
    final tier = plan['tier'] as String;
    final price = plan['price'] as int;
    final label = plan['label'] as String;
    final days = plan['durationDays'] as int;

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (!isSelected)
              BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.04), blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.neutral400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
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
                  Text(l10n.subscriptionDays(days),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text(l10n.subscriptionPrice(price),
                style: AppTextStyles.heading5.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
