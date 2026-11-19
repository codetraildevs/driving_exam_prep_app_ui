import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../data/referral_repository.dart';
import '../widgets/referral_overview.dart';

class ReferralPage extends StatefulWidget {
  final ReferralRepository? repository;
  const ReferralPage({super.key, this.repository});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  String? _code;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(
            title: l10n.referralTitle,
            subtitle: _code == null ? null : l10n.referralCodeLabel(_code!),
          ),
          Expanded(
            child: ReferralOverview(
              repository: widget.repository,
              onLoaded: (summary) {
                if (_code != summary.code) {
                  setState(() => _code = summary.code);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
