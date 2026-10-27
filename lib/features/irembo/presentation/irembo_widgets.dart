import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../data/irembo_repository.dart';

/// The three requests an applicant may submit: Provisoire, Permis · Manual and
/// Permis · Automatic. An account can submit one request in each slot.
const iremboSlots = ['Provisoire', 'Permis|Manual', 'Permis|Automatic'];

String iremboSlot(String? service, String? option) => service == null
    ? ''
    : service == 'Permis'
    ? 'Permis|${option ?? ''}'
    : 'Provisoire';

String irLabel(AppLocalizations l, String key) => switch (key) {
  'fullName' => l.irFullName,
  'phoneNumber' => l.irPhone,
  'nationalId' => l.irNationalId,
  'dob' => l.irDob,
  'service' => l.irService,
  'permisOption' => l.irOption,
  'category' => l.irCategory,
  'provisoireCode' => l.irProvisoireCode,
  'examLanguage' => l.irExamLanguage,
  'district' => l.irDistrict,
  'preferredExamDate' => l.irExamDate,
  'reference' => l.irReference,
  'status' => l.irStatus,
  'createdAt' => l.irSubmitted,
  'updatedAt' => l.irUpdated,
  'assignedStaffId' => l.irAssigned,
  'reason' => l.irReason,
  'created' => l.irCreated,
  'internalNoteAdded' => l.irInternalNotes,
  'applicantMessageAdded' => l.irMessages,
  _ => l.irChange,
};
String irValue(AppLocalizations l, dynamic value) =>
    switch (value?.toString()) {
      'Manual' => l.irManual,
      'Automatic' => l.irAutomatic,
      'rw' => l.irKinyarwanda,
      'en' => l.irEnglish,
      'fr' => l.irFrench,
      'Pending' => l.irPending,
      'In Review' => l.irInReview,
      'Needs Information' => l.irNeedsInformation,
      'Completed' => l.irCompleted,
      'Rejected' => l.irRejected,
      'Cancelled' => l.irCancelled,
      null || '' => '—',
      _ => value.toString(),
    };
String irError(AppLocalizations l, Object error) {
  final code = error is IremboFailure ? error.code : '';
  final status = error is IremboFailure ? error.statusCode : null;
  if (code == 'iremboSetupRequired') return l.irServerSetup;
  if (code == 'iremboDeleteUnavailable') return l.irDeleteUnavailable;
  if (code == 'alreadySubmitted') return l.irAlreadySubmitted;
  if (code == 'notFound' || status == 401 || status == 403) {
    return l.irAccessUnavailable;
  }
  if (status == 404) return l.irServerSetup;
  if (status != null && status >= 500) return l.irServiceUnavailable;
  if (code == 'conflict') return l.irConflict;
  if (code == 'reasonRequired') return l.irReasonRequired;
  if (code.startsWith('invalid')) return l.irInvalid;
  return l.irUnavailable;
}

void irToast(BuildContext context, String message) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));

class IremboScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final double maxWidth;
  final Widget? bottomBar;
  const IremboScaffold({
    super.key,
    required this.title,
    required this.child,
    this.maxWidth = 960,
    this.bottomBar,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: bottomBar,
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          AppPageHeader(title: title),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class IremboDetailsFields extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool compact, copyable;
  const IremboDetailsFields({
    super.key,
    required this.data,
    this.compact = false,
    this.copyable = false,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final keys = [
      'fullName',
      'phoneNumber',
      'nationalId',
      'dob',
      if (compact) 'preferredExamDate',
      if (!compact) ...[
        'service',
        if (data['service'] == 'Permis') ...[
          'permisOption',
          'category',
          'provisoireCode',
        ],
        'examLanguage',
        'district',
        if (data['preferredExamDate'] != null) 'preferredExamDate',
      ],
    ];
    final messages = data['messages'];
    String? latestMessage;
    String? latestAuthor;
    if (messages is List) {
      final appMsg =
          messages
              .map((m) => Map<String, dynamic>.from(m as Map))
              .where((m) => m['applicantVisible'] == true)
              .toList()
            ..sort((a, b) {
              final da =
                  DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
                  DateTime.now();
              final db =
                  DateTime.tryParse(b['createdAt']?.toString() ?? '') ??
                  DateTime.now();
              return da.compareTo(db);
            });
      if (appMsg.isNotEmpty) {
        latestMessage = appMsg.last['body'].toString();
        latestAuthor = (appMsg.last['staffName'] ?? '').toString();
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final key in keys)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        irLabel(l, key),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        irValue(l, data[key]),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                if (copyable)
                  IconButton(
                    key: ValueKey('copy-${data['id']}-$key'),
                    tooltip: '${l.irCopy}: ${irLabel(l, key)}',
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    onPressed: data[key] == null || data[key].toString().isEmpty
                        ? null
                        : () async {
                            try {
                              await Clipboard.setData(
                                ClipboardData(text: data[key].toString()),
                              );
                              if (context.mounted) irToast(context, l.irCopied);
                            } catch (_) {
                              if (context.mounted) {
                                irToast(context, l.irCopyFailed);
                              }
                            }
                          },
                  ),
              ],
            ),
          ),
        if (latestMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${l.irMessages}: $latestMessage',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                if ((latestAuthor ?? '').isNotEmpty)
                  Text(
                    ' — $latestAuthor',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
