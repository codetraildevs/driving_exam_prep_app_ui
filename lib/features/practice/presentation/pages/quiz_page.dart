import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/locale/locale_provider.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/offline_cache.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../exam/data/models/exam_model.dart';
import '../../../exam/data/models/exam_question.dart';
import '../../../exam/data/repositories/exam_repository.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  final int examIndex;

  const QuizPage({required this.quizId, this.examIndex = 0, Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final ExamRepository _examRepository = ExamRepository();

  Exam? _exam;
  bool _isLoading = true;
  String? _error;

  int _currentQuestion = 0;
  final Map<int, String> _answers = {};
  bool _submitted = false;
  bool _timedOut = false;
  bool _showResults = false;

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
          _error = exam == null ? AppLocalizations.of(context).examNotFound : null;
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

  int get _timeSpentSeconds => _totalSeconds - _secondsLeft;

  String get _timeSpentFormatted {
    final s = _timeSpentSeconds;
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
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
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.upload_rounded, color: AppColors.warning, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.quizSubmitConfirmTitle,
                style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.quizSubmitConfirmMessage(_answeredCount, _exam!.questions.length),
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _doSubmit();
            },
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: Text(l10n.quizSubmitPractice),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _doSubmit({bool autoSubmit = false}) {
    _timer?.cancel();
    setState(() {
      _submitted = true;
      _showResults = true;
    });
    _saveResultsToApi();
  }

  Future<void> _saveResultsToApi() async {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;
    if (userId == null || userId.isEmpty) return;

    final questions = _exam!.questions;
    final total = questions.length;
    int correct = 0;
    for (int i = 0; i < total; i++) {
      if (_answers[i] == questions[i].correctAnswer) correct++;
    }
    final score = total > 0 ? (correct / total * 100).round() : 0;

    final body = {
      'userId': userId,
      'examId': widget.quizId,
      'score': score,
      'totalQuestions': total,
      'correctAnswers': correct,
      'timeSpent': _timeSpentSeconds,
    };

    final cache = OfflineCache();

    // Append to local exam-results cache so progress/certificates work offline
    final cacheKey = cache.examResultsKey(userId);
    try {
      final existing = await cache.load(cacheKey);
      final list = (existing is List) ? List<dynamic>.from(existing) : <dynamic>[];
      list.insert(0, {
        ...body,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await cache.save(cacheKey, list);
    } catch (_) {}

    // Try API; on failure queue for later sync
    try {
      final result = await ApiHelper().post('/api/practice-results', body: body);
      if (!result.isSuccess) {
        await cache.queuePendingResult(body);
      }
    } catch (_) {
      await cache.queuePendingResult(body);
    }
  }

  void _retake() {
    setState(() {
      _currentQuestion = 0;
      _answers.clear();
      _submitted = false;
      _timedOut = false;
      _showResults = false;
      _secondsLeft = _totalSeconds;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _exam == null) {
      return Scaffold(
        body: Column(
          children: [
            AppPageHeader(title: l10n.practiceTitle, showBack: true),
            Expanded(
              child: Center(
                child: Text(
                  _error ?? l10n.examNotFound,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show results page after submission
    if (_showResults) {
      return _buildResultsPage(l10n);
    }

    return _buildQuizPage(l10n);
  }

  // ── Results Page ───────────────────────────────────────────────────────────

  Widget _buildResultsPage(AppLocalizations l10n) {
    final total = _exam!.questions.length;
    final correct = _correctCount;
    final incorrect = total - correct;
    final accuracy = ((correct / total) * 100).toInt();
    final passed = accuracy >= 70;
    final resultColor = passed ? AppColors.success : AppColors.error;
    final gradient = LinearGradient(
      colors: passed
          ? [AppColors.success, AppColors.success.withValues(alpha: 0.7)]
          : [AppColors.error, AppColors.error.withValues(alpha: 0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(title: l10n.quizResults, showBack: false),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  if (_timedOut) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_off_rounded, color: AppColors.warning, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.quizTimeUp,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Score hero card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: resultColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Score circle
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$accuracy%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              ),
                              Icon(
                                passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          passed ? l10n.quizPassed : l10n.quizFailed,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.quizResult(correct, total),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Stats grid ──
                  Row(
                    children: [
                      Expanded(child: _ResultStat(
                        icon: Icons.quiz_rounded,
                        label: l10n.progressTotalQuestions,
                        value: '$total',
                        color: AppColors.primary,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _ResultStat(
                        icon: Icons.check_circle_outline,
                        label: l10n.progressCorrectAnswers,
                        value: '$correct',
                        color: AppColors.success,
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _ResultStat(
                        icon: Icons.cancel_outlined,
                        label: l10n.progressIncorrect,
                        value: '$incorrect',
                        color: AppColors.error,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _ResultStat(
                        icon: Icons.timer_outlined,
                        label: l10n.quizTimeTaken,
                        value: _timeSpentFormatted,
                        color: AppColors.warning,
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                


                  // Actions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _retake,
                      icon: const Icon(Icons.replay_rounded),
                      label: Text(l10n.quizRetake),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(l10n.quizBackToPractice),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quiz Page ──────────────────────────────────────────────────────────────

  Widget _buildQuizPage(AppLocalizations l10n) {
    final questions = _exam!.questions;
    final question = questions[_currentQuestion];
    final answeredCount = _answeredCount;
    final progress = answeredCount / questions.length;
    final isLastQuestion = _currentQuestion == questions.length - 1;

    return Scaffold(
      body: Column(
        children: [
          // Gradient header
          AppPageHeader(
            title: widget.examIndex > 0
                ? '${_exam!.title} ${widget.examIndex}'
                : _exam!.title,
            showBack: true,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _secondsLeft < 60
                    ? AppColors.error.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.2),
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
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.quizQuestionOf(_currentQuestion + 1, questions.length),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      l10n.quizAnswered(answeredCount, questions.length),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
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
                          color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 12),
                        Text(question.question, style: AppTextStyles.bodyMedium),
                        if (question.questionImgUrl.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              question.questionImgUrl,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildOptions(question),
                ],
              ),
            ),
          ),

          // Bottom navigation: Previous, Next/Submit, and Submit Practice always visible
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                // Previous button
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
                const SizedBox(width: 3),
                // Submit Practice button (always visible, but disabled if already submitted)
                FloatingActionButton.extended(
                  heroTag: 'submitPracticeFAB',
                  onPressed: _submitted ? null : _doSubmit,
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.textInverse,
                  label: Text(l10n.quizSubmitPractice, style: const TextStyle(fontSize: 10)),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                const SizedBox(width: 4),
                // Next or Submit button
                Expanded(
                  child: isLastQuestion
                      ? ElevatedButton.icon(
                          onPressed: _submitted ? null : _doSubmit,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(l10n.quizSubmitPractice, style: const TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.textInverse,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _goToNext,
                          icon: const Icon(Icons.chevron_right),
                          label: Text(l10n.quizNext, style: const TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
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

      final cs = Theme.of(context).colorScheme;
      Color borderColor = cs.outline;
      Color backgroundColor = cs.surface;
      Widget? trailingIcon;

      if (shouldHighlight) {
        if (isCorrect) {
          borderColor = AppColors.success;
          backgroundColor = AppColors.success.withValues(alpha: 0.1);
          trailingIcon = const Icon(Icons.check_circle, color: AppColors.success);
        } else if (isSelected) {
          borderColor = AppColors.error;
          backgroundColor = AppColors.error.withValues(alpha: 0.1);
          trailingIcon = const Icon(Icons.cancel, color: AppColors.error);
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 1),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: isAnswered ? null : () => _handleAnswerSelected(option),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: isSelected
                          ? (isCorrect ? AppColors.success : AppColors.error)
                          : Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                    color: isSelected
                        ? (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.2)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCorrect ? AppColors.success : AppColors.error,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(option, style: AppTextStyles.bodyMedium)),
              if (trailingIcon != null) trailingIcon,
            ],
          ),
        ),
      );
    }).toList();
  }
}

// ── Result stat card ──────────────────────────────────────────────────────────

class _ResultStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading5.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
