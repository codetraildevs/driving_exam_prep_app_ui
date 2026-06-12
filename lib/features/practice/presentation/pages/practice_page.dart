import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/locale/locale_notifier.dart';
import '../../../../shared/subscription/subscription_notifier.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../exam/data/models/exam_model.dart';
import '../../../exam/data/repositories/exam_repository.dart';

class PracticePage extends ConsumerStatefulWidget {
  const PracticePage({Key? key}) : super(key: key);

  @override
  ConsumerState<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage> {
  final ExamRepository _examRepository = ExamRepository();
  List<Exam> _exams = [];
  bool _isLoading = true;
  String? _error;
  String _lastLangCode = '';
  /// Ensures the locale listener is attached only once in build().
  bool _listenerAttached = false;

  @override
  void initState() {
    super.initState();
    // Load exams on first build — read locale inside the callback so it's
    // safe from late-init issues.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _lastLangCode = ref.read(localeProvider).effectiveLocale.languageCode;
        _loadExams(_lastLangCode);
      }
    });
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

  void _onExamTap(BuildContext context, Exam exam, int index) {
    final subscription = ref.read(subscriptionProvider);
    if (exam.isFree || subscription.hasActiveAccess) {
      context.push('/practice/quiz/${exam.quizId}?examIndex=${index + 1}');
    } else {
      context.push('/subscription');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subscription = ref.watch(subscriptionProvider);

    // ref.listen can only be called inside build(), so we attach the locale
    // listener here with a guard to avoid re-registering on every rebuild.
    if (!_listenerAttached) {
      _listenerAttached = true;
      ref.listen(localeProvider, (prev, next) {
        final newCode = next.effectiveLocale.languageCode;
        final oldCode = prev?.effectiveLocale.languageCode;
        if (newCode != oldCode) {
          _lastLangCode = newCode;
          _examRepository.clearCache();
          _loadExams(newCode);
        }
      });
    }

    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(
            title: l10n.practiceTitle,
            showBack: false,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: AppColors.error),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _loadExams(_lastLangCode),
                                child: Text(l10n.commonRetry),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _exams.length,
                          itemBuilder: (context, index) {
                            final exam = _exams[index];
                            final isLocked =
                                exam.isPaid && !subscription.hasActiveAccess;
                            return _ExamCard(
                              index: index,
                              exam: exam,
                              isLocked: isLocked,
                              onTap: () => _onExamTap(context, exam, index),
                              l10n: l10n,
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;
  final int index;
  final bool isLocked;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _ExamCard({
    required this.exam,
    required this.index,
    required this.isLocked,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: exam.isFree ? AppColors.success.withValues(alpha: 0.4) : AppColors.neutral200,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
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
                  // Exam image or fallback icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildExamImage(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${exam.title} ${index + 1}',
                          style: AppTextStyles.heading6,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.examQuestions(exam.questions.length),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ]
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
                  child: Text(
                    l10n.examFree,
                    style: const TextStyle(
                      color: AppColors.textInverse,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildExamImage() {
    if (exam.examImgUrl.isNotEmpty) {
      return Image.asset(
        exam.examImgUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
      );
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: exam.isFree
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        exam.isFree ? Icons.lock_open : Icons.quiz,
        color: exam.isFree ? AppColors.success : AppColors.primary,
        size: 32,
      ),
    );
  }
}
