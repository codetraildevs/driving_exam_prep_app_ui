import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_rule_in_rwanda/features/auth/data/models/user_model.dart';
import 'package:traffic_rule_in_rwanda/features/irembo/data/irembo_repository.dart';
import 'package:traffic_rule_in_rwanda/shared/network/api_helper.dart';
import 'package:traffic_rule_in_rwanda/shared/session/auth_session.dart';

class TestApi implements ApiHelper {
  ApiResponse response = const ApiResponse(
    statusCode: 200,
    data: {
      'items': [
        {'id': 'r1'},
      ],
      'total': 1,
    },
    isSuccess: true,
    debugInfo: '',
  );
  int deleteStatus = 404;
  final posts = <String>[];
  @override
  Future<ApiResponse> get(
    String path, {
    Map<String, String>? queryParams,
  }) async => response;
  @override
  Future<ApiResponse> delete(String path) async => ApiResponse(
    statusCode: deleteStatus,
    data: null,
    isSuccess: false,
    debugInfo: '',
  );
  @override
  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    posts.add(path);
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> signIn(String id, {String role = 'USER'}) => AuthSession().setUser(
  UserModel(
    id: id,
    name: 'Applicant',
    phoneNumber: '0788123456',
    role: role,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'saved requests survive restart and timeouts but never cross accounts or roles',
    () async {
      await signIn('u1');
      final api = TestApi();
      await IremboRepository(api: api).list({});
      api.response = const ApiResponse(
        statusCode: 0,
        data: null,
        isSuccess: false,
        debugInfo: 'timeout',
      );
      final repo = IremboRepository(api: api);
      expect((await repo.cachedList({}))?['total'], 1);
      expect((await repo.list({}))['offline'], true);
      expect(await repo.cachedList({'service': 'Permis'}), isNull);
      await signIn('u2');
      expect(await repo.cachedList({}), isNull);
      await expectLater(repo.list({}), throwsA(isA<IremboFailure>()));
      await signIn('u1', role: 'ADMIN');
      expect(await repo.cachedList({}), isNull);
      await signIn('u1');
      await AuthSession().clear();
      await signIn('u1');
      expect(await repo.cachedList({}), isNull);
    },
  );

  test('authorization failures never fall back to cached data', () async {
    await signIn('u1');
    final api = TestApi();
    final repo = IremboRepository(api: api);
    await repo.list({});
    api.response = const ApiResponse(
      statusCode: 403,
      data: null,
      isSuccess: false,
      debugInfo: '',
    );
    await expectLater(repo.list({}), throwsA(isA<IremboFailure>()));
    expect(await repo.cachedList({}), isNull);
  });

  test(
    'DELETE route failure uses POST fallback and invalidates saved requests',
    () async {
      await signIn('a1', role: 'ADMIN');
      final api = TestApi();
      final repo = IremboRepository(api: api);
      await repo.list({});
      await repo.delete('r1');
      expect(api.posts, ['/api/irembo-requests/r1/delete']);
      expect(await repo.cachedList({}), isNull);
      api.deleteStatus = 403;
      await expectLater(repo.delete('r1'), throwsA(isA<IremboFailure>()));
      expect(api.posts.length, 1);
    },
  );

  test(
    'missing delete endpoints report deployment problem without false success',
    () async {
      final api = TestApi()
        ..response = const ApiResponse(
          statusCode: 404,
          data: null,
          isSuccess: false,
          debugInfo: '',
        );
      final repo = IremboRepository(api: api);
      await expectLater(
        repo.delete('r1'),
        throwsA(
          isA<IremboFailure>().having(
            (e) => e.code,
            'code',
            'iremboDeleteUnavailable',
          ),
        ),
      );
      await expectLater(
        repo.deleteMany(['r1', 'r2']),
        throwsA(isA<IremboFailure>()),
      );
    },
  );
}
