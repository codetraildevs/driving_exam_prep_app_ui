
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';
import '../locale/locale_notifier.dart';
import '../network/api_helper.dart';
import '../session/auth_session.dart';

/// Creative, responsive language selector optimized for a Rwanda traffic app.
/// - Traffic-themed animated header
/// - Responsive grid/list for language cards
/// - Animated selection, gradient CTA, accessible semantics
class LanguageSelectorPage extends StatefulWidget {
  const LanguageSelectorPage({Key? key}) : super(key: key);

  @override
  State<LanguageSelectorPage> createState() => _LanguageSelectorPageState();
}

class _LanguageSelectorPageState extends State<LanguageSelectorPage>
    with SingleTickerProviderStateMixin {
  late String _selectedCode;
  late final AnimationController _carController;

  // Short, native-language taglines to hint at benefits for a traffic app.
  static const Map<String, String> _nativeTaglines = {
    'en': 'Traffic alerts & signs',
    'fr': 'Alertes trafic & panneaux',
    'rw': 'Amategeko y\'umuhanda n\'ibyapa',
  };

  @override
  void initState() {
    super.initState();

    final deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final supported =
        LocaleNotifier.supportedLocales.map((l) => l.languageCode);
    _selectedCode = supported.contains(deviceCode) ? deviceCode : 'rw';

    // Car animation: loops left-to-right slowly to give life to the header.
    _carController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();
  }

  @override
  void dispose() {
    _carController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
 
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Localizations.override(
        context: context,
        locale: Locale(_selectedCode),
        child: Builder(builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            extendBodyBehindAppBar: true,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Curved gradient header
                  ClipPath(
                    clipper: _CurvedHeaderClipper(),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 24,
                        bottom: 32,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradientFor(
                            Theme.of(context).brightness),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language,
                              size: 36, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            l10n.languageSelectTitle,
                            style: AppTextStyles.heading4.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              l10n.languageSelectDescription,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          
                  // Body content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _useDeviceLanguage,
                                icon: const Icon(Icons.phone_iphone_outlined, size: 18),
                                label: Text(l10n.languageSelectDeviceLanguage),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.18)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Tooltip(
                              message: l10n.languageSelectHelpTooltip,
                              child: IconButton(
                                onPressed: () => _showQuickHelp(context),
                                icon: const Icon(Icons.help_outline),
                                color: AppColors.neutral600,
                              ),
                            )
                          ],
                        ),
          
                        const SizedBox(height: 16),
          
                        // Language options: list or grid based on width
                        isWide ? _buildGridOptions() : _buildListOptions(),
          
                        // CTA area
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildConfirmButton(context, l10n),
                            ),
                          ],
                        ),
          
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            context.go('/landing');
                          },
                          child: Text(
                            l10n.languageSelectMaybeLater,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.neutral600),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, AppLocalizations l10n) {
    return Semantics(
      button: true,
      label: 'Confirm language',
      child: ElevatedButton(
        onPressed: _onConfirm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
          // Gradient via Material's elevation + primary color; emulate gradient with Container
          backgroundColor: AppColors.primary,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.1)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            child: Text(
              l10n.authContinue,
              style: AppTextStyles.buttonLarge
                  .copyWith(color: AppColors.textInverse),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListOptions() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      children: LocaleNotifier.supportedLocales.map((locale) {
        final code = locale.languageCode;
        final name = LocaleNotifier.localeNames[code] ?? code.toUpperCase();
        final tagline = _nativeTaglines[code] ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _CreativeLanguageCard(
            name: name,
            tagline: tagline,
            code: code,
            isSelected: code == _selectedCode,
            onTap: () => setState(() => _selectedCode = code),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridOptions() {
    final items = LocaleNotifier.supportedLocales
        .map((l) => l.languageCode)
        .toList(growable: false);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 92,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final code = items[index];
        final name = LocaleNotifier.localeNames[code] ?? code.toUpperCase();
        final tagline = _nativeTaglines[code] ?? '';
        return _CreativeLanguageCard(
          name: name,
          tagline: tagline,
          code: code,
          isSelected: code == _selectedCode,
          onTap: () => setState(() => _selectedCode = code),
        );
      },
    );
  }

  Future<void> _onConfirm() async {
    ProviderScope.containerOf(context, listen: false).read(localeProvider.notifier).setLocale(Locale(_selectedCode));
    // Best-effort sync to backend if authenticated
    syncLanguageToBackend(_selectedCode);
    if (!mounted) return;
    context.go('/landing');
  }

  void _useDeviceLanguage() {
    final deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final supported =
        LocaleNotifier.supportedLocales.map((l) => l.languageCode);
    final code = supported.contains(deviceCode) ? deviceCode : 'en';
    setState(() => _selectedCode = code);
  }

  void _showQuickHelp(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.languageSelectHelpTitle, style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(
                l10n.languageSelectHelpContent,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.commonGotIt),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Public helper: best-effort sync of preferred language to the backend.
Future<void> syncLanguageToBackend(String langCode) async {
  try {
    final session = AuthSession();
    final token = await session.getToken();
    if (token == null || token.isEmpty) return;
    final user = await session.getUser();
    if (user == null) return;
    await ApiHelper().put(
      '/api/users/${user.id}',
      body: {'preferredLanguage': langCode},
    );
  } catch (e) {
    // Ignore errors — language is already saved locally
    assert(() {
      // ignore: avoid_print
      print('[LanguageSelector] syncLanguageToBackend error: $e');
      return true;
    }());
  }
}

/// Creative language card with animated selection and tagline.
class _CreativeLanguageCard extends StatelessWidget {
  final String name;
  final String tagline;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _CreativeLanguageCard({
    required this.name,
    required this.tagline,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Visual scale when selected for a lively interaction.
    final scale = isSelected ? 1.02 : 1.0;
    final borderColor =
        isSelected ? AppColors.primary : AppColors.neutral200;
    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.06)
        : AppColors.surface;

    return Semantics(
      selected: isSelected,
      label: '$name language option',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.diagonal3Values(scale, scale, 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Row(
            children: [
              // Flag or icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _flagEmoji(code),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tagline,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // animated check
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                transitionBuilder: (child, anim) {
                  return ScaleTransition(scale: anim, child: child);
                },
                child: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primary, key: ValueKey('sel'))
                    : const Icon(Icons.chevron_right, color: AppColors.neutral500, key: ValueKey('unsel')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _flagEmoji(String code) {
    switch (code) {
      case 'fr':
        return '🇫🇷';
      case 'rw':
        return '🇷🇼';
      default:
        return '🇬🇧';
    }
  }
}

/// Reusable dialog-based selector (for Settings). Returns selected Locale or null.
Future<Locale?> showLanguageSelectorDialog(BuildContext context) {
  final container = ProviderScope.containerOf(context, listen: false);
  final localeState = container.read(localeProvider);
  String selectedCode = localeState.effectiveLocale.languageCode;

  return showDialog<Locale>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).languageSelectDialogTitle),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: SingleChildScrollView(
              child: RadioGroup<String>(
                groupValue: selectedCode,
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedCode = value);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: LocaleNotifier.supportedLocales.map((locale) {
                    final code = locale.languageCode;
                    final name = LocaleNotifier.localeNames[code] ?? code.toUpperCase();
                    return RadioListTile<String>(
                      title: Text(name),
                      value: code,
                      activeColor: AppColors.primary,
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(context).commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, Locale(selectedCode)),
                child: Text(AppLocalizations.of(context).commonConfirm),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Clips the bottom edge of a container into a smooth downward curve.
class _CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 40)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}