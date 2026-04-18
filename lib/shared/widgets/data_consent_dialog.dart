import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shows a data-consent dialog on first launch.
///
/// Once accepted the preference is persisted and the dialog is never shown again.
class DataConsentDialog {
  static const _consentKey = 'data_consent_accepted';
  static bool _showing = false;

  /// Returns `true` if the user has already accepted the data consent.
  static Future<bool> hasAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  /// Shows the consent dialog if the user has not yet accepted.
  /// Returns immediately if consent was already given.
  /// Safe to call from multiple pages — only one dialog will ever appear.
  static Future<void> showIfNeeded(BuildContext context) async {
    if (_showing) return;
    if (await hasAccepted()) return;
    if (!context.mounted) return;
    _showing = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => _ConsentDialogContent(
        onAccept: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_consentKey, true);
          _showing = false;
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        },
        onReadPolicy: () {
          // Open privacy policy page in a new route via the root navigator.
          Navigator.of(dialogContext, rootNavigator: true).push(
            MaterialPageRoute<void>(
              builder: (_) => const _InlinePrivacyPolicyPage(),
            ),
          );
        },
      ),
    );
    _showing = false;
  }
}

class _ConsentDialogContent extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onReadPolicy;

  const _ConsentDialogContent({
    required this.onAccept,
    required this.onReadPolicy,
  });

  @override
  State<_ConsentDialogContent> createState() => _ConsentDialogContentState();
}

class _ConsentDialogContentState extends State<_ConsentDialogContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.surfaceDark2 : AppColors.neutral100;

    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Gradient header ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradientFor(
                          isDark ? Brightness.dark : Brightness.light),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.consentTitle,
                          style: AppTextStyles.heading5.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // ── Body ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Data collection items
                        _DataItem(
                          icon: Icons.person_outline_rounded,
                          label: l10n.consentItemPhone,
                          detail: l10n.consentItemPhoneDetail,
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        _DataItem(
                          icon: Icons.fingerprint_rounded,
                          label: l10n.consentItemDevice,
                          detail: l10n.consentItemDeviceDetail,
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        _DataItem(
                          icon: Icons.trending_up_rounded,
                          label: l10n.consentItemProgress,
                          detail: l10n.consentItemProgressDetail,
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        _DataItem(
                          icon: Icons.cloud_off_rounded,
                          label: l10n.consentItemCache,
                          detail: l10n.consentItemCacheDetail,
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),

                        const SizedBox(height: 12),

                        // Security badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                size: 18,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.consentSecurityNote,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: subtextColor,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Privacy policy link
                        InkWell(
                          onTap: widget.onReadPolicy,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.policy_rounded,
                                  size: 16,
                                  color: AppColors.primaryLight,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.consentReadPolicy,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: AppColors.primaryLight,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Accept button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradientFor(
                                  isDark ? Brightness.dark : Brightness.light),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: widget.onAccept,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),  
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded( child: Text(
                                    l10n.consentAccept,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  )
                                ],
                              )
                              
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single data collection item row with icon and description.
class _DataItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final Color cardColor;
  final Color textColor;
  final Color subtextColor;

  const _DataItem({
    required this.icon,
    required this.label,
    required this.detail,
    required this.cardColor,
    required this.textColor,
    required this.subtextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 11,
                      color: subtextColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lightweight inline privacy-policy page shown from the consent dialog.
/// Uses the root navigator so it stacks on top of the dialog.
class _InlinePrivacyPolicyPage extends StatelessWidget {
  const _InlinePrivacyPolicyPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.consentReadPolicy),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.privacyIntro,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
            const SizedBox(height: 20),
            _section(l10n.privacyDataCollection, l10n.privacyDataCollectionBody),
            _section(l10n.privacyDataUsage, l10n.privacyDataUsageBody),
            _section(l10n.privacyDataProtection, l10n.privacyDataProtectionBody),
            _section(l10n.privacyDataSharing, l10n.privacyDataSharingBody),
            _section(l10n.privacyUserRights, l10n.privacyUserRightsBody),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.heading6
                  .copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(body,
              style: AppTextStyles.bodySmall.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}
