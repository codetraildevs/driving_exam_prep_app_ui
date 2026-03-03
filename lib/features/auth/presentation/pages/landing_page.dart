import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isMobile) _buildMobileLayout(context) else _buildWebLayout(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        _buildLogo(),
        const SizedBox(height: 48),
        _buildContent(context, isMobile: true),
      ],
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(size: 80),
                  const SizedBox(height: 48),
                  Text(
                    'Master Traffic Rules',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.textInverse,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pass Your Driving License Exam With Confidence',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textInverse.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: _buildContent(context, isMobile: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo({double size = 64}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          '⚠️',
          style: TextStyle(fontSize: size * 0.6),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isMobile) const SizedBox(height: 0) else _buildLogo(),
        if (isMobile) const SizedBox(height: 32),
        if (isMobile) ...[
          Text(
            'Master Traffic Rules',
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
        if (isMobile)
          Text(
            'Pass Your Driving License Exam With Confidence',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        if (isMobile) const SizedBox(height: 32),
        if (!isMobile) ...[
          Text(
            'Welcome to Traffic Rules Learning',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Learn traffic rules, practice with mock exams, and track your progress. Everything you need to pass your provisional driving license exam.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () => context.push('/login'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Get Started',
            style: AppTextStyles.buttonLarge,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => context.push('/login'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Login',
            style: AppTextStyles.buttonMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
