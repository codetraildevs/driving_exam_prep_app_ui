import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../shared/locale/locale_provider.dart';
import '../../../../shared/network/api_config.dart';
import '../../../../shared/session/auth_session.dart';
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

  List<Map<String, dynamic>> _getPlans(String langCode) {
    if (langCode == 'rw') {
      return [
        {'tier': '1_MONTH', 'durationDays': 30, 'price': 1500, 'label': '1 Month'},
        {'tier': '3_MONTHS', 'durationDays': 90, 'price': 3000, 'label': '3 Months'},
        {'tier': '6_MONTHS', 'durationDays': 180, 'price': 5000, 'label': '6 Months'},
      ];
    } else {
      return [
        {'tier': '1_MONTH', 'durationDays': 30, 'price': 3000, 'label': '1 Month'},
        {'tier': '3_MONTHS', 'durationDays': 90, 'price': 5000, 'label': '3 Months'},
        {'tier': '6_MONTHS', 'durationDays': 180, 'price': 10000, 'label': '6 Months'},
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
    });

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
              'paymentTier': tier,
              'amount': price,
              'currency': 'RWF',
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _successMessage =
              'Your request has been submitted. You will be activated once payment is confirmed.';
        });
      } else {
        final data = json.decode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Request failed. Please try again.';
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection and try again.';
      });
    } finally {
      setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCode = context.watch<LocaleProvider>().effectiveLocale.languageCode;
    final subscription = context.watch<SubscriptionProvider>();
    final plans = _getPlans(langCode);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Practice Exam Access'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Access Active',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            if (subscription.expiresAt != null)
                              Text(
                                'Expires: ${subscription.expiresAt!.toLocal().toString().split(' ')[0]}',
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.lock_open, size: 48, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text(
                      'Unlock All Practice Exams',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get access to all ${langCode == 'rw' ? '12' : '20'}+ premium practice exams',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pricing label
              Text(
                'Choose a Plan',
                style: AppTextStyles.heading5,
              ),
              const SizedBox(height: 4),
              Text(
                'Currency: RWF',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Plan cards
              ...plans.map((plan) => _PlanCard(
                    plan: plan,
                    isLoading: _isRequesting,
                    onRequest: (tier, price) =>
                        _requestAccess(context, tier, price, langCode),
                  )),

              // Success/Error messages
              if (_successMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    border: Border.all(color: AppColors.success.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(12),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    border: Border.all(color: AppColors.error.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isLoading;
  final void Function(String tier, int price) onRequest;

  const _PlanCard({
    required this.plan,
    required this.isLoading,
    required this.onRequest,
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
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
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
                    '$days days',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${price.toString()} RWF',
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
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Request Access'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
