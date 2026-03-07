import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/locale/locale_provider.dart';
import '../../../../shared/network/api_config.dart';
import '../../../../shared/session/auth_session.dart';
import '../../../../shared/subscription/subscription_provider.dart';

const _kHelpNumber = '0788657595';
const _kMomoNumber = '323294';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isRequesting = false;
  String? _successMessage;
  String? _errorMessage;
  bool _isDuplicateRequest = false;
  bool _isPaymentError = false;

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

  Future<void> _requestAccess(
    BuildContext context,
    String tier,
    int price,
    String langCode,
  ) async {
    setState(() {
      _isRequesting = true;
      _successMessage = null;
      _errorMessage = null;
      _isDuplicateRequest = false;
      _isPaymentError = false;
    });

    final l10n = AppLocalizations.of(context);

    // Get userId from the AuthBloc state (most reliable, already in memory).
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
      final token = await AuthSession().getToken();
      final baseUrl = ApiConfig.baseUrl;

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/payments/request'),
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'userId': userId,
              'paymentTier': tier,
              'amount': price,
              'currency': 'RWF',
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _successMessage = l10n.subscriptionRequestSent;
        });
      } else if (response.statusCode == 409) {
        // Duplicate request
        setState(() {
          _isDuplicateRequest = true;
          _errorMessage = l10n.paymentRequestExists;
        });
      } else {
        final data = json.decode(response.body);
        final msg = (data['message'] as String?)?.isNotEmpty == true
            ? data['message'] as String
            : l10n.paymentError;
        setState(() {
          _isPaymentError = true;
          _errorMessage = msg;
        });
      }
    } catch (e) {
      setState(() {
        _isPaymentError = true;
        _errorMessage = l10n.paymentError;
      });
    } finally {
      setState(() => _isRequesting = false);
    }
  }

  Future<void> _copyNumber(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _kHelpNumber));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).paymentCopyNumber),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _callNumber() async {
    final uri = Uri.parse('tel:$_kHelpNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp() async {
    const msg = "Request access for driving exam app";
    final uri = Uri.parse('https://wa.me/$_kHelpNumber?text=${Uri.encodeComponent(msg)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langCode = context.watch<LocaleProvider>().effectiveLocale.languageCode;
    final subscription = context.watch<SubscriptionProvider>();
    final plans = _getPlans(langCode, l10n);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscriptionTitle),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isLarge ? 32 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current status
              if (subscription.hasActiveAccess) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    border: Border.all(color: AppColors.success.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.subscriptionAccessActive,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            if (subscription.expiresAt != null)
                              Text(
                                l10n.subscriptionExpires(
                                  subscription.expiresAt!.toLocal().toString().split(' ')[0],
                                ),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.lock_open, size: 48, color: AppColors.textInverse),
                    const SizedBox(height: 12),
                    Text(
                      l10n.subscriptionSubtitle,
                      style: const TextStyle(
                        color: AppColors.textInverse,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.subscriptionGetAccess(langCode == 'rw' ? 12 : 20),
                      style: const TextStyle(color: AppColors.textInverse, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pricing label
              Text(l10n.subscriptionChoosePlan, style: AppTextStyles.heading5),
              const SizedBox(height: 4),
              Text(
                l10n.subscriptionCurrency,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Plan cards
              ...plans.map((plan) => _PlanCard(
                    plan: plan,
                    isLoading: _isRequesting,
                    onRequest: (tier, price) =>
                        _requestAccess(context, tier, price, langCode),
                    l10n: l10n,
                  )),

              const SizedBox(height: 24),

              // Payment Instructions Card — always visible
              _PaymentInstructionsCard(l10n: l10n),

              // Success/Error messages
              if (_successMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    border: Border.all(color: AppColors.success.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _ErrorCard(
                  message: _errorMessage!,
                  isPaymentError: _isPaymentError,
                  isDuplicate: _isDuplicateRequest,
                  l10n: l10n,
                  onCopy: () => _copyNumber(context),
                  onCall: _callNumber,
                  onWhatsApp: _openWhatsApp,
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PaymentRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isLoading;
  final void Function(String tier, int price) onRequest;
  final AppLocalizations l10n;

  const _PlanCard({
    required this.plan,
    required this.isLoading,
    required this.onRequest,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final tier = plan['tier'] as String;
    final price = plan['price'] as int;
    final label = plan['label'] as String;
    final days = plan['durationDays'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.heading6),
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
                  style: AppTextStyles.heading5.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: isLoading ? null : () => onRequest(tier, price),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textInverse),
                        )
                      : Text(l10n.subscriptionRequestAccess),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
