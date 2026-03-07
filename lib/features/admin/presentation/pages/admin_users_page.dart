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
  List<dynamic> _users = [];
  int _totalUsers = 0;
  String? _error;
  final _searchCtrl = TextEditingController();
  String _accessFilter = 'all';
  String _sortDir = 'DESC';
  String _roleFilter = '';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _todayOnly = false;
  int _page = 1;
  static const _limit = 10;
  final _loadingMap = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _page = 1;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await AuthSession().getToken();
      final qp = <String, String>{
        'page': '$_page',
        'limit': '$_limit',
        'sortDir': _sortDir,
        if (_searchCtrl.text.isNotEmpty) 'search': _searchCtrl.text,
        if (_accessFilter == 'hasAccess') 'hasAccess': 'true',
        if (_accessFilter == 'noAccess') 'hasAccess': 'false',
        if (_roleFilter.isNotEmpty) 'role': _roleFilter,
        if (_todayOnly) 'today': '1',
        if (!_todayOnly && _dateFrom != null)
          'dateFrom': _dateFrom!.toIso8601String().split('T')[0],
        if (!_todayOnly && _dateTo != null)
          'dateTo': _dateTo!.toIso8601String().split('T')[0],
      };
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/users')
          .replace(queryParameters: qp);
      final response = await http
          .get(uri, headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          })
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = (data is List)
              ? data
              : (data['users'] ?? data['data'] ?? []);
          _totalUsers = (data is Map)
              ? (data['total'] ?? _users.length)
              : _users.length;
        });
      } else {
        setState(() => _error = 'HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _blockUser(
      String userId, bool currentlyBlocked, AppLocalizations l10n) async {
    final newStatus = currentlyBlocked ? 1 : 0;
    setState(() => _loadingMap[userId] = true);
    try {
      final token = await AuthSession().getToken();
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/users/$userId/block'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'isActive': newStatus}),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        _showSnack(
          context,
          currentlyBlocked ? l10n.adminUserUnblocked : l10n.adminUserBlocked,
          AppColors.success,
        );
        _loadUsers();
      } else {
        _showSnack(context, 'HTTP ${response.statusCode}', AppColors.error);
      }
    } catch (e) {
      _showSnack(context, e.toString(), AppColors.error);
    } finally {
      setState(() => _loadingMap.remove(userId));
    }
  }

  Future<void> _deleteUser(
      String userId, String name, AppLocalizations l10n) async {
    setState(() => _loadingMap[userId] = true);
    try {
      final token = await AuthSession().getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/users/$userId'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        _showSnack(context, l10n.adminUserDeleted, AppColors.success);
        _loadUsers();
      } else {
        final body = json.decode(response.body);
        final code = body['code'] ?? '';
        if (code == 'BLOCK_FIRST') {
          _showSnack(context, l10n.adminMustBlockFirst, AppColors.warning);
        } else {
          _showSnack(
            context,
            body['error'] ?? 'HTTP ${response.statusCode}',
            AppColors.error,
          );
        }
      }
    } catch (e) {
      _showSnack(context, e.toString(), AppColors.error);
    } finally {
      setState(() => _loadingMap.remove(userId));
    }
  }

  Future<void> _markCalled(
      String userId, String notes, AppLocalizations l10n) async {
    setState(() => _loadingMap[userId] = true);
    try {
      final token = await AuthSession().getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/users/$userId/mark-called'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'notes': notes}),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack(context, l10n.adminCallLogged, AppColors.success);
        _loadUsers();
      } else {
        _showSnack(context, 'HTTP ${response.statusCode}', AppColors.error);
      }
    } catch (e) {
      _showSnack(context, e.toString(), AppColors.error);
    } finally {
      setState(() => _loadingMap.remove(userId));
    }
  }

  void _showSnack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────────

  void _showBlockConfirm(BuildContext ctx, Map user, AppLocalizations l10n) {
    final id = (user['id'] ?? '').toString();
    final name = (user['fullName'] ?? user['name'] ?? '').toString();
    final isActive = _isActiveUser(user);
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(isActive ? l10n.adminBlockUser : l10n.adminUnblockUser),
        content: Text(isActive
            ? l10n.adminBlockUserConfirm(name)
            : '${l10n.adminUnblockUser} $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _blockUser(id, !isActive, l10n);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppColors.error : AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: Text(isActive ? l10n.adminBlockUser : l10n.adminUnblockUser),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext ctx, Map user, AppLocalizations l10n) {
    final id = (user['id'] ?? '').toString();
    final name = (user['fullName'] ?? user['name'] ?? '').toString();
    final isActive = _isActiveUser(user);

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 26),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.adminDeleteUserAction)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isActive)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(l10n.adminMustBlockFirst,
                            style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
            if (!isActive)
              Text(l10n.adminDeleteUserConfirm(name)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          if (!isActive)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _deleteUser(id, name, l10n);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.adminDeleteUserAction),
            ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext ctx, Map user, AppLocalizations l10n) {
    final id = (user['id'] ?? '').toString();
    final notesCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(l10n.adminCallUser),
        content: TextField(
          controller: notesCtrl,
          decoration:
              InputDecoration(hintText: l10n.adminEnterCallNotes),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _markCalled(id, notesCtrl.text, l10n);
            },
            child: Text(l10n.adminSubmitCall),
          ),
        ],
      ),
    );
  }

  void _showGrantSheet(Map user, AppLocalizations l10n) {
    final userId = (user['id'] ?? '').toString();
    final lang = (user['preferredLanguage'] ?? 'en').toString();
    final tiers = _getTiers(lang, l10n);
    String? selectedTier = tiers.first['tier'] as String;
    bool customMode = false;
    final daysCtrl = TextEditingController();
    final amtCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  left: 20, right: 20, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.adminSelectTier,
                      style: AppTextStyles.heading6),
                  const SizedBox(height: 12),
                  if (!customMode)
                    ...tiers.map((t) {
                      final isSelected = selectedTier == t['tier'];
                      return RadioListTile<String>(
                        value: t['tier'] as String,
                        groupValue: selectedTier,
                        title: Text(t['label'] as String),
                        subtitle: Text(
                            '${t['price']} RWF'),
                        onChanged: (v) =>
                            setModal(() => selectedTier = v),
                        selected: isSelected,
                      );
                    }).toList(),
                  const SizedBox(height: 4),
                  CheckboxListTile(
                    value: customMode,
                    title: Text(l10n.adminOrCustom),
                    onChanged: (v) =>
                        setModal(() => customMode = v ?? false),
                    dense: true,
                  ),
                  if (customMode) ...[
                    TextField(
                      controller: daysCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: l10n.adminEnterDays),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextField(
                    controller: amtCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: l10n.adminPaymentAmount),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        _submitGrant(ctx, userId, selectedTier, customMode,
                            daysCtrl.text, amtCtrl.text, l10n),
                    child: Text(l10n.adminAccessGranted),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
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

  Future<void> _submitGrant(
    BuildContext ctx,
    String userId,
    String? tier,
    bool customMode,
    String daysText,
    String amtText,
    AppLocalizations l10n,
  ) async {
    final amount = int.tryParse(amtText) ?? 0;
    if (amount <= 0) {
      _showSnack(ctx, l10n.adminInvalidAmount, AppColors.error);
      return;
    }
    final body = <String, dynamic>{'paymentAmount': amount};
    if (customMode) {
      final d = int.tryParse(daysText) ?? 0;
      if (d <= 0) {
        _showSnack(ctx, l10n.adminInvalidDays, AppColors.error);
        return;
      }
      body['durationDays'] = d;
    } else {
      body['paymentTier'] = tier ?? '';
    }
    setState(() => _loadingMap[userId] = true);
    try {
      final token = await AuthSession().getToken();
      final response = await http.post(
        Uri.parse(
            '${ApiConfig.baseUrl}/api/admin/users/$userId/grant-access'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));
      if (mounted) Navigator.pop(ctx);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack(context, l10n.adminAccessGranted, AppColors.success);
        _loadUsers();
      } else {
        _showSnack(context, 'HTTP ${response.statusCode}', AppColors.error);
      }
    } catch (e) {
      _showSnack(context, e.toString(), AppColors.error);
    } finally {
      setState(() => _loadingMap.remove(userId));
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  bool _hasActiveAccess(Map u) {
    final expires = (u['accessExpiresAt'] ?? u['access']?['expiresAt'])
        ?.toString();
    if (expires == null) return false;
    return DateTime.tryParse(expires)?.isAfter(DateTime.now()) ?? false;
  }

  bool _isActiveUser(Map u) {
    final v = u['isActive'];
    return v == true || v == 1 || v == '1' || v == 'true';
  }

  int get _totalPages => (_totalUsers / _limit).ceil().clamp(1, 9999);

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminUsers),
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
          // ── Search bar ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: l10n.adminSearchUsers,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // ── Filter row ───────────────────────────────────────────────
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _chip(l10n.adminFilterAll, 'all' == _accessFilter, () {
                  setState(() => _accessFilter = 'all');
                  _page = 1;
                  _loadUsers();
                }),
                const SizedBox(width: 6),
                _chip(l10n.adminFilterHasAccess, _accessFilter == 'hasAccess',
                    () {
                  setState(() => _accessFilter = 'hasAccess');
                  _page = 1;
                  _loadUsers();
                }),
                const SizedBox(width: 6),
                _chip(l10n.adminFilterNoAccess, _accessFilter == 'noAccess',
                    () {
                  setState(() => _accessFilter = 'noAccess');
                  _page = 1;
                  _loadUsers();
                }),
                const SizedBox(width: 6),
                _chip('👑 Admin', _roleFilter == 'ADMIN', () {
                  setState(() => _roleFilter =
                      _roleFilter == 'ADMIN' ? '' : 'ADMIN');
                  _page = 1;
                  _loadUsers();
                }),
                const SizedBox(width: 6),
                _chip('👤 User', _roleFilter == 'USER', () {
                  setState(() =>
                      _roleFilter = _roleFilter == 'USER' ? '' : 'USER');
                  _page = 1;
                  _loadUsers();
                }),
                const SizedBox(width: 6),
                _chip(l10n.adminFilterToday, _todayOnly, () {
                  setState(() {
                    _todayOnly = !_todayOnly;
                    if (_todayOnly) {
                      _dateFrom = null;
                      _dateTo = null;
                    }
                  });
                  _page = 1;
                  _loadUsers();
                }),
              ],
            ),
          ),

          // ── Sort + Date range row ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => _sortDir =
                        _sortDir == 'DESC' ? 'ASC' : 'DESC');
                    _page = 1;
                    _loadUsers();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _sortDir == 'DESC'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _sortDir == 'DESC'
                              ? l10n.adminSortDesc
                              : l10n.adminSortAsc,
                          style: const TextStyle(
                              color: AppColors.primary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!_todayOnly)
                  GestureDetector(
                    onTap: () => _pickDateRange(context, l10n),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (_dateFrom != null)
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.date_range, size: 14,
                              color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            _dateFrom != null
                                ? '${_dateFrom!.toIso8601String().split('T')[0]} – ${_dateTo?.toIso8601String().split('T')[0] ?? '...'}'
                                : l10n.adminDateRange,
                            style: const TextStyle(
                                color: AppColors.primary, fontSize: 12),
                          ),
                          if (_dateFrom != null) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _dateFrom = null;
                                  _dateTo = null;
                                });
                                _page = 1;
                                _loadUsers();
                              },
                              child: const Icon(Icons.close,
                                  size: 14, color: AppColors.primary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  '${l10n.adminTotalUsers}: $_totalUsers',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // ── User list ────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(_error!,
                                style: AppTextStyles.bodyMedium,
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              child: Text(l10n.commonRetry),
                            ),
                          ],
                        ),
                      )
                    : _users.isEmpty
                        ? Center(child: Text(l10n.adminNoUsers))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                            itemCount: _users.length,
                            itemBuilder: (ctx, i) =>
                                _UserCard(
                                  user: _users[i] as Map,
                                  isLoading: _loadingMap[
                                          (_users[i] as Map)['id']?.toString() ?? ''] ??
                                      false,
                                  onCall: () => _showCallDialog(
                                      ctx, _users[i] as Map, l10n),
                                  onGrant: () =>
                                      _showGrantSheet(_users[i] as Map, l10n),
                                  onBlock: () => _showBlockConfirm(
                                      ctx, _users[i] as Map, l10n),
                                  onDelete: () => _showDeleteConfirm(
                                      ctx, _users[i] as Map, l10n),
                                  onProfile: () {
                                    final id = (_users[i] as Map)['id']
                                        ?.toString() ?? '';
                                    context
                                        .push('/admin/users/$id/profile');
                                  },
                                  l10n: l10n,
                                ),
                          ),
          ),

          // ── Pagination ───────────────────────────────────────────────
          if (!_isLoading && _error == null && _totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _page > 1
                        ? () {
                            setState(() => _page--);
                            _loadUsers();
                          }
                        : null,
                  ),
                  Text(
                    l10n.adminPage(_page, _totalPages),
                    style: AppTextStyles.labelMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _page < _totalPages
                        ? () {
                            setState(() => _page++);
                            _loadUsers();
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(
      BuildContext context, AppLocalizations l10n) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now,
      initialDateRange: _dateFrom != null && _dateTo != null
          ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
          : null,
    );
    if (range != null) {
      setState(() {
        _dateFrom = range.start;
        _dateTo = range.end;
        _todayOnly = false;
      });
      _page = 1;
      _loadUsers();
    }
  }
}

// ── User card ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final Map user;
  final bool isLoading;
  final VoidCallback onCall;
  final VoidCallback onGrant;
  final VoidCallback onBlock;
  final VoidCallback onDelete;
  final VoidCallback onProfile;
  final AppLocalizations l10n;

  const _UserCard({
    required this.user,
    required this.isLoading,
    required this.onCall,
    required this.onGrant,
    required this.onBlock,
    required this.onDelete,
    required this.onProfile,
    required this.l10n,
  });

  bool get _hasAccess {
    final expires =
        (user['accessExpiresAt'])?.toString();
    if (expires == null) return false;
    return DateTime.tryParse(expires)?.isAfter(DateTime.now()) ?? false;
  }

  bool get _isActive {
    final v = user['isActive'];
    return v == true || v == 1 || v == '1' || v == 'true';
  }

  String _langEmoji() {
    switch ((user['preferredLanguage'] ?? 'en').toString().toLowerCase()) {
      case 'rw':
        return '🇷🇼';
      case 'fr':
        return '🇫🇷';
      default:
        return '🇬🇧';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name =
        (user['fullName'] ?? user['name'] ?? 'Unknown').toString();
    final phone =
        (user['phoneNumber'] ?? user['phone_number'] ?? '').toString();
    final role = (user['role'] ?? 'USER').toString();
    final created =
        (user['createdAt'] ?? user['created_at'] ?? '').toString().split('T')[0];
    final calledAt = (user['lastCalledAt'] ?? '').toString();
    final lang = (user['preferredLanguage'] ?? 'en').toString();

    final accessColor = _hasAccess ? AppColors.success : AppColors.error;
    final blockedColor =
        !_isActive ? AppColors.error : AppColors.textTertiary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row ───────────────────────────────────────────────
            Row(
              children: [
                GestureDetector(
                  onTap: onProfile,
                  child: CircleAvatar(
                    backgroundColor:
                        AppColors.primary.withOpacity(0.15),
                    radius: 22,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: AppTextStyles.heading6
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onProfile,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(name,
                                  style: AppTextStyles.heading6,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            if (!_isActive)
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  l10n.adminIsBlocked,
                                  style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        Text(phone,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary)),
                        Text(
                          l10n.adminRegistrationDate(created),
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_langEmoji(),
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 2),
                    Text(
                      '$lang',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Status badges row ─────────────────────────────────────
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _badge(
                  _hasAccess ? l10n.adminHasAccess : l10n.adminNoAccess,
                  accessColor,
                ),
                _badge(role, AppColors.primary),
                if (calledAt.isNotEmpty)
                  _badge('📞 ${calledAt.split('T')[0]}',
                      AppColors.textSecondary),
              ],
            ),

            if (_hasAccess && user['accessExpiresAt'] != null) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.subscriptionExpires(user['accessExpiresAt'].toString().split('T')[0])} • ${user['paymentTier'] ?? ''}',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],

            const SizedBox(height: 10),

            // ── Actions row ───────────────────────────────────────────
            if (isLoading)
              const Center(
                  child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2)))
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _actionBtn(
                    icon: Icons.phone_rounded,
                    label: l10n.adminCallUser,
                    color: AppColors.primary,
                    onTap: onCall,
                  ),
                  _actionBtn(
                    icon: Icons.key_rounded,
                    label: l10n.adminAccess,
                    color: AppColors.success,
                    onTap: onGrant,
                  ),
                  _actionBtn(
                    icon: _isActive ? Icons.block : Icons.check_circle,
                    label: _isActive
                        ? l10n.adminBlockUser
                        : l10n.adminUnblockUser,
                    color: _isActive ? AppColors.warning : AppColors.success,
                    onTap: onBlock,
                  ),
                  _actionBtn(
                    icon: Icons.delete_rounded,
                    label: l10n.adminDeleteUserAction,
                    color: AppColors.error,
                    onTap: onDelete,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
}
