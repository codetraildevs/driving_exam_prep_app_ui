import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.progressTitle),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCard(l10n),
              const SizedBox(height: 32),
              Text(
                l10n.progressPerformanceSummary,
                style: AppTextStyles.heading5,
              ),
              const SizedBox(height: 16),
              _buildStatRow(l10n.progressTotalAttempts, '12', Icons.assignment),
              _buildStatRow(l10n.progressBestScore, '92%', Icons.emoji_events),
              _buildStatRow(l10n.progressAverageScore, '78%', Icons.trending_up),
              _buildStatRow(l10n.progressSignsLearned, '45', Icons.traffic),
              const SizedBox(height: 32),
              Text(
                l10n.progressRecentExams,
                style: AppTextStyles.heading5,
              ),
              const SizedBox(height: 16),
              _buildExamCard(l10n.progressMockExam(1), '85%', l10n.progressPassed, AppColors.success),
              const SizedBox(height: 12),
              _buildExamCard(l10n.progressMockExam(2), '78%', l10n.progressPassed, AppColors.success),
              const SizedBox(height: 12),
              _buildExamCard(l10n.progressPracticeQuiz, '92%', l10n.progressExcellent, AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.progressOverall,
            style: AppTextStyles.heading6.copyWith(
              color: AppColors.textInverse.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressMetric('65%', l10n.progressComplete),
              _buildProgressMetric('78%', l10n.progressAvgScore),
              _buildProgressMetric('45', l10n.progressSigns),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: 0.65,
              minHeight: 12,
              backgroundColor: AppColors.textInverse.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.textInverse,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textInverse.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.heading6.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(String title, String score, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                score.replaceAll('%', ''),
                style: AppTextStyles.heading6.copyWith(
                  color: color,
                ),
              ),
            ),
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
                  status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward, color: AppColors.neutral400),
        ],
      ),
    );
  }
}
