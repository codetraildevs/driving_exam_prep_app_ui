import 'dart:math';
import '../../../shared/network/api_helper.dart';

class IremboRepository {
  final ApiHelper _api = ApiHelper();
  static const path = '/api/irembo-requests';
  Future<Map<String, dynamic>> list(Map<String, String> filters) async =>
      _map(await _api.get(path, queryParams: filters));
  Future<Map<String, dynamic>> get(String id) async =>
      _map(await _api.get('$path/${Uri.encodeComponent(id)}'));
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async =>
      _map(await _api.post(path, body: data));
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async =>
      _map(await _api.put('$path/${Uri.encodeComponent(id)}', body: data));
  Future<List<Map<String, dynamic>>> staff() async {
    final response = await _api.get('$path/staff');
    if (!response.isSuccess)
      throw IremboFailure(response.errorMessage ?? 'iremboUnavailable');
    return response.dataList
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Map<String, dynamic> _map(ApiResponse response) {
    if (!response.isSuccess || response.data is! Map)
      throw IremboFailure(response.errorMessage ?? 'iremboUnavailable');
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
  const IremboFailure(this.code);
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
    if (!RegExp(r'^07[2389]\d{7}$').hasMatch(phone(data['phoneNumber'])))
      return 'phoneNumber';
    if (!RegExp(r'^\d{16}$').hasMatch((data['nationalId'] as String).trim()))
      return 'nationalId';
    if (!validDate(data['dob']) ||
        DateTime.parse(data['dob']).isAfter(DateTime.now()))
      return 'dob';
    if (!['Provisoire', 'Permis'].contains(data['service'])) return 'service';
    if (!['rw', 'en', 'fr'].contains(data['examLanguage']))
      return 'examLanguage';
    if (!districts.contains(data['district'])) return 'district';
    if (data['service'] == 'Permis') {
      if (!['Manual', 'Automatic'].contains(data['permisOption']))
        return 'permisOption';
      if ((data['provisoireCode']?.toString().trim() ?? '').isEmpty ||
          data['provisoireCode'].toString().length > 80)
        return 'provisoireCode';
      final category = data['category']?.toString().trim().toUpperCase();
      if (data['permisOption'] == 'Automatic'
          ? category != 'A'
          : !['A', 'B', 'F'].contains(category))
        return 'category';
    }
    final date = data['preferredExamDate'];
    if (date != null && date != '') {
      if (!validDate(date)) return 'preferredExamDate';
    }
    return null;
  }

  static bool validDate(dynamic value) {
    if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value))
      return false;
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
