import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/irembo_repository.dart';
import 'irembo_widgets.dart';
import 'irembo_form_page.dart';
import 'irembo_request_page.dart';

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

  Future<void> _load() async {
    final revision = ++_revision;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final data = await _repo.list({
        ..._filters,
        if (widget.manage) 'search': _search.text.trim(),
        if (widget.manage) 'page': '$_page',
      });
      if (!mounted || revision != _revision) return;
      setState(() {
        _items = (data['items'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _total = int.parse(data['total'].toString());
        _loaded = true;
      });
    } catch (e) {
      if (mounted && revision == _revision) {
        setState(() => _error = irError(AppLocalizations.of(context), e));
      }
    } finally {
      if (mounted && revision == _revision) setState(() => _busy = false);
    }
  }

  Future<void> _open(Map<String, dynamic> row) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => IremboRequestPage(
          id: row['id'],
          manage: widget.manage,
          repository: _repo,
        ),
      ),
    );
    if (mounted) _load();
  }

  Future<void> _create(String service, [String? option]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => IremboFormPage(
          service: service,
          permisOption: option,
          repository: _repo,
        ),
      ),
    );
    if (result == true && mounted) {
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
      onChanged: (v) => setState(() {
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
      }),
    );
  }

  Future<void> _filterDate(String key) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_filters[key] ?? '') ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
    );
    if (date != null && mounted) {
      setState(() => _filters[key] = date.toIso8601String().substring(0, 10));
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
                    SizedBox(
                      width: width,
                      child: _filter('permisOption', l.irOption, [
                        'Manual',
                        'Automatic',
                      ]),
                    ),
                    SizedBox(
                      width: width,
                      child: _filter('category', l.irCategory, ['A', 'B', 'F']),
                    ),
                    SizedBox(
                      width: width,
                      child: _filter(
                        'status',
                        l.irStatus,
                        IremboRules.statuses,
                      ),
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
                          onPressed: () => _filterDate(key),
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
                    FilledButton(
                      onPressed: _busy
                          ? null
                          : () {
                              _page = 1;
                              _load();
                            },
                      child: Text(l.irApply),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () {
                              setState(() {
                                _filters.clear();
                                _search.clear();
                                _page = 1;
                              });
                              _load();
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
    VoidCallback onTap, {
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
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l.irNotice),
        ),
      ),
      const SizedBox(height: 16),
      Text(l.irChooseService, style: Theme.of(context).textTheme.titleMedium),
      LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth < 380
              ? constraints.maxWidth
              : (constraints.maxWidth - 12) / 2;
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
                  description: l.irProvisoireHelp,
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
                  description: l.irPermisHelp,
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
      FilledButton.icon(
        key: const ValueKey('irembo-continue'),
        onPressed: _service == null || (_service == 'Permis' && _option == null)
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.manage) ...[
            _serviceSelection(l),
            const SizedBox(height: 24),
            Text(l.irMyRequests, style: Theme.of(context).textTheme.titleLarge),
          ] else ...[
            Text(l.irStaffHelp),
            const SizedBox(height: 16),
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
                          _load();
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
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _loaded && _error == null
                    ? Text('${l.irResults}: $_total')
                    : const SizedBox.shrink(),
              ),
              IconButton(
                tooltip: l.irRetry,
                onPressed: _busy ? null : _load,
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
                      onPressed: _busy ? null : _load,
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
              if (widget.manage && constraints.maxWidth >= 900) {
                final keys = [
                  'reference',
                  'fullName',
                  'phoneNumber',
                  'service',
                  'permisOption',
                  'category',
                  'examLanguage',
                  'district',
                  'createdAt',
                  'assignedStaffId',
                  'status',
                ];
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      for (final key in keys)
                        DataColumn(label: Text(irLabel(l, key))),
                      DataColumn(label: Text(l.irView)),
                    ],
                    rows: [
                      for (final row in _items)
                        DataRow(
                          cells: [
                            for (final key in keys)
                              DataCell(
                                Text(
                                  key == 'assignedStaffId'
                                      ? (row['assignedStaffName'] ??
                                                l.irUnassigned)
                                            .toString()
                                      : irValue(l, row[key]),
                                ),
                              ),
                            DataCell(
                              IconButton(
                                tooltip: l.irView,
                                icon: const Icon(Icons.visibility_outlined),
                                onPressed: () => _open(row),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  for (final row in _items)
                    Card(
                      child: ListTile(
                        isThreeLine: true,
                        title: Text(row['reference'].toString()),
                        subtitle: Text(
                          '${widget.manage ? '${row['fullName']} · ${row['phoneNumber']}\n' : ''}${row['service']} ${row['permisOption'] == null ? '' : '· ${irValue(l, row['permisOption'])}'} · ${irValue(l, row['status'])}\n${row['createdAt']}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _open(row),
                      ),
                    ),
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
                          _load();
                        },
                  child: Text(l.irPrevious),
                ),
                Text('$_page / ${(_total / 20).ceil().clamp(1, 100000)}'),
                OutlinedButton(
                  onPressed: _busy || _page * 20 >= _total
                      ? null
                      : () {
                          _page++;
                          _load();
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
