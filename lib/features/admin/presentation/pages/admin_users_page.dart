import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/network/api_config.dart';
import '../../../../shared/session/auth_session.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  bool _isLoading = true;
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  final Map<String, bool> _loadingMap = {};

  static const List<String> _filters = ['all', 'hasAccess', 'noAccess', 'rw', 'en', 'fr'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        setState(() {
          _allUsers = (data is List) ? data : (data['users'] ?? data['data'] ?? []);
        });
        _applyFilters();
      } else {
        setState(() => _error = 'Failed to load users');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        final name = (u['name'] ?? u['fullName'] ?? '').toString().toLowerCase();
        final phone = (u['phoneNumber'] ?? u['phone_number'] ?? '').toString().toLowerCase();
        final lang = (u['preferredLanguage'] ?? u['preferred_language'] ?? 'en').toString().toLowerCase();
        final hasAccess = _hasActiveAccess(u);

        final matchesSearch = query.isEmpty || name.contains(query) || phone.contains(query);
        bool matchesFilter = true;
        if (_selectedFilter == 'hasAccess') matchesFilter = hasAccess;
        if (_selectedFilter == 'noAccess') matchesFilter = !hasAccess;
        if (_selectedFilter == 'rw') matchesFilter = lang == 'rw';
        if (_selectedFilter == 'en') matchesFilter = lang == 'en';
        if (_selectedFilter == 'fr') matchesFilter = lang == 'fr';

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  bool _hasActiveAccess(Map u) {
    final access = u['access'] ?? u['subscription'];
    if (access == null) return false;
    final expiresAt = access['expires_at'] ?? access['expiresAt'];
    if (expiresAt == null) return false;
    return DateTime.tryParse(expiresAt.toString())?.isAfter(DateTime.now()) ?? false;
  }

  String _langEmoji(String lang) {
    switch (lang.toLowerCase()) {
      case 'rw': return '🇷🇼';
      case 'fr': return '🇫🇷';
      default: return '🇬🇧';
    }
  }

  String _filterLabel(String filter, AppLocalizations l10n) {
    switch (filter) {
      case 'hasAccess': return l10n.adminFilterHasAccess;
      case 'noAccess': return l10n.adminFilterNoAccess;
      case 'rw': return '🇷🇼 RW';
      case 'en': return '🇬🇧 EN';
      case 'fr': return '🇫🇷 FR';
      default: return l10n.adminFilterAll;
    }
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

  void _showGrantAccessSheet(Map user, AppLocalizations l10n) {
    final userId = (user['id'] ?? '').toString();
    final name = (user['name'] ?? user['fullName'] ?? 'Unknown').toString();
    final lang = (user['preferredLanguage'] ?? user['preferred_language'] ?? 'en').toString().toLowerCase();
    final tiers = _getTiers(lang, l10n);
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
                    final isSelected = selectedTier == tier['tier'];
                    return GestureDetector(
                      onTap: () => setSheet(() {
                        selectedTier = tier['tier'] as String;
                        amountCtrl.text = (tier['price'] as int).toString();
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.primaryGradient : null,
                          color: isSelected ? null : Theme.of(ctx).colorScheme.surface,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.neutral300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? AppColors.textInverse : AppColors.textSecondary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tier['label'] as String,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isSelected ? AppColors.textInverse : null,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ]),
                            Text(
                              l10n.subscriptionPrice(tier['price'] as int),
                              style: AppTextStyles.heading6.copyWith(
                                color: isSelected ? AppColors.textInverse : AppColors.primary,
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
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.adminCallUser, style: AppTextStyles.heading5),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: l10n.adminEnterCallNotes,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
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
        _loadUsers();
      } else if (mounted) {
        String msg = l10n.commonError;
        try {
          final d = json.decode(response.body);
          msg = (d['message'] ?? d['error'] ?? msg).toString();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
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
          SnackBar(content: Text(l10n.adminCallLogged), backgroundColor: AppColors.success),
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
      appBar: AppBar(
        title: Text(l10n.adminUsers),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.adminSearchUsers,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter chips
          Container(
            color: Theme.of(context).colorScheme.surface,
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filterLabel(filter, l10n)),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedFilter = filter);
                      _applyFilters();
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ),

          // Users list
          Expanded(
            child: _isLoading
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
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index] as Map;
                            final name = (user['name'] ?? user['fullName'] ?? 'Unknown').toString();
                            final phone = (user['phoneNumber'] ?? user['phone_number'] ?? '').toString();
                            final lang = (user['preferredLanguage'] ?? user['preferred_language'] ?? 'en').toString().toLowerCase();
                            final createdAt = (user['created_at'] ?? user['createdAt'] ?? '').toString().split('T')[0];
                            final hasAccess = _hasActiveAccess(user);
                            final userId = (user['id'] ?? '').toString();
                            final isUserLoading = _loadingMap[userId] ?? false;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // User info row
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => context.push('/admin/users/$userId/profile'),
                                          child: CircleAvatar(
                                            backgroundColor: AppColors.primary.withOpacity(0.15),
                                            radius: 22,
                                            child: Text(
                                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                                              style: AppTextStyles.heading6.copyWith(color: AppColors.primary),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => context.push('/admin/users/$userId/profile'),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(name, style: AppTextStyles.heading6),
                                                Text(phone, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                                                if (createdAt.isNotEmpty)
                                                  Text(
                                                    l10n.adminRegistrationDate(createdAt),
                                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(_langEmoji(lang), style: const TextStyle(fontSize: 18)),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: hasAccess
                                                    ? AppColors.success.withOpacity(0.15)
                                                    : AppColors.error.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                hasAccess ? l10n.adminHasAccess : l10n.adminNoAccess,
                                                style: TextStyle(
                                                  color: hasAccess ? AppColors.success : AppColors.error,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Action buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: isUserLoading
                                                ? null
                                                : () => _showGrantAccessSheet(user, l10n),
                                            icon: const Icon(Icons.key, size: 15),
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
                                            icon: const Icon(Icons.phone, size: 15),
                                            label: Text(l10n.adminCallUser, style: const TextStyle(fontSize: 12)),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.primary,
                                              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          onPressed: () => context.push('/admin/users/$userId/profile'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: const Icon(Icons.person, size: 16),
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
          ),
        ],
      ),
    );
  }
}
