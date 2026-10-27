import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'irembo_widgets.dart';

class IremboPaymentBar extends StatelessWidget {
  /// MoMo Pay merchant code for Irembo service fees only; the subscription
  /// page uses the owner destinations in `lib/config/payment_config.dart`.
  static const momoPayCode = '644203';
  final String? service;
  final String? option;
  const IremboPaymentBar({super.key, this.service, this.option});

  static int? fee(String? service, String? option) {
    if (service == 'Provisoire') return 1000;
    if (service == 'Permis' && option == 'Manual') return 1000;
    if (service == 'Permis' && option == 'Automatic') return 5000;
    return null;
  }

  /// The exact USSD request the applicant dials, e.g. `*182*8*1*644203*1000#`.
  static String? ussdCode(String? service, String? option) {
    final amount = fee(service, option);
    return amount == null ? null : '*182*8*1*$momoPayCode*$amount#';
  }

  Future<void> _dial(BuildContext context, String code) async {
    final l = AppLocalizations.of(context);
    try {
      final opened = await launchUrl(Uri(scheme: 'tel', path: code));
      if (!opened && context.mounted) irToast(context, l.irCallFailed);
    } catch (_) {
      if (context.mounted) irToast(context, l.irCallFailed);
    }
  }

  Future<void> _copy(BuildContext context, String code) async {
    final l = AppLocalizations.of(context);
    try {
      await Clipboard.setData(ClipboardData(text: code));
      if (context.mounted) irToast(context, l.irCopied);
    } catch (_) {
      if (context.mounted) irToast(context, l.irCopyFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final amount = fee(service, option);
    final code = ussdCode(service, option);
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.irServiceFee,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  if (amount != null)
                    Text(
                      '$amount RWF',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const ValueKey('irembo-pay'),
                icon: const Icon(Icons.phone_outlined),
                label: Text(
                  amount == null
                      ? l.irChooseService
                      : '${l.irPay} · $amount RWF',
                ),
                onPressed: code == null ? null : () => _dial(context, code),
              ),
              if (code != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        code,
                        key: const ValueKey('irembo-payment-code'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      key: const ValueKey('irembo-copy-payment'),
                      tooltip: l.irCopy,
                      onPressed: () => _copy(context, code),
                      icon: const Icon(Icons.copy_outlined, size: 20),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
