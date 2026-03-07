class ExamQuestion {
  final String question;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final String correctAnswer;
  final String questionImgUrl;

  ExamQuestion({
    required this.question,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctAnswer,
    this.questionImgUrl = '',
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    return ExamQuestion(
      question: json['question'] ?? '',
      option1: json['option1'] ?? '',
      option2: json['option2'] ?? '',
      option3: json['option3'] ?? '',
      option4: json['option4'] ?? '',
      correctAnswer: json['correctAnswer'] ?? '',
      questionImgUrl: json['questionImgUrl'] ?? '',
    );
  }
}
