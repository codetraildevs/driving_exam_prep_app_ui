import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/offline_cache.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import '../../../../shared/session/auth_session.dart';
import '../../../../shared/subscription/subscription_notifier.dart';
import '../../../../shared/widgets/app_menu_button.dart';

class ProfilePage extends StatefulWidget {
  /// When [userId] is provided, admin is viewing another user's profile.
  /// When null, shows the currently logged-in user's own profile.
  final String? userId;

  const ProfilePage({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Only used when viewing another user (admin flow)
  Map<String, dynamic>? _targetUser;
  bool _loadingTarget = false;
  String? _loadError;

  // Dynamic progress for own profile
  int _uniqueExamsPassed = 0;
  static const _kTotalExams = 20;
  static const _kPassPercent = 90;

  bool get _isAdminView => widget.userId != null;

  @override
  void initState() {
    super.initState();
    if (_isAdminView) {
      _loadTargetUser();
    } else {
      _loadProgress();
    }
  }

  /// Load exam results to compute certificate progress.
  Future<void> _loadProgress() async {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;
    if (userId == null) return;

    final cache = OfflineCache();
    final cacheKey = cache.examResultsKey(userId);
    List<dynamic> results = [];

    try {
      final res = await ApiHelper().get('/api/exam-results/$userId');
      if (res.isSuccess) {
        results = res.dataList;
        await cache.save(cacheKey, results);
      } else {
        final cached = await cache.load(cacheKey);
        if (cached is List) results = cached;
      }
    } catch (_) {
      final cached = await cache.load(cacheKey);
      if (cached is List) results = cached;
    }

    // Deduplicate: latest attempt per examId
    final unique = <String, Map<String, dynamic>>{};
    for (final r in results) {
      if (r is! Map<String, dynamic>) continue;
      final eid = (r['examId'] ?? '').toString();
      if (eid.isEmpty || unique.containsKey(eid)) continue;
      unique[eid] = r;
    }
    final passed = unique.values.where((r) {
      final s = r['score'];
      final score = s is int ? s : int.tryParse(s?.toString() ?? '') ?? 0;
      return score >= _kPassPercent;
    }).length;

    if (mounted) setState(() => _uniqueExamsPassed = passed);
  }

  Future<void> _loadTargetUser() async {
    setState(() {
      _loadingTarget = true;
      _loadError = null;
    });
    try {
      final result = await ApiHelper().get('/api/admin/users');
      if (result.isSuccess) {
        final data = result.data;
        final users = (data is List)
            ? data
            : (data['users'] ?? data['data'] ?? []);
        final found = users.firstWhere(
          (u) => u['id']?.toString() == widget.userId,
          orElse: () => null,
        );
        setState(() {
          _targetUser = found != null ? Map<String, dynamic>.from(found) : null;
          if (_targetUser == null) _loadError = 'User not found';
        });
      } else if (result.statusCode == 401) {
        if (mounted) {
          await AuthSession().clear();
          if (mounted) context.go('/login');
        }
        return;
      } else {
        setState(
          () => _loadError = result.errorMessage ?? 'Failed to load user',
        );
      }
    } catch (e) {
      setState(() => _loadError = e.toString());
    } finally {
      setState(() => _loadingTarget = false);
    }
  }

  Future<void> _grantAccess(String tier, AppLocalizations l10n) async {
    try {
      final result = await ApiHelper().post(
        '/api/admin/users/${widget.userId}/grant-access',
        body: {'tier': tier},
      );

      if (result.statusCode == 401 && mounted) {
        await AuthSession().clear();
        if (mounted) context.go('/login');
        return;
      }

      if (result.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminAccessGranted),
            backgroundColor: AppColors.success,
          ),
        );
        _loadTargetUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _markCalled(String notes, AppLocalizations l10n) async {
    try {
      final result = await ApiHelper().post(
        '/api/admin/users/${widget.userId}/mark-called',
        body: {'notes': notes},
      );

      if (result.statusCode == 401 && mounted) {
        await AuthSession().clear();
        if (mounted) context.go('/login');
        return;
      }

      if (result.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminCallLogged),
            backgroundColor: AppColors.success,
          ),
        );
        _loadTargetUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showGrantAccessSheet(AppLocalizations l10n, String lang) {
    final primary = Theme.of(context).colorScheme.primary;
    final tiers = lang == 'rw'
        ? [
            {
              'tier': '1_MONTH',
              'price': 1500,
              'label': l10n.subscriptionMonth1,
            },
            {
              'tier': '3_MONTHS',
              'price': 3000,
              'label': l10n.subscriptionMonth3,
            },
            {
              'tier': '6_MONTHS',
              'price': 5000,
              'label': l10n.subscriptionMonth6,
            },
          ]
        : [
            {
              'tier': '1_MONTH',
              'price': 3000,
              'label': l10n.subscriptionMonth1,
            },
            {
              'tier': '3_MONTHS',
              'price': 5000,
              'label': l10n.subscriptionMonth3,
            },
            {
              'tier': '6_MONTHS',
              'price': 10000,
              'label': l10n.subscriptionMonth6,
            },
          ];
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
              const SizedBox(height: 12),
              ...tiers.map((tier) {
                final isSelected = selectedTier == tier['tier'];
                return GestureDetector(
                  onTap: () => setSheetState(
                    () => selectedTier = tier['tier'] as String,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? primary : AppColors.neutral300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? primary.withValues(alpha: 0.08)
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tier['label'] as String,
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          l10n.subscriptionPrice(tier['price'] as int),
                          style: AppTextStyles.heading6.copyWith(
                            color: primary,
                          ),
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
                        _grantAccess(selectedTier!, l10n);
                      },
                child: Text(l10n.adminGrantAccess),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callUserDirect(AppLocalizations l10n) async {
    final phone =
        (_targetUser?['phoneNumber'] ?? _targetUser?['phone_number'] ?? '')
            .toString();
    if (phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    // Mark as called in backend
    _markCalled('', l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    if (_isAdminView) {
      if (_loadingTarget) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text(l10n.profileTitle),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      if (_loadError != null || _targetUser == null) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text(l10n.profileTitle),
          ),
          body: Center(child: Text(_loadError ?? 'User not found')),
        );
      }
      return _buildAdminUserProfile(context, l10n, _targetUser!);
    }

    // Own profile view
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = state.user;
          final screenWidth = MediaQuery.of(context).size.width;
          // Comfortable reading width on desktop; phone-fill on mobile.
          final maxContentWidth = isDesktop(context)
              ? AppContentWidths.compact
              : (screenWidth > AppBreakpoints.tablet
                    ? AppContentWidths.tablet
                    : double.infinity);

          final topPadding = MediaQuery.of(context).padding.top;
          return Column(
            children: [
              // Curved gradient header with avatar
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradientFor(
                    Theme.of(context).brightness,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Title row
                    Row(
                      children: [
                        // Hamburger opens the desktop drawer; hidden on
                        // mobile where bottom navigation is used.
                        const SizedBox(
                          width: 48,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AppMenuButton(),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              l10n.profileTitle,
                              style: AppTextStyles.heading5.copyWith(
                                color: AppColors.textInverse,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Avatar
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          user.name.trim().isNotEmpty
                              ? user.name.trim()[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textInverse,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.name,
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role,
                        style: const TextStyle(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textInverse,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.profileLocation,
                          style: TextStyle(
                            color: AppColors.textInverse.withValues(
                              alpha: 0.85,
                            ),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),

                          // Info card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // _InfoRow(
                                //   icon: Icons.phone,
                                //   label: l10n,
                                //   value: user.phoneNumber,
                                // ),
                                _InfoRow(
                                  icon: Icons.calendar_today,
                                  label: l10n.profileRegistered(
                                    user.createdAt.toLocal().toString().split(
                                      ' ',
                                    )[0],
                                  ),
                                  value: '',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Progress card
                          Builder(
                            builder: (context) {
                              final passed = _uniqueExamsPassed;
                              const total = _kTotalExams;
                              final pct = total > 0
                                  ? (passed / total).clamp(0.0, 1.0)
                                  : 0.0;
                              final pctInt = (pct * 100).toInt();
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: primary.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            l10n.profileOverallProgress,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$pctInt%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        minHeight: 10,
                                        backgroundColor: primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        color: primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.profileModulesCompleted(
                                        passed,
                                        total,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          Text(
                            l10n.profileAccount,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          _menuTile(
                            context: context,
                            icon: Icons.settings,
                            title: l10n.profileSettings,
                            subtitle: l10n.profileSettingsSubtitle,
                            onTap: () => context.push('/settings'),
                          ),

                          const SizedBox(height: 8),
                          _menuTile(
                            context: context,
                            icon: Icons.verified_rounded,
                            title: l10n.profileCertificatesTitle,
                            subtitle: l10n.profileCertificatesSubtitle,
                            onTap: () => context.push('/certificates'),
                          ),
                          const SizedBox(height: 8),
                          // Subscription tile — always visible so users can
                          // view their active access status or request access.
                          Consumer(
                            builder: (context, ref, _) {
                              final sub = ref.watch(subscriptionProvider);
                              return _menuTile(
                                context: context,
                                icon: sub.hasActiveAccess
                                    ? Icons.verified_outlined
                                    : Icons.lock_open_outlined,
                                title: sub.hasActiveAccess
                                    ? l10n.subscriptionAccessActive
                                    : l10n.subscriptionTitle,
                                subtitle:
                                    sub.hasActiveAccess && sub.expiresAt != null
                                    ? l10n.subscriptionExpires(
                                        sub.expiresAt!
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0],
                                      )
                                    : l10n.subscriptionSubtitle,
                                onTap: () => context.push('/subscription'),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          ListTile(
                            onTap: () => _showDeleteDialog(context, l10n),
                            leading: const Icon(
                              Icons.delete_forever,
                              color: AppColors.error,
                            ),
                            title: Text(
                              l10n.profileDeleteAccount,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          ListTile(
                            onTap: () => _showLogoutDialog(context, l10n),
                            leading: const Icon(
                              Icons.logout,
                              color: AppColors.error,
                            ),
                            title: Text(
                              l10n.profileSignOut,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Admin-only view of a specific user's profile
  Widget _buildAdminUserProfile(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, dynamic> user,
  ) {
    final name = (user['name'] ?? user['fullName'] ?? 'Unknown').toString();
    final phone = (user['phoneNumber'] ?? user['phone_number'] ?? '')
        .toString();
    final role = (user['role'] ?? 'USER').toString();
    final lang =
        (user['preferredLanguage'] ?? user['preferred_language'] ?? 'en')
            .toString()
            .toLowerCase();
    final createdAt = (user['created_at'] ?? user['createdAt'] ?? '')
        .toString()
        .split('T')[0];

    final access = user['access'] ?? user['subscription'];
    final expiresAt = access != null
        ? (access['expires_at'] ?? access['expiresAt'] ?? '').toString()
        : '';
    final expiryDate = expiresAt.isNotEmpty ? expiresAt.split('T')[0] : '';
    final hasAccess =
        expiryDate.isNotEmpty &&
        (DateTime.tryParse(expiresAt)?.isAfter(DateTime.now()) ?? false);
    final isExpired =
        expiryDate.isNotEmpty &&
        (DateTime.tryParse(expiresAt)?.isBefore(DateTime.now()) ?? false);

    final lastCalled = user['last_called_at'] ?? user['lastCalledAt'];
    final callNotes = user['call_notes'] ?? user['callNotes'];

    final langDisplay = _langLabel(lang);
    final primary = Theme.of(context).colorScheme.primary;
    final statusText = hasAccess
        ? l10n.adminHasAccess
        : isExpired
        ? l10n.adminAccessExpired
        : l10n.adminNoAccess;
    final statusColor = hasAccess
        ? AppColors.success
        : isExpired
        ? AppColors.warning
        : AppColors.error;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.profileTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar + name + role
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradientFor(
                        Theme.of(context).brightness,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textInverse,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: AppTextStyles.heading4),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      role,
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact & language info
            _InfoCard(
              children: [
                _InfoRow(
                  icon: Icons.phone,
                  label: l10n.authPhoneNumber,
                  value: phone,
                ),
                _InfoRow(
                  icon: Icons.language,
                  label: l10n.profileLanguage,
                  value: langDisplay,
                ),
                if (createdAt.isNotEmpty)
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: l10n.profileRegistered(createdAt),
                    value: '',
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Access status
            _InfoCard(
              title: l10n.profileAccessStatus,
              children: [
                _InfoRow(
                  icon: hasAccess ? Icons.check_circle : Icons.cancel,
                  label: statusText,
                  value: expiryDate.isNotEmpty
                      ? l10n.adminAccessExpires(expiryDate)
                      : '',
                  valueColor: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Call history (if any)
            if (lastCalled != null) ...[
              _InfoCard(
                title: l10n.profileCallHistory,
                children: [
                  _InfoRow(
                    icon: Icons.phone_callback,
                    label: l10n.adminLastCalled,
                    value: lastCalled.toString().split('T')[0],
                  ),
                  if (callNotes != null && callNotes.toString().isNotEmpty)
                    _InfoRow(
                      icon: Icons.notes,
                      label: l10n.adminCallNotes,
                      value: callNotes.toString(),
                    ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            // Admin action buttons
            Text(l10n.adminDashboard, style: AppTextStyles.heading5),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showGrantAccessSheet(l10n, lang),
                    icon: const Icon(Icons.key),
                    label: Text(l10n.adminGrantAccess),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.textInverse,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callUserDirect(l10n),
                    icon: const Icon(Icons.phone),
                    label: Text(l10n.adminCallUser),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _langLabel(String lang) {
    switch (lang) {
      case 'rw':
        return '🇷🇼 Kinyarwanda';
      case 'fr':
        return '🇫🇷 French';
      default:
        return '🇬🇧 English';
    }
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.profileDeleteConfirmTitle,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  l10n.profileDeleteInstructions,
                  style: TextStyle(fontSize: 13, height: 1.6, color: textColor),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.profileDeleteConfirmMessage,
                style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                Navigator.pop(ctx);
                context.read<AuthBloc>().add(
                  DeleteAccountEvent(userId: authState.user.id),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.profileDelete),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    final primary = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppColors.warning, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.profileLogoutConfirmTitle,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.profileLogoutConfirmMessage,
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const SignOutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.profileSignOut),
          ),
        ],
      ),
    );
  }

  static Widget _menuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        tileColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.05),
          ),
        ),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// ── Shared helper widgets ──────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _InfoCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (value.isNotEmpty)
            Flexible(
              child: Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.textPrimary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}
