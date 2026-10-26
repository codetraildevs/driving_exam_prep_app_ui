import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../data/irembo_repository.dart';
import 'irembo_widgets.dart';
import 'irembo_form_page.dart';

class IremboRequestPage extends StatefulWidget {
  final String id;
  final bool manage;
  final IremboRepository? repository;
  const IremboRequestPage({
    super.key,
    required this.id,
    this.manage = false,
    this.repository,
  });
  @override
  State<IremboRequestPage> createState() => _IremboRequestPageState();
}

class _IremboRequestPageState extends State<IremboRequestPage> {
  late final IremboRepository _repo = widget.repository ?? IremboRepository();
  Map<String, dynamic>? _row;
  List<Map<String, dynamic>> _staff = [];
  String? _status, _assigned, _error;
  bool _loading = true, _saving = false;
  final _reason = TextEditingController(),
      _note = TextEditingController(),
      _message = TextEditingController();
  bool get _isStaff {
    final auth = context.read<AuthBloc>().state;
    return widget.manage &&
        auth is AuthAuthenticated &&
        ['ADMIN', 'MANAGER'].contains(auth.user.role);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  void dispose() {
    _reason.dispose();
    _note.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final row = await _repo.get(widget.id);
      List<Map<String, dynamic>> staff = [];
      if (mounted && _isStaff) {
        try {
          staff = await _repo.staff();
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _row = row;
        _staff = staff;
        _status = row['status'];
        _assigned = row['assignedStaffId'];
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = irError(AppLocalizations.of(context), e));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _copy(String text) async {
    if (!_isStaff) return;
    final l = AppLocalizations.of(context);
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) irToast(context, l.irCopied);
    } catch (_) {
      if (mounted) irToast(context, l.irCopyFailed);
    }
  }

  Future<void> _call() async {
    if (!_isStaff) return;
    final l = AppLocalizations.of(context);
    try {
      if (!await launchUrl(
        Uri(scheme: 'tel', path: _row!['phoneNumber'].toString()),
      )) {
        throw StateError('call');
      }
    } catch (_) {
      if (mounted) irToast(context, l.irCallFailed);
    }
  }

  Future<void> _edit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => IremboFormPage(
          service: _row!['service'],
          permisOption: _row!['permisOption'],
          existing: _row,
          repository: _repo,
        ),
      ),
    );
    if (result == true && mounted) _load();
  }

  Future<void> _save() async {
    if (_saving || !_isStaff) return;
    final l = AppLocalizations.of(context);
    if (_status != _row!['status'] &&
        ['Needs Information', 'Rejected'].contains(_status) &&
        _reason.text.trim().isEmpty) {
      setState(() => _error = l.irReasonRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _repo.update(widget.id, {
        'version': int.parse(_row!['version'].toString()),
        'status': _status,
        'assignedStaffId': _assigned,
        'reason': _reason.text,
        'internalNote': _note.text,
        'applicantMessage': _message.text,
      });
      if (!mounted) return;
      _reason.clear();
      _note.clear();
      _message.clear();
      irToast(context, l.irSaved);
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = irError(l, e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _messages(AppLocalizations l, bool internal) {
    final rows = (_row?['messages'] as List? ?? [])
        .where((r) => (r['applicantVisible'].toString() == '0') == internal)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          internal ? l.irInternalNotes : l.irMessages,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(l.irNoMessages),
          ),
        for (final r in rows)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r['body'].toString()),
                  const SizedBox(height: 4),
                  Text(
                    '${r['staffName'] ?? '—'} · ${r['createdAt']}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _audit(AppLocalizations l) => ExpansionTile(
    title: Text(l.irAudit),
    children: [
      for (final row in _row?['audit'] as List? ?? [])
        _auditEntry(l, Map<String, dynamic>.from(row)),
    ],
  );
  Widget _auditEntry(AppLocalizations l, Map<String, dynamic> row) {
    Map changes = {};
    try {
      changes = jsonDecode(row['changesJson'].toString()) as Map;
    } catch (_) {}
    return ListTile(
      title: Text('${row['actorName'] ?? '—'} · ${row['createdAt']}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in changes.entries)
            Text(
              e.value is Map
                  ? '${irLabel(l, e.key.toString())}: ${irValue(l, e.value['from'])} → ${irValue(l, e.value['to'])}'
                  : e.value is bool
                  ? irLabel(l, e.key.toString())
                  : '${irLabel(l, e.key.toString())}: ${e.value}',
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final row = _row;
    final staff = _isStaff;
    final names = <String, String>{
      for (final s in _staff) s['id'].toString(): s['name'].toString(),
    };
    if (_assigned != null) names.putIfAbsent(_assigned!, () => l.irAssigned);
    final copyKeys = [
      if (row?['service'] == 'Permis') 'provisoireCode',
      'fullName',
      'phoneNumber',
      'nationalId',
      'dob',
    ];
    return IremboScaffold(
      title: row?['reference']?.toString() ?? l.irView,
      maxWidth: 800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(padding: const EdgeInsets.all(12), child: Text(_error!)),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: l.irRetry,
              onPressed: _loading || _saving ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
          ),
          if (row != null) ...[
            Text(
              irValue(l, row['status']),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text('${l.irSubmitted}: ${row['createdAt']}'),
            const SizedBox(height: 12),
            Text(l.irNotice),
            const SizedBox(height: 20),
            IremboDetailsFields(data: row),
            if (staff) ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: _call,
                    icon: const Icon(Icons.call),
                    label: Text(l.irCall),
                  ),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _edit,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l.irEdit),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final key in copyKeys)
                    OutlinedButton.icon(
                      onPressed: () => _copy(row[key]?.toString() ?? ''),
                      icon: const Icon(Icons.copy, size: 18),
                      label: Text('${l.irCopy}: ${irLabel(l, key)}'),
                    ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _copy(
                  copyKeys
                      .map((k) => '${irLabel(l, k)}: ${row[k] ?? ''}')
                      .join('\n'),
                ),
                icon: const Icon(Icons.copy_all),
                label: Text(l.irCopyAll),
              ),
            ],
            const Divider(height: 32),
            _messages(l, false),
            if (staff) ...[
              const Divider(height: 32),
              _messages(l, true),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey('status-$_status'),
                initialValue: _status,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l.irStatus,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final s in IremboRules.statuses)
                    DropdownMenuItem(value: s, child: Text(irValue(l, s))),
                ],
                onChanged: _saving ? null : (v) => setState(() => _status = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey('assigned-$_assigned'),
                initialValue: _assigned ?? '',
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l.irAssigned,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: '', child: Text(l.irUnassigned)),
                  for (final e in names.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: _saving
                    ? null
                    : (v) => setState(() => _assigned = v == '' ? null : v),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reason,
                enabled: !_saving,
                maxLength: 2000,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l.irReason,
                  border: const OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: _note,
                enabled: !_saving,
                maxLength: 2000,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l.irInternalNotes,
                  helperText: l.irInternalHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: _message,
                enabled: !_saving,
                maxLength: 2000,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l.irMessage,
                  border: const OutlineInputBorder(),
                ),
              ),
              FilledButton(
                onPressed: _saving || _loading ? null : _save,
                child: Text(l.irSave),
              ),
              const SizedBox(height: 16),
              _audit(l),
            ],
          ],
        ],
      ),
    );
  }
}
