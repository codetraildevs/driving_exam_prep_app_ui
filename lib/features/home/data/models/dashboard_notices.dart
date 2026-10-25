import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/network/api_helper.dart';

class DashboardNotice {
  final String title;
  final String body;
  final bool unread;
  const DashboardNotice({required this.title, required this.body, required this.unread});
}

/// A stub response is unavailable, not an empty notification inbox.
class DashboardNotices {
  final List<DashboardNotice> items;
  const DashboardNotices(this.items);
  int get unreadCount => items.where((item) => item.unread).length;

  factory DashboardNotices.fromPayload(dynamic payload) {
    final dynamic rows = payload is List ? payload : payload is Map ? payload['notifications'] : null;
    if (rows is! List) throw const FormatException('Notifications are not available');
    return DashboardNotices(rows.whereType<Map>().map((row) {
      final read = row['isRead'] ?? row['is_read'];
      return DashboardNotice(
        title: row['title'] is String ? row['title'] as String : '',
        body: row['body'] is String ? row['body'] as String : row['message'] is String ? row['message'] as String : '',
        unread: read == false || read == 0 || read == '0',
      );
    }).where((item) => item.title.isNotEmpty || item.body.isNotEmpty).toList());
  }
}

// Scope notification state to the signed-in user; never reuse another inbox.
final dashboardNoticesProvider = FutureProvider.autoDispose.family<DashboardNotices, String>((ref, userId) async {
  final result = await ApiHelper().get('/api/notifications');
  if (!result.isSuccess) throw StateError('Notifications request failed');
  return DashboardNotices.fromPayload(result.data);
});
