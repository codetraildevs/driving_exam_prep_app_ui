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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final amount = fee(service, option);
    final code = amount == null ? null : '*182*8*1*$momoPayCode*$amount#';
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.irServiceFee,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const ValueKey('irembo-pay'),
                  icon: const Icon(Icons.phone_outlined),
                  label: Text(
                    amount == null
                        ? l.irChooseService
                        : '${l.irPay} · $amount RWF',
                  ),
                  onPressed: code == null
                      ? null
                      : () async {
                          try {
                            final opened = await launchUrl(
                              Uri(scheme: 'tel', path: code),
                            );
                            if (!opened && context.mounted) {
                              irToast(context, l.irCallFailed);
                            }
                          } catch (_) {
                            if (context.mounted) {
                              irToast(context, l.irCallFailed);
                            }
                          }
                        },
                ),
              ),
              if (code != null)
                TextButton(
                  key: const ValueKey('irembo-copy-payment'),
                  onPressed: () async {
                    try {
                      await Clipboard.setData(ClipboardData(text: code));
                      if (context.mounted) irToast(context, l.irCopied);
                    } catch (_) {
                      if (context.mounted) irToast(context, l.irCopyFailed);
                    }
                  },
                  child: Text(code),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
