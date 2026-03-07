import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/network/api_config.dart';
import '../../../../shared/session/auth_session.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = true;
  List<dynamic> _users = [];
  String? _error;

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
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/users'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = (data is List) ? data : (data['users'] ?? data['data'] ?? []);
        });
      } else {
        setState(() => _error = 'Failed to load data');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int get _totalUsers => _users.length;

  int get _activeSubscriptions => _users.where((u) {
        final access = u['access'] ?? u['subscription'];
        if (access == null) return false;
        final expiresAt = access['expires_at'] ?? access['expiresAt'];
        if (expiresAt == null) return false;
        return DateTime.tryParse(expiresAt.toString())?.isAfter(DateTime.now()) ?? false;
      }).length;

  int get _recentRegistrations {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _users.where((u) {
      final created = u['created_at'] ?? u['createdAt'];
      if (created == null) return false;
      return DateTime.tryParse(created.toString())?.isAfter(cutoff) ?? false;
    }).length;
  }

  Map<String, int> get _usersByLanguage {
    final Map<String, int> counts = {'rw': 0, 'en': 0, 'fr': 0};
    for (final u in _users) {
      final lang = (u['preferredLanguage'] ?? u['preferred_language'] ?? 'en').toString().toLowerCase();
      if (counts.containsKey(lang)) {
        counts[lang] = (counts[lang] ?? 0) + 1;
      } else {
        counts['en'] = (counts['en'] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated ? authState.user.name : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Welcome header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.adminDashboard,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (userName.isNotEmpty)
                                Text(
                                  userName,
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Stats grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.4,
                          children: [
                            _StatCard(
                              title: l10n.adminTotalUsers,
                              value: '$_totalUsers',
                              icon: Icons.people,
                              color: AppColors.primary,
                            ),
                            _StatCard(
                              title: l10n.adminActiveSubscriptions,
                              value: '$_activeSubscriptions',
                              icon: Icons.verified,
                              color: AppColors.success,
                            ),
                            _StatCard(
                              title: l10n.adminRecentRegistrations,
                              value: '$_recentRegistrations',
                              icon: Icons.person_add,
                              color: AppColors.warning,
                            ),
                            _StatCard(
                              title: l10n.adminUsersByLanguage,
                              value: '🇷🇼${_usersByLanguage['rw']} 🇬🇧${_usersByLanguage['en']} 🇫🇷${_usersByLanguage['fr']}',
                              icon: Icons.language,
                              color: AppColors.primaryLight,
                              isSmallText: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Quick actions
                        Text(l10n.homeServices, style: AppTextStyles.heading5),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.people,
                                label: l10n.adminManageUsers,
                                color: AppColors.primary,
                                onTap: () => context.push('/admin/users'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.key,
                                label: l10n.adminManageAccess,
                                color: AppColors.success,
                                onTap: () => context.push('/admin/access'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.assessment,
                                label: l10n.adminViewProgress,
                                color: AppColors.warning,
                                onTap: () => context.push('/admin/progress'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isSmallText;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isSmallText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: isSmallText
                ? AppTextStyles.labelMedium.copyWith(color: color, fontWeight: FontWeight.bold)
                : AppTextStyles.heading4.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
