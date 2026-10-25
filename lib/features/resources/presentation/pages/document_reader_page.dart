import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../domain/study_document.dart';

class DocumentReaderPage extends StatefulWidget {
  final StudyDocument document;
  const DocumentReaderPage({super.key, required this.document});
  @override
  State<DocumentReaderPage> createState() => _DocumentReaderPageState();
}

class _DocumentReaderPageState extends State<DocumentReaderPage> {
  final _controller = PdfViewerController();
  late Future<ByteData> _data;
  int _page = 1;
  int _total = 0;
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    _data = rootBundle.load(widget.document.assetPath);
  }

  void _retry() {
    setState(() {
      _attempt++;
      _total = 0;
      _page = 1;
      _data = rootBundle.load(widget.document.assetPath);
    });
  }

  Widget _error(AppLocalizations l10n) => Center(child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.description_outlined, size: 40),
      const SizedBox(height: 12),
      Text(l10n.resourcesReadError, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
      const SizedBox(height: 12),
      FilledButton(onPressed: _retry, child: Text(l10n.commonRetry)),
    ]),
  ));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(body: Column(children: [
      AppPageHeader(title: widget.document.title(l10n)),
      Expanded(child: FutureBuilder<ByteData>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasError) return _error(l10n);
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.requireData;
          return PdfViewer.data(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
            key: ValueKey(_attempt),
            sourceName: widget.document.assetPath,
            controller: _controller,
            params: PdfViewerParams(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              // No external URL handler: documents remain inside the app.
              linkHandlerParams: null,
              loadingBannerBuilder: (_, __, ___) => const Center(child: CircularProgressIndicator()),
              errorBannerBuilder: (_, __, ___, ____) => _error(l10n),
              onViewerReady: (document, controller) {
                if (mounted) setState(() => _total = document.pages.length);
              },
              onPageChanged: (page) {
                if (mounted && page != null && page != _page) setState(() => _page = page);
              },
            ),
          );
        },
      )),
      if (_total > 0) SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
          IconButton(tooltip: l10n.resourcesPreviousPage,
            onPressed: _total > 0 && _page > 1 ? () => _controller.goToPage(pageNumber: _page - 1) : null,
            icon: const Icon(Icons.chevron_left)),
          Text(_total > 0 ? l10n.resourcesPageCount(_page, _total) : l10n.resourcesLoading,
            style: AppTextStyles.bodySmall),
          IconButton(tooltip: l10n.resourcesNextPage,
            onPressed: _total > 0 && _page < _total ? () => _controller.goToPage(pageNumber: _page + 1) : null,
            icon: const Icon(Icons.chevron_right)),
          IconButton(tooltip: l10n.resourcesZoomOut,
            onPressed: _total > 0 ? () => _controller.zoomDown() : null,
            icon: const Icon(Icons.zoom_out)),
          IconButton(tooltip: l10n.resourcesZoomIn,
            onPressed: _total > 0 ? () => _controller.zoomUp() : null,
            icon: const Icon(Icons.zoom_in)),
        ]),
      )),
    ]));
  }
}
