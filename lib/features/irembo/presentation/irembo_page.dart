import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/irembo_repository.dart';
import 'irembo_widgets.dart';
import 'irembo_form_page.dart';
import 'irembo_payment_bar.dart';

class IremboPage extends StatefulWidget {
  final bool manage;
  final IremboRepository? repository;
  const IremboPage({super.key, this.manage = false, this.repository});
  @override
  State<IremboPage> createState() => _IremboPageState();
}

class _IremboPageState extends State<IremboPage> {
  late final IremboRepository _repo = widget.repository ?? IremboRepository();
  final _search = TextEditingController();
  final _filters = <String, String>{};
  final _selected = <String>{};
  bool _offline = false;
  List<Map<String, dynamic>> _items = [], _staff = [];
  bool _busy = false, _loaded = false;
  String? _service, _option;
  String? _error;
  int _page = 1, _total = 0, _revision = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      if (widget.manage) _loadStaff();
    });
  }

  @override
  void dispose() {
    _revision++;
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    try {
      final staff = await _repo.staff();
      if (mounted) setState(() => _staff = staff);
    } catch (_) {
      /* List remains usable if staff lookup is unavailable. */
    }
  }

  /// Applicants may submit one request per service slot. A single account can
  /// still have several requests across Provisoire, Permis · Manual and
  /// Permis · Automatic, so choosing a service does not block the others.
  void _preselect() {
    final used = {
      for (final row in _items)
        iremboSlot(row['service'] as String?, row['permisOption'] as String?),
    };
    final current = iremboSlot(_service, _option);
    if (current.isNotEmpty && !used.contains(current)) return;
    final open = iremboSlots.where((slot) => !used.contains(slot)).toList();
    final next = (open.isEmpty ? iremboSlots.first : open.first).split('|');
    _service = next.first;
    _option = next.length > 1 ? next[1] : null;
  }

  bool _slotUsed(String? service, String? option) {
    final slot = iremboSlot(service, option);
    if (!iremboSlots.contains(slot)) return false;
    return _items.any(
      (row) =>
          iremboSlot(
            row['service'] as String?,
            row['permisOption'] as String?,
          ) ==
          slot,
    );
  }

  Future<void> _load() async {
    final revision = ++_revision;
    setState(() {
      _busy = true;
      _error = null;
    });
    final filters = {
      ..._filters,
      if (widget.manage) 'search': _search.text.trim(),
      if (widget.manage) 'page': '$_page',
    };
    try {
      final cached = await _repo.cachedList(filters);
      if (!mounted || revision != _revision) return;
      if (cached != null) setState(() => _setData(cached));
      final data = await _repo.list(filters);
      if (!mounted || revision != _revision) return;
      setState(() {
        _setData(data);
      });
    } catch (e) {
      if (mounted && revision == _revision) {
        setState(() => _error = irError(AppLocalizations.of(context), e));
      }
    } finally {
      if (mounted && revision == _revision) setState(() => _busy = false);
    }
  }

  void _setData(Map<String, dynamic> data) {
    _items = (data['items'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    _total = int.parse(data['total'].toString());
    _offline = data['offline'] == true;
    _selected.clear();
    if (!widget.manage && _items.isNotEmpty) _preselect();
    _loaded = true;
  }

  Future<void> _refresh() async {
    if (_busy) return;
    await _load();
  }

  Future<void> _delete(Map<String, dynamic>? row) async {
    if (_busy || _offline) return;
    final ids = row == null ? _selected.toList() : [row['id'].toString()];
    if (ids.isEmpty) return;
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.irDeleteRequest),
        content: Text(
          '${row == null ? '${l.irSelected}: ${ids.length}' : '${row['fullName']} — ${row['service']}'}\n${l.irDeleteConfirm}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.profileDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      if (row == null) {
        await _repo.deleteMany(ids);
      } else {
        await _repo.delete(ids.single);
      }
      if (!mounted) return;
      setState(() {
        _items.removeWhere((item) => ids.contains(item['id'].toString()));
        _selected.removeAll(ids);
        _total = (_total - ids.length).clamp(0, _total);
      });
      if (_items.isEmpty && _page > 1) _page--;
      await _load();
    } catch (e) {
      if (mounted) irToast(context, irError(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _adminCard(Map<String, dynamic> row, AppLocalizations l) => Card(
    key: ValueKey('row-${row['id']}'),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckboxListTile(
            key: ValueKey('select-${row['id']}'),
            contentPadding: EdgeInsets.zero,
            title: Text(l.irSelectRequest),
            value: _selected.contains(row['id'].toString()),
            onChanged: _busy || _offline
                ? null
                : (value) => setState(() {
                    if (value == true) {
                      _selected.add(row['id'].toString());
                    } else {
                      _selected.remove(row['id'].toString());
                    }
                  }),
          ),
          Text(
            [
              row['service'],
              if (row['permisOption'] != null) irValue(l, row['permisOption']),
              irValue(l, row['status']),
            ].join(' · '),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          IremboDetailsFields(data: row, compact: true, copyable: true),
          const Divider(),
          Row(
            children: [
              TextButton.icon(
                onPressed: (row['phoneNumber']?.toString().trim() ?? '').isEmpty
                    ? null
                    : () => _call(row),
                icon: const Icon(Icons.call_outlined),
                label: Text(l.irCall),
              ),
              const Spacer(),
              IconButton(
                key: ValueKey('delete-${row['id']}'),
                tooltip: l.profileDelete,
                onPressed: _busy || _offline ? null : () => _delete(row),
                color: Theme.of(context).colorScheme.error,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Future<void> _call(Map<String, dynamic> row) async {
    final l = AppLocalizations.of(context);
    try {
      if (!await launchUrl(
        Uri(scheme: 'tel', path: row['phoneNumber'].toString().trim()),
      )) {
        throw StateError('call');
      }
    } catch (_) {
      if (mounted) irToast(context, l.irCallFailed);
    }
  }

  Future<void> _create(String service, [String? option]) async {
    if (!_loaded ||
        _busy ||
        _offline ||
        _error != null ||
        _slotUsed(service, option)) {
      return;
    }
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => IremboFormPage(
          service: service,
          permisOption: option,
          repository: _repo,
        ),
      ),
    );
    if (mounted) {
      _page = 1;
      _load();
    }
  }

  Widget _filter(
    String key,
    String title,
    List<String> values, {
    Map<String, String>? names,
  }) {
    final l = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      key: ValueKey('$key-${_filters[key]}'),
      initialValue: _filters[key] ?? '',
      isExpanded: true,
      decoration: InputDecoration(
        labelText: title,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: '', child: Text(l.irAll)),
        for (final v in values)
          DropdownMenuItem(value: v, child: Text(names?[v] ?? irValue(l, v))),
      ],
      onChanged: _busy
          ? null
          : (v) {
              setState(() {
                if (v == null || v.isEmpty) {
                  _filters.remove(key);
                } else {
                  _filters[key] = v;
                  if (key == 'service' && v == 'Provisoire') {
                    _filters.remove('permisOption');
                    _filters.remove('category');
                  }
                  if (key == 'permisOption' && v == 'Automatic') {
                    _filters.remove('category');
                  }
                }
                _page = 1;
              });
              _load();
            },
    );
  }

  Future<void> _filterDate(String key) async {
    final now = DateTime.now();
    final first = key == 'to'
        ? DateTime.tryParse(_filters['from'] ?? '')
        : null;
    final last = key == 'from' ? DateTime.tryParse(_filters['to'] ?? '') : null;
    var initial = DateTime.tryParse(_filters[key] ?? '') ?? now;
    if (first != null && initial.isBefore(first)) initial = first;
    if (last != null && initial.isAfter(last)) initial = last;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first ?? DateTime(2000),
      lastDate: last ?? DateTime(now.year + 1),
    );
    if (date != null && mounted) {
      setState(() => _filters[key] = date.toIso8601String().substring(0, 10));
      _page = 1;
      _load();
    }
  }

  Widget _filterPanel(AppLocalizations l) => ExpansionTile(
    title: Text(l.irFilters),
    children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth < 500
                ? constraints.maxWidth
                : (constraints.maxWidth - 16) / 2;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: width,
                      child: _filter('service', l.irService, [
                        'Provisoire',
                        'Permis',
                      ]),
                    ),
                    if (_filters['service'] != 'Provisoire')
                      SizedBox(
                        width: width,
                        child: _filter('permisOption', l.irOption, [
                          'Manual',
                          'Automatic',
                        ]),
                      ),
                    if (_filters['service'] != 'Provisoire' &&
                        _filters['permisOption'] != 'Automatic')
                      SizedBox(
                        width: width,
                        child: _filter('category', l.irCategory, [
                          'A',
                          'B',
                          'F',
                        ]),
                      ),
                    SizedBox(
                      width: width,
                      child: _filter('examLanguage', l.irExamLanguage, [
                        'rw',
                        'en',
                        'fr',
                      ]),
                    ),
                    SizedBox(
                      width: width,
                      child: _filter(
                        'district',
                        l.irDistrict,
                        IremboRules.districts,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _filter(
                        'assignedStaffId',
                        l.irAssigned,
                        ['unassigned', ..._staff.map((s) => s['id'] as String)],
                        names: {
                          'unassigned': l.irUnassigned,
                          for (final s in _staff) s['id']: s['name'].toString(),
                        },
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _filter(
                        'sort',
                        l.irSort,
                        ['newest', 'oldest', 'name', 'updated'],
                        names: {
                          'newest': l.irNewest,
                          'oldest': l.irOldest,
                          'name': l.irFullName,
                          'updated': l.irUpdated,
                        },
                      ),
                    ),
                    for (final key in ['from', 'to'])
                      SizedBox(
                        width: width,
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : () => _filterDate(key),
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            '${key == 'from' ? l.irFrom : l.irTo}: ${_filters[key] ?? '—'}',
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () {
                              setState(() {
                                _filters.clear();
                                _search.clear();
                                _page = 1;
                              });
                              _refresh();
                            },
                      child: Text(l.irClear),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ],
  );
  Widget _choice(
    String key,
    String title,
    IconData icon,
    bool selected,
    VoidCallback? onTap, {
    String? description,
  }) {
    final theme = Theme.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Card(
        color: selected ? theme.colorScheme.primaryContainer : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          key: ValueKey(key),
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: theme.colorScheme.primary),
                    const Spacer(),
                    Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(title, style: theme.textTheme.titleMedium),
                if (description != null) ...[
                  const SizedBox(height: 6),
                  Text(description),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceSelection(AppLocalizations l) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(l.irNotice),
      const SizedBox(height: 12),
      Text(l.irChooseService, style: Theme.of(context).textTheme.titleMedium),
      LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              SizedBox(
                width: width,
                child: _choice(
                  'service-provisoire',
                  'Provisoire',
                  Icons.assignment_outlined,
                  _service == 'Provisoire',
                  () => setState(() {
                    _service = 'Provisoire';
                    _option = null;
                  }),
                ),
              ),
              SizedBox(
                width: width,
                child: _choice(
                  'service-permis',
                  'Permis',
                  Icons.directions_car_outlined,
                  _service == 'Permis',
                  () => setState(() {
                    _service = 'Permis';
                  }),
                ),
              ),
            ],
          );
        },
      ),
      if (_service == 'Permis') ...[
        const SizedBox(height: 16),
        Text(l.irChooseOption, style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            ChoiceChip(
              key: const ValueKey('option-manual'),
              label: Text(l.irManual),
              selected: _option == 'Manual',
              onSelected: (_) => setState(() => _option = 'Manual'),
            ),
            ChoiceChip(
              key: const ValueKey('option-automatic'),
              label: Text(l.irAutomatic),
              selected: _option == 'Automatic',
              onSelected: (_) => setState(() => _option = 'Automatic'),
            ),
          ],
        ),
      ],
      const SizedBox(height: 16),
      if (_slotUsed(_service, _option))
        Text(l.irAlreadySubmitted, key: const ValueKey('irembo-submitted'))
      else
        FilledButton.icon(
          key: const ValueKey('irembo-continue'),
          onPressed:
              !_loaded ||
                  _busy ||
                  _offline ||
                  _error != null ||
                  _service == null ||
                  (_service == 'Permis' && _option == null)
              ? null
              : () => _create(_service!, _option),
          icon: const Icon(Icons.arrow_forward),
          label: Text(l.irContinue),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IremboScaffold(
      title: widget.manage ? l.irWorkspace : l.irTitle,
      maxWidth: 1400,
      bottomBar: widget.manage
          ? null
          : IremboPaymentBar(service: _service, option: _option),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.manage) ...[
            _serviceSelection(l),
            const SizedBox(height: 24),
            Text(l.irMyRequests, style: Theme.of(context).textTheme.titleLarge),
          ] else ...[
            TextField(
              controller: _search,
              decoration: InputDecoration(
                labelText: l.irSearch,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: l.irApply,
                  onPressed: _busy
                      ? null
                      : () {
                          _page = 1;
                          _refresh();
                        },
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
              onSubmitted: (_) {
                _page = 1;
                _load();
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final status in ['', ...IremboRules.statuses])
                  ChoiceChip(
                    selectedColor: Theme.of(context).colorScheme.primary,
                    checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                    labelStyle: TextStyle(
                      color: (_filters['status'] ?? '') == status
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                    ),
                    label: Text(status.isEmpty ? l.irAll : irValue(l, status)),
                    selected: (_filters['status'] ?? '') == status,
                    onSelected: _busy
                        ? null
                        : (_) {
                            setState(() {
                              if (status.isEmpty) {
                                _filters.remove('status');
                              } else {
                                _filters['status'] = status;
                              }
                              _page = 1;
                            });
                            _load();
                          },
                  ),
              ],
            ),
            Card(child: _filterPanel(l)),
            if (_filters.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in _filters.entries)
                    InputChip(
                      selected: true,
                      showCheckmark: false,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      deleteIconColor: Theme.of(context).colorScheme.onPrimary,
                      label: Text(
                        '${switch (entry.key) {
                          'from' => l.irFrom,
                          'to' => l.irTo,
                          'sort' => l.irSort,
                          _ => irLabel(l, entry.key),
                        }}: ${entry.key == 'assignedStaffId' ? (entry.value == 'unassigned' ? l.irUnassigned : _staff.where((s) => s['id'] == entry.value).map((s) => s['name']).firstOrNull ?? l.irAssigned) : irValue(l, entry.value)}',
                      ),
                      onDeleted: _busy
                          ? null
                          : () {
                              setState(() {
                                _filters.remove(entry.key);
                                _page = 1;
                              });
                              _load();
                            },
                    ),
                ],
              ),
          ],
          const SizedBox(height: 16),
          if (_offline)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l.irOfflineSaved,
                key: const ValueKey('irembo-offline'),
              ),
            ),
          if (widget.manage && _loaded && _error == null && _items.isNotEmpty)
            Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterChip(
                  key: const ValueKey('select-page'),
                  label: Text(l.irSelectPage),
                  selected: _selected.length == _items.length,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                  labelStyle: TextStyle(
                    color: _selected.length == _items.length
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                  onSelected: _busy || _offline
                      ? null
                      : (value) => setState(() {
                          _selected.clear();
                          if (value) {
                            _selected.addAll(
                              _items.map((r) => r['id'].toString()),
                            );
                          }
                        }),
                ),
                Text('${l.irSelected}: ${_selected.length}'),
                FilledButton.icon(
                  key: const ValueKey('delete-selected'),
                  onPressed: _busy || _offline || _selected.isEmpty
                      ? null
                      : () => _delete(null),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l.irDeleteSelected),
                ),
              ],
            ),
          Row(
            children: [
              Expanded(
                child: widget.manage && _loaded && _error == null
                    ? Text('${l.irResults}: $_total')
                    : const SizedBox.shrink(),
              ),
              IconButton(
                tooltip: l.irRetry,
                onPressed: _busy ? null : _refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.irRequestsUnavailable,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_error!),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _refresh,
                      icon: const Icon(Icons.refresh),
                      label: Text(l.irRetry),
                    ),
                  ],
                ),
              ),
            ),
          if (!_busy && _loaded && _error == null && _items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(widget.manage ? l.irEmpty : l.irNoRequests),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (!widget.manage) {
                if (!_loaded || _error != null || _items.isEmpty) {
                  return const SizedBox.shrink();
                }
                // Applicants see what they submitted, not just a status line.
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final row in _items)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      row['service'].toString(),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  Text(irValue(l, row['status'])),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${l.irSubmitted}: ${row['createdAt']}'),
                              const SizedBox(height: 12),
                              IremboDetailsFields(data: row),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              }
              if (!_loaded || _error != null) return const SizedBox.shrink();
              final width = constraints.maxWidth >= 900
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  for (final row in _items)
                    SizedBox(width: width, child: _adminCard(row, l)),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (widget.manage && _loaded && _error == null && _total > 20)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _busy || _page <= 1
                      ? null
                      : () {
                          _page--;
                          _refresh();
                        },
                  child: Text(l.irPrevious),
                ),
                Text('$_page / ${(_total / 20).ceil().clamp(1, 100000)}'),
                OutlinedButton(
                  onPressed: _busy || _page * 20 >= _total
                      ? null
                      : () {
                          _page++;
                          _refresh();
                        },
                  child: Text(l.irNext),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
