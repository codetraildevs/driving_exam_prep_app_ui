import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/network/api_config.dart';
import '../../../../shared/session/auth_session.dart';

class AdminAccessPage extends StatefulWidget {
  const AdminAccessPage({Key? key}) : super(key: key);

  @override
  State<AdminAccessPage> createState() => _AdminAccessPageState();
}

class _AdminAccessPageState extends State<AdminAccessPage> {
  bool _isLoading = true;
  List<dynamic> _users = [];
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
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = (data is List) ? data : (data['users'] ?? data['data'] ?? []);
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

  bool _hasActiveAccess(Map user) {
    final access = user['access'] ?? user['subscription'];
    if (access == null) return false;
    final expiresAt = access['expires_at'] ?? access['expiresAt'];
    if (expiresAt == null) return false;
    return DateTime.tryParse(expiresAt.toString())?.isAfter(DateTime.now()) ?? false;
  }

  bool _isExpired(Map user) {
    final access = user['access'] ?? user['subscription'];
    if (access == null) return false;
    final expiresAt = access['expires_at'] ?? access['expiresAt'];
    if (expiresAt == null) return false;
    final date = DateTime.tryParse(expiresAt.toString());
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  String _getExpiryDate(Map user) {
    final access = user['access'] ?? user['subscription'];
    if (access == null) return '';
    final expiresAt = access['expires_at'] ?? access['expiresAt'];
    if (expiresAt == null) return '';
    return expiresAt.toString().split('T')[0];
  }

  List<Map<String, dynamic>> _getTiers(String langCode, AppLocalizations l10n) {
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

  void _showGrantAccessSheet(Map user, AppLocalizations l10n) {
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
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.adminSelectTier, style: AppTextStyles.heading5),
              const SizedBox(height: 16),
              ...tiers.map((tier) {
                final isSelected = selectedTier == tier['tier'];
                return GestureDetector(
                  onTap: () => setSheetState(() => selectedTier = tier['tier'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.neutral300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedTier == null
                    ? null
                    : () {
                        Navigator.of(ctx).pop();
                        _grantAccess(userId, selectedTier!, l10n);
                      },
                child: Text(l10n.adminGrantAccess),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCallSheet(Map user, AppLocalizations l10n) {
    final userId = (user['id'] ?? '').toString();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.adminCallUser, style: AppTextStyles.heading5),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: l10n.adminEnterCallNotes,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _markCalled(userId, notesController.text, l10n);
              },
              child: Text(l10n.adminSubmitCall),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _grantAccess(String userId, String tier, AppLocalizations l10n) async {
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.adminAccessGranted),
              backgroundColor: AppColors.success,
            ),
          );
          _loadUsers();
        }
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

  Future<void> _markCalled(String userId, String notes, AppLocalizations l10n) async {
    try {
      final token = await AuthSession().getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/users/$userId/mark-called'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'notes': notes}),
      ).timeout(const Duration(seconds: 15));

      if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminCallLogged),
            backgroundColor: AppColors.success,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.adminAccess),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
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
                      ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index] as Map;
                      final userId = (user['id'] ?? '').toString();
                      final name = (user['name'] ?? user['fullName'] ?? 'Unknown').toString();
                      final phone = (user['phoneNumber'] ?? user['phone_number'] ?? '').toString();
                      final lang = (user['preferredLanguage'] ?? user['preferred_language'] ?? 'en').toString().toLowerCase();
                      final hasAccess = _hasActiveAccess(user);
                      final isExpired = _isExpired(user);
                      final expiryDate = _getExpiryDate(user);
                      final lastCalled = user['last_called_at'] ?? user['lastCalledAt'];
                      final isUserLoading = _loadingMap[userId] ?? false;

                      Color statusColor = AppColors.error;
                      String statusText = l10n.adminNoAccess;
                      if (hasAccess) {
                        statusColor = AppColors.success;
                        statusText = l10n.adminHasAccess;
                      } else if (isExpired) {
                        statusColor = AppColors.warning;
                        statusText = l10n.adminAccessExpired;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                        Text(phone, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (expiryDate.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  l10n.adminAccessExpires(expiryDate),
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                                ),
                              ],
                              if (lastCalled != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.adminLastCalled}: ${lastCalled.toString().split('T')[0]}',
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: isUserLoading
                                          ? null
                                          : () => _showGrantAccessSheet(user, l10n),
                                      icon: const Icon(Icons.key, size: 16),
                                      label: Text(l10n.adminGrantAccess, style: const TextStyle(fontSize: 12)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.success,
                                        side: BorderSide(color: AppColors.success.withOpacity(0.5)),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showCallSheet(user, l10n),
                                      icon: const Icon(Icons.phone, size: 16),
                                      label: Text(l10n.adminCallUser, style: const TextStyle(fontSize: 12)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
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
}
