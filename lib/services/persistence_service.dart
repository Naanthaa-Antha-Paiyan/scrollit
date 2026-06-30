import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/scripts/models/script.dart';
import '../features/settings/models/app_settings.dart';
import '../features/settings/models/reader_enums.dart';

class PersistenceService {
  // ── Script keys ────────────────────────────────────────────────────
  static const _scriptsKey = 'scripts_metadata';
  static const _contentPrefix = 'script_content_';
  static const _positionPrefix = 'script_position_';
  static const _lastOpenedKey = 'last_opened_script';

  // ── Reader appearance keys (backward-compatible) ───────────────────
  static const _fontSizeKey = 'reader_font_size';
  static const _fontWeightKey = 'reader_font_weight';
  static const _horizontalPaddingKey = 'reader_horizontal_padding';
  static const _lineHeightKey = 'reader_line_height';
  static const _letterSpacingKey = 'reader_letter_spacing';
  static const _textColorKey = 'reader_text_color';
  static const _mirrorModeKey = 'reader_mirror_mode';
  static const _optimizationPresetKey = 'reader_optimization_preset';

  // ── Scrolling keys ─────────────────────────────────────────────────
  static const _scrollSpeedKey = 'reader_scroll_speed';
  static const _manualScrollStepKey = 'scroll_manual_step';
  static const _pageJumpSizeKey = 'scroll_page_jump';

  // ── Teleprompter keys ──────────────────────────────────────────────
  static const _ghostOverlayKey = 'reader_ghost_overlay';

  // ── Remote keys ────────────────────────────────────────────────────
  static const _showLastKeyKey = 'remote_show_last_key';
  static const _showDebugKey = 'remote_show_debug';

  final SharedPreferences _prefs;

  PersistenceService(this._prefs);

  // ═══════════════════════════════════════════════════════════════════
  // Scripts
  // ═══════════════════════════════════════════════════════════════════

  List<Script> loadScripts() {
    final json = _prefs.getString(_scriptsKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => Script.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveScripts(List<Script> scripts) async {
    final json = jsonEncode(scripts.map((s) => s.toJson()).toList());
    await _prefs.setString(_scriptsKey, json);
  }

  Future<void> saveScriptContent(String id, String content) async {
    await _prefs.setString('$_contentPrefix$id', content);
  }

  String loadScriptContent(String id) {
    return _prefs.getString('$_contentPrefix$id') ?? '';
  }

  Future<void> deleteScriptContent(String id) async {
    await _prefs.remove('$_contentPrefix$id');
    await _prefs.remove('$_positionPrefix$id');
  }

  Future<void> saveScriptPosition(String id, double position) async {
    await _prefs.setDouble('$_positionPrefix$id', position);
  }

  double loadScriptPosition(String id) {
    return _prefs.getDouble('$_positionPrefix$id') ?? 0.0;
  }

  String? getLastOpenedScript() {
    return _prefs.getString(_lastOpenedKey);
  }

  Future<void> setLastOpenedScript(String id) async {
    await _prefs.setString(_lastOpenedKey, id);
  }

  // ═══════════════════════════════════════════════════════════════════
  // App Settings
  // ═══════════════════════════════════════════════════════════════════

  /// Loads all app settings from SharedPreferences.
  ///
  /// Backward compatible: existing keys for fontSize, scrollSpeed,
  /// horizontalPadding, and mirrorMode are read as-is. New fields
  /// fall back to [AppSettings] defaults when absent.
  AppSettings loadAppSettings() {
    return AppSettings(
      // Reader appearance
      fontSize: _prefs.getDouble(_fontSizeKey) ?? 32.0,
      fontWeight: FontWeightOption.fromKey(_prefs.getString(_fontWeightKey)),
      horizontalPadding: _prefs.getDouble(_horizontalPaddingKey) ?? 48.0,
      lineHeight: _prefs.getDouble(_lineHeightKey) ?? 1.6,
      letterSpacing: _prefs.getDouble(_letterSpacingKey) ?? 0.0,
      textColor: TextColorOption.fromKey(_prefs.getString(_textColorKey)),
      mirrorMode: _prefs.getBool(_mirrorModeKey) ?? false,
      optimizationPreset: OptimizationPreset.fromKey(
        _prefs.getString(_optimizationPresetKey),
      ),
      // Scrolling
      scrollSpeed: _prefs.getDouble(_scrollSpeedKey) ?? 1.0,
      manualScrollStep: ManualScrollStep.fromKey(
        _prefs.getString(_manualScrollStepKey),
      ),
      pageJumpSize: PageJumpSize.fromKey(_prefs.getString(_pageJumpSizeKey)),
      // Teleprompter
      ghostReductionOverlay: _prefs.getBool(_ghostOverlayKey) ?? false,
      // Remote
      showLastKeyReceived: _prefs.getBool(_showLastKeyKey) ?? false,
      showRemoteDebugInfo: _prefs.getBool(_showDebugKey) ?? false,
    );
  }

  /// Persists all app settings to SharedPreferences.
  Future<void> saveAppSettings(AppSettings s) async {
    // Reader appearance
    await _prefs.setDouble(_fontSizeKey, s.fontSize);
    await _prefs.setString(_fontWeightKey, s.fontWeight.key);
    await _prefs.setDouble(_horizontalPaddingKey, s.horizontalPadding);
    await _prefs.setDouble(_lineHeightKey, s.lineHeight);
    await _prefs.setDouble(_letterSpacingKey, s.letterSpacing);
    await _prefs.setString(_textColorKey, s.textColor.key);
    await _prefs.setBool(_mirrorModeKey, s.mirrorMode);
    await _prefs.setString(_optimizationPresetKey, s.optimizationPreset.key);
    // Scrolling
    await _prefs.setDouble(_scrollSpeedKey, s.scrollSpeed);
    await _prefs.setString(_manualScrollStepKey, s.manualScrollStep.key);
    await _prefs.setString(_pageJumpSizeKey, s.pageJumpSize.key);
    // Teleprompter
    await _prefs.setBool(_ghostOverlayKey, s.ghostReductionOverlay);
    // Remote
    await _prefs.setBool(_showLastKeyKey, s.showLastKeyReceived);
    await _prefs.setBool(_showDebugKey, s.showRemoteDebugInfo);
  }
}
