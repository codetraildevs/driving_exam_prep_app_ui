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

  final examQuestions = [
    {
      'question': 'What is the speed limit on highways?',
      'answers': ['90 km/h', '100 km/h', '110 km/h', '120 km/h'],
      'correct': 3,
    },
    {
      'question': 'What does a yellow traffic light mean?',
      'answers': ['Stop immediately', 'Go ahead', 'Be prepared to stop', 'Turn around'],
      'correct': 2,
    },
    {
      'question': 'How far from a fire hydrant can you park?',
      'answers': ['1 meter', '3 meters', '5 meters', '10 meters'],
      'correct': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTimer();
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
    final accuracy = ((_correctAnswers / examQuestions.length) * 100).toInt();
    final passed = accuracy >= 70;
    context.push('/exam/result/$_currentQuestion');
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
                  color: timeColor.withOpacity(0.1),
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
                      backgroundColor: AppColors.neutral200,
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
                      } else if (isSelected && !_answered) {
                        borderColor = AppColors.primary;
                        backgroundColor = AppColors.primary.withOpacity(0.05);
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
