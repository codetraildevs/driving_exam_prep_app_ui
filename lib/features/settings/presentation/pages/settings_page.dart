import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/locale/locale_provider.dart';
import '../../../../shared/locale/language_selector_page.dart';
import '../../../../shared/theme/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final surfaceColor = cs.surface;
    final outlineColor = cs.outline;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSectionHeader(l10n.settingsPreferences),

              // ── Theme selector ──────────────────────────────────────
              _ThemeSelectorTile(
                surfaceColor: surfaceColor,
                outlineColor: outlineColor,
              ),

              _buildToggleSetting(
                surfaceColor: surfaceColor,
                outlineColor: outlineColor,
                title: l10n.settingsNotifications,
                subtitle: l10n.settingsNotificationsSubtitle,
                value: _notifications,
                onChanged: (value) => setState(() => _notifications = value),
              ),
              _buildLanguageSetting(l10n, surfaceColor, outlineColor),
              const Divider(),
              _buildSectionHeader(l10n.settingsAbout),
              _buildTextSetting(
                surfaceColor: surfaceColor,
                outlineColor: outlineColor,
                icon: Icons.info_outline,
                title: l10n.settingsAboutApp,
                subtitle: l10n.settingsVersion('1.0.0'),
              ),
              _buildTextSetting(
                surfaceColor: surfaceColor,
                outlineColor: outlineColor,
                icon: Icons.description_outlined,
                title: l10n.settingsPrivacyPolicy,
                subtitle: l10n.settingsPrivacyPolicySubtitle,
                onTap: () {},
              ),
              _buildTextSetting(
                surfaceColor: surfaceColor,
                outlineColor: outlineColor,
                icon: Icons.description_outlined,
                title: l10n.settingsTermsOfService,
                subtitle: l10n.settingsTermsOfServiceSubtitle,
                onTap: () {},
              ),
              _buildSectionHeader(l10n.settingsData),
              _buildTextSetting(
                surfaceColor: surfaceColor,
                outlineColor: outlineColor,
                icon: Icons.delete_outline,
                title: l10n.settingsResetProgress,
                subtitle: l10n.settingsResetProgressSubtitle,
                textColor: AppColors.error,
                onTap: () => _showResetConfirmation(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyles.heading6.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSetting({
    required Color surfaceColor,
    required Color outlineColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: outlineColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSetting(
      AppLocalizations l10n, Color surfaceColor, Color outlineColor) {
    final provider = context.watch<LocaleProvider>();
    final currentName =
        LocaleProvider.localeNames[provider.effectiveLocale.languageCode] ??
            'English';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: outlineColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(l10n.settingsLanguage,
            style: Theme.of(context).textTheme.labelLarge),
        subtitle: Text(currentName,
            style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => _showLanguageDialog(),
      ),
    );
  }

  Widget _buildTextSetting({
    required Color surfaceColor,
    required Color outlineColor,
    required IconData icon,
    required String title,
    required String subtitle,
    Color textColor = AppColors.textPrimary,
    VoidCallback? onTap,
  }) {
    final effectiveTextColor =
        textColor == AppColors.textPrimary
            ? Theme.of(context).colorScheme.onSurface
            : textColor;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: outlineColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: effectiveTextColor),
        title: Text(title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: effectiveTextColor)),
        subtitle: Text(subtitle,
            style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog() async {
    final locale = await showLanguageSelectorDialog(context);
    if (locale != null && mounted) {
      context.read<LocaleProvider>().setLocale(locale);
    }
  }

  void _showResetConfirmation() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsResetConfirmTitle),
        content: Text(l10n.settingsResetConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.settingsResetSuccess),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              l10n.commonReset,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Theme Selector Tile — three-segment chip row
// ═══════════════════════════════════════════════════════════════════════════

class _ThemeSelectorTile extends StatelessWidget {
  final Color surfaceColor;
  final Color outlineColor;

  const _ThemeSelectorTile({
    required this.surfaceColor,
    required this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: outlineColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how the app looks',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ThemeChip(
                icon: Icons.brightness_auto,
                label: 'System',
                selected: themeProvider.isSystem,
                onTap: () => themeProvider.setThemeMode(ThemeMode.system),
              ),
              const SizedBox(width: 8),
              _ThemeChip(
                icon: Icons.light_mode,
                label: 'Light',
                selected: themeProvider.isLight,
                onTap: () => themeProvider.setThemeMode(ThemeMode.light),
              ),
              const SizedBox(width: 8),
              _ThemeChip(
                icon: Icons.dark_mode,
                label: 'Dark',
                selected: themeProvider.isDark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? cs.primary : cs.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? cs.primary : cs.outline.withOpacity(0.5),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? cs.onPrimary : cs.onSurface.withOpacity(0.7),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? cs.onPrimary : cs.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
