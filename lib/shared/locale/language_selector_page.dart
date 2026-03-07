
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../locale/locale_provider.dart';
import '../network/api_config.dart';
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
    'en': 'Traffic alerts & maps',
    'fr': 'Alertes trafic & cartes',
    'rw': 'Amakuru y\'imihanda & amakarita',
  };

  @override
  void initState() {
    super.initState();

    final deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final supported =
        LocaleProvider.supportedLocales.map((l) => l.languageCode);
    _selectedCode = supported.contains(deviceCode) ? deviceCode : 'en';

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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // Animated header
              // _buildHeader(context),

              const SizedBox(height: 18),

              // Title & subtitle
              Text(
                'Choose your language',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'You can change this later in Settings — get localized traffic alerts and routing.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 18),

              // Quick actions row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _useDeviceLanguage,
                      icon: const Icon(Icons.phone_iphone_outlined),
                      label: const Text('Use device language'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary.withOpacity(0.18)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Tooltip(
                    message: 'Language help',
                    child: IconButton(
                      onPressed: () => _showQuickHelp(context),
                      icon: const Icon(Icons.help_outline),
                      color: AppColors.neutral600,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 18),

              // Language options: responsive layout (grid on wide, list on narrow)
              Expanded(
                child: isWide ? _buildGridOptions() : _buildListOptions(),
              ),

              // CTA area
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildConfirmButton(context),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // Allow user to skip for now; still navigate to landing but don't persist a selection.
                  context.go('/landing');
                },
                child: Text(
                  'Maybe later',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.neutral600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  

  Widget _buildListOptions() {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      children: LocaleProvider.supportedLocales.map((locale) {
        final code = locale.languageCode;
        final name = LocaleProvider.localeNames[code] ?? code.toUpperCase();
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
    final items = LocaleProvider.supportedLocales
        .map((l) => l.languageCode)
        .toList(growable: false);
    return GridView.builder(
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
        final name = LocaleProvider.localeNames[code] ?? code.toUpperCase();
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

  Widget _buildConfirmButton(BuildContext context) {
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
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            child: Text(
              _confirmLabel,
              style: AppTextStyles.buttonLarge.copyWith(color: AppColors.textInverse),
            ),
          ),
        ),
      ),
    );
  }

  String get _confirmLabel {
    switch (_selectedCode) {
      case 'fr':
        return 'Continuer';
      case 'rw':
        return 'Komeza';
      default:
        return 'Continue';
    }
  }

  Future<void> _onConfirm() async {
    final provider = context.read<LocaleProvider>();
    await provider.setLocale(Locale(_selectedCode));
    // Best-effort sync to backend if authenticated
    _syncLanguageToBackend(_selectedCode);
    if (!mounted) return;
    context.go('/landing');
  }

  Future<void> _syncLanguageToBackend(String langCode) async {
    try {
      final session = AuthSession();
      final token = await session.getToken();
      if (token == null || token.isEmpty) return;
      final user = await session.getUser();
      if (user == null) return;
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/users/${user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'preferredLanguage': langCode}),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      // Ignore errors — language is already saved locally
      assert(() {
        // ignore: avoid_print
        print('[LanguageSelector] syncLanguageToBackend error: $e');
        return true;
      }());
    }
  }

  void _useDeviceLanguage() {
    final deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final supported =
        LocaleProvider.supportedLocales.map((l) => l.languageCode);
    final code = supported.contains(deviceCode) ? deviceCode : 'en';
    setState(() => _selectedCode = code);
  }

  void _showQuickHelp(BuildContext context) {
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
              Text('Why choose a language?', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(
                'Selecting a language ensures that alerts, maps, and voice prompts are shown in your preferred language. You can change this later in Settings.',
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Got it'),
              ),
            ],
          ),
        );
      },
    );
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
        ? AppColors.primary.withOpacity(0.06)
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
          transform: Matrix4.identity()..scale(scale),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.04),
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
  final provider = context.read<LocaleProvider>();
  String selectedCode = provider.effectiveLocale.languageCode;

  return showDialog<Locale>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Select language'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: LocaleProvider.supportedLocales.map((locale) {
                  final code = locale.languageCode;
                  final name = LocaleProvider.localeNames[code] ?? code.toUpperCase();
                  return RadioListTile<String>(
                    title: Text(name),
                    value: code,
                    groupValue: selectedCode,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setDialogState(() => selectedCode = value ?? selectedCode);
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, Locale(selectedCode)),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    },
  );
}