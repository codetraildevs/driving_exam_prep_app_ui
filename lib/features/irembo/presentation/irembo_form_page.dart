import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../data/irembo_repository.dart';
import 'irembo_widgets.dart';
import 'irembo_payment_bar.dart';

class IremboFormPage extends StatefulWidget {
  final String service;
  final String? permisOption;
  final Map<String, dynamic>? existing;
  final IremboRepository? repository;
  const IremboFormPage({
    super.key,
    required this.service,
    this.permisOption,
    this.existing,
    this.repository,
  });
  @override
  State<IremboFormPage> createState() => _IremboFormPageState();
}

class _IremboFormPageState extends State<IremboFormPage> {
  final _form = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  late final IremboRepository _repo = widget.repository ?? IremboRepository();
  late final String _key = IremboRepository.newKey();
  late String _service;
  String? _option, _category, _language, _district;
  bool _busy = false, _submitted = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _service = widget.service;
    _option = widget.permisOption;
    final auth = context.read<AuthBloc>().state;
    final profile = auth is AuthAuthenticated ? auth.user : null;
    final data =
        widget.existing ??
        <String, dynamic>{
          'fullName': profile?.name,
          'phoneNumber': profile?.phoneNumber,
        };
    for (final key in [
      'fullName',
      'phoneNumber',
      'nationalId',
      'dob',
      'provisoireCode',
      'preferredExamDate',
    ]) {
      _controllers[key] = TextEditingController(
        text: data[key]?.toString() ?? '',
      );
    }
    _language = data['examLanguage'] as String?;
    _district = data['district'] as String?;
    _category = _option == 'Automatic' ? 'A' : data['category'] as String?;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _data() => IremboRules.applicable({
    for (final e in _controllers.entries) e.key: e.value.text,
    'service': _service,
    'permisOption': _option,
    'category': _category,
    'examLanguage': _language,
    'district': _district,
  });
  void _select(String service, String? option) {
    setState(() {
      if (_service != service) _controllers['provisoireCode']!.clear();
      if (_service != service || _option != option) {
        _category = option == 'Automatic' ? 'A' : null;
      }
      _service = service;
      _option = option;
    });
  }

  Future<void> _date(String key) async {
    final now = DateTime.now();
    final dob = key == 'dob';
    final current = DateTime.tryParse(_controllers[key]!.text);
    final first = dob ? DateTime(1) : DateTime(now.year, now.month, now.day);
    final last = dob ? now : DateTime(now.year + 10, 12, 31);
    final selected = await showDatePicker(
      context: context,
      initialDate:
          current != null && !current.isBefore(first) && !current.isAfter(last)
          ? current
          : (dob ? DateTime(now.year - 18, now.month, now.day) : now),
      firstDate: first,
      lastDate: last,
    );
    if (selected != null && mounted) {
      setState(
        () => _controllers[key]!.text = selected.toIso8601String().substring(
          0,
          10,
        ),
      );
    }
  }

  Future<void> _districtPicker() async {
    final l = AppLocalizations.of(context);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String search = '';
        return StatefulBuilder(
          builder: (context, update) => AlertDialog(
            title: Text(l.irSelectDistrict),
            content: SizedBox(
              width: 420,
              height: 360,
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l.irDistrict,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (v) => update(() => search = v),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final d in IremboRules.districts.where(
                          (d) => d.toLowerCase().contains(
                            search.trim().toLowerCase(),
                          ),
                        ))
                          ListTile(
                            title: Text(d),
                            selected: d == _district,
                            onTap: () => Navigator.pop(dialogContext, d),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l.irClose),
              ),
            ],
          ),
        );
      },
    );
    if (result != null && mounted) setState(() => _district = result);
  }

  Future<void> _save() async {
    if (_busy || _submitted) return;
    final valid = _form.currentState!.validate();
    if (!valid || IremboRules.validate(_data()) != null) {
      setState(() => _error = AppLocalizations.of(context).irInvalid);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final data = _data();
      final result = widget.existing == null
          ? await _repo.create({...data, 'requestKey': _key})
          : await _repo.update(widget.existing!['id'], {
              ...data,
              if (_controllers['preferredExamDate']!.text.isEmpty)
                'preferredExamDate': null,
              'version': int.parse(widget.existing!['version'].toString()),
            });
      if (!mounted) return;
      setState(() => _submitted = true);
      final l = AppLocalizations.of(context);
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: Text(l.irSaved),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l.irReference}: ${result['reference']}'),
              const SizedBox(height: 12),
              Text(l.irNotice),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text(l.irClose),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        if (e is IremboFailure && e.code == 'alreadySubmitted') {
          _submitted = true;
        }
        final message = irError(AppLocalizations.of(context), e);
        setState(() => _error = message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(String key, {bool date = false, bool optional = false}) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: ValueKey('irembo-$key'),
        controller: _controllers[key],
        readOnly: date,
        enabled: !_busy,
        keyboardType: ['phoneNumber', 'nationalId'].contains(key)
            ? TextInputType.phone
            : TextInputType.text,
        inputFormatters: key == 'nationalId'
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ]
            : null,
        decoration: InputDecoration(
          labelText: irLabel(l, key),
          border: const OutlineInputBorder(),
          suffixIcon: date
              ? IconButton(
                  tooltip: irLabel(l, key),
                  onPressed: _busy ? null : () => _date(key),
                  icon: const Icon(Icons.calendar_today),
                )
              : null,
        ),
        onTap: date ? () => _date(key) : null,
        validator: (v) {
          if (optional && (v ?? '').isEmpty) return null;
          if ((v ?? '').trim().isEmpty) return l.irRequired;
          final error = IremboRules.validate(_data());
          if (error != key) return null;
          return key == 'nationalId'
              ? l.irInvalidId
              : key == 'phoneNumber'
              ? l.irInvalidPhone
              : l.irInvalid;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IremboScaffold(
      title: widget.existing == null ? l.irNew : l.irEdit,
      maxWidth: 680,
      bottomBar: widget.existing == null
          ? IremboPaymentBar(service: _service, option: _option)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.irNotice),
            ),
          ),
          const SizedBox(height: 16),
          AbsorbPointer(
            absorbing: _busy,
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.existing != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Provisoire'),
                          selected: _service == 'Provisoire',
                          onSelected: (_) => _select('Provisoire', null),
                        ),
                        ChoiceChip(
                          label: Text('Permis · ${l.irManual}'),
                          selected: _service == 'Permis' && _option == 'Manual',
                          onSelected: (_) => _select('Permis', 'Manual'),
                        ),
                        ChoiceChip(
                          label: Text('Permis · ${l.irAutomatic}'),
                          selected:
                              _service == 'Permis' && _option == 'Automatic',
                          onSelected: (_) => _select('Permis', 'Automatic'),
                        ),
                      ],
                    )
                  else
                    Text(
                      _service == 'Permis'
                          ? 'Permis · ${irValue(l, _option)}'
                          : 'Provisoire',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  const SizedBox(height: 20),
                  _field('fullName'),
                  _field('phoneNumber'),
                  _field('nationalId'),
                  _field('dob', date: true),
                  if (_service == 'Permis') ...[
                    _field('provisoireCode'),
                    if (_option == 'Automatic')
                      Text('${l.irCategory}: A')
                    else
                      FormField<String>(
                        validator: (_) =>
                            _category == null ? l.irRequired : null,
                        builder: (state) => RadioGroup<String>(
                          groupValue: _category,
                          onChanged: (v) {
                            setState(() => _category = v);
                            state.didChange(v);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.irCategory),
                              for (final c in ['A', 'B', 'F'])
                                RadioListTile<String>(title: Text(c), value: c),
                              if (state.hasError)
                                Text(
                                  state.errorText!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                  DropdownButtonFormField<String>(
                    initialValue: _language,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l.irExamLanguage,
                      hintText: l.irLanguageHint,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      for (final v in ['rw', 'en', 'fr'])
                        DropdownMenuItem(value: v, child: Text(irValue(l, v))),
                    ],
                    onChanged: (v) => setState(() => _language = v),
                    validator: (v) => v == null ? l.irRequired : null,
                  ),
                  const SizedBox(height: 16),
                  FormField<String>(
                    key: ValueKey(_district),
                    validator: (_) => _district == null ? l.irRequired : null,
                    builder: (state) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _districtPicker,
                          icon: const Icon(Icons.location_on_outlined),
                          label: Text(_district ?? l.irSelectDistrict),
                        ),
                        if (state.hasError)
                          Text(
                            state.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field('preferredExamDate', date: true, optional: true),
                  if (_controllers['preferredExamDate']!.text.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(
                        () => _controllers['preferredExamDate']!.clear(),
                      ),
                      child: Text(l.irClose),
                    ),
                  Text(l.irDateNotice),
                  const SizedBox(height: 20),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  FilledButton(
                    onPressed: _busy || _submitted ? null : _save,
                    child: Text(
                      _busy
                          ? l.irPending
                          : widget.existing == null
                          ? l.irConfirm
                          : l.irSave,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
