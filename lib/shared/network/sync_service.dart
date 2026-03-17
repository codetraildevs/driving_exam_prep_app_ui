import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../network/api_helper.dart';
import '../network/offline_cache.dart';

/// Watches connectivity and syncs pending offline data when back online.
class SyncService {
  static final SyncService _instance = SyncService._();
  factory SyncService() => _instance;
  SyncService._();

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
      _onlineController.add(_isOnline);
    }

    // When coming back online, sync pending data
    if (_isOnline && !wasOnline) {
      await syncPendingResults();
    }
  }

  /// Force a connectivity check now.
  Future<bool> checkNow() async {
    await _checkConnectivity();
    return _isOnline;
  }

  /// Sync all pending practice results to the backend.
  Future<void> syncPendingResults() async {
    final pending = await _cache.getPendingResults();
    if (pending.isEmpty) return;

    if (kDebugMode) {
      debugPrint('[SyncService] Syncing ${pending.length} pending results...');
    }

    int synced = 0;
    for (int i = pending.length - 1; i >= 0; i--) {
      try {
        final result = await ApiHelper().post(
          '/api/practice-results',
          body: pending[i],
        );
        if (result.isSuccess) {
          await _cache.removePendingResult(i);
          synced++;
        }
      } catch (_) {
        // Will retry on next connectivity change
      }
    }

    if (kDebugMode && synced > 0) {
      debugPrint('[SyncService] Synced $synced results successfully');
    }
  }
}
