import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'version_service.dart';

/// Centralized analytics service wrapping Firebase Analytics.
///
/// All analytics calls are wrapped in try-catch — failures are silently
/// logged to debug console but never impact app functionality.
class AnalyticsService {
  static AnalyticsService? _instance;
  FirebaseAnalytics? _analytics;
  bool _initialized = false;

  AnalyticsService._();

  /// Singleton accessor.
  static AnalyticsService get instance {
    _instance ??= AnalyticsService._();
    return _instance!;
  }

  /// Initialize analytics. Safe to call multiple times.
  Future<void> init() async {
    if (_initialized) return;
    try {
      _analytics = FirebaseAnalytics.instance;
      _initialized = true;
    } catch (e) {
      debugPrint('AnalyticsService: Failed to initialize — $e');
    }
  }

  /// Set version-related user properties on the analytics instance.
  Future<void> setVersionProperties(VersionService versionService) async {
    await _setUserProperty('app_version', versionService.appVersion);
    await _setUserProperty('build_number', versionService.buildNumber);
    await _setUserProperty('full_version', versionService.fullVersion);
  }

  // ── App Usage ────────────────────────────────────────────────────────

  Future<void> logAppOpened() => _logEvent('app_opened');

  Future<void> logSessionStarted() => _logEvent('session_started');

  Future<void> logReaderOpened({String? scriptId}) =>
      _logEvent('reader_opened', {'script_id': scriptId});

  Future<void> logReaderClosed({String? scriptId}) =>
      _logEvent('reader_closed', {'script_id': scriptId});

  // ── Reader Features ──────────────────────────────────────────────────

  Future<void> logMirrorModeEnabled() => _logEvent('mirror_mode_enabled');

  Future<void> logMirrorModeDisabled() => _logEvent('mirror_mode_disabled');

  Future<void> logAutoScrollStarted() => _logEvent('auto_scroll_started');

  Future<void> logAutoScrollStopped() => _logEvent('auto_scroll_stopped');

  Future<void> logManualScrollUsed() => _logEvent('manual_scroll_used');

  Future<void> logRemoteConnected() => _logEvent('remote_connected');

  Future<void> logRemoteDisconnected() => _logEvent('remote_disconnected');

  Future<void> logOrientationChanged(String orientation) =>
      _logEvent('orientation_changed', {'orientation': orientation});

  // ── Settings Changes ─────────────────────────────────────────────────

  Future<void> logScrollSpeedChanged(double speed) =>
      _logEvent('scroll_speed_changed', {'speed': speed});

  Future<void> logFontSizeChanged(double size) =>
      _logEvent('font_size_changed', {'size': size});

  Future<void> logThemeChanged(String theme) =>
      _logEvent('theme_changed', {'theme': theme});

  /// Generic settings change event for less common settings.
  Future<void> logSettingChanged(String setting, String value) =>
      _logEvent('setting_changed', {'setting': setting, 'value': value});

  // ── Private helpers ──────────────────────────────────────────────────

  Future<void> _logEvent(
    String name, [
    Map<String, Object?>? parameters,
  ]) async {
    if (!_initialized || _analytics == null) return;
    try {
      // Filter out null values from parameters.
      final filtered = parameters?.map((k, v) => MapEntry(k, v))
        ?..removeWhere((_, v) => v == null);

      await _analytics!.logEvent(
        name: name,
        parameters: filtered?.map(
          (k, v) => MapEntry(k, v as Object),
        ),
      );
    } catch (e) {
      debugPrint('AnalyticsService: Failed to log "$name" — $e');
    }
  }

  Future<void> _setUserProperty(String name, String value) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('AnalyticsService: Failed to set property "$name" — $e');
    }
  }
}
