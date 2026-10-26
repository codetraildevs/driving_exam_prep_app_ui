import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../network/api_helper.dart';
import '../network/offline_cache.dart';
import '../session/auth_session.dart';

/// Watches connectivity and syncs pending offline data when back online.
class SyncService {
  static final SyncService _instance = SyncService._();
  factory SyncService() => _instance;
  SyncService._() : currentUserId = null, submit = null;
  SyncService.forTesting({required this.currentUserId, required this.submit});
  final Future<String?> Function()? currentUserId;
  final Future<ApiResponse> Function(Map<String, dynamic>)? submit;
  Future<void>? _syncing;

  Future<String?> _userId() async =>
      currentUserId != null ? await currentUserId!() : (await AuthSession().getUser())?.id;

  final _cache = OfflineCache();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Timer? _connectivityTimer;
  final _onlineController = StreamController<bool>.broadcast();
  Stream<bool> get onlineStream => _onlineController.stream;

  /// Start periodic connectivity checks.
  void start() {
    _checkConnectivity();
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _checkConnectivity(),
    );
  }

  void dispose() {
    _connectivityTimer?.cancel();
    _onlineController.close();
  }

  Future<void> _checkConnectivity() async {
    // dart:io is stubbed on web — InternetAddress.lookup throws
    // UnsupportedError there. Browsers expose their own online/offline
    // events; keep the default (online) state on web.
    if (kIsWeb) {
      await syncPendingResults();
      return;
    }

    final wasOnline = _isOnline;
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      _isOnline = false;
    } on TimeoutException {
      _isOnline = false;
    } catch (_) {
      _isOnline = false;
    }

    if (_isOnline != wasOnline) {
      if (!_onlineController.isClosed) _onlineController.add(_isOnline);
    }

    // When coming back online, sync pending data
    if (_isOnline) {
      await syncPendingResults();
    }
  }

  /// Force a connectivity check now.
  Future<bool> checkNow() async {
    await _checkConnectivity();
    return _isOnline;
  }

  /// Sync all pending practice results to the backend.
  Future<void> syncPendingResults() {
    return _syncing ??= _syncOnce().whenComplete(() => _syncing = null);
  }

  Future<void> _syncOnce() async {
    try {
      final userId = await _userId();
      if (userId == null) return;
      final pending = (await _cache.getPendingResults())
          .where((row) => row['userId'] == userId).toList();
      for (final row in pending) {
        if (await _userId() != userId) return;
        final result = await (submit != null
            ? submit!(row)
            : ApiHelper().post('/api/practice-results', body: row));
        if (!result.isSuccess) return; // Keep the outbox; retry on the next check.
        final serverId = result.data is Map ? result.data['id']?.toString() : null;
        if (serverId == null || serverId.isEmpty) return;
        await _cache.acknowledgeResult(row['clientResultId'] as String, userId, serverId);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[SyncService] Results remain queued for retry.');
    }
  }
}
