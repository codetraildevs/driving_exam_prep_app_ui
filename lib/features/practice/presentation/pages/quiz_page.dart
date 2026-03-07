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
  int _correctAnswers = 0;
  bool _answered = false;
  String? _selectedAnswer;

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
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  void _handleAnswerSelected(String answer) {
    if (!_answered) {
      final question = _exam!.questions[_currentQuestion];
      setState(() {
        _selectedAnswer = answer;
        _answered = true;
        if (answer == question.correctAnswer) {
          _correctAnswers++;
        }
      });
    }
  }

  void _handleNext() {
    final questions = _exam!.questions;
    if (_currentQuestion < questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _answered = false;
        _selectedAnswer = null;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final total = _exam!.questions.length;
    final accuracy = (((_correctAnswers / total) * 100)).toInt();
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accuracy >= 70 ? AppColors.success : AppColors.warning,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                accuracy >= 70 ? Icons.check_circle : Icons.info,
                color: AppColors.textInverse,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.quizComplete, style: AppTextStyles.heading4, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              l10n.quizScore(accuracy),
              style: AppTextStyles.heading3.copyWith(
                color: accuracy >= 70 ? AppColors.success : AppColors.warning,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.quizResult(_correctAnswers, total),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.pop();
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(l10n.quizBackToPractice),
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
          backgroundColor: AppColors.surface,
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
    final progress = (_currentQuestion + 1) / questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text(
          _exam!.title,
          style: AppTextStyles.labelLarge,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.quizQuestion(_currentQuestion + 1, questions.length),
                        style: AppTextStyles.labelLarge,
                      ),
                      Text(
                        '$_correctAnswers/${questions.length}',
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.neutral200,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (question.questionImgUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            question.questionImgUrl,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    Text(question.question, style: AppTextStyles.heading4),
                    const SizedBox(height: 32),
                    ..._buildOptions(question),
                  ],
                ),
              ),
            ),
            if (_answered)
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _currentQuestion == questions.length - 1
                        ? l10n.quizFinish
                        : l10n.quizNextQuestion,
                    style: AppTextStyles.buttonLarge,
                  ),
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

    return options.map((option) {
      final isSelected = _selectedAnswer == option;
      final isCorrect = option == question.correctAnswer;
      final shouldHighlight = _answered && (isSelected || isCorrect);

      Color borderColor = AppColors.neutral300;
      Color backgroundColor = AppColors.surface;

      if (shouldHighlight) {
        if (isCorrect) {
          borderColor = AppColors.success;
          backgroundColor = AppColors.success.withOpacity(0.1);
        } else if (isSelected) {
          borderColor = AppColors.error;
          backgroundColor = AppColors.error.withOpacity(0.1);
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => _handleAnswerSelected(option),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: Text(option, style: AppTextStyles.bodyMedium)),
                if (shouldHighlight)
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? AppColors.success : AppColors.error,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
