import 'package:json_annotation/json_annotation.dart';

import 'exam_question.dart';

part 'exam_model.g.dart';

@JsonSerializable()
class Exam {
  @JsonKey(defaultValue: '')
  final String quizId;

  @JsonKey(defaultValue: '')
  final String examType;

  @JsonKey(defaultValue: '')
  final String title;

  @JsonKey(defaultValue: '')
  final String examImgUrl;

  @JsonKey(defaultValue: [])
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

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);

  Map<String, dynamic> toJson() => _$ExamToJson(this);
}
