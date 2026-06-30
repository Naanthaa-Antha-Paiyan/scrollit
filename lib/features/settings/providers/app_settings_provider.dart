import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  }

  Future<void> setFontWeight(FontWeightOption value) async {
    state = state.copyWith(fontWeight: value);
    await _persist();
  }

  Future<void> setHorizontalPadding(double value) async {
    state = state.copyWith(
      horizontalPadding: value.clamp(
        AppSettings.minHorizontalPadding,
        AppSettings.maxHorizontalPadding,
      ),
    );
    await _persist();
  }

  Future<void> setLineHeight(double value) async {
    state = state.copyWith(
      lineHeight: value.clamp(
        AppSettings.minLineHeight,
        AppSettings.maxLineHeight,
      ),
    );
    await _persist();
  }

  Future<void> setLetterSpacing(double value) async {
    state = state.copyWith(
      letterSpacing: value.clamp(
        AppSettings.minLetterSpacing,
        AppSettings.maxLetterSpacing,
      ),
    );
    await _persist();
  }

  Future<void> setTextColor(TextColorOption value) async {
    state = state.copyWith(textColor: value);
    await _persist();
  }

  Future<void> toggleMirrorMode() async {
    state = state.copyWith(mirrorMode: !state.mirrorMode);
    await _persist();
  }

  Future<void> setOptimizationPreset(OptimizationPreset value) async {
    state = state.copyWith(optimizationPreset: value);
    await _persist();
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
  }

  Future<void> setManualScrollStep(ManualScrollStep value) async {
    state = state.copyWith(manualScrollStep: value);
    await _persist();
  }

  Future<void> setPageJumpSize(PageJumpSize value) async {
    state = state.copyWith(pageJumpSize: value);
    await _persist();
  }

  // ── Teleprompter ───────────────────────────────────────────────────

  Future<void> toggleGhostReductionOverlay() async {
    state = state.copyWith(
      ghostReductionOverlay: !state.ghostReductionOverlay,
    );
    await _persist();
  }

  // ── Remote Control ─────────────────────────────────────────────────

  Future<void> toggleShowLastKeyReceived() async {
    state = state.copyWith(
      showLastKeyReceived: !state.showLastKeyReceived,
    );
    await _persist();
  }

  Future<void> toggleShowRemoteDebugInfo() async {
    state = state.copyWith(
      showRemoteDebugInfo: !state.showRemoteDebugInfo,
    );
    await _persist();
  }
}
