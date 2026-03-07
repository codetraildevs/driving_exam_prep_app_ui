import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/locale/locale_provider.dart';
import '../../../../shared/subscription/subscription_provider.dart';
import '../../../exam/data/models/exam_model.dart';
import '../../../exam/data/repositories/exam_repository.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({Key? key}) : super(key: key);

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final ExamRepository _examRepository = ExamRepository();
  List<Exam> _exams = [];
  bool _isLoading = true;
  String? _error;
  String _lastLangCode = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final langCode =
        context.watch<LocaleProvider>().effectiveLocale.languageCode;
    if (langCode != _lastLangCode) {
      _lastLangCode = langCode;
      _examRepository.clearCache();
      _loadExams(langCode);
    }
  }

  Future<void> _loadExams(String langCode) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final exams = await _examRepository.loadAllExams(langCode);
      // Sort: free exams first
      exams.sort((a, b) {
        if (a.isFree && !b.isFree) return -1;
        if (!a.isFree && b.isFree) return 1;
        return 0;
      });
      if (mounted) setState(() => _exams = exams);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onExamTap(BuildContext context, Exam exam) {
    final subscription = context.read<SubscriptionProvider>();
    if (exam.isFree || subscription.hasActiveAccess) {
      context.push('/practice/quiz/${exam.quizId}');
    } else {
      context.push('/subscription');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subscription = context.watch<SubscriptionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.practiceTitle),
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadExams(_lastLangCode),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exams.length,
                    itemBuilder: (context, index) {
                      final exam = _exams[index];
                      final isLocked = exam.isPaid && !subscription.hasActiveAccess;
                      return _ExamCard(
                        exam: exam,
                        isLocked: isLocked,
                        onTap: () => _onExamTap(context, exam),
                      );
                    },
                  ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;
  final bool isLocked;
  final VoidCallback onTap;

  const _ExamCard({
    required this.exam,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: exam.isFree ? AppColors.success.withOpacity(0.4) : AppColors.neutral200,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: exam.isFree
                          ? AppColors.success.withOpacity(0.15)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      exam.isFree ? Icons.lock_open : Icons.quiz,
                      color: exam.isFree ? AppColors.success : AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.title,
                          style: AppTextStyles.heading6,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${exam.questions.length} questions',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLocked)
                    const Icon(Icons.lock, color: AppColors.textTertiary)
                  else
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
            if (exam.isFree)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'FREE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
