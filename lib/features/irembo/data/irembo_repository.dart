import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/network/api_helper.dart';
import '../../../shared/network/offline_cache.dart';
import '../../../shared/session/auth_session.dart';

class IremboRepository {
  final ApiHelper _api;
  IremboRepository({ApiHelper? api}) : _api = api ?? ApiHelper();
  final _cache = OfflineCache();
  Future<void> _invalidate() async {
    final scope = await _scope();
    if (scope == null) return;
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where(
      (k) => k.startsWith('offline_cache_${scope}_'),
    )) {
      await prefs.remove(key);
    }
  }

  Future<String?> _scope() async {
    final user = await AuthSession().getUser();
    return user == null ? null : 'irembo_${user.id}_${user.role}';
  }

  String _listKey(String scope, Map<String, String> filters) {
    final keys = filters.keys.toList()..sort();
    return '${scope}_list_${jsonEncode({for (final key in keys) key: filters[key]})}';
  }

  Future<Map<String, dynamic>?> cachedList(Map<String, String> filters) async {
    final scope = await _scope();
    if (scope == null) return null;
    final data = await _cache.load(_listKey(scope, filters));
    return data is Map
        ? {...Map<String, dynamic>.from(data), 'offline': true}
        : null;
  }

  Future<Map<String, dynamic>> _read(
    String endpoint,
    String key,
    String? scope, {
    Map<String, String>? filters,
  }) async {
    final response = await _api.get(endpoint, queryParams: filters);
    if (scope != await _scope()) {
      throw const IremboFailure('forbidden', statusCode: 403);
    }
    if (response.isSuccess) {
      final data = _map(response);
      if (scope != null) {
        try {
          await _cache.save(key, data);
        } catch (_) {
          /* Online reads still succeed. */
        }
      }
      return data;
    }
    if (scope != null &&
        (response.statusCode == 0 || response.statusCode >= 500)) {
      final cached = await _cache.load(key);
      if (cached is Map) {
        return {...Map<String, dynamic>.from(cached), 'offline': true};
      }
    }
    if (scope != null && [401, 403].contains(response.statusCode)) {
      await _invalidate();
    } else if (scope != null && response.statusCode == 404) {
      await _cache.remove(key);
    }
    return _map(response);
  }

  static const path = '/api/irembo-requests';
  Future<Map<String, dynamic>> list(Map<String, String> filters) async {
    final scope = await _scope();
    return _read(path, _listKey(scope ?? '', filters), scope, filters: filters);
  }

  Future<Map<String, dynamic>> get(String id) async {
    final scope = await _scope();
    return _read(
      '$path/${Uri.encodeComponent(id)}',
      '${scope}_detail_$id',
      scope,
    );
  }

  Future<void> delete(String id) async {
    var response = await _api.delete('$path/${Uri.encodeComponent(id)}');
    if ([404, 405].contains(response.statusCode)) {
      response = await _api.post('$path/${Uri.encodeComponent(id)}/delete');
    }
    if (!response.isSuccess) {
      throw IremboFailure(
        response.statusCode == 404
            ? 'iremboDeleteUnavailable'
            : response.errorMessage ?? 'iremboUnavailable',
        statusCode: response.statusCode,
      );
    }
    await _invalidate();
  }

  Future<void> deleteMany(List<String> ids) async {
    final response = await _api.post('$path/bulk-delete', body: {'ids': ids});
    if (!response.isSuccess) {
      throw IremboFailure(
        response.statusCode == 404
            ? 'iremboDeleteUnavailable'
            : response.errorMessage ?? 'iremboUnavailable',
        statusCode: response.statusCode,
      );
    }
    await _invalidate();
  }

  Future<Map<String, dynamic>> _remember(
    Map<String, dynamic> row,
    String? scope,
  ) async {
    if (scope != await _scope()) {
      throw const IremboFailure('forbidden', statusCode: 403);
    }
    if (scope == null) return row;
    try {
      final previous = await cachedList({});
      await _invalidate();
      await _cache.save('${scope}_detail_${row['id']}', row);
      if (scope.endsWith('_USER')) {
        final items =
            (previous?['items'] as List? ?? [])
                .where((r) => r['id'] != row['id'])
                .toList()
              ..add(row);
        await _cache.save(_listKey(scope, {}), {
          'items': items,
          'total': items.length,
        });
      }
    } catch (_) {
      /* A successful submission must not fail due to local storage. */
    }
    return row;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final scope = await _scope();
    return _remember(_map(await _api.post(path, body: data)), scope);
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final scope = await _scope();
    return _remember(
      _map(await _api.put('$path/${Uri.encodeComponent(id)}', body: data)),
      scope,
    );
  }

  Future<List<Map<String, dynamic>>> staff() async {
    final response = await _api.get('$path/staff');
    if (!response.isSuccess) {
      throw IremboFailure(
        response.errorMessage ?? 'iremboUnavailable',
        statusCode: response.statusCode,
      );
    }
    return response.dataList
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Map<String, dynamic> _map(ApiResponse response) {
    if (!response.isSuccess || response.data is! Map) {
      throw IremboFailure(
        response.errorMessage ?? 'iremboUnavailable',
        statusCode: response.statusCode,
      );
    }
    return Map<String, dynamic>.from(response.data as Map);
  }

  static String newKey() {
    final random = Random.secure();
    final b = List.generate(16, (_) => random.nextInt(256));
    b[6] = (b[6] & 15) | 64;
    b[8] = (b[8] & 63) | 128;
    final s = b.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
    return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
  }
}

class IremboFailure implements Exception {
  final String code;
  final int? statusCode;
  const IremboFailure(this.code, {this.statusCode});
}

class IremboRules {
  static const districts = [
    'Bugesera',
    'Gasabo',
    'Gicumbi',
    'Gisagara',
    'Huye',
    'Karongi',
    'Kayonza',
    'Kicukiro',
    'Kirehe',
    'Muhanga',
    'Musanze',
    'Ngoma',
    'Ngororero',
    'Nyagatare',
    'Nyamagabe',
    'Nyamasheke',
    'Nyanza',
    'Nyarugenge',
    'Nyaruguru',
    'Rubavu',
    'Ruhango',
    'Rusizi',
    'Rutsiro',
    'Rwamagana',
  ];
  static const statuses = [
    'Pending',
    'In Review',
    'Needs Information',
    'Completed',
    'Rejected',
    'Cancelled',
  ];
  static String phone(String input) {
    final value = input.trim().replaceAll(RegExp(r'[\s()\-]'), '');
    final match = RegExp(r'^(?:\+?250|0)?(7[2389]\d{7})$').firstMatch(value);
    return match == null ? value : '0${match[1]}';
  }

  static String? validate(Map<String, dynamic> data) {
    for (final f in [
      'fullName',
      'phoneNumber',
      'nationalId',
      'dob',
      'service',
      'examLanguage',
      'district',
    ]) {
      if (data[f] is! String || (data[f] as String).trim().isEmpty) return f;
    }
    if ((data['fullName'] as String).trim().length > 150) return 'fullName';
    if (!RegExp(r'^07[2389]\d{7}$').hasMatch(phone(data['phoneNumber']))) {
      return 'phoneNumber';
    }
    if (!RegExp(r'^\d{16}$').hasMatch((data['nationalId'] as String).trim())) {
      return 'nationalId';
    }
    if (!validDate(data['dob']) ||
        DateTime.parse(data['dob']).isAfter(DateTime.now())) {
      return 'dob';
    }
    if (!['Provisoire', 'Permis'].contains(data['service'])) return 'service';
    if (!['rw', 'en', 'fr'].contains(data['examLanguage'])) {
      return 'examLanguage';
    }
    if (!districts.contains(data['district'])) return 'district';
    if (data['service'] == 'Permis') {
      if (!['Manual', 'Automatic'].contains(data['permisOption'])) {
        return 'permisOption';
      }
      if ((data['provisoireCode']?.toString().trim() ?? '').isEmpty ||
          data['provisoireCode'].toString().length > 80) {
        return 'provisoireCode';
      }
      final category = data['category']?.toString().trim().toUpperCase();
      if (data['permisOption'] == 'Automatic'
          ? category != 'A'
          : !['A', 'B', 'F'].contains(category)) {
        return 'category';
      }
    }
    final date = data['preferredExamDate'];
    if (date != null && date != '') {
      if (!validDate(date)) return 'preferredExamDate';
    }
    return null;
  }

  static bool validDate(dynamic value) {
    if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return false;
    }
    final date = DateTime.tryParse(value);
    return date != null && date.toIso8601String().substring(0, 10) == value;
  }

  static Map<String, dynamic> applicable(Map<String, dynamic> input) {
    final data = Map<String, dynamic>.from(input);
    for (final key in ['fullName', 'nationalId', 'provisoireCode']) {
      if (data[key] is String) data[key] = (data[key] as String).trim();
    }
    data['phoneNumber'] = phone(data['phoneNumber']?.toString() ?? '');
    if (data['service'] != 'Permis') {
      data.remove('permisOption');
      data.remove('category');
      data.remove('provisoireCode');
    } else if (data['permisOption'] == 'Automatic') {
      data['category'] = 'A';
    } else {
      data['category'] = data['category']?.toString().trim().toUpperCase();
    }
    if (data['preferredExamDate'] == '') data.remove('preferredExamDate');
    return data;
  }
}
