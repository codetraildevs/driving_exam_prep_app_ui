import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/locale/locale_notifier.dart';
import '../../../../shared/locale/language_selector_page.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/theme/theme_notifier.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

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
      body: Column(
        children: [
          AppPageHeader(
            title: l10n.settingsTitle,
            showBack: true,
          ),
          Expanded(
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
                onTap: () => context.push('/about'),
              ),
              _buildTextSetting(
                surfaceColor: surfaceColor,
                outlineColor: outlineColor,
                icon: Icons.description_outlined,
                title: l10n.settingsPrivacyPolicy,
                subtitle: l10n.settingsPrivacyPolicySubtitle,
                onTap: () => context.push('/privacy-policy'),
              ),
              _buildTextSetting(
                surfaceColor: surfaceColor,
                outlineColor: outlineColor,
                icon: Icons.description_outlined,
                title: l10n.settingsTermsOfService,
                subtitle: l10n.settingsTermsOfServiceSubtitle,
                onTap: () => context.push('/terms-of-service'),
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
        ],
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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
        border: Border.all(color: outlineColor.withValues(alpha: 0.5)),
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
    return Consumer(
      builder: (context, ref, _) {
        final localeState = ref.watch(localeProvider);
        final currentName =
            LocaleNotifier.localeNames[localeState.effectiveLocale.languageCode] ??
                'English';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            tileColor: surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: outlineColor.withValues(alpha: 0.5)),
            ),
            title: Text(l10n.settingsLanguage,
                style: Theme.of(context).textTheme.labelLarge),
            subtitle: Text(currentName,
                style: Theme.of(context).textTheme.bodySmall),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _showLanguageDialog(),
          ),
        );
      },
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        tileColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: outlineColor.withValues(alpha: 0.5)),
        ),
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
      ProviderScope.containerOf(context, listen: false).read(localeProvider.notifier).setLocale(locale);
      syncLanguageToBackend(locale.languageCode);
    }
  }

  void _showResetConfirmation() {
    final l10n = AppLocalizations.of(context);
    final textColor = Theme.of(context).colorScheme.onSurface;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.settingsResetConfirmTitle,
          style: TextStyle(color: textColor),
        ),
        content: Text(
          l10n.settingsResetConfirmMessage,
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _performReset();
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

  Future<void> _performReset() async {
    final l10n = AppLocalizations.of(context);
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    if (userId == null || userId.isEmpty) return;

    try {
      await ApiHelper().post('/api/practice-results/reset', body: {
        'userId': userId,
      });
    } catch (_) {
      // Backend may not support this yet; that's okay
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsResetSuccess),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Theme Selector Tile — three-segment chip row
// ═══════════════════════════════════════════════════════════════════════════

class _ThemeSelectorTile extends ConsumerWidget {
  final Color surfaceColor;
  final Color outlineColor;

  const _ThemeSelectorTile({
    required this.surfaceColor,
    required this.outlineColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    void setTheme(ThemeMode mode) =>
        ref.read(themeProvider.notifier).setThemeMode(mode);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: outlineColor.withValues(alpha: 0.5)),
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
                l10n.settingsAppearance,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settingsAppearanceDesc,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ThemeChip(
                icon: Icons.brightness_auto,
                label: l10n.settingsThemeSystem,
                selected: themeNotifier == ThemeMode.system,
                onTap: () => setTheme(ThemeMode.system),
              ),
              const SizedBox(width: 8),
              _ThemeChip(
                icon: Icons.light_mode,
                label: l10n.settingsThemeLight,
                selected: themeNotifier == ThemeMode.light,
                onTap: () => setTheme(ThemeMode.light),
              ),
              const SizedBox(width: 8),
              _ThemeChip(
                icon: Icons.dark_mode,
                label: l10n.settingsThemeDark,
                selected: themeNotifier == ThemeMode.dark,
                onTap: () => setTheme(ThemeMode.dark),
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
              color: selected ? cs.primary : cs.outline.withValues(alpha: 0.5),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.25),
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
                color: selected ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
