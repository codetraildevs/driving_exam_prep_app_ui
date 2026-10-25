import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../domain/study_document.dart';
import 'document_reader_page.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(body: Column(children: [
      AppPageHeader(title: l10n.resourcesTitle),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l10n.resourcesDescription, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            for (final document in StudyDocument.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2))),
                  child: InkWell(
                    key: ValueKey('resource-${document.name}'),
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => DocumentReaderPage(document: document))),
                    child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                      Icon(document == StudyDocument.gazette ? Icons.menu_book_outlined : Icons.traffic_outlined,
                        color: AppColors.primary, size: 30),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(document.title(l10n), style: AppTextStyles.heading5),
                        const SizedBox(height: 4),
                        Text(l10n.resourcesOfflinePdf, style: AppTextStyles.bodySmall),
                      ])),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: AppColors.primary),
                    ])),
                  ),
                ),
              ),
          ]),
        )),
      )),
    ]));
  }
}
