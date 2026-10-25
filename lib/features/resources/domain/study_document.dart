import '../../../l10n/generated/app_localizations.dart';

enum StudyDocument {
  gazette('assets/files/Igazeti.pdf'),
  roadSigns('assets/files/Ibyapa.pdf');

  final String assetPath;
  const StudyDocument(this.assetPath);

  String title(AppLocalizations l10n) => switch (this) {
    gazette => l10n.resourcesGazette,
    roadSigns => l10n.resourcesRoadSigns,
  };
}
