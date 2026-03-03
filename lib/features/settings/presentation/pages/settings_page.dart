import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notifications = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSectionHeader('Preferences'),
              _buildToggleSetting(
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
              ),
              _buildToggleSetting(
                title: 'Notifications',
                subtitle: 'Receive daily reminders',
                value: _notifications,
                onChanged: (value) {
                  setState(() {
                    _notifications = value;
                  });
                },
              ),
              _buildLanguageSetting(),
              const Divider(),
              _buildSectionHeader('About'),
              _buildTextSetting(
                icon: Icons.info_outline,
                title: 'About Traffic Rules App',
                subtitle: 'Version 1.0.0',
              ),
              _buildTextSetting(
                icon: Icons.description_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {},
              ),
              _buildTextSetting(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read our terms',
                onTap: () {},
              ),
              _buildSectionHeader('Data'),
              _buildTextSetting(
                icon: Icons.delete_outline,
                title: 'Reset Progress',
                subtitle: 'Clear all your data',
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
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSetting({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral200),
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
                  Text(
                    title,
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSetting() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          'Language',
          style: AppTextStyles.labelLarge,
        ),
        subtitle: Text(
          _language,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => _showLanguageDialog(),
      ),
    );
  }

  Widget _buildTextSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    Color textColor = AppColors.textPrimary,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('Spanish'),
            _buildLanguageOption('French'),
            _buildLanguageOption('German'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _language == language;
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: _language,
      onChanged: (value) {
        setState(() {
          _language = value ?? _language;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'Are you sure you want to reset all your progress? This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progress reset successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'Reset',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
