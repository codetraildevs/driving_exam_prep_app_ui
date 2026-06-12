// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exam _$ExamFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Exam', json, ($checkedConvert) {
      final val = Exam(
        quizId: $checkedConvert('quizId', (v) => v as String? ?? ''),
        examType: $checkedConvert('examType', (v) => v as String? ?? ''),
        title: $checkedConvert('title', (v) => v as String? ?? ''),
        examImgUrl: $checkedConvert('examImgUrl', (v) => v as String? ?? ''),
        questions: $checkedConvert(
          'questions',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => ExamQuestion.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
        ),
      );
      return val;
    });

Map<String, dynamic> _$ExamToJson(Exam instance) => <String, dynamic>{
  'quizId': instance.quizId,
  'examType': instance.examType,
  'title': instance.title,
  'examImgUrl': instance.examImgUrl,
  'questions': instance.questions.map((e) => e.toJson()).toList(),
};
