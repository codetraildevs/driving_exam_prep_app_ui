import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_rule_in_rwanda/features/home/data/models/dashboard_notices.dart';

void main() {
  test('backend stub is unavailable rather than a fabricated empty inbox', () {
    expect(() => DashboardNotices.fromPayload({'message': 'Notifications endpoint', 'userId': 'u1'}), throwsFormatException);
  });
  test('empty notification list is supported', () {
    expect(DashboardNotices.fromPayload({'notifications': []}).items, isEmpty);
  });
  test('badge counts only explicit unread records with content', () {
    final data = DashboardNotices.fromPayload([
      {'title': 'Unread', 'isRead': false},
      {'title': 'Read', 'is_read': 1},
      {'title': 'Unknown read status'},
      {'title': 'Unread numeric', 'is_read': 0},
      {'isRead': false},
    ]);
    expect(data.unreadCount, 2);
    expect(data.items.length, 4);
  });
}
