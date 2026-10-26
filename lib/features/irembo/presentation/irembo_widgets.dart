import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../data/irembo_repository.dart';

String irLabel(AppLocalizations l, String key) => switch (key) {
  'fullName' => l.irFullName, 'phoneNumber' => l.irPhone, 'nationalId' => l.irNationalId,
  'dob' => l.irDob, 'service' => l.irService, 'permisOption' => l.irOption,
  'category' => l.irCategory, 'provisoireCode' => l.irProvisoireCode,
  'examLanguage' => l.irExamLanguage, 'district' => l.irDistrict,
  'preferredExamDate' => l.irExamDate, 'reference' => l.irReference,
  'status' => l.irStatus, 'createdAt' => l.irSubmitted, 'updatedAt' => l.irUpdated,
  'assignedStaffId' => l.irAssigned, 'reason' => l.irReason,
  'created' => l.irCreated, 'internalNoteAdded' => l.irInternalNotes,
  'applicantMessageAdded' => l.irMessages, _ => l.irChange,
};
String irValue(AppLocalizations l, dynamic value) => switch(value?.toString()) {
  'Manual' => l.irManual, 'Automatic' => l.irAutomatic,
  'rw' => l.irKinyarwanda, 'en' => l.irEnglish, 'fr' => l.irFrench,
  'Pending' => l.irPending, 'In Review' => l.irInReview,
  'Needs Information' => l.irNeedsInformation, 'Completed' => l.irCompleted,
  'Rejected' => l.irRejected, 'Cancelled' => l.irCancelled,
  null || '' => '—', _ => value.toString(),
};
String irError(AppLocalizations l, Object error) {
  final code = error is IremboFailure ? error.code : '';
  if (code == 'conflict') return l.irConflict;
  if (code == 'reasonRequired') return l.irReasonRequired;
  if (code.startsWith('invalid')) return l.irInvalid;
  return l.irUnavailable;
}
void irToast(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
class IremboScaffold extends StatelessWidget {
  final String title; final Widget child; final double maxWidth;
  const IremboScaffold({super.key, required this.title, required this.child, this.maxWidth=960});
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(top:false, child: Column(children:[
    AppPageHeader(title:title), Expanded(child: SingleChildScrollView(padding:const EdgeInsets.all(16),
      child: Center(child: ConstrainedBox(constraints:BoxConstraints(maxWidth:maxWidth),child:child)))),
  ])));
}
class IremboDetailsFields extends StatelessWidget {
  final Map<String,dynamic> data;
  const IremboDetailsFields({super.key, required this.data});
  @override Widget build(BuildContext context) {
    final l=AppLocalizations.of(context);
    final keys=['fullName','phoneNumber','nationalId','dob','service',
      if(data['service']=='Permis') ...['permisOption','category','provisoireCode'],
      'examLanguage','district',if(data['preferredExamDate']!=null) 'preferredExamDate'];
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[for(final key in keys)
      Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(irLabel(l,key),style:Theme.of(context).textTheme.labelMedium),
        Text(irValue(l,data[key]),style:Theme.of(context).textTheme.bodyLarge),
      ]))]);
  }
}
