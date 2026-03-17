import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({Key? key}) : super(key: key);

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  bool _answered = false;
  int? _selectedAnswer;
  late DateTime _startTime;
  int _remainingSeconds = 1800;

  List<Map<String, dynamic>> _buildExamQuestions(AppLocalizations l10n) => [
    {
      'question': l10n.examSampleQ1,
      'answers': [l10n.examSampleQ1A1, l10n.examSampleQ1A2, l10n.examSampleQ1A3, l10n.examSampleQ1A4],
      'correct': 3,
    },
    {
      'question': l10n.examSampleQ2,
      'answers': [l10n.examSampleQ2A1, l10n.examSampleQ2A2, l10n.examSampleQ2A3, l10n.examSampleQ2A4],
      'correct': 2,
    },
    {
      'question': l10n.examSampleQ3,
      'answers': [l10n.examSampleQ3A1, l10n.examSampleQ3A2, l10n.examSampleQ3A3, l10n.examSampleQ3A4],
      'correct': 1,
    },
  ];

  late List<Map<String, dynamic>> examQuestions;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    examQuestions = _buildExamQuestions(AppLocalizations.of(context));
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        _submitExam();
        return false;
      }
      return true;
    });
  }

  void _handleAnswerSelected(int index) {
    if (!_answered) {
      setState(() {
        _selectedAnswer = index;
        _answered = true;
        if (index == examQuestions[_currentQuestion]['correct']) {
          _correctAnswers++;
        }
      });
    }
  }

  void _handleNext() {
    if (_currentQuestion < examQuestions.length - 1) {
      setState(() {
        _currentQuestion++;
        _answered = false;
        _selectedAnswer = null;
      });
    } else {
      _submitExam();
    }
  }

  void _submitExam() {
    final total = examQuestions.length;
    final accuracy = total > 0 ? ((_correctAnswers / total) * 100).toInt() : 0;
    final elapsed = DateTime.now().difference(_startTime).inSeconds;
    context.push('/exam/result/0', extra: {
      'score': accuracy,
      'totalQuestions': total,
      'correctAnswers': _correctAnswers,
      'timeSpentSeconds': elapsed,
      'examTitle': '',
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final question = examQuestions[_currentQuestion];
    final progress = (_currentQuestion + 1) / examQuestions.length;
    final timeColor = _remainingSeconds < 300 ? AppColors.error : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(AppLocalizations.of(context).examMockExam),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: timeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatTime(_remainingSeconds),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: timeColor,
                  ),
                ),
              ),
            ),
          ),
        ],
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
                        l10n.quizQuestion(_currentQuestion + 1, examQuestions.length),
                        style: AppTextStyles.labelLarge,
                      ),
                      Text(
                        '$_correctAnswers/${examQuestions.length}',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
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
                    Text(
                      question['question'] as String,
                      style: AppTextStyles.heading4,
                    ),
                    const SizedBox(height: 32),
                    ...(question['answers'] as List<String>).asMap().entries.map((e) {
                      final index = e.key;
                      final answer = e.value;
                      final isSelected = _selectedAnswer == index;
                      final isCorrect = index == question['correct'];
                      final shouldHighlight = _answered && (isSelected || isCorrect);

                      Color borderColor = Theme.of(context).colorScheme.outline;
                      Color backgroundColor = Theme.of(context).colorScheme.surface;

                      if (shouldHighlight) {
                        if (isCorrect) {
                          borderColor = AppColors.success;
                          backgroundColor = AppColors.success.withValues(alpha: 0.1);
                        } else if (isSelected) {
                          borderColor = AppColors.error;
                          backgroundColor = AppColors.error.withValues(alpha: 0.1);
                        }
                      } else if (isSelected && !_answered) {
                        borderColor = AppColors.primary;
                        backgroundColor = AppColors.primary.withValues(alpha: 0.05);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _handleAnswerSelected(index),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              border: Border.all(color: borderColor, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    answer,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ),
                                if (shouldHighlight)
                                  Icon(
                                    isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: isCorrect
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
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
                    _currentQuestion == examQuestions.length - 1
                        ? l10n.examSubmit
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
}
