import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          kToolbarHeight + MediaQuery.of(context).padding.top,
        ),
        child: AppPageHeader(
          title: l10n.forgotPasswordTitle,
          onBack: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                l10n.forgotPasswordTitle,
                style: AppTextStyles.heading4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.forgotPasswordDescription,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: Text(l10n.forgotPasswordBackToLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
