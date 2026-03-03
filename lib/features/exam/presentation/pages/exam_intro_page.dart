import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';

class ExamIntroPage extends StatelessWidget {
  const ExamIntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.assignment,
                        size: 48,
                        color: AppColors.textInverse,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Mock Exam',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textInverse,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Exam Instructions',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 24),
              _buildInstructionItem(
                icon: Icons.timer,
                title: 'Time Limit',
                description: '30 minutes total for 20 questions',
              ),
              const SizedBox(height: 16),
              _buildInstructionItem(
                icon: Icons.help,
                title: '20 Questions',
                description: 'Multiple choice format with 4 options each',
              ),
              const SizedBox(height: 16),
              _buildInstructionItem(
                icon: Icons.check_circle,
                title: 'Passing Score',
                description: 'You need 70% or higher to pass',
              ),
              const SizedBox(height: 16),
              _buildInstructionItem(
                icon: Icons.info,
                title: 'No Going Back',
                description: 'You cannot revisit previous questions',
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Make sure you have stable internet and won\'t be interrupted',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.push('/exam/start'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Start Exam',
                  style: AppTextStyles.buttonLarge,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
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
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
