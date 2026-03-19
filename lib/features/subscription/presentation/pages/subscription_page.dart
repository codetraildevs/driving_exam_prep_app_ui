import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/locale/locale_provider.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/subscription/subscription_provider.dart';
import '../../../../shared/widgets/app_page_header.dart';

const _kHelpNumber = '0788659575';
const _kMomoPayCode = '323294';
const _kTigoCashNumber='0728877442';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String? _loadingTier;
  String? _successMessage;
  String? _errorMessage;
  bool _isDuplicateRequest = false;
  String _selectedTier = '3_MONTHS'; // Default to popular plan

  List<Map<String, dynamic>> _getPlans(String langCode, AppLocalizations l10n) {
    if (langCode == 'rw') {
      return [
        {'tier': '1_MONTH', 'durationDays': 30, 'price': 1500, 'label': l10n.subscriptionMonth1, 'popular': false},
        {'tier': '3_MONTHS', 'durationDays': 90, 'price': 3000, 'label': l10n.subscriptionMonth3, 'popular': true},
        {'tier': '6_MONTHS', 'durationDays': 180, 'price': 5000, 'label': l10n.subscriptionMonth6, 'popular': false},
      ];
    } else {
      return [
        {'tier': '1_MONTH', 'durationDays': 30, 'price': 3000, 'label': l10n.subscriptionMonth1, 'popular': false},
        {'tier': '3_MONTHS', 'durationDays': 90, 'price': 5000, 'label': l10n.subscriptionMonth3, 'popular': true},
        {'tier': '6_MONTHS', 'durationDays': 180, 'price': 10000, 'label': l10n.subscriptionMonth6, 'popular': false},
      ];
    }
  }

  void _showPaymentModal(
    BuildContext context,
    String tier,
    int price,
    String langCode,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final momoCode = '*182*8*1*$_kMomoPayCode*$price#';
    final mobileCode = '*182*1*1*$_kHelpNumber*$price#';
    final tigoCashCode = '*182*1*1*$_kTigoCashNumber*$price#';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Text(
              l10n.paymentChooseMethod,
              style: AppTextStyles.heading5,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.subscriptionPrice(price),
              style: AppTextStyles.heading4.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            // MoMo Pay option
            _PaymentOptionTile(
              icon: Icons.phone_android_rounded,
              title: l10n.paymentMomoPayNumber,
              subtitle: momoCode,
              color: AppColors.warning,
              onTap: () {
                Navigator.of(ctx).pop();
                _dialUssd(momoCode);
                _submitPaymentRequest(context, tier, price, langCode);
              },
              theme: theme,
            ),
            const SizedBox(height: 12),
            // Mobile Money option
            _PaymentOptionTile(
              icon: Icons.account_balance_wallet_rounded,
              title: l10n.paymentMobileMoneyNumber,
              subtitle: mobileCode,
              color: AppColors.primary,
              onTap: () {
                Navigator.of(ctx).pop();
                _dialUssd(mobileCode);
                _submitPaymentRequest(context, tier, price, langCode);
              },
              theme: theme,
            ),
            const SizedBox(height: 12),
            // Tigo Cash option
            _PaymentOptionTile(
              icon: Icons.account_balance_wallet_rounded,
              title: l10n.paymentTigoCashNumber,
              subtitle: tigoCashCode,
              color: AppColors.textTertiary,
              onTap: () {
                Navigator.of(ctx).pop();
                _dialUssd(tigoCashCode);
                _submitPaymentRequest(context, tier, price, langCode);
              },
              theme: theme,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPaymentRequest(
    BuildContext context,
    String tier,
    int price,
    String langCode,
  ) async {
    final l10n = AppLocalizations.of(context);
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;
    if (userId == null || userId.isEmpty) return;

    try {
      final result = await ApiHelper().post(
        '/api/payments/request',
        body: {
          'userId': userId,
          'paymentTier': tier,
          'amount': price,
          'currency': 'RWF',
        },
      );
      if (!mounted) return;

      if (result.statusCode == 401) {
        context.read<AuthBloc>().add(const SignOutEvent());
        context.go('/login');
        return;
      } else if (result.statusCode == 409) {
        setState(() {
          _isDuplicateRequest = true;
          _errorMessage = l10n.paymentRequestExists;
        });
      } else if (result.isSuccess) {
        final data = result.data;
        if (data is Map && data['duplicate'] == true) {
          setState(() {
            _isDuplicateRequest = true;
            _errorMessage = l10n.paymentRequestExists;
          });
        } else {
          setState(() {
            _successMessage = l10n.subscriptionRequestSent;
          });
        }
      }
    } catch (_) {
      // Fire-and-forget; user already dialled USSD
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.generalCopied),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
    final uri = Uri.parse('https://wa.me/250${_kHelpNumber.substring(1)}?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _dialUssd(String ussdCode) async {
    final uri = Uri(scheme: 'tel', path: ussdCode);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  int _getSelectedPrice(List<Map<String, dynamic>> plans) {
    final plan = plans.firstWhere(
      (p) => p['tier'] == _selectedTier,
      orElse: () => plans[1],
    );
    return plan['price'] as int;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langCode = context.watch<LocaleProvider>().effectiveLocale.languageCode;
    final subscription = context.watch<SubscriptionProvider>();
    final plans = _getPlans(langCode, l10n);
    final theme = Theme.of(context);
    final selectedPrice = _getSelectedPrice(plans);
    final momoCode = '*182*8*1*$_kMomoPayCode*$selectedPrice#';
    final mobileCode = '*182*1*1*$_kHelpNumber*$selectedPrice#';
    final tigoCashCode = '*182*1*1*$_kTigoCashNumber*$selectedPrice#';

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Active subscription banner ──
                  if (subscription.hasActiveAccess) ...[
                    _ActiveAccessBanner(l10n: l10n, subscription: subscription),
                    const SizedBox(height: 20),
                  ],

                  // ── Plan selection ──
                  Text(l10n.subscriptionChoosePlan, style: AppTextStyles.heading5),
                  const SizedBox(height: 4),
                  Text(
                    l10n.subscriptionCurrency,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  ...plans.map((plan) => _PlanCard(
                        plan: plan,
                        loadingTier: _loadingTier,
                        selectedTier: _selectedTier,
                        onSelect: (tier) => setState(() => _selectedTier = tier),
                        onRequest: (tier, price) =>
                            _showPaymentModal(context, tier, price, langCode),
                        l10n: l10n,
                      )),

                  // ── Success / Error messages ──
                  if (_successMessage != null) ...[
                    const SizedBox(height: 10),
                    _StatusBanner(
                      message: _successMessage!,
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    _StatusBanner(
                      message: _errorMessage!,
                      icon: _isDuplicateRequest ? Icons.info_outline : Icons.error_outline,
                      color: _isDuplicateRequest ? AppColors.warning : AppColors.error,
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Payment Instructions ──
                  _SectionHeader(
                    icon: Icons.receipt_long_rounded,
                    title: l10n.paymentInstructionsTitle,
                  ),
                  const SizedBox(height: 10),

                  // Step 1 – MoMo Pay
                  _UssdCodeCard(
                    stepNumber: 1,
                    title: l10n.subscriptionPaymentMomo,
                    description: l10n.paymentMomoPayDial,
                    ussdCode: momoCode,
                    onCopy: () => _copyToClipboard(context, momoCode),
                    onDial: () => _dialUssd(momoCode),
                    theme: theme,
                  ),
                  const SizedBox(height: 10),

                  // Step 2 – Mobile Money.
                  _UssdCodeCard(
                    stepNumber: 2,
                    title: l10n.subscriptionPaymentMobile,
                    description: l10n.paymentMobileMoneyDial,
                    ussdCode: mobileCode,
                    onCopy: () => _copyToClipboard(context, mobileCode),
                    onDial: () => _dialUssd(mobileCode),
                    theme: theme,
                  ),
   // Step 3 – Tigo Cash
                  _UssdCodeCard(
                    stepNumber: 3,
                    title: l10n.subscriptionPaymentTigoCash,
                    description: l10n.paymentTigoCashDial,
                    ussdCode: tigoCashCode,
                    onCopy: () => _copyToClipboard(context, tigoCashCode),
                    onDial: () => _dialUssd(tigoCashCode),
                    theme: theme,
                  ),
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
                    onWhatsApp: () => _openWhatsApp(l10n.paymentWhatsAppMessage),
                  ),

                  const SizedBox(height: 32),
                ],
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
  final SubscriptionProvider subscription;

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
            child: const Icon(Icons.verified_rounded, color: AppColors.success, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.subscriptionAccessActive,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success, fontSize: 15),
                ),
                if (subscription.expiresAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      l10n.subscriptionExpires(
                        subscription.expiresAt!.toLocal().toString().split(' ')[0],
                      ),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
        Text(title, style: AppTextStyles.heading5),
      ],
    );
  }
}

class _UssdCodeCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;
  final String ussdCode;
  final VoidCallback onCopy;
  final VoidCallback onDial;
  final ThemeData theme;

  const _UssdCodeCard({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.ussdCode,
    required this.onCopy,
    required this.onDial,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$stepNumber',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: AppTextStyles.heading6),
                ),
              ],
            ),
          ),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 10),
          // USSD Code block
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.dialpad_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ussdCode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onCopy,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.copy_rounded, size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: onDial,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.phone_rounded, size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
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
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
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
              const SizedBox(
                height: 10,
              ),
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

class _StatusBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const _StatusBanner({
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final String? loadingTier;
  final String selectedTier;
  final ValueChanged<String> onSelect;
  final void Function(String tier, int price) onRequest;
  final AppLocalizations l10n;

  const _PlanCard({
    required this.plan,
    required this.loadingTier,
    required this.selectedTier,
    required this.onSelect,
    required this.onRequest,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final tier = plan['tier'] as String;
    final price = plan['price'] as int;
    final label = plan['label'] as String;
    final days = plan['durationDays'] as int;
    final isPopular = plan['popular'] as bool;
    final isSelected = selectedTier == tier;
    final isThisTierLoading = loadingTier == tier;
    final anyLoading = loadingTier != null;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onSelect(tier),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.4),
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
                      const SizedBox(height: 2),
                      Text(
                        l10n.subscriptionDays(days),
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.subscriptionPrice(price),
                      style: AppTextStyles.heading5.copyWith(
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed: anyLoading ? null : () => onRequest(tier, price),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPopular ? AppColors.success : null,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isThisTierLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textInverse),
                              )
                            : Text(
                                l10n.subscriptionRequestAccess,
                                style: const TextStyle(fontSize: 13),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Popular badge
          if (isPopular)
            Positioned(
              top: 0,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.subscriptionPopular,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final ThemeData theme;

  const _PaymentOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.heading6),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
