import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/network/api_config.dart';
import '../../../../shared/session/auth_session.dart';

class AdminUserProfilePage extends StatefulWidget {
  final String userId;

  const AdminUserProfilePage({required this.userId, Key? key}) : super(key: key);

  @override
  State<AdminUserProfilePage> createState() => _AdminUserProfilePageState();
}

class _AdminUserProfilePageState extends State<AdminUserProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await AuthSession().getToken();
      // Fetch all users and find this one (or use specific endpoint if available)
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
          _user = found != null ? Map<String, dynamic>.from(found) : null;
          if (_user == null) _error = 'User not found';
        });
      } else {
        setState(() => _error = 'Failed to load user');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _hasActiveAccess() {
    if (_user == null) return false;
    final access = _user!['access'] ?? _user!['subscription'];
    if (access == null) return false;
    final expiresAt = access['expires_at'] ?? access['expiresAt'];
    if (expiresAt == null) return false;
    return DateTime.tryParse(expiresAt.toString())?.isAfter(DateTime.now()) ?? false;
  }

  String _langEmoji(String lang) {
    switch (lang.toLowerCase()) {
      case 'rw': return '🇷🇼 Kinyarwanda';
      case 'fr': return '🇫🇷 French';
      default: return '🇬🇧 English';
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
        _loadUser();
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
        _loadUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showGrantAccessSheet(AppLocalizations l10n) {
    final lang = (_user!['preferredLanguage'] ?? _user!['preferred_language'] ?? 'en').toString().toLowerCase();
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.profileTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _user == null
              ? Center(child: Text(_error ?? 'User not found', style: AppTextStyles.bodyMedium))
              : _buildProfile(context, l10n),
    );
  }

  Widget _buildProfile(BuildContext context, AppLocalizations l10n) {
    final user = _user!;
    final name = (user['name'] ?? user['fullName'] ?? 'Unknown').toString();
    final phone = (user['phoneNumber'] ?? user['phone_number'] ?? '').toString();
    final role = (user['role'] ?? 'USER').toString();
    final lang = (user['preferredLanguage'] ?? user['preferred_language'] ?? 'en').toString().toLowerCase();
    final createdAt = (user['created_at'] ?? user['createdAt'] ?? '').toString().split('T')[0];
    final hasAccess = _hasActiveAccess();
    final access = user['access'] ?? user['subscription'];
    final expiryDate = access != null
        ? (access['expires_at'] ?? access['expiresAt'] ?? '').toString().split('T')[0]
        : '';
    final lastCalled = user['last_called_at'] ?? user['lastCalledAt'];
    final callNotes = user['call_notes'] ?? user['callNotes'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar + basic info
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
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
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
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Info card
          _InfoCard(children: [
            _InfoRow(icon: Icons.phone, label: l10n.authPhoneNumber, value: phone),
            _InfoRow(icon: Icons.language, label: l10n.profileLanguage, value: _langEmoji(lang)),
            if (createdAt.isNotEmpty)
              _InfoRow(icon: Icons.calendar_today, label: l10n.profileRegistered(createdAt), value: ''),
          ]),
          const SizedBox(height: 16),

          // Access status
          _InfoCard(title: l10n.profileAccessStatus, children: [
            _InfoRow(
              icon: hasAccess ? Icons.check_circle : Icons.cancel,
              label: hasAccess ? l10n.adminHasAccess : l10n.adminNoAccess,
              value: expiryDate.isNotEmpty ? l10n.adminAccessExpires(expiryDate) : '',
              valueColor: hasAccess ? AppColors.success : AppColors.error,
            ),
          ]),
          const SizedBox(height: 16),

          // Call history
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
            const SizedBox(height: 16),
          ],

          // Admin actions
          Text(l10n.adminDashboard, style: AppTextStyles.heading5),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showGrantAccessSheet(l10n),
                  icon: const Icon(Icons.key),
                  label: Text(l10n.adminGrantAccess),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
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
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _InfoCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
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

  const _InfoRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))),
          if (value.isNotEmpty)
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}
