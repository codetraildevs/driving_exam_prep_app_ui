import '../../../shared/network/api_helper.dart';
import 'referral_session.dart';

class ReferralSummary {
  final String code;
  final String link;
  final int total;
  final int confirmed;
  final int pending;
  final List<Map<String, dynamic>> history;
  final int? nextOffset;

  ReferralSummary.fromJson(Map<String, dynamic> json)
    : code = json['code'] as String,
      link = json['link'] as String,
      total = (json['total'] as num).toInt(),
      confirmed = (json['confirmed'] as num).toInt(),
      pending = (json['pending'] as num).toInt(),
      history = (json['history'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      nextOffset = (json['nextOffset'] as num?)?.toInt() {
    if (ReferralSession.codeFromLink(link) != code) {
      throw const FormatException('Invalid invitation');
    }
  }

  ReferralSummary._(
    this.code,
    this.link,
    this.total,
    this.confirmed,
    this.pending,
    this.history,
    this.nextOffset,
  );

  /// Appends the next page of history to this summary.
  ReferralSummary append(ReferralSummary next) => ReferralSummary._(
    next.code,
    next.link,
    next.total,
    next.confirmed,
    next.pending,
    [...history, ...next.history],
    next.nextOffset,
  );
}

class ReferralRepository {
  Future<ReferralSummary> load({int offset = 0}) async {
    final response = await ApiHelper().get(
      '/api/referrals/me',
      queryParams: {'offset': '$offset'},
    );
    if (!response.isSuccess || response.data is! Map) {
      throw const FormatException('Referral service unavailable');
    }
    return ReferralSummary.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
