import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../shared/network/api_config.dart';
import '../../../../shared/session/auth_session.dart';
import '../../../../shared/subscription/subscription_provider.dart';

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

  bool get _isAdminView => widget.userId != null;

  @override
  void initState() {
    super.initState();
    if (_isAdminView) _loadTargetUser();
  }

  Future<void> _loadTargetUser() async {
    setState(() {
      _loadingTarget = true;
      _loadError = null;
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
        final users = (data is List) ? data : (data['users'] ?? data['data'] ?? []);
        final found = users.firstWhere(
          (u) => u['id']?.toString() == widget.userId,
          orElse: () => null,
        );
        setState(() {
          _targetUser = found != null ? Map<String, dynamic>.from(found) : null;
          if (_targetUser == null) _loadError = 'User not found';
        });
      } else {
        setState(() => _loadError = 'Failed to load user');
      }
    } catch (e) {
      setState(() => _loadError = e.toString());
    } finally {
      setState(() => _loadingTarget = false);
    }
  }

  Future<void> _grantAccess(String tier, AppLocalizations l10n) async {
    try {
      final token = await AuthSession().getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/users/${widget.userId}/grant-access'),
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
        _loadTargetUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _markCalled(String notes, AppLocalizations l10n) async {
    try {
      final token = await AuthSession().getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/users/${widget.userId}/mark-called'),
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
        _loadTargetUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showGrantAccessSheet(AppLocalizations l10n, String lang) {
    final tiers = lang == 'rw'
        ? [
            {'tier': '1_MONTH', 'price': 1500, 'label': l10n.subscriptionMonth1},
            {'tier': '3_MONTHS', 'price': 3000, 'label': l10n.subscriptionMonth3},
            {'tier': '6_MONTHS', 'price': 5000, 'label': l10n.subscriptionMonth6},
          ]
        : [
            {'tier': '1_MONTH', 'price': 3000, 'label': l10n.subscriptionMonth1},
            {'tier': '3_MONTHS', 'price': 5000, 'label': l10n.subscriptionMonth3},
            {'tier': '6_MONTHS', 'price': 10000, 'label': l10n.subscriptionMonth6},
          ];
    String? selectedTier;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
              const SizedBox(height: 12),
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

  void _showCallSheet(AppLocalizations l10n) {
    final notesController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                _markCalled(notesController.text, l10n);
              },
              child: Text(l10n.adminSubmitCall),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Admin view: loading another user's data
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
          final maxContentWidth = screenWidth > 600 ? 500.0 : double.infinity;

          return SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.primary.withOpacity(0.1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.go('/home'),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            l10n.profileTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
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
                            // Avatar
                            Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.primaryGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.name.trim().isNotEmpty
                                          ? user.name.trim()[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textInverse,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(user.name, style: AppTextStyles.heading3),
                                const SizedBox(height: 6),
                                // Role badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.role,
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.profileLocation,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // Info card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primary.withOpacity(0.05)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _InfoRow(
                                    icon: Icons.phone,
                                    label: l10n.authPhoneNumber,
                                    value: user.phoneNumber,
                                  ),
                                  _InfoRow(
                                    icon: Icons.calendar_today,
                                    label: l10n.profileRegistered(user.createdAt.toLocal().toString().split(' ')[0]),
                                    value: '',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Progress card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primary.withOpacity(0.05)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          l10n.profileOverallProgress,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const Text(
                                        '75%',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: LinearProgressIndicator(
                                      value: 0.75,
                                      minHeight: 10,
                                      backgroundColor: AppColors.primary.withOpacity(0.1),
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.profileModulesCompleted(15, 20),
                                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                  ),
                                ],
                              ),
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
                              icon: Icons.settings,
                              title: l10n.profileSettings,
                              subtitle: l10n.profileSettingsSubtitle,
                              onTap: () => context.push('/settings'),
                            ),

                            const SizedBox(height: 8),

                            // Subscription tile — always visible so users can
                            // view their active access status or request access.
                            Builder(builder: (context) {
                              final sub = context.watch<SubscriptionProvider>();
                              return _menuTile(
                                icon: sub.hasActiveAccess
                                    ? Icons.verified_outlined
                                    : Icons.lock_open_outlined,
                                title: sub.hasActiveAccess
                                    ? l10n.subscriptionAccessActive
                                    : l10n.subscriptionTitle,
                                subtitle: sub.hasActiveAccess && sub.expiresAt != null
                                    ? l10n.subscriptionExpires(
                                        sub.expiresAt!.toLocal().toString().split(' ')[0],
                                      )
                                    : l10n.subscriptionSubtitle,
                                onTap: () => context.push('/subscription'),
                              );
                            }),

                            const SizedBox(height: 20),

                            ListTile(
                              onTap: () => _showDeleteDialog(context, l10n),
                              leading: const Icon(Icons.delete_forever, color: AppColors.error),
                              title: Text(
                                l10n.profileDeleteAccount,
                                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                              ),
                            ),

                            ListTile(
                              onTap: () => _showLogoutDialog(context, l10n),
                              leading: const Icon(Icons.logout, color: AppColors.error),
                              title: Text(
                                l10n.profileSignOut,
                                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    final phone = (user['phoneNumber'] ?? user['phone_number'] ?? '').toString();
    final role = (user['role'] ?? 'USER').toString();
    final lang = (user['preferredLanguage'] ?? user['preferred_language'] ?? 'en')
        .toString()
        .toLowerCase();
    final createdAt =
        (user['created_at'] ?? user['createdAt'] ?? '').toString().split('T')[0];

    final access = user['access'] ?? user['subscription'];
    final expiresAt = access != null
        ? (access['expires_at'] ?? access['expiresAt'] ?? '').toString()
        : '';
    final expiryDate = expiresAt.isNotEmpty ? expiresAt.split('T')[0] : '';
    final hasAccess = expiryDate.isNotEmpty &&
        (DateTime.tryParse(expiresAt)?.isAfter(DateTime.now()) ?? false);
    final isExpired = expiryDate.isNotEmpty &&
        (DateTime.tryParse(expiresAt)?.isBefore(DateTime.now()) ?? false);

    final lastCalled = user['last_called_at'] ?? user['lastCalledAt'];
    final callNotes = user['call_notes'] ?? user['callNotes'];

    final langDisplay = _langLabel(lang);
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
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        color: AppColors.primary,
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
            _InfoCard(children: [
              _InfoRow(icon: Icons.phone, label: l10n.authPhoneNumber, value: phone),
              _InfoRow(icon: Icons.language, label: l10n.profileLanguage, value: langDisplay),
              if (createdAt.isNotEmpty)
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: l10n.profileRegistered(createdAt),
                  value: '',
                ),
            ]),
            const SizedBox(height: 14),

            // Access status
            _InfoCard(title: l10n.profileAccessStatus, children: [
              _InfoRow(
                icon: hasAccess ? Icons.check_circle : Icons.cancel,
                label: statusText,
                value: expiryDate.isNotEmpty ? l10n.adminAccessExpires(expiryDate) : '',
                valueColor: statusColor,
              ),
            ]),
            const SizedBox(height: 14),

            // Call history (if any)
            if (lastCalled != null) ...[
              _InfoCard(title: l10n.profileCallHistory, children: [
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
              ]),
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
                    onPressed: () => _showCallSheet(l10n),
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
      case 'rw': return '🇷🇼 Kinyarwanda';
      case 'fr': return '🇫🇷 French';
      default: return '🇬🇧 English';
    }
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.profileDeleteConfirmTitle)),
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
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Text(
                  l10n.profileDeleteInstructions,
                  style: const TextStyle(fontSize: 13, height: 1.6),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.profileDeleteConfirmMessage,
                style: const TextStyle(fontWeight: FontWeight.w500),
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
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const SignOutEvent());
              context.go('/landing');
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppColors.warning, size: 26),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.profileLogoutConfirmTitle)),
          ],
        ),
        content: Text(l10n.profileLogoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const SignOutEvent());
              context.go('/landing');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.profileSignOut),
          ),
        ],
      ),
    );
  }

  static Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
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
        boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
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
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
