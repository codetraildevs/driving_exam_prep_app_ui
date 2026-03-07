import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/locale/locale_provider.dart';
import '../../../exam/data/models/exam_model.dart';
import '../../../exam/data/models/exam_question.dart';
import '../../../exam/data/repositories/exam_repository.dart';

class QuizPage extends StatefulWidget {
  final String quizId;

  const QuizPage({required this.quizId, Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final ExamRepository _examRepository = ExamRepository();

  Exam? _exam;
  bool _isLoading = true;
  String? _error;

  int _currentQuestion = 0;
  // Map: question index → selected answer
  final Map<int, String> _answers = {};
  bool _submitted = false;
  bool _timedOut = false;

  // Timer: 20 minutes = 1200 seconds
  static const int _totalSeconds = 1200;
  int _secondsLeft = _totalSeconds;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      final langCode =
          context.read<LocaleProvider>().effectiveLocale.languageCode;
      _loadExam(langCode);
    }
  }

  Future<void> _loadExam(String langCode) async {
    try {
      final exam = await _examRepository.getExamById(widget.quizId, langCode);
      if (mounted) {
        setState(() {
          _exam = exam;
          _isLoading = false;
          _error = exam == null ? 'Exam not found' : null;
        });
        if (exam != null) _startTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _timer?.cancel();
          _timedOut = true;
          _doSubmit(autoSubmit: true);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleAnswerSelected(String answer) {
    if (_submitted) return;
    setState(() {
      _answers[_currentQuestion] = answer;
    });
  }

  void _goToPrevious() {
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
    }
  }

  void _goToNext() {
    final questions = _exam!.questions;
    if (_currentQuestion < questions.length - 1) {
      setState(() => _currentQuestion++);
    }
  }

  int get _answeredCount => _answers.length;

  int get _correctCount {
    int count = 0;
    final questions = _exam!.questions;
    for (int i = 0; i < questions.length; i++) {
      if (_answers[i] == questions[i].correctAnswer) count++;
    }
    return count;
  }

  void _confirmSubmit() {
    if (_submitted) return;
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.quizSubmitConfirmTitle),
        content: Text(
          l10n.quizSubmitConfirmMessage(_answeredCount, _exam!.questions.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _doSubmit();
            },
            child: Text(l10n.adminSubmitCall),
          ),
        ],
      ),
    );
  }

  void _doSubmit({bool autoSubmit = false}) {
    _timer?.cancel();
    setState(() => _submitted = true);
    _showResults(autoSubmit: autoSubmit);
  }

  void _showResults({bool autoSubmit = false}) {
    final total = _exam!.questions.length;
    final correct = _correctCount;
    final accuracy = ((correct / total) * 100).toInt();
    final l10n = AppLocalizations.of(context);
    final passed = accuracy >= 70;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (autoSubmit || _timedOut) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.quizTimeUp,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: passed ? AppColors.success : AppColors.warning,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                passed ? Icons.check_circle : Icons.info,
                color: AppColors.textInverse,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.quizResults,
              style: AppTextStyles.heading4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              passed ? l10n.quizPassed : l10n.quizFailed,
              style: AppTextStyles.heading5.copyWith(
                color: passed ? AppColors.success : AppColors.warning,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.quizScore(accuracy),
              style: AppTextStyles.heading3.copyWith(
                color: passed ? AppColors.success : AppColors.warning,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.quizResult(correct, total),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.pop();
                    },
                    child: Text(l10n.quizBackToPractice),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      // Reset and retake
                      setState(() {
                        _currentQuestion = 0;
                        _answers.clear();
                        _submitted = false;
                        _timedOut = false;
                        _secondsLeft = _totalSeconds;
                      });
                      _startTimer();
                    },
                    child: Text(l10n.quizRetake),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _exam == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            _error ?? 'Exam not found',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final questions = _exam!.questions;
    final question = questions[_currentQuestion];
    final answeredCount = _answeredCount;
    final progress = answeredCount / questions.length;
    final isAnswered = _answers.containsKey(_currentQuestion);
    final isLastQuestion = _currentQuestion == questions.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _exam!.title,
                          style: AppTextStyles.heading6.copyWith(color: AppColors.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Timer badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _secondsLeft < 60
                              ? AppColors.error
                              : AppColors.warning,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer, color: AppColors.textInverse, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _formattedTime,
                              style: const TextStyle(
                                color: AppColors.textInverse,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.quizQuestionOf(_currentQuestion + 1, questions.length),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        l10n.quizProgress,
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: AppColors.neutral200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Question + Options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Q${_currentQuestion + 1}',
                                  style: const TextStyle(
                                    color: AppColors.textInverse,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(question.question, style: AppTextStyles.bodyMedium),
                              ),
                            ],
                          ),
                          if (question.questionImgUrl.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                question.questionImgUrl,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Answer options
                    ..._buildOptions(question),
                  ],
                ),
              ),
            ),

            // Bottom section
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Answered counter + Submit + Time
                  Row(
                    children: [
                      Text(
                        l10n.quizAnswered(answeredCount, questions.length),
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _submitted ? null : _confirmSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: AppColors.textInverse,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.quizSubmitPractice,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.quizTimeRemaining(_formattedTime),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _secondsLeft < 60 ? AppColors.error : AppColors.textSecondary,
                          fontWeight: _secondsLeft < 60 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Navigation bar
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _currentQuestion > 0 ? _goToPrevious : null,
                          icon: const Icon(Icons.chevron_left),
                          label: Text(l10n.quizPrevious),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: !isLastQuestion ? _goToNext : null,
                          icon: const Icon(Icons.chevron_right),
                          label: Text(l10n.quizNext),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions(ExamQuestion question) {
    final options = [
      question.option1,
      question.option2,
      question.option3,
      question.option4,
    ].where((o) => o.isNotEmpty).toList();

    final selectedAnswer = _answers[_currentQuestion];
    final isAnswered = selectedAnswer != null;

    return options.map((option) {
      final isSelected = selectedAnswer == option;
      final isCorrect = option == question.correctAnswer;
      final shouldHighlight = isAnswered && (isSelected || isCorrect);

      Color borderColor = AppColors.neutral300;
      Color backgroundColor = AppColors.surface;
      Widget? trailingIcon;

      if (shouldHighlight) {
        if (isCorrect) {
          borderColor = AppColors.success;
          backgroundColor = AppColors.success.withOpacity(0.1);
          trailingIcon = const Icon(Icons.check_circle, color: AppColors.success);
        } else if (isSelected) {
          borderColor = AppColors.error;
          backgroundColor = AppColors.error.withOpacity(0.1);
          trailingIcon = const Icon(Icons.cancel, color: AppColors.error);
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: isAnswered ? null : () => _handleAnswerSelected(option),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Checkbox indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? (isCorrect ? AppColors.success : AppColors.error)
                          : AppColors.neutral300,
                      width: 2,
                    ),
                    color: isSelected
                        ? (isCorrect ? AppColors.success : AppColors.error).withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCorrect ? AppColors.success : AppColors.error,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(option, style: AppTextStyles.bodyMedium)),
                if (trailingIcon != null) trailingIcon,
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
