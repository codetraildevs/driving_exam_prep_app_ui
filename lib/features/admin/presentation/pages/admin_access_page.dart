import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/network/api_config.dart';
import '../../../../shared/session/auth_session.dart';

/// Access Management page — shows users who have (or had) a subscription.
/// Admins can renew/extend access or revoke it here.
class AdminAccessPage extends StatefulWidget {
  const AdminAccessPage({Key? key}) : super(key: key);

  @override
  State<AdminAccessPage> createState() => _AdminAccessPageState();
}

class _AdminAccessPageState extends State<AdminAccessPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _subscribed = [];
  String? _error;
  final Map<String, bool> _loadingMap = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await AuthSession().getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/users'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final all = (data is List)
            ? List<dynamic>.from(data)
            : List<dynamic>.from(data['users'] ?? data['data'] ?? []);

        // Keep only users who have (or had) an access entry
        setState(() {
          _subscribed = all
              .where((u) {
                final access = u['access'] ?? u['subscription'];
                return access != null;
              })
              .map((u) => Map<String, dynamic>.from(u as Map))
              .toList();
        });
      } else {
        setState(() => _error = 'Failed to load users');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _hasActiveAccess(Map<String, dynamic> user) {
    final access = user['access'] ?? user['subscription'];
    if (access == null) return false;
    final expiresAt = access['expires_at'] ?? access['expiresAt'];
    if (expiresAt == null) return false;
    return DateTime.tryParse(expiresAt.toString())?.isAfter(DateTime.now()) ?? false;
  }

  bool _isExpired(Map<String, dynamic> user) {
    final access = user['access'] ?? user['subscription'];
    if (access == null) return false;
    final expiresAt = access['expires_at'] ?? access['expiresAt'];
    if (expiresAt == null) return false;
    final date = DateTime.tryParse(expiresAt.toString());
    return date != null && date.isBefore(DateTime.now());
  }

  String _expiryDate(Map<String, dynamic> user) {
    final access = user['access'] ?? user['subscription'];
    if (access == null) return '';
    final raw = (access['expires_at'] ?? access['expiresAt'] ?? '').toString();
    return raw.isNotEmpty ? raw.split('T')[0] : '';
  }

  String _tier(Map<String, dynamic> user) {
    final access = user['access'] ?? user['subscription'];
    if (access == null) return '';
    return (access['tier'] ?? access['payment_tier'] ?? '').toString().replaceAll('_', ' ');
  }

  List<Map<String, dynamic>> _getTiers(String lang, AppLocalizations l10n) {
    if (lang == 'rw') {
      return [
        {'tier': '1_MONTH', 'price': 1500, 'label': l10n.subscriptionMonth1},
        {'tier': '3_MONTHS', 'price': 3000, 'label': l10n.subscriptionMonth3},
        {'tier': '6_MONTHS', 'price': 5000, 'label': l10n.subscriptionMonth6},
      ];
    }
    return [
      {'tier': '1_MONTH', 'price': 3000, 'label': l10n.subscriptionMonth1},
      {'tier': '3_MONTHS', 'price': 5000, 'label': l10n.subscriptionMonth3},
      {'tier': '6_MONTHS', 'price': 10000, 'label': l10n.subscriptionMonth6},
    ];
  }

  void _showRenewSheet(Map<String, dynamic> user, AppLocalizations l10n) {
    final userId = (user['id'] ?? '').toString();
    final lang = (user['preferredLanguage'] ?? user['preferred_language'] ?? 'en').toString().toLowerCase();
    final tiers = _getTiers(lang, l10n);
    String? selectedTier;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.adminSelectTier, style: AppTextStyles.heading5),
              const SizedBox(height: 14),
              ...tiers.map((tier) {
                final isSelected = selectedTier == tier['tier'];
                return GestureDetector(
                  onTap: () => setSheetState(() => selectedTier = tier['tier'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.neutral300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? AppColors.primary.withOpacity(0.08) : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tier['label'] as String, style: AppTextStyles.bodyMedium),
                        Text(
                          l10n.subscriptionPrice(tier['price'] as int),
                          style: AppTextStyles.heading6.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: selectedTier == null
                    ? null
                    : () {
                        Navigator.of(ctx).pop();
                        _renewAccess(userId, selectedTier!, l10n);
                      },
                child: Text(l10n.adminGrantAccess),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _renewAccess(String userId, String tier, AppLocalizations l10n) async {
    setState(() => _loadingMap[userId] = true);
    try {
      final token = await AuthSession().getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/users/$userId/grant-access'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'tier': tier}),
      ).timeout(const Duration(seconds: 15));

      if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminAccessGranted), backgroundColor: AppColors.success),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _loadingMap.remove(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminAccess),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(_error!, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
                    ],
                  ),
                )
              : _subscribed.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.subscriptions_outlined, size: 64, color: AppColors.neutral400),
                          const SizedBox(height: 16),
                          Text(
                            l10n.adminNoAccess,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _subscribed.length,
                        itemBuilder: (context, index) {
                          final user = _subscribed[index];
                          final userId = (user['id'] ?? '').toString();
                          final name = (user['name'] ?? user['fullName'] ?? 'Unknown').toString();
                          final phone = (user['phoneNumber'] ?? user['phone_number'] ?? '').toString();
                          final lang = (user['preferredLanguage'] ?? user['preferred_language'] ?? 'en').toString().toLowerCase();
                          final active = _hasActiveAccess(user);
                          final expired = _isExpired(user);
                          final expiry = _expiryDate(user);
                          final tierLabel = _tier(user);
                          final isUserLoading = _loadingMap[userId] ?? false;

                          Color statusColor;
                          String statusText;
                          if (active) {
                            statusColor = AppColors.success;
                            statusText = l10n.adminHasAccess;
                          } else if (expired) {
                            statusColor = AppColors.warning;
                            statusText = l10n.adminAccessExpired;
                          } else {
                            statusColor = AppColors.error;
                            statusText = l10n.adminNoAccess;
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User info
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppColors.primary.withOpacity(0.15),
                                        radius: 20,
                                        child: Text(
                                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                                          style: AppTextStyles.heading6.copyWith(color: AppColors.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name, style: AppTextStyles.heading6),
                                            Text(
                                              phone,
                                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          _langChip(lang),
                                          const SizedBox(height: 4),
                                          _StatusBadge(text: statusText, color: statusColor),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // Subscription details
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        if (tierLabel.isNotEmpty)
                                          _DetailRow(
                                            icon: Icons.card_membership,
                                            label: l10n.adminTierLabel,
                                            value: tierLabel.toUpperCase(),
                                          ),
                                        if (expiry.isNotEmpty)
                                          _DetailRow(
                                            icon: active ? Icons.event_available : Icons.event_busy,
                                            label: active ? l10n.adminExpiresLabel : l10n.adminAccessExpired,
                                            value: expiry,
                                            valueColor: active ? AppColors.success : AppColors.warning,
                                          ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Renew/extend button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: isUserLoading
                                          ? null
                                          : () => _showRenewSheet(user, l10n),
                                      icon: isUserLoading
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textInverse),
                                            )
                                          : const Icon(Icons.refresh, size: 16),
                                      label: Text(l10n.adminRenewAccess),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: active ? AppColors.primary : AppColors.success,
                                        foregroundColor: AppColors.textInverse,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _langChip(String lang) {
    const emojis = {'rw': '🇷🇼', 'fr': '🇫🇷', 'en': '🇬🇧'};
    return Text(emojis[lang] ?? '🇬🇧', style: const TextStyle(fontSize: 16));
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
