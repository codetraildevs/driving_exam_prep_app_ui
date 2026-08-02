import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../../../shared/locale/locale_notifier.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/offline_cache.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../exam/data/models/exam_model.dart';
import '../../../exam/data/models/exam_question.dart';
import '../../../exam/data/repositories/exam_repository.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  final int examIndex;

  const QuizPage({required this.quizId, this.examIndex = 0, Key? key})
    : super(key: key);

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
  static const _securityChannel = MethodChannel(
    'com.driveprep.rwanda/security',
  );

  @override
  void initState() {
    super.initState();

    // Protect exam content from screenshots/screen recording
    ScreenProtector.preventScreenshotOn();
    //  ScreenProtector.protectDataOn(); // Use this if needed for protecting data in background
    _securityChannel.invokeMethod('secureScreenOn');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      final langCode = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(localeProvider).effectiveLocale.languageCode;
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
          _error = exam == null
              ? AppLocalizations.of(context).examNotFound
              : null;
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
    // Re-enable screenshots when leaving the quiz
    ScreenProtector.preventScreenshotOff();
    // ScreenProtector.protectDataOff();
    _securityChannel.invokeMethod('secureScreenOff');
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
      final list = (existing is List)
          ? List<dynamic>.from(existing)
          : <dynamic>[];
      list.insert(0, {...body, 'createdAt': DateTime.now().toIso8601String()});
      await cache.save(cacheKey, list);
    } catch (_) {}

    // Try API; on failure queue for later sync
    try {
      final result = await ApiHelper().post(
        '/api/practice-results',
        body: body,
      );
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
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
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
          ? [AppColors.success, AppColors.success.withValues(alpha: 0.8)]
          : [AppColors.error, AppColors.error.withValues(alpha: 0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(title: l10n.quizResults, showBack: false),
          Expanded(
            child: SingleChildScrollView(
              // Scroll view already applies 20px side padding; only cap the
              // content width so the result card doesn't stretch edge-to-edge.
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ConstrainedContent(
                maxWidth: AppContentWidths.narrow,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    if (_timedOut) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.timer_off_rounded,
                              color: AppColors.warning,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.quizTimeUp,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Premium Score Header ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: resultColor.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  value: accuracy / 100,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.15,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$accuracy%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 28,
                                    ),
                                  ),
                                  Text(
                                    l10n.examYourScore.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            passed ? l10n.quizPassed : l10n.quizFailed,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.quizResult(correct, total),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Modern Stats Grid ──
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: [
                        _ResultStatMini(
                          icon: Icons.check_circle_rounded,
                          label: l10n.progressCorrectAnswers,
                          value: '$correct',
                          color: AppColors.success,
                        ),
                        _ResultStatMini(
                          icon: Icons.cancel_rounded,
                          label: l10n.progressIncorrect,
                          value: '$incorrect',
                          color: AppColors.error,
                        ),
                        _ResultStatMini(
                          icon: Icons.timer_rounded,
                          label: l10n.quizTimeTaken,
                          value: _timeSpentFormatted,
                          color: AppColors.warning,
                        ),
                        _ResultStatMini(
                          icon: Icons.quiz_rounded,
                          label: l10n.progressTotalQuestions,
                          value: '$total',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _retake,
                        icon: const Icon(Icons.replay_rounded, size: 20),
                        label: Text(l10n.quizRetake),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        label: Text(l10n.quizBackToPractice),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
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
                  const Icon(
                    Icons.timer,
                    color: AppColors.textInverse,
                    size: 14,
                  ),
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
            // Cap the progress row so it stays centered on desktop.
            child: ConstrainedContent(
              maxWidth: AppContentWidths.narrow,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.quizQuestionOf(
                          _currentQuestion + 1,
                          questions.length,
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        l10n.quizAnswered(answeredCount, questions.length),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.outlineVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Question + Options
          Expanded(
            child: SingleChildScrollView(
              // Scroll view already applies 16px side padding; only cap the
              // content width so question text stays readable on desktop.
              padding: const EdgeInsets.all(16),
              child: ConstrainedContent(
                maxWidth: AppContentWidths.narrow,
                padding: EdgeInsets.zero,
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
                            color: Theme.of(
                              context,
                            ).shadowColor.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 12),
                          Text(
                            question.question,
                            style: AppTextStyles.bodyMedium,
                          ),
                          if (question.questionImgUrl.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                question.questionImgUrl,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
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
          ),

          // Bottom navigation: Previous, Next/Submit, and Submit Practice always visible
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            // Cap the button row so the action buttons stay centered on desktop.
            child: ConstrainedContent(
              maxWidth: AppContentWidths.narrow,
              padding: EdgeInsets.zero,
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
                    label: Text(
                      l10n.quizSubmitPractice,
                      style: const TextStyle(fontSize: 10),
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Next or Submit button
                  Expanded(
                    child: isLastQuestion
                        ? ElevatedButton.icon(
                            onPressed: _submitted ? null : _doSubmit,
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              l10n.quizSubmitPractice,
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: AppColors.textInverse,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _goToNext,
                            icon: const Icon(Icons.chevron_right),
                            label: Text(
                              l10n.quizNext,
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
          trailingIcon = const Icon(
            Icons.check_circle,
            color: AppColors.success,
          );
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
                        ? (isCorrect ? AppColors.success : AppColors.error)
                              .withValues(alpha: 0.2)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCorrect
                                  ? AppColors.success
                                  : AppColors.error,
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

class _ResultStatMini extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultStatMini({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
