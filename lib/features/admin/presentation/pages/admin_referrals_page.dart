import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/widgets/app_page_header.dart';

class AdminReferralRepository {
  Future<Map<String, dynamic>> load({
    String? userId,
    String search = '',
    int offset = 0,
  }) async {
    final response = await ApiHelper().get(
      userId == null
          ? '/api/admin/referrals'
          : '/api/admin/referrals/${Uri.encodeComponent(userId)}',
      queryParams: {'search': search, 'offset': '$offset'},
    );
    if (!response.isSuccess || response.data is! Map) {
      throw const FormatException('Referral lookup unavailable');
    }
    return Map<String, dynamic>.from(response.data as Map);
  }
}

class AdminReferralsPage extends StatefulWidget {
  final String? userId;
  final AdminReferralRepository? repository;
  const AdminReferralsPage({super.key, this.userId, this.repository});

  @override
  State<AdminReferralsPage> createState() => _AdminReferralsPageState();
}

class _AdminReferralsPageState extends State<AdminReferralsPage> {
  late final _repository = widget.repository ?? AdminReferralRepository();
  final _search = TextEditingController();
  Timer? _debounce;
  int _request = 0;
  int _offset = 0;
  int? _nextOffset;
  int _total = 0;
  bool _loading = true;
  bool _error = false;
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _searchChanged(String value) {
    _debounce?.cancel();
    // Invalidate old responses immediately, including during the debounce.
    _request++;
    setState(() {
      _loading = true;
      _error = false;
      _items = [];
    });
    _debounce = Timer(const Duration(milliseconds: 350), () => _load());
  }

  Future<void> _load({int offset = 0}) async {
    _debounce?.cancel();
    final request = ++_request;
    setState(() {
      _offset = offset;
      _loading = true;
      _error = false;
    });
    try {
      final data = await _repository.load(
        userId: widget.userId,
        search: _search.text.trim(),
        offset: offset,
      );
      if (!mounted || request != _request) return;
      setState(() {
        _items = (data['items'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _user = data['user'] == null
            ? null
            : Map<String, dynamic>.from(data['user'] as Map);
        _total = (data['total'] as num).toInt();
        _offset = offset;
        _nextOffset = (data['nextOffset'] as num?)?.toInt();
      });
    } catch (_) {
      if (mounted && request == _request) setState(() => _error = true);
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = widget.userId != null;
    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(
            title: detail ? l10n.adminReferralInvitees : l10n.adminReferrals,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _load(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (!detail)
                    TextField(
                      controller: _search,
                      onChanged: _searchChanged,
                      onSubmitted: (_) => _load(),
                      decoration: InputDecoration(
                        labelText: l10n.adminReferralSearch,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).deleteButtonTooltip,
                          onPressed: () {
                            _search.clear();
                            _load();
                          },
                          icon: const Icon(Icons.clear),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  if (_user != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '${_user!['fullName']}\n${_user!['phoneNumber']}\n${_user!['code'] ?? ''}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error)
                    Column(
                      children: [
                        Text(l10n.referralLoadError),
                        TextButton(
                          onPressed: () => _load(offset: _offset),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    )
                  else ...[
                    Text(
                      '${detail ? l10n.adminReferralInvitees : l10n.adminUsers}: $_total',
                    ),
                    const SizedBox(height: 8),
                    if (_items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          detail ? l10n.referralEmpty : l10n.adminNoUsers,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    for (final item in _items)
                      Card(
                        child: ListTile(
                          isThreeLine: true,
                          title: Text(
                            item['fullName'] as String? ??
                                l10n.adminReferralDeletedUser,
                          ),
                          subtitle: Text(
                            detail
                                ? '${item['phoneNumber'] ?? ''}\n${item['createdAt']} · ${item['status'] == 'confirmed' ? l10n.referralConfirmed : l10n.referralPending}'
                                : '${item['phoneNumber']}\n${item['code'] ?? ''}\n${l10n.adminReferralInvitees}: ${item['invitedCount']}',
                          ),
                          trailing: detail
                              ? null
                              : const Icon(Icons.chevron_right),
                          onTap: detail
                              ? null
                              : () => context.push(
                                  '/admin/referrals/${Uri.encodeComponent(item['id'] as String)}',
                                ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).previousPageTooltip,
                          onPressed: _offset == 0
                              ? null
                              : () => _load(
                                  offset: (_offset - 20).clamp(0, _offset),
                                ),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text('${_offset ~/ 20 + 1}'),
                        IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).nextPageTooltip,
                          onPressed: _nextOffset == null
                              ? null
                              : () => _load(offset: _nextOffset!),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
