import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _AdminAccessPageState extends State<AdminAccessPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          // ── Gradient header with tabs ───────────────────────────────────
          _GradientTabHeader(title: l10n.adminAccess, tabCtrl: _tabCtrl, l10n: l10n),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: const [
                _AccessCodesTab(),
                _GrantAccessTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient header that contains the page title and a [TabBar].
/// Used by [AdminAccessPage] to match the style of [AppPageHeader]
/// while also hosting the two-tab navigation.
class _GradientTabHeader extends StatelessWidget {
  final String title;
  final TabController tabCtrl;
  final AppLocalizations l10n;

  const _GradientTabHeader({
    required this.title,
    required this.tabCtrl,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final gradient = AppColors.primaryGradientFor(Theme.of(context).brightness);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.textInverse,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: tabCtrl,
              labelColor: AppColors.textInverse,
              unselectedLabelColor: AppColors.textInverse.withValues(alpha: 0.6),
              indicatorColor: AppColors.textInverse,
              indicatorWeight: 3,
              tabs: [
                Tab(text: l10n.adminAccess),
                Tab(text: l10n.adminManageUsers),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Tab 1 – Access Codes list
// ═══════════════════════════════════════════════════════════════════════════════

class _AccessCodesTab extends StatefulWidget {
  const _AccessCodesTab();

  @override
  State<_AccessCodesTab> createState() => _AccessCodesTabState();
}

class _AccessCodesTabState extends State<_AccessCodesTab> {
  bool _isLoading = true;
  List<dynamic> _codes = [];
  int _total = 0;
  String? _error;
  String _sortDir = 'DESC';
  bool _todayOnly = false;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _blockedFilter; // null = all, 'true' = blocked, 'false' = active
  int _page = 1;
  static const _limit = 10;
  final _loadingMap = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
        if (_todayOnly) 'today': '1',
        if (!_todayOnly && _dateFrom != null)
          'dateFrom': _dateFrom!.toIso8601String().split('T')[0],
        if (!_todayOnly && _dateTo != null)
          'dateTo': _dateTo!.toIso8601String().split('T')[0],
        if (_blockedFilter != null) 'isBlocked': _blockedFilter!,
      };
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/access-codes')
          .replace(queryParameters: qp);
      final res = await http
          .get(uri, headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          })
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _codes = (data is List)
              ? data
              : (data['codes'] ?? data['data'] ?? []);
          _total = (data is Map) ? (data['total'] ?? _codes.length) : _codes.length;
        });
      } else {
        setState(() => _error = 'HTTP ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _blockCode(String id, AppLocalizations l10n) async {
    setState(() => _loadingMap[id] = true);
    try {
      final token = await AuthSession().getToken();
      final res = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/access-codes/$id/block'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        _showSnack(l10n.adminAccessBlocked, AppColors.success);
        _load();
      } else {
        _showSnack('HTTP ${res.statusCode}', AppColors.error);
      }
    } catch (e) {
      _showSnack(e.toString(), AppColors.error);
    } finally {
      setState(() => _loadingMap.remove(id));
    }
  }

  Future<void> _deleteCode(String id, AppLocalizations l10n) async {
    setState(() => _loadingMap[id] = true);
    try {
      final token = await AuthSession().getToken();
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/access-codes/$id'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        _showSnack(l10n.adminAccessDeleted, AppColors.success);
        _load();
      } else {
        _showSnack('HTTP ${res.statusCode}', AppColors.error);
      }
    } catch (e) {
      _showSnack(e.toString(), AppColors.error);
    } finally {
      setState(() => _loadingMap.remove(id));
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _confirmBlock(BuildContext ctx, Map code, AppLocalizations l10n) {
    final id = (code['id'] ?? '').toString();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(l10n.adminBlockAccess),
        content: Text(l10n.adminBlockAccessConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _blockCode(id, l10n);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.adminBlockAccess),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, Map code, AppLocalizations l10n) {
    final id = (code['id'] ?? '').toString();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(l10n.adminDeleteAccess),
        content: Text(l10n.adminDeleteAccessConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCode(id, l10n);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.adminDeleteAccess),
          ),
        ],
      ),
    );
  }

  int get _totalPages => (_total / _limit).ceil().clamp(1, 9999);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // ── Toolbar ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              // Chips group — scrollable so they never overflow on small screens
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Sort
                      _toolChip(context,
                        icon: _sortDir == 'DESC'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        label: _sortDir == 'DESC' ? l10n.adminSortDesc : l10n.adminSortAsc,
                        onTap: () {
                          setState(() => _sortDir =
                              _sortDir == 'DESC' ? 'ASC' : 'DESC');
                          _page = 1;
                          _load();
                        },
                      ),
                      const SizedBox(width: 8),
                      // Today
                      _toolChip(context,
                        icon: Icons.today,
                        label: l10n.adminFilterToday,
                        selected: _todayOnly,
                        onTap: () {
                          setState(() {
                            _todayOnly = !_todayOnly;
                            if (_todayOnly) {
                              _dateFrom = null;
                              _dateTo = null;
                            }
                          });
                          _page = 1;
                          _load();
                        },
                      ),
                      // Date range
                      if (!_todayOnly) ...[
                        const SizedBox(width: 8),
                        _toolChip(context,
                          icon: Icons.date_range,
                          label: _dateFrom != null
                              ? _dateFrom!.toIso8601String().split('T')[0]
                              : l10n.adminDateRange,
                          selected: _dateFrom != null,
                          onTap: () => _pickDateRange(context, l10n),
                          onClear: _dateFrom != null
                              ? () {
                                  setState(() {
                                    _dateFrom = null;
                                    _dateTo = null;
                                  });
                                  _page = 1;
                                  _load();
                                }
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Refresh button — always visible on the right
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _load,
                iconSize: 20,
              ),
            ],
          ),
        ),

        // ── Status filter chips ──────────────────────────────────────────
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _filterChip(context, l10n.adminFilterAll, _blockedFilter == null, () {
                setState(() => _blockedFilter = null);
                _page = 1;
                _load();
              }),
              const SizedBox(width: 6),
              _filterChip(context, l10n.adminIsActive, _blockedFilter == 'false', () {
                setState(() =>
                    _blockedFilter = _blockedFilter == 'false' ? null : 'false');
                _page = 1;
                _load();
              }),
              const SizedBox(width: 6),
              _filterChip(context, l10n.adminIsBlocked, _blockedFilter == 'true', () {
                setState(() =>
                    _blockedFilter = _blockedFilter == 'true' ? null : 'true');
                _page = 1;
                _load();
              }),
            ],
          ),
        ),

        // ── List ─────────────────────────────────────────────────────────
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
                          const SizedBox(height: 12),
                          Text(_error!,
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _load,
                            child: Text(l10n.commonRetry),
                          ),
                        ],
                      ),
                    )
                  : _codes.isEmpty
                      ? const Center(child: Icon(Icons.key_off, size: 64,
                          color: AppColors.neutral400))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(12, 0, 12, 8),
                            itemCount: _codes.length,
                            itemBuilder: (ctx, i) {
                              final code = _codes[i] as Map;
                              final id = (code['id'] ?? '').toString();
                              final isLoading =
                                  _loadingMap[id] ?? false;
                              return _AccessCodeCard(
                                code: code,
                                isLoading: isLoading,
                                onBlock: () =>
                                    _confirmBlock(ctx, code, l10n),
                                onDelete: () =>
                                    _confirmDelete(ctx, code, l10n),
                                l10n: l10n,
                              );
                            },
                          ),
                        ),
        ),

        // ── Pagination ───────────────────────────────────────────────────
        if (!_isLoading && _error == null && _totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _page > 1
                      ? () {
                          setState(() => _page--);
                          _load();
                        }
                      : null,
                ),
                Text(
                  AppLocalizations.of(context)
                      .adminPage(_page, _totalPages),
                  style: AppTextStyles.labelMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _page < _totalPages
                      ? () {
                          setState(() => _page++);
                          _load();
                        }
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _toolChip(BuildContext context, {
    required IconData icon,
    required String label,
    bool selected = false,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final bg = Theme.of(context).colorScheme.surface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.12)
              : bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: primary),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: primary, fontSize: 12)),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close,
                    size: 12, color: primary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final primary = Theme.of(context).colorScheme.primary;
    final bg = Theme.of(context).colorScheme.surface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.15)
              : bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? primary
                  : primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check, size: 12, color: primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color:
                    selected ? primary : AppColors.textSecondary,
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
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
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
      _load();
    }
  }
}

// ── Access code card ──────────────────────────────────────────────────────────

class _AccessCodeCard extends StatelessWidget {
  final Map code;
  final bool isLoading;
  final VoidCallback onBlock;
  final VoidCallback onDelete;
  final AppLocalizations l10n;

  const _AccessCodeCard({
    required this.code,
    required this.isLoading,
    required this.onBlock,
    required this.onDelete,
    required this.l10n,
  });

  bool get _isBlocked {
    final v = code['isBlocked'];
    return v == true || v == 1 || v == '1';
  }

  bool get _isExpired {
    final exp = (code['expiresAt'] ?? '').toString();
    if (exp.isEmpty) return false;
    return DateTime.tryParse(exp)?.isBefore(DateTime.now()) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final codeStr = (code['code'] ?? '').toString();
    final userName = (code['userName'] ?? '').toString();
    final userPhone = (code['userPhone'] ?? '').toString();
    final tier = (code['paymentTier'] ?? '').toString();
    final amount = code['paymentAmount'];
    final created =
        (code['createdAt'] ?? '').toString().split('T')[0];
    final expires =
        (code['expiresAt'] ?? '').toString().split('T')[0];
    final inactive = _isBlocked || _isExpired;
    final statusColor = inactive ? AppColors.error : AppColors.success;
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Code + status ─────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.key_rounded,
                          size: 14, color: primary),
                      const SizedBox(width: 6),
                      Text(
                        codeStr,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: primary,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: codeStr));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(AppLocalizations.of(context).generalCopied),
                          duration: const Duration(seconds: 1)),
                    );
                  },
                  child: const Icon(Icons.copy, size: 16,
                      color: AppColors.textSecondary),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    inactive
                        ? l10n.adminIsBlocked
                        : l10n.adminIsActive,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── User info ─────────────────────────────────────────────
            if (userName.isNotEmpty || userPhone.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    userName.isNotEmpty ? userName : userPhone,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  if (userPhone.isNotEmpty && userName.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      userPhone,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ],
              ),

            const SizedBox(height: 6),

            // ── Dates & tier ──────────────────────────────────────────
            Wrap(
              spacing: 12,
              children: [
                if (tier.isNotEmpty)
                  _info(Icons.workspace_premium, tier.replaceAll('_', ' ')),
                if (amount != null)
                  _info(Icons.payment, l10n.priceRwf(amount.toString())),
                if (created.isNotEmpty)
                  _info(Icons.calendar_today, created),
                if (expires.isNotEmpty)
                  _info(Icons.access_time, expires,
                      color: _isExpired ? AppColors.error : null),
              ],
            ),

            const SizedBox(height: 10),

            // ── Actions ───────────────────────────────────────────────
            if (isLoading)
              const Center(
                  child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2)))
            else
              Row(
                children: [
                  if (!inactive)
                    _actionBtn(
                      icon: Icons.block,
                      label: l10n.adminBlockAccess,
                      color: AppColors.warning,
                      onTap: onBlock,
                    ),
                  if (!inactive) const SizedBox(width: 8),
                  _actionBtn(
                    icon: Icons.delete_rounded,
                    label: l10n.adminDeleteAccess,
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

  Widget _info(IconData icon, String text, {Color? color}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12,
              color: color ?? AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(text,
              style: AppTextStyles.labelSmall.copyWith(
                  color: color ?? AppColors.textSecondary)),
        ],
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
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Tab 2 – Grant Access to users
// ═══════════════════════════════════════════════════════════════════════════════

class _GrantAccessTab extends StatefulWidget {
  const _GrantAccessTab();

  @override
  State<_GrantAccessTab> createState() => _GrantAccessTabState();
}

class _GrantAccessTabState extends State<_GrantAccessTab> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  int _total = 0;
  String? _error;
  final _searchCtrl = TextEditingController();
  String _accessFilter = 'all';
  int _page = 1;
  static const _limit = 10;
  final _loadingMap = <String, bool>{};
  // pending payment user IDs
  final Set<String> _pendingIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    _page = 1;
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
      final qp = <String, String>{
        'page': '$_page',
        'limit': '$_limit',
        if (_searchCtrl.text.isNotEmpty) 'search': _searchCtrl.text,
        if (_accessFilter == 'hasAccess') 'hasAccess': 'true',
        if (_accessFilter == 'noAccess') 'hasAccess': 'false',
      };
      final usersUri = Uri.parse('${ApiConfig.baseUrl}/api/admin/users')
          .replace(queryParameters: qp);

      final results = await Future.wait([
        http.get(usersUri, headers: headers).timeout(const Duration(seconds: 15)),
        http.get(Uri.parse('${ApiConfig.baseUrl}/api/payments'), headers: headers)
            .timeout(const Duration(seconds: 15)),
      ]);

      if (results[0].statusCode == 200) {
        final data = json.decode(results[0].body);
        final userList = (data is List)
            ? List<dynamic>.from(data)
            : List<dynamic>.from(data['users'] ?? data['data'] ?? []);
        _total = (data is Map) ? (data['total'] ?? userList.length) : userList.length;

        _pendingIds.clear();
        if (results[1].statusCode == 200) {
          final pData = json.decode(results[1].body);
          final payments = (pData is List) ? pData : (pData['payments'] ?? pData['data'] ?? []);
          for (final p in payments) {
            if ((p['status'] ?? '').toString().toUpperCase() == 'PENDING') {
              final uid = (p['userId'] ?? p['user_id'] ?? '').toString();
              if (uid.isNotEmpty) _pendingIds.add(uid);
            }
          }
        }

        setState(() {
          _users = userList
              .map((u) => Map<String, dynamic>.from(u as Map))
              .toList();
        });
      } else {
        setState(() => _error = 'HTTP ${results[0].statusCode}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int get _totalPages => (_total / _limit).ceil().clamp(1, 9999);

  void _showGrantSheet(Map<String, dynamic> user, AppLocalizations l10n) {
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
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.adminSelectTier, style: AppTextStyles.heading6),
              const SizedBox(height: 8),
              if (!customMode)
                ...tiers.map((t) => RadioListTile<String>(
                      value: t['tier'] as String,
                      groupValue: selectedTier,
                      title: Text(t['label'] as String),
                      subtitle: Text(l10n.priceRwf(t['price'].toString())),
                      onChanged: (v) => setModal(() => selectedTier = v),
                    )).toList(),
              CheckboxListTile(
                value: customMode,
                title: Text(l10n.adminOrCustom),
                onChanged: (v) => setModal(() => customMode = v ?? false),
                dense: true,
              ),
              if (customMode)
                TextField(
                  controller: daysCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: l10n.adminEnterDays),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: l10n.adminPaymentAmount),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _submitGrant(ctx, userId, selectedTier,
                    customMode, daysCtrl.text, amtCtrl.text, l10n),
                child: Text(l10n.adminAccessGranted),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.adminInvalidAmount),
          backgroundColor: AppColors.error));
      return;
    }
    final body = <String, dynamic>{'paymentAmount': amount};
    if (customMode) {
      final d = int.tryParse(daysText) ?? 0;
      if (d <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.adminInvalidDays),
            backgroundColor: AppColors.error));
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
        Uri.parse('${ApiConfig.baseUrl}/api/admin/users/$userId/grant-access'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));
      if (mounted) Navigator.pop(ctx);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.adminAccessGranted),
            backgroundColor: AppColors.success));
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.errorHttpStatus(response.statusCode)),
            backgroundColor: AppColors.error));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()), backgroundColor: AppColors.error));
    } finally {
      setState(() => _loadingMap.remove(userId));
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // ── Search bar ───────────────────────────────────────────────────
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
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        // ── Filter chips ─────────────────────────────────────────────────
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _chip(context, l10n.adminFilterAll, _accessFilter == 'all', () {
                setState(() => _accessFilter = 'all');
                _page = 1;
                _loadData();
              }),
              const SizedBox(width: 6),
              _chip(context, l10n.adminFilterHasAccess, _accessFilter == 'hasAccess',
                  () {
                setState(() => _accessFilter = 'hasAccess');
                _page = 1;
                _loadData();
              }),
              const SizedBox(width: 6),
              _chip(context, l10n.adminFilterNoAccess, _accessFilter == 'noAccess',
                  () {
                setState(() => _accessFilter = 'noAccess');
                _page = 1;
                _loadData();
              }),
            ],
          ),
        ),

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
                          const SizedBox(height: 12),
                          Text(_error!,
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: Text(l10n.commonRetry),
                          ),
                        ],
                      ),
                    )
                  : _users.isEmpty
                      ? Center(child: Text(l10n.adminNoUsers))
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                            itemCount: _users.length,
                            itemBuilder: (ctx, i) {
                              final user = _users[i];
                              final userId =
                                  (user['id'] ?? '').toString();
                              final isLoading =
                                  _loadingMap[userId] ?? false;
                              final hasPending =
                                  _pendingIds.contains(userId);
                              return _GrantUserCard(
                                user: user,
                                isLoading: isLoading,
                                hasPending: hasPending,
                                onGrant: () =>
                                    _showGrantSheet(user, l10n),
                                l10n: l10n,
                              );
                            },
                          ),
                        ),
        ),

        // ── Pagination ───────────────────────────────────────────────────
        if (!_isLoading && _error == null && _totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _page > 1
                      ? () {
                          setState(() => _page--);
                          _loadData();
                        }
                      : null,
                ),
                Text(l10n.adminPage(_page, _totalPages),
                    style: AppTextStyles.labelMedium),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _page < _totalPages
                      ? () {
                          setState(() => _page++);
                          _loadData();
                        }
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final primary = Theme.of(context).colorScheme.primary;
    final bg = Theme.of(context).colorScheme.surface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.15)
              : bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? primary
                  : primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check, size: 12, color: primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? primary : AppColors.textSecondary,
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
}

// ── Grant user card ───────────────────────────────────────────────────────────

class _GrantUserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isLoading;
  final bool hasPending;
  final VoidCallback onGrant;
  final AppLocalizations l10n;

  const _GrantUserCard({
    required this.user,
    required this.isLoading,
    required this.hasPending,
    required this.onGrant,
    required this.l10n,
  });

  bool get _hasAccess {
    final exp = (user['accessExpiresAt'])?.toString();
    if (exp == null) return false;
    return DateTime.tryParse(exp)?.isAfter(DateTime.now()) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final name = (user['fullName'] ?? user['name'] ?? '').toString();
    final phone = (user['phoneNumber'] ?? '').toString();
    final lang = (user['preferredLanguage'] ?? 'en').toString();
    final expires = (user['accessExpiresAt'] ?? '').toString().split('T')[0];
    final accessColor = _hasAccess ? AppColors.success : AppColors.error;
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primary.withValues(alpha: 0.15),
              radius: 22,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: AppTextStyles.heading6
                    .copyWith(color: primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(name,
                              style: AppTextStyles.labelLarge,
                              overflow: TextOverflow.ellipsis)),
                      if (hasPending)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '⏳ ${l10n.certificatesPending}',
                            style: const TextStyle(
                                color: AppColors.warning,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  Text(phone,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accessColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _hasAccess
                              ? l10n.adminHasAccess
                              : l10n.adminNoAccess,
                          style: TextStyle(
                              color: accessColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lang.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary),
                      ),
                      if (_hasAccess && expires.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          expires,
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textTertiary),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
            else
              IconButton(
                icon: const Icon(Icons.key_rounded,
                    color: AppColors.success),
                onPressed: onGrant,
                tooltip: l10n.adminAccessGranted,
              ),
          ],
        ),
      ),
    );
  }
}
