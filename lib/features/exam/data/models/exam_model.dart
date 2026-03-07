import 'exam_question.dart';

class Exam {
  final String quizId;
  final String examType;
  final String title;
  final String examImgUrl;
  final List<ExamQuestion> questions;

  Exam({
    required this.quizId,
    required this.examType,
    required this.title,
    this.examImgUrl = '',
    required this.questions,
  });

  bool get isFree => examType == 'Free';
  bool get isPaid => examType == 'Paid';

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      quizId: json['quizId'] ?? '',
      examType: json['examType'] ?? 'Paid',
      title: json['title'] ?? '',
      examImgUrl: json['examImgUrl'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => ExamQuestion.fromJson(q))
              .toList() ??
          [],
    );
  }
}
