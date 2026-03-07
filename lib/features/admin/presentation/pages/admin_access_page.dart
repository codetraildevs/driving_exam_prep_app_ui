import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/network/api_config.dart';
import '../../../../shared/session/auth_session.dart';

/// Access Management page — shows ALL users so admin can grant, renew, or
/// revoke access with a tier selection or custom duration.
class AdminAccessPage extends StatefulWidget {
  const AdminAccessPage({Key? key}) : super(key: key);

  @override
  State<AdminAccessPage> createState() => _AdminAccessPageState();
}

class _AdminAccessPageState extends State<AdminAccessPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _pendingUsers = [];
  String? _error;
  final Map<String, bool> _loadingMap = {};
  String _filter = 'all'; // 'all' | 'active' | 'pending' | 'none'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await AuthSession().getToken();
      final headers = {if (token != null) 'Authorization': 'Bearer $token'};

      final results = await Future.wait([
        http
            .get(Uri.parse('${ApiConfig.baseUrl}/api/admin/users?limit=100'),
                headers: headers)
            .timeout(const Duration(seconds: 15)),
        http
            .get(Uri.parse('${ApiConfig.baseUrl}/api/payments'),
                headers: headers)
            .timeout(const Duration(seconds: 15)),
      ]);

      final usersResp = results[0];
      final paymentsResp = results[1];

      if (usersResp.statusCode == 200) {
        final data = json.decode(usersResp.body);
        final users = (data is List)
            ? List<dynamic>.from(data)
            : List<dynamic>.from(data['users'] ?? data['data'] ?? []);

        final Set<String> pendingUserIds = {};
        if (paymentsResp.statusCode == 200) {
          final pData = json.decode(paymentsResp.body);
          final payments = (pData is List)
              ? pData
              : (pData['payments'] ?? pData['data'] ?? []);
          for (final p in payments) {
            if ((p['status'] ?? '').toString().toUpperCase() == 'PENDING') {
              final uid = (p['userId'] ?? p['user_id'] ?? '').toString();
              if (uid.isNotEmpty) pendingUserIds.add(uid);
            }
          }
        }

        final allUsers = users
            .map((u) => Map<String, dynamic>.from(u as Map))
            .toList();

        for (final u in allUsers) {
          u['_hasPendingRequest'] =
              pendingUserIds.contains((u['id'] ?? '').toString());
        }

        setState(() {
          _allUsers = allUsers;
          _pendingUsers = allUsers
              .where((u) => u['_hasPendingRequest'] == true)
              .toList();
        });
      } else {
        setState(() => _error =
            '${usersResp.statusCode}: ${_extractMessage(usersResp.body)}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _extractMessage(String body) {
    try {
      final d = json.decode(body);
      return (d['message'] ?? d['error'] ?? body).toString();
    } catch (_) {
      return body;
    }
  }

  bool _hasActiveAccess(Map<String, dynamic> user) {
    final access = user['access'] ?? user['subscription'];
    if (access != null) {
      final exp = access['expires_at'] ?? access['expiresAt'];
      if (exp != null) {
        return DateTime.tryParse(exp.toString())?.isAfter(DateTime.now()) ??
            false;
      }
    }
    final exp = user['accessExpiresAt'];
    if (exp != null) {
      return DateTime.tryParse(exp.toString())?.isAfter(DateTime.now()) ?? false;
    }
    return (user['hasActiveAccess'] ?? 0) == 1;
  }

  bool _isExpired(Map<String, dynamic> user) {
    final access = user['access'] ?? user['subscription'];
    String? exp;
    if (access != null) {
      exp = (access['expires_at'] ?? access['expiresAt'])?.toString();
    }
    exp ??= user['accessExpiresAt']?.toString();
    if (exp == null || exp.isEmpty) return false;
    final date = DateTime.tryParse(exp);
    return date != null && date.isBefore(DateTime.now());
  }

  String _expiryDate(Map<String, dynamic> user) {
    final access = user['access'] ?? user['subscription'];
    String? raw;
    if (access != null) {
      raw = (access['expires_at'] ?? access['expiresAt'])?.toString();
    }
    raw ??= user['accessExpiresAt']?.toString();
    if (raw == null || raw.isEmpty) return '';
    return raw.split('T')[0];
  }

  String _tier(Map<String, dynamic> user) {
    final access = user['access'] ?? user['subscription'];
    if (access != null) {
      return (access['tier'] ?? access['payment_tier'] ?? '')
          .toString()
          .replaceAll('_', ' ');
    }
    return (user['paymentTier'] ?? '').toString().replaceAll('_', ' ');
  }

  List<Map<String, dynamic>> get _filteredUsers {
    switch (_filter) {
      case 'active':
        return _allUsers.where(_hasActiveAccess).toList();
      case 'pending':
        return _pendingUsers;
      case 'none':
        return _allUsers
            .where((u) => !_hasActiveAccess(u) && !_isExpired(u))
            .toList();
      default:
        return _allUsers;
    }
  }

  List<Map<String, dynamic>> _getTiers(AppLocalizations l10n) => [
        {'tier': '1_MONTH', 'durationDays': 30, 'price': 3000, 'label': l10n.subscriptionMonth1},
        {'tier': '3_MONTHS', 'durationDays': 90, 'price': 5000, 'label': l10n.subscriptionMonth3},
        {'tier': '6_MONTHS', 'durationDays': 180, 'price': 10000, 'label': l10n.subscriptionMonth6},
      ];

  void _showGrantSheet(Map<String, dynamic> user, AppLocalizations l10n) {
    final userId = (user['id'] ?? '').toString();
    final name = (user['name'] ?? user['fullName'] ?? 'Unknown').toString();
    final tiers = _getTiers(l10n);

    String? selectedTier;
    bool useCustom = false;
    final daysCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String? sheetError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.vpn_key_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l10n.adminGrantAccess}: $name',
                        style: AppTextStyles.heading6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (sheetError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(sheetError!, style: const TextStyle(color: AppColors.error)),
                  ),
                  const SizedBox(height: 8),
                ],

                Row(
                  children: [
                    Text(l10n.adminSelectTier, style: AppTextStyles.labelMedium),
                    const Spacer(),
                    TextButton.icon(
                      icon: Icon(useCustom ? Icons.list_alt_rounded : Icons.tune_rounded, size: 16),
                      label: Text(
                        useCustom ? l10n.adminSelectTier : l10n.adminOrCustom,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => setSheet(() {
                        useCustom = !useCustom;
                        selectedTier = null;
                        daysCtrl.clear();
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (!useCustom) ...[
                  ...tiers.map((tier) {
                    final sel = selectedTier == tier['tier'];
                    return GestureDetector(
                      onTap: () => setSheet(() {
                        selectedTier = tier['tier'] as String;
                        amountCtrl.text = (tier['price'] as int).toString();
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: sel ? AppColors.primaryGradient : null,
                          color: sel ? null : Theme.of(ctx).colorScheme.surface,
                          border: Border.all(
                            color: sel ? AppColors.primary : Theme.of(ctx).colorScheme.outline.withOpacity(0.4),
                            width: sel ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              sel ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: sel ? AppColors.textInverse : AppColors.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              tier['label'] as String,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: sel ? AppColors.textInverse : null,
                                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              l10n.subscriptionPrice(tier['price'] as int),
                              style: AppTextStyles.heading6.copyWith(
                                color: sel ? AppColors.textInverse : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ] else ...[
                  TextField(
                    controller: daysCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.adminCustomDays,
                      hintText: l10n.adminEnterDays,
                      prefixIcon: const Icon(Icons.date_range),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 4),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.adminPaymentAmount,
                    hintText: l10n.adminEnterAmount,
                    prefixIcon: const Icon(Icons.payments_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l10n.adminGrantAccess),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textInverse,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;
                    if (amount <= 0) {
                      setSheet(() => sheetError = l10n.adminInvalidAmount);
                      return;
                    }
                    if (useCustom) {
                      final days = int.tryParse(daysCtrl.text.trim()) ?? 0;
                      if (days <= 0) {
                        setSheet(() => sheetError = l10n.adminInvalidDays);
                        return;
                      }
                      Navigator.of(ctx).pop();
                      _grantAccess(userId, null, days, amount, l10n);
                    } else {
                      if (selectedTier == null) {
                        setSheet(() => sheetError = l10n.adminSelectTier);
                        return;
                      }
                      Navigator.of(ctx).pop();
                      _grantAccess(userId, selectedTier, 0, amount, l10n);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _grantAccess(
    String userId, String? tier, int customDays, int amount, AppLocalizations l10n,
  ) async {
    setState(() => _loadingMap[userId] = true);
    try {
      final token = await AuthSession().getToken();
      final body = <String, dynamic>{'paymentAmount': amount};
      if (tier != null && tier.isNotEmpty) {
        body['paymentTier'] = tier;
      } else {
        body['durationDays'] = customDays;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/users/$userId/grant-access'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminAccessGranted), backgroundColor: AppColors.success),
        );
        _loadData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_extractMessage(response.body)), backgroundColor: AppColors.error),
        );
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: l10n.adminFilterAll,
                  selected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                  count: _allUsers.length,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.adminPendingRequests,
                  selected: _filter == 'pending',
                  onTap: () => setState(() => _filter = 'pending'),
                  count: _pendingUsers.length,
                  accentColor: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.adminHasAccess,
                  selected: _filter == 'active',
                  onTap: () => setState(() => _filter = 'active'),
                  count: _allUsers.where(_hasActiveAccess).length,
                  accentColor: AppColors.success,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.adminNoAccess,
                  selected: _filter == 'none',
                  onTap: () => setState(() => _filter = 'none'),
                  count: _allUsers.where((u) => !_hasActiveAccess(u) && !_isExpired(u)).length,
                  accentColor: AppColors.error,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError(l10n)
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Text(
                              l10n.adminNoUsers,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (ctx, i) => _buildUserCard(_filteredUsers[i], l10n),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
              onPressed: _loadData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, AppLocalizations l10n) {
    final userId = (user['id'] ?? '').toString();
    final name = (user['name'] ?? user['fullName'] ?? 'Unknown').toString();
    final phone = (user['phoneNumber'] ?? user['phone_number'] ?? '').toString();
    final lang = (user['preferredLanguage'] ?? user['preferred_language'] ?? 'en').toString().toLowerCase();
    final active = _hasActiveAccess(user);
    final expired = _isExpired(user);
    final expiry = _expiryDate(user);
    final tierLabel = _tier(user);
    final hasPending = user['_hasPendingRequest'] == true;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: hasPending
            ? BorderSide(color: AppColors.warning.withOpacity(0.6), width: 1.5)
            : BorderSide.none,
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasPending)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, color: AppColors.warning, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      l10n.adminPendingRequests,
                      style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.heading6),
                      Text(phone, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _LangChip(lang: lang),
                    const SizedBox(height: 4),
                    _StatusBadge(text: statusText, color: statusColor),
                  ],
                ),
              ],
            ),

            if (tierLabel.isNotEmpty || expiry.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (tierLabel.isNotEmpty)
                      _DetailRow(icon: Icons.card_membership, label: l10n.adminTierLabel, value: tierLabel.toUpperCase()),
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
            ],

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUserLoading ? null : () => _showGrantSheet(user, l10n),
                icon: isUserLoading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textInverse))
                    : Icon(active ? Icons.refresh_rounded : Icons.vpn_key_rounded),
                label: Text(active ? l10n.adminRenewAccess : l10n.adminGrantAccess),
                style: ElevatedButton.styleFrom(
                  backgroundColor: active ? AppColors.primary : AppColors.success,
                  foregroundColor: AppColors.textInverse,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int count;
  final Color accentColor;

  const _FilterChip({
    required this.label, required this.selected, required this.onTap,
    required this.count, this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accentColor : accentColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? accentColor : accentColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : accentColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withOpacity(0.25) : accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? Colors.white : accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String lang;
  const _LangChip({required this.lang});

  @override
  Widget build(BuildContext context) {
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
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
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
          Text(value, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}
