import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/network/api_client.dart';
import '../../../../shared/network/api_config.dart';
import '../../../../shared/network/api_endpoints.dart';
import '../../../../shared/session/auth_session.dart';
import '../models/exam_model.dart';
import '../models/exam_question.dart';

class ExamRepository {
  static final ExamRepository _instance = ExamRepository._internal();
  factory ExamRepository() => _instance;
  ExamRepository._internal();

  final Map<String, List<Exam>> _cache = {};

  final ApiClient _api = ApiClient(
    dioClient: Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 2),
      receiveTimeout: const Duration(seconds: 2),
    )),
  );
  final AuthSession _session = AuthSession();

  Future<List<Exam>> loadAllExams(String langCode) async {
    if (_cache.containsKey(langCode)) {
      return _cache[langCode]!;
    }

    List<Exam> exams;
    try {
      exams = await _loadExamsFromBackend(langCode);
      if (exams.isEmpty) {
        exams = await _loadExamsFromCached(langCode) ??
            await _loadExamsFromAsset(langCode);
      } else {
        await _saveExamsToCached(langCode, exams);
      }
    } catch (_) {
      exams = await _loadExamsFromCached(langCode) ??
          await _loadExamsFromAsset(langCode);
      if (exams.isEmpty) {
        try {
          exams = await _loadExamsFromAsset(langCode);
        } catch (_) {
          exams = await _loadExamsFromAsset('rw');
        }
      }
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

  Future<List<Exam>> _loadExamsFromBackend(String langCode) async {
    final token = await _session.getToken();
    final data = await _api.get(
      ApiEndpoints.exams,
      queryParameters: {'language': langCode},
      headers: token == null ? null : {'Authorization': 'Bearer $token'},
    );

    final rawList = data is List
        ? data
        : (data is Map
            ? (data['exams'] ?? data['data'] ?? <dynamic>[])
            : <dynamic>[]);

    final exams = <Exam>[];
    for (final item in rawList) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final id = (m['id'] ?? '').toString();
      if (id.isEmpty) continue;

      final courseType = (m['examType'] ?? m['courseType'] ?? '').toString().toLowerCase();
      final isFree = courseType == 'free';

      final questions = await _loadQuestionsFromBackend(id);

      exams.add(Exam(
        quizId: id,
        examType: isFree ? 'Free' : 'Paid',
        title: (m['title'] ?? '').toString(),
        examImgUrl: (m['examImgUrl'] ?? '').toString(),
        questions: questions,
      ));
    }
    return exams;
  }

  Future<List<ExamQuestion>> _loadQuestionsFromBackend(String examId) async {
    try {
      final token = await _session.getToken();
      final data = await _api.get(
        ApiEndpoints.examQuestions(examId),
        queryParameters: {'limit': 100},
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
      );

      final rawQuestions = data is Map
          ? (data['questions'] ?? data['data'] ?? <dynamic>[])
          : (data is List ? data : <dynamic>[]);

      return rawQuestions.whereType<Map>().map((q) {
        final m = Map<String, dynamic>.from(q);
        return ExamQuestion(
          question: (m['content'] ?? m['title'] ?? '').toString(),
          option1: (m['option1'] ?? '').toString(),
          option2: (m['option2'] ?? '').toString(),
          option3: (m['option3'] ?? '').toString(),
          option4: (m['option4'] ?? '').toString(),
          correctAnswer: (m['correctAnswer'] ?? m['correct_answer'] ?? '').toString(),
          questionImgUrl: (m['questionImgUrl'] ?? m['question_img_url'] ?? '').toString(),
        );
      }).toList();
    } catch (_) {
      return const <ExamQuestion>[];
    }
  }

  Future<List<Exam>?> _loadExamsFromCached(String langCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('exam_cache_$langCode');
      if (raw == null || raw.isEmpty) return null;
      final decoded = json.decode(raw);
      if (decoded is! List) return null;
      final exams = decoded
          .whereType<Map>()
          .map((e) => Exam.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return exams.isEmpty ? null : exams;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveExamsToCached(String langCode, List<Exam> exams) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'exam_cache_$langCode',
        json.encode(exams.map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      // Best-effort cache; ignore failures.
    }
  }

  Future<List<Exam>> _loadExamsFromAsset(String langCode) async {
    final jsonString =
        await rootBundle.loadString('assets/exams/${langCode}_exams.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> examList = jsonData['exams'] ?? [];
    return examList.map((e) => Exam.fromJson(e)).toList();
  }
}
