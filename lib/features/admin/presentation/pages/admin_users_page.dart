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
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.adminUsers),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.surface,
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
            color: AppColors.surface,
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
                            final createdAt = user['created_at'] ?? user['createdAt'] ?? '';
                            final hasAccess = _hasActiveAccess(user);
                            final userId = (user['id'] ?? '').toString();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                onTap: () => context.push('/admin/users/$userId/profile'),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.2),
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                                    style: AppTextStyles.heading6.copyWith(color: AppColors.primary),
                                  ),
                                ),
                                title: Text(name, style: AppTextStyles.heading6),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(phone, style: AppTextStyles.bodySmall),
                                    if (createdAt.isNotEmpty)
                                      Text(
                                        l10n.adminRegistrationDate(createdAt.toString().split('T')[0]),
                                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_langEmoji(lang), style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                isThreeLine: true,
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
