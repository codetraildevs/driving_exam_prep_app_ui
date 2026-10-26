import 'package:flutter/services.dart';
import 'package:traffic_rule_in_rwanda/features/exam/data/repositories/exam_repository.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/repositories/auth_repository.dart';
import 'package:traffic_rule_in_rwanda/features/auth/presentation/bloc/auth_bloc.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/shared/network/offline_cache.dart';
import 'package:traffic_rule_in_rwanda/shared/network/api_helper.dart';
import 'package:traffic_rule_in_rwanda/shared/network/sync_service.dart';
import 'package:traffic_rule_in_rwanda/shared/subscription/subscription_notifier.dart';

Map<String, dynamic> attempt(String user, String exam) => {
  'userId': user, 'examId': exam, 'score': 90, 'totalQuestions': 20,
  'correctAnswers': 18, 'timeSpent': 100,
};
const failed = ApiResponse(statusCode: 0, data: null, isSuccess: false, debugInfo: 'offline');
ApiResponse success(String id) => ApiResponse(statusCode: 201, data: {'id': id},
  isSuccess: true, debugInfo: 'saved');

class _CachedAuth extends AuthRepository {
  final Completer<bool> refresh = Completer<bool>();
  final user = UserModel(id: 'u1', name: 'Offline Driver', phoneNumber: '0788123456',
    createdAt: DateTime(2026), updatedAt: DateTime(2026));
  @override Future<UserModel?> getCurrentUser() async => user;
  @override Future<bool> tryRefreshSession() => refresh.future;
  @override Future<String?> getCurrentUserId() async => user.id;
  @override Future<UserModel?> fetchUserProfile(String id) async => user;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final cache = OfflineCache();
  testWidgets('study languages load offline and existing image gaps remain explicit', (tester) async {
    await tester.runAsync(() async {
      final images = <String>{};
      for (final language in ['rw', 'en', 'fr']) {
        ExamRepository().clearCache();
        final exams = await ExamRepository().loadAllExams(language);
        expect(exams, isNotEmpty);
        expect(exams.any((e) => e.isFree), isTrue);
        for (final exam in exams) {
          expect(exam.questions, isNotEmpty);
          images.addAll(exam.questions.map((q) => q.questionImgUrl).where((p) => p.isNotEmpty));
        }
      }
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final bundled = manifest.listAssets().toSet();
      // Existing content is preserved at the owner's request. Keep known
      // missing references explicit; detect any new packaging regressions.
      const knownMissing = {
        'assets/images/ex12q6.webp', 'assets/images/q264.webp',
        'assets/images/q265.webp', 'assets/images/q267.webp',
        'assets/images/q289.webp', 'assets/images/q290.webp',
        'assets/images/q319.webp', 'assets/images/q253.webp',
        'assets/images/q254.webp', 'assets/images/q255.webp',
        'assets/images/q256.webp', 'assets/images/q18.webp',
        'assets/images/q88.webp', 'URL_232', 'URL_233', 'URL_296',
      };
      expect(images.difference(bundled), knownMissing,
        reason: 'Report content gaps without editing authored exams.');
      for (final path in images.intersection(bundled)) {
        expect((await rootBundle.load(path)).lengthInBytes, greaterThan(0), reason: path);
      }
    });
  });

  test('cached account becomes available before the network responds', () async {
    final repo = _CachedAuth();
    final bloc = AuthBloc(authRepository: repo);
    final authenticated = bloc.stream.firstWhere((state) => state is AuthAuthenticated);
    bloc.add(const CheckAuthStatusEvent());
    await authenticated.timeout(const Duration(seconds: 1));
    expect(repo.refresh.isCompleted, isFalse);
    repo.refresh.complete(false);
    await bloc.close();
  });


  test('concurrent offline attempts persist separately and survive server refresh', () async {
    await Future.wait([cache.queuePendingResult(attempt('u1', 'a')),
      cache.queuePendingResult(attempt('u1', 'b'))]);
    final pending = await cache.getPendingResults();
    expect(pending.length, 2);
    expect(pending.map((e) => e['clientResultId']).toSet().length, 2);
    await cache.save(cache.examResultsKey('u1'), []);
    expect((await cache.load(cache.examResultsKey('u1')) as List).length, 2);
    await cache.save(cache.examResultsKey('u2'), []);
    expect(await cache.load(cache.examResultsKey('u2')), isEmpty);
  });

  test('failed sync retains results, retry is single flight and account scoped', () async {
    await cache.queuePendingResult(attempt('u1', 'a'));
    await cache.queuePendingResult(attempt('u2', 'b'));
    final pendingResponse = Completer<ApiResponse>();
    var calls = 0;
    final sync = SyncService.forTesting(currentUserId: () async => 'u1',
      submit: (body) { calls++; expect(body['userId'], 'u1'); return pendingResponse.future; });
    final first = sync.syncPendingResults();
    final second = sync.syncPendingResults();
    await Future<void>.delayed(Duration.zero);
    pendingResponse.complete(failed);
    await Future.wait([first, second]);
    expect(calls, 1);
    expect((await cache.getPendingResults()).length, 2);
    final retry = SyncService.forTesting(currentUserId: () async => 'u1',
      submit: (body) async => success(body['clientResultId'] as String));
    await retry.syncPendingResults();
    expect((await cache.getPendingResults()).single['userId'], 'u2');
  });

  test('attempt queued during sync is not removed with an older attempt', () async {
    await cache.queuePendingResult(attempt('u1', 'a'));
    final response = Completer<ApiResponse>();
    final started = Completer<String>();
    final sync = SyncService.forTesting(currentUserId: () async => 'u1',
      submit: (body) { started.complete(body['clientResultId'] as String); return response.future; });
    final running = sync.syncPendingResults();
    final id = await started.future;
    await cache.queuePendingResult(attempt('u1', 'b'));
    response.complete(success(id));
    await running;
    expect((await cache.getPendingResults()).single['examId'], 'b');
  });

  test('outbox recovers progress after an interrupted cache write', () async {
    await cache.queuePendingResult(attempt('u1', 'a'));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('offline_cache_exam_results_u1');
    expect((await cache.load(cache.examResultsKey('u1')) as List).single['examId'], 'a');
    expect(await cache.load(cache.examResultsKey('u2')), isNull);
  });

  test('legacy queued attempts receive stable retry identifiers', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('offline_cache_pending_results', jsonEncode([attempt('u1', 'a')]));
    final first = (await cache.getPendingResults()).single['clientResultId'];
    expect(first, isNotNull);
    expect((await cache.getPendingResults()).single['clientResultId'], first);
  });

  test('invalid cached JSON does not prevent opening offline content', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('offline_cache_broken', '{');
    expect(await cache.load('broken'), isNull);
  });

  test('offline access remains scoped to the verified account and expires', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_status_u1', jsonEncode({
      'hasActiveAccess': true, 'expiresAt': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'paymentTier': '1_MONTH',
    }));
    final container = ProviderContainer(overrides: [
      subscriptionProvider.overrideWith(() => SubscriptionNotifier(loader: (_) async => failed)),
    ]);
    addTearDown(container.dispose);
    final notifier = container.read(subscriptionProvider.notifier);
    await notifier.refreshStatus('u1');
    expect(container.read(subscriptionProvider).hasActiveAccess, isTrue);
    expect(container.read(subscriptionProvider).hasError, isTrue);
    await notifier.refreshStatus('u2');
    expect(container.read(subscriptionProvider).hasActiveAccess, isFalse);
    await prefs.setString('access_status_u1', jsonEncode({
      'hasActiveAccess': true, 'expiresAt': DateTime.now().subtract(const Duration(seconds: 1)).toIso8601String(),
    }));
    await notifier.refreshStatus('u1');
    expect(container.read(subscriptionProvider).hasActiveAccess, isFalse);
  });

  test('access state stops granting access when its expiry passes', () async {
    final state = SubscriptionState(hasActiveAccess: true,
      expiresAt: DateTime.now().add(const Duration(milliseconds: 20)));
    expect(state.hasActiveAccess, isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(state.hasActiveAccess, isFalse);
  });
}
