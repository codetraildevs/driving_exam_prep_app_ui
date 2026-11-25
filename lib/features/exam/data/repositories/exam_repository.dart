import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/exam_model.dart';

class ExamRepository {
  static final ExamRepository _instance = ExamRepository._internal();
  factory ExamRepository() => _instance;
  ExamRepository._internal();

  final Map<String, List<Exam>> _cache = {};

  /// Loads all exams for the given language code.
  /// Falls back to 'rw' if the language-specific file doesn't exist.
  Future<List<Exam>> loadAllExams(String langCode) async {
    if (_cache.containsKey(langCode)) {
      return _cache[langCode]!;
    }

    List<Exam> exams;
    try {
      exams = await _loadExamsFromAsset(langCode);
    } catch (_) {
      // Fallback to Kinyarwanda
      exams = await _loadExamsFromAsset('rw');
    }

    _cache[langCode] = exams;
    return exams;
  }

  Future<List<Exam>> loadFreeExams(String langCode) async {
    final all = await loadAllExams(langCode);
    return all.where((e) => e.isFree).toList();
  }

  Future<List<Exam>> loadPaidExams(String langCode) async {
    final all = await loadAllExams(langCode);
    return all.where((e) => e.isPaid).toList();
  }

  Future<Exam?> getExamById(String quizId, String langCode) async {
    final all = await loadAllExams(langCode);
    try {
      return all.firstWhere((e) => e.quizId == quizId);
    } catch (_) {
      return null;
    }
  }

  void clearCache() {
    _cache.clear();
  }

  Future<List<Exam>> _loadExamsFromAsset(String langCode) async {
    final jsonString =
        await rootBundle.loadString('assets/exams/${langCode}_exams.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> examList = jsonData['exams'] ?? [];
    return examList.map((e) => Exam.fromJson(e)).toList();
  }
}
