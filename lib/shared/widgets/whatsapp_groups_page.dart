import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/generated/app_localizations.dart';
import '../network/api_helper.dart';
import '../network/offline_cache.dart';
import '../session/auth_session.dart';
import 'app_page_header.dart';
import '../responsive/responsive_layout.dart';

class WhatsappGroupsPage extends StatefulWidget {
  final bool manage;
  // Optional loader keeps loading and retry behavior independently testable.
  final Future<ApiResponse> Function()? loadGroups;
  const WhatsappGroupsPage({super.key, this.manage = false, this.loadGroups});

  @override
  State<WhatsappGroupsPage> createState() => _WhatsappGroupsPageState();
}

class _WhatsappGroupsPageState extends State<WhatsappGroupsPage> {
  String _text(String en, String rw, String fr) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'rw': return rw;
      case 'fr': return fr;
      default: return en;
    }
  }

  List<dynamic> _groups = [];
  bool _loading = true;
  bool _saving = false;
  bool _requestInFlight = false;
  String? _error;
  String? _cacheKey;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_requestInFlight || !mounted) return;
    _requestInFlight = true;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      try {
        final user = await AuthSession().getUser();
        _cacheKey = user == null ? null : 'whatsapp_groups_${user.id}';
        if (_cacheKey != null && _groups.isEmpty && !widget.manage) {
          final cached = await OfflineCache().load(_cacheKey!);
          if (mounted && cached is List) {
            setState(() { _groups = cached; _saved = true; });
          }
        }
      } catch (_) { /* Storage failure must not block the directory. */ }
      final result = await (widget.loadGroups?.call() ??
          ApiHelper().get('/api/whatsapp-groups'));
      if (!mounted) return;
      setState(() {
        if (result.isSuccess) {
          _groups = result.dataList;
          _saved = false;
        } else {
          _error = _loadError;
        }
      });
      if (result.isSuccess && _cacheKey != null && !widget.manage) {
        try { await OfflineCache().save(_cacheKey!, result.dataList); } catch (_) {}
      }
    } catch (_) {
      if (mounted) setState(() => _error = _loadError);
    } finally {
      _requestInFlight = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _loadError => _text(
    'Unable to load WhatsApp groups. Check your internet connection and try again.',
    'Ntibishobotse kubona amatsinda ya WhatsApp. Reba ko ufite interineti wongere ugerageze.',
    'Impossible de charger les groupes WhatsApp. Vérifiez votre connexion Internet et réessayez.',
  );

  void _message(String text) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _edit([Map<String, dynamic>? group]) async {
    final name = TextEditingController(text: group?['name'] as String? ?? '');
    final url = TextEditingController(text: group?['inviteUrl'] as String? ?? '');
    final form = GlobalKey<FormState>();
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(group == null ? _text('Add WhatsApp group', 'Ongeramo itsinda rya WhatsApp', 'Ajouter un groupe WhatsApp') : _text('Edit WhatsApp group', 'Hindura itsinda rya WhatsApp', 'Modifier le groupe WhatsApp')),
        content: Form(
          key: form,
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: name, maxLength: 120, decoration: InputDecoration(labelText: _text('Group name', 'Izina ry’itsinda', 'Nom du groupe')), validator: (v) => (v?.trim().isEmpty ?? true) ? _text('Enter a name', 'Andika izina', 'Saisissez un nom') : null),
            TextFormField(controller: url, maxLength: 500, decoration: InputDecoration(labelText: _text('WhatsApp invite link', 'Ihuza ryo kwinjira muri WhatsApp', 'Lien d’invitation WhatsApp')), validator: (v) {
              final uri = Uri.tryParse(v?.trim() ?? '');
              return uri != null && uri.scheme == 'https' && uri.host == 'chat.whatsapp.com' && RegExp(r'^/[A-Za-z0-9]+$').hasMatch(uri.path) && uri.userInfo.isEmpty && !uri.hasPort && !uri.hasFragment ? null : _text('Enter a valid WhatsApp invite link', 'Andika ihuza rya WhatsApp rikwiye', 'Saisissez un lien WhatsApp valide');
            }),
          ])),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_text('Cancel', 'Reka', 'Annuler'))),
          FilledButton(onPressed: () {
            if (form.currentState!.validate()) Navigator.pop(ctx, {'name': name.text.trim(), 'inviteUrl': url.text.trim()});
          }, child: Text(_text('Save', 'Bika', 'Enregistrer'))),
        ],
      ),
    );
    // Let the dialog route finish disposing its text fields before controllers.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    name.dispose();
    url.dispose();
    if (data == null || !mounted) return;
    setState(() => _saving = true);
    final result = group == null
        ? await ApiHelper().post('/api/whatsapp-groups', body: data)
        : await ApiHelper().put('/api/whatsapp-groups/${group['id']}', body: data);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isSuccess) { await _load(); } else { _message(result.errorMessage ?? _text('Unable to save group', 'Ntibishobotse kubika itsinda', 'Impossible d’enregistrer le groupe')); }
  }

  Future<void> _delete(Map<String, dynamic> group) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(_text('Delete group?', 'Siba itsinda?', 'Supprimer le groupe ?')),
      content: Text(group['name'] as String),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(_text('Cancel', 'Reka', 'Annuler'))),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(_text('Delete', 'Siba', 'Supprimer'))),
      ],
    ));
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    final result = await ApiHelper().delete('/api/whatsapp-groups/${group['id']}');
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isSuccess) { await _load(); } else { _message(result.errorMessage ?? _text('Unable to delete group', 'Ntibishobotse gusiba itsinda', 'Impossible de supprimer le groupe')); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: widget.manage ? FloatingActionButton(onPressed: _saving ? null : () => _edit(), child: const Icon(Icons.add)) : null,
    body: Column(children: [
      AppPageHeader(title: AppLocalizations.of(context).joinGroup, trailing: IconButton(
        key: const ValueKey('whatsapp-refresh'), tooltip: AppLocalizations.of(context).commonRetry,
        onPressed: _loading || _saving ? null : _load, icon: const Icon(Icons.refresh, color: Colors.white))),
      Expanded(child: _loading && _groups.isEmpty ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
      onRefresh: _load,
      child: ListView(padding: const EdgeInsets.all(16), physics: const AlwaysScrollableScrollPhysics(), children: [ConstrainedContent(padding: EdgeInsets.zero, maxWidth: 800, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(widget.manage ? AppLocalizations.of(context).waManageIntro : AppLocalizations.of(context).waIntro))),
        if (_saved) Padding(padding: const EdgeInsets.all(12), child: Text(AppLocalizations.of(context).waCached)),
        if (_saving || _loading) const LinearProgressIndicator(),
        if (_error != null) Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_error!),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).commonRetry),
            ),
          ]),
        )),
        if (_error == null && _groups.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Text(_text('No WhatsApp groups available yet.', 'Nta matsinda ya WhatsApp arahari.', 'Aucun groupe WhatsApp disponible.'))),
        for (final item in _groups) Card(child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Icon(Icons.groups, color: Theme.of(context).colorScheme.primary)),
          title: Text(item['name'] as String),
          subtitle: widget.manage ? Text(item['inviteUrl'] as String, maxLines: 2, overflow: TextOverflow.ellipsis) : Text(AppLocalizations.of(context).joinGroup),
          onTap: widget.manage ? null : () async {
            try {
              final uri = Uri.parse(item['inviteUrl'] as String);
              if (uri.scheme != 'https' || uri.host != 'chat.whatsapp.com' || !await launchUrl(uri, mode: LaunchMode.externalApplication)) _message(_text('Unable to open group', 'Ntibishobotse gufungura itsinda', 'Impossible d’ouvrir le groupe'));
            } catch (_) { _message(_text('Unable to open group', 'Ntibishobotse gufungura itsinda', 'Impossible d’ouvrir le groupe')); }
          },
          trailing: widget.manage ? Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(tooltip: _text('Edit', 'Hindura', 'Modifier'), onPressed: _saving ? null : () => _edit(Map<String, dynamic>.from(item)), icon: const Icon(Icons.edit)),
            IconButton(tooltip: _text('Delete', 'Siba', 'Supprimer'), onPressed: _saving ? null : () => _delete(Map<String, dynamic>.from(item)), icon: const Icon(Icons.delete_outline)),
          ]) : const Icon(Icons.open_in_new),
        )),
        const SizedBox(height: 80),
      ]))]),
    )),
    ]),
  );
}
