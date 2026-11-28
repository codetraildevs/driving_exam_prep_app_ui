import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Process-wide crash reporting backed by Firebase Crashlytics.
///
/// [initialize] installs the global error handlers *before* it talks to
/// Firebase, so framework and uncaught asynchronous errors are never lost and
/// the app still launches when Firebase is not configured yet (e.g. no
/// `google-services.json` / `GoogleService-Info.plist` in the build). In that
/// case errors are reported to the console instead of the dashboard.
class CrashReporting {
  CrashReporting._();

  static final CrashReporting instance = CrashReporting._();

  /// Whether Crashlytics finished initializing and can accept reports.
  bool get isReady => _ready;

  /// Whether reports are collected at all (in-memory switch, see
  /// [setCollectionEnabled]). Starts enabled so crashes that happen before the
  /// stored consent preference has been read are still reported; callers turn
  /// collection off as soon as they know the user has not consented.
  bool get isEnabled => _enabled;

  bool _ready = false;
  bool _enabled = true;
  bool _handlersInstalled = false;
  FlutterExceptionHandler? _frameworkHandler;

  /// Installs global handlers and connects to Firebase Crashlytics.
  ///
  /// Safe to call more than once; only the first call does work.
  Future<void> initialize() async {
    if (_handlersInstalled) return;
    _handlersInstalled = true;

    // Keep the existing handlers so debug builds still log and show the red
    // error screen, then layer reporting on top.
    _frameworkHandler = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      _frameworkHandler?.call(details);
      unawaited(
        record(
          details.exception,
          details.stack,
          reason: details.context?.toDescription() ?? details.library,
          fatal: true,
        ),
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      unawaited(record(error, stack, fatal: true));
      // Marked as handled so an unexpected background error cannot take the
      // whole isolate down.
      return true;
    };

    // Crashlytics needs a native Firebase app; web builds skip it.
    if (kIsWeb) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        _enabled,
      );
      _ready = true;
      if (kDebugMode) {
        debugPrint('[crash] Crashlytics ready (debug build, collection $_enabled)');
      }
    } catch (error) {
      debugPrint(
        '[crash] Crashlytics unavailable, continuing without reporting: $error',
      );
    }
  }

  /// Reports [error] to Crashlytics. Never throws.
  Future<void> record(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
    Iterable<Object> information = const [],
  }) async {
    if (!_enabled) return;
    if (!_ready) {
      if (kDebugMode) {
        debugPrint('[crash] (not reported) ${reason ?? ''} $error');
      }
      return;
    }
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason,
        fatal: fatal,
        information: information,
        printDetails: false,
      );
    } catch (reportingError) {
      debugPrint('[crash] failed to record error: $reportingError');
    }
  }

  /// Adds a breadcrumb shown with the next crash report.
  Future<void> log(String message) async {
    if (!_ready || !_enabled) return;
    try {
      await FirebaseCrashlytics.instance.log(message);
    } catch (_) {
      // Logging must never affect the user's flow.
    }
  }

  /// Attaches the signed-in user id to crash reports.
  Future<void> setUserIdentifier(String? userId) async {
    if (!_ready) return;
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
    } catch (_) {
      // Best effort only.
    }
  }

  /// Toggles collection, e.g. when the user changes their data consent.
  Future<void> setCollectionEnabled(bool enabled) async {
    _enabled = enabled;
    if (!_ready) return;
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        enabled,
      );
    } catch (_) {
      // Best effort only.
    }
  }
}
