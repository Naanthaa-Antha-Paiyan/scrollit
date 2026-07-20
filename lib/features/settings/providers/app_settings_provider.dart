import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/analytics_service.dart';
import '../../../services/persistence_service.dart';
import '../../scripts/providers/scripts_provider.dart';
import '../models/app_settings.dart';
import '../models/reader_enums.dart';

/// Global provider for all app settings.
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final persistence = ref.read(persistenceServiceProvider);
  return AppSettingsNotifier(persistence);
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final PersistenceService _persistence;
  final AnalyticsService _analytics = AnalyticsService.instance;

  AppSettingsNotifier(this._persistence) : super(const AppSettings()) {
    _load();
  }

  void _load() {
    state = _persistence.loadAppSettings();
  }

  Future<void> _persist() async {
    await _persistence.saveAppSettings(state);
  }

  // ── Reader Appearance ──────────────────────────────────────────────

  Future<void> setFontSize(double value) async {
    state = state.copyWith(
      fontSize: value.clamp(AppSettings.minFontSize, AppSettings.maxFontSize),
    );
    await _persist();
    _analytics.logFontSizeChanged(state.fontSize);
  }

  Future<void> setFontWeight(FontWeightOption value) async {
    state = state.copyWith(fontWeight: value);
    await _persist();
    _analytics.logSettingChanged('font_weight', value.label);
  }

  Future<void> setHorizontalPadding(double value) async {
    state = state.copyWith(
      horizontalPadding: value.clamp(
        AppSettings.minHorizontalPadding,
        AppSettings.maxHorizontalPadding,
      ),
    );
    await _persist();
    _analytics.logSettingChanged(
        'horizontal_padding', state.horizontalPadding.round().toString());
  }

  Future<void> setLineHeight(double value) async {
    state = state.copyWith(
      lineHeight: value.clamp(
        AppSettings.minLineHeight,
        AppSettings.maxLineHeight,
      ),
    );
    await _persist();
    _analytics.logSettingChanged(
        'line_height', state.lineHeight.toStringAsFixed(1));
  }

  Future<void> setLetterSpacing(double value) async {
    state = state.copyWith(
      letterSpacing: value.clamp(
        AppSettings.minLetterSpacing,
        AppSettings.maxLetterSpacing,
      ),
    );
    await _persist();
    _analytics.logSettingChanged(
        'letter_spacing', state.letterSpacing.toStringAsFixed(1));
  }

  Future<void> setTextColor(TextColorOption value) async {
    state = state.copyWith(textColor: value);
    await _persist();
    _analytics.logSettingChanged('text_color', value.label);
  }

  Future<void> toggleMirrorMode() async {
    state = state.copyWith(mirrorMode: !state.mirrorMode);
    await _persist();
    if (state.mirrorMode) {
      _analytics.logMirrorModeEnabled();
    } else {
      _analytics.logMirrorModeDisabled();
    }
  }

  Future<void> setOptimizationPreset(OptimizationPreset value) async {
    state = state.copyWith(optimizationPreset: value);
    await _persist();
    _analytics.logSettingChanged('optimization_preset', value.label);
  }

  // ── Scrolling ──────────────────────────────────────────────────────

  Future<void> setScrollSpeed(double value) async {
    state = state.copyWith(
      scrollSpeed: value.clamp(
        AppSettings.minScrollSpeed,
        AppSettings.maxScrollSpeed,
      ),
    );
    await _persist();
    _analytics.logScrollSpeedChanged(state.scrollSpeed);
  }

  Future<void> setManualScrollStep(ManualScrollStep value) async {
    state = state.copyWith(manualScrollStep: value);
    await _persist();
    _analytics.logSettingChanged('manual_scroll_step', value.label);
  }

  Future<void> setPageJumpSize(PageJumpSize value) async {
    state = state.copyWith(pageJumpSize: value);
    await _persist();
    _analytics.logSettingChanged('page_jump_size', value.label);
  }

  // ── Teleprompter ───────────────────────────────────────────────────

  Future<void> toggleGhostReductionOverlay() async {
    state = state.copyWith(
      ghostReductionOverlay: !state.ghostReductionOverlay,
    );
    await _persist();
    _analytics.logSettingChanged(
        'ghost_reduction_overlay', state.ghostReductionOverlay.toString());
  }

  // ── Remote Control ─────────────────────────────────────────────────

  Future<void> toggleShowLastKeyReceived() async {
    state = state.copyWith(
      showLastKeyReceived: !state.showLastKeyReceived,
    );
    await _persist();
    _analytics.logSettingChanged(
        'show_last_key_received', state.showLastKeyReceived.toString());
  }

  Future<void> toggleShowRemoteDebugInfo() async {
    state = state.copyWith(
      showRemoteDebugInfo: !state.showRemoteDebugInfo,
    );
    await _persist();
    _analytics.logSettingChanged(
        'show_remote_debug_info', state.showRemoteDebugInfo.toString());
  }
}
