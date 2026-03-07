import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isOffline = false;
  List<dynamic> _users = [];
  int _totalPractices = 0;
  String? _error;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  static const _cacheKey = 'admin_dashboard_cache';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isOffline = false;
    });

    // Load from cache first for instant display
    await _loadFromCache();

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
        final users = (data is List) ? data : (data['users'] ?? data['data'] ?? []);
        // Cache for offline use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, json.encode({'users': users, 'ts': DateTime.now().toIso8601String()}));
        setState(() {
          _users = users;
          _totalPractices = _computeTotalPractices(users);
        });
        _animController.forward(from: 0);
      } else {
        setState(() => _error = 'HTTP ${response.statusCode}');
      }
    } catch (_) {
      // Network error — already showing cached data
      setState(() => _isOffline = true);
      if (_users.isEmpty) setState(() => _error = 'No network. No cached data available.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final decoded = json.decode(raw);
        final users = decoded['users'] ?? [];
        if (mounted) {
          setState(() {
            _users = users;
            _totalPractices = _computeTotalPractices(users);
          });
          _animController.forward(from: 0);
        }
      }
    } catch (_) {}
  }

  int _computeTotalPractices(List users) {
    // Sum practice attempts across all users if the field exists
    int total = 0;
    for (final u in users) {
      total += (u['practiceCount'] ?? u['practice_count'] ?? 0) as int;
    }
    // Return 0 when the backend doesn't expose per-user practice counts yet;
    // the field will be populated once the API supports it.
    return total;
  }

  int get _totalUsers => _users.length;

  int get _activeSubscriptions => _users.where((u) {
        final access = u['access'] ?? u['subscription'];
        if (access == null) return false;
        final exp = access['expires_at'] ?? access['expiresAt'];
        if (exp == null) return false;
        return DateTime.tryParse(exp.toString())?.isAfter(DateTime.now()) ?? false;
      }).length;

  int get _recentRegistrations {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _users.where((u) {
      final c = u['created_at'] ?? u['createdAt'];
      if (c == null) return false;
      return DateTime.tryParse(c.toString())?.isAfter(cutoff) ?? false;
    }).length;
  }

  Map<String, int> get _usersByLanguage {
    final Map<String, int> counts = {'rw': 0, 'en': 0, 'fr': 0};
    for (final u in _users) {
      final lang = (u['preferredLanguage'] ?? u['preferred_language'] ?? 'en')
          .toString()
          .toLowerCase();
      counts[counts.containsKey(lang) ? lang : 'en'] =
          (counts[counts.containsKey(lang) ? lang : 'en'] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated ? authState.user.name : '';
    final userInitial = userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : 'A';

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context, l10n, userName, userInitial, innerBoxIsScrolled),
        ],
        body: _buildBody(context, l10n),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    AppLocalizations l10n,
    String userName,
    String userInitial,
    bool innerBoxIsScrolled,
  ) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      floating: false,
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        l10n.adminDashboard,
        style: const TextStyle(color: AppColors.textInverse, fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      actions: [
        // Offline indicator
        if (_isOffline)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Tooltip(
              message: 'Offline – showing cached data',
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('OFFLINE', style: TextStyle(color: AppColors.textInverse, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textInverse),
          onPressed: _loadData,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.textInverse),
          onPressed: () {},
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradientFor(Theme.of(context).brightness)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textInverse.withValues(alpha: 0.25),
                      border: Border.all(color: AppColors.textInverse.withValues(alpha: 0.5), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        userInitial,
                        style: const TextStyle(
                          color: AppColors.textInverse,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeWelcomeBack,
                          style: TextStyle(color: AppColors.textInverse.withValues(alpha: 0.8), fontSize: 13),
                        ),
                        Text(
                          userName.isNotEmpty ? userName : 'Admin',
                          style: const TextStyle(
                            color: AppColors.textInverse,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Active subs badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: AppColors.textInverse, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$_activeSubscriptions active',
                          style: const TextStyle(color: AppColors.textInverse, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    if (_isLoading && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: AppColors.neutral400),
              const SizedBox(height: 16),
              Text(_error!, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Platform banner card ─────────────────────────────────
              _buildPlatformCard(context, l10n),
              const SizedBox(height: 24),

              // ── Admin Actions ────────────────────────────────────────
              _sectionHeader(l10n.adminActionsTitle),
              const SizedBox(height: 12),
              _buildActionsGrid(context, l10n),
              const SizedBox(height: 24),

              // ── Quick Stats ──────────────────────────────────────────
              _sectionHeader(l10n.adminQuickStats),
              const SizedBox(height: 12),
              _buildQuickStats(l10n),
              const SizedBox(height: 24),

              // ── Language breakdown ───────────────────────────────────
              _sectionHeader(l10n.adminUsersByLanguage),
              const SizedBox(height: 12),
              _buildLanguageBreakdown(l10n),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Platform banner card
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPlatformCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradientFor(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.adminDashboard,
                  style: AppTextStyles.heading5.copyWith(color: AppColors.textInverse),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.adminManagePlatformDesc,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textInverse.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/admin/users'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textInverse,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.adminManagePlatform,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              _decorIcon(Icons.people, AppColors.textInverse),
              const SizedBox(height: 8),
              _decorIcon(Icons.quiz, AppColors.textInverse),
              const SizedBox(height: 8),
              _decorIcon(Icons.key, AppColors.textInverse),
            ],
          ),
        ],
      ),
    );
  }

  Widget _decorIcon(IconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Admin Actions grid — 3 actions (NO Courses)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildActionsGrid(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // Row 1: Manage Users | Access Codes
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.people,
                title: l10n.adminManageUsers,
                description: l10n.adminManageUsersDesc,
                gradientColors: [AppColors.primary, AppColors.primaryLight],
                onTap: () => context.push('/admin/users'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.key_rounded,
                title: l10n.adminAccess,
                description: l10n.adminAccessCodesDesc,
                gradientColors: [AppColors.success, const Color(0xFF4ADE80)],
                onTap: () => context.push('/admin/access'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Manage Exams (full width — primary action)
        _ActionCardWide(
          icon: Icons.quiz_rounded,
          title: l10n.adminManageExams,
          description: l10n.adminManageExamsDesc,
          accentColor: AppColors.accent,
          onTap: () => context.push('/admin/progress'),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Quick Stats
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildQuickStats(AppLocalizations l10n) {
    final byLang = _usersByLanguage;
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.people,
            value: '$_totalUsers',
            label: l10n.adminTotalUsers,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.quiz_outlined,
            value: '$_totalPractices',
            label: l10n.adminTotalPractices,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Language breakdown mini-bar
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildLanguageBreakdown(AppLocalizations l10n) {
    final byLang = _usersByLanguage;
    final total = _totalUsers > 0 ? _totalUsers : 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          _LangRow(flag: '��🇼', lang: 'Kinyarwanda', count: byLang['rw']!, total: total, color: AppColors.primary),
          const SizedBox(height: 10),
          _LangRow(flag: '🇬🇧', lang: 'English', count: byLang['en']!, total: total, color: AppColors.accent),
          const SizedBox(height: 10),
          _LangRow(flag: '🇫🇷', lang: 'Français', count: byLang['fr']!, total: total, color: AppColors.success),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.heading5,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Supporting widgets
// ══════════════════════════════════════════════════════════════════════════════

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.textInverse.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.textInverse, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textInverse,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: AppColors.textInverse.withValues(alpha: 0.8),
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCardWide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final VoidCallback onTap;

  const _ActionCardWide({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.3), blurRadius: 8)],
              ),
              child: Icon(icon, color: AppColors.textInverse, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading6,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: accentColor),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LangRow extends StatelessWidget {
  final String flag;
  final String lang;
  final int count;
  final int total;
  final Color color;

  const _LangRow({
    required this.flag,
    required this.lang,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        Text(flag, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        SizedBox(
          width: 72,
          child: Text(lang, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.1),
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
