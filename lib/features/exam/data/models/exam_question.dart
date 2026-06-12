import 'package:json_annotation/json_annotation.dart';

part 'exam_question.g.dart';

@JsonSerializable()
class ExamQuestion {
  @JsonKey(defaultValue: '')
  final String question;

  @JsonKey(defaultValue: '')
  final String option1;

  @JsonKey(defaultValue: '')
  final String option2;

  @JsonKey(defaultValue: '')
  final String option3;

  @JsonKey(defaultValue: '')
  final String option4;

  @JsonKey(defaultValue: '')
  final String correctAnswer;

  @JsonKey(defaultValue: '')
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

  factory ExamQuestion.fromJson(Map<String, dynamic> json) =>
      _$ExamQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$ExamQuestionToJson(this);
}
