import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';

class QuizPage extends StatefulWidget {
  final String categoryId;

  const QuizPage({required this.categoryId, Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  bool _answered = false;
  int? _selectedAnswer;

  final quizData = [
    {
      'question': 'What does a red traffic light mean?',
      'answers': ['Stop', 'Go', 'Slow down', 'Turn left'],
      'correct': 0,
    },
    {
      'question': 'What is the maximum speed limit in urban areas?',
      'answers': ['60 km/h', '80 km/h', '50 km/h', '90 km/h'],
      'correct': 2,
    },
    {
      'question': 'Can you park in a no-parking zone?',
      'answers': ['Yes, always', 'No, never', 'Only at night', 'Only on weekends'],
      'correct': 1,
    },
  ];

  void _handleAnswerSelected(int index) {
    if (!_answered) {
      setState(() {
        _selectedAnswer = index;
        _answered = true;
        if (index == quizData[_currentQuestion]['correct']) {
          _correctAnswers++;
        }
      });
    }
  }

  void _handleNext() {
    if (_currentQuestion < quizData.length - 1) {
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
    final accuracy = ((_correctAnswers / quizData.length) * 100).toInt();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
            Text(
              'Quiz Complete!',
              style: AppTextStyles.heading4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $accuracy%',
              style: AppTextStyles.heading3.copyWith(
                color: accuracy >= 70 ? AppColors.success : AppColors.warning,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You got $_correctAnswers out of ${quizData.length} correct',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
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
              child: const Text('Back to Practice'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = quizData[_currentQuestion];
    final progress = (_currentQuestion + 1) / quizData.length;

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
                        'Question ${_currentQuestion + 1}/${quizData.length}',
                        style: AppTextStyles.labelLarge,
                      ),
                      Text(
                        '${(_correctAnswers)}/${quizData.length}',
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
                    _currentQuestion == quizData.length - 1
                        ? 'Finish Quiz'
                        : 'Next Question',
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
