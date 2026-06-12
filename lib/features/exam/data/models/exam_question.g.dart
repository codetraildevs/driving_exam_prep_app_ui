// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamQuestion _$ExamQuestionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExamQuestion', json, ($checkedConvert) {
      final val = ExamQuestion(
        question: $checkedConvert('question', (v) => v as String? ?? ''),
        option1: $checkedConvert('option1', (v) => v as String? ?? ''),
        option2: $checkedConvert('option2', (v) => v as String? ?? ''),
        option3: $checkedConvert('option3', (v) => v as String? ?? ''),
        option4: $checkedConvert('option4', (v) => v as String? ?? ''),
        correctAnswer: $checkedConvert(
          'correctAnswer',
          (v) => v as String? ?? '',
        ),
        questionImgUrl: $checkedConvert(
          'questionImgUrl',
          (v) => v as String? ?? '',
        ),
      );
      return val;
    });

Map<String, dynamic> _$ExamQuestionToJson(ExamQuestion instance) =>
    <String, dynamic>{
      'question': instance.question,
      'option1': instance.option1,
      'option2': instance.option2,
      'option3': instance.option3,
      'option4': instance.option4,
      'correctAnswer': instance.correctAnswer,
      'questionImgUrl': instance.questionImgUrl,
    };
