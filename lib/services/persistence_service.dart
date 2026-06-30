import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/scripts/models/script.dart';
import '../features/reader/models/reader_settings.dart';

class PersistenceService {
  static const _scriptsKey = 'scripts_metadata';
  static const _contentPrefix = 'script_content_';
  static const _positionPrefix = 'script_position_';
  static const _lastOpenedKey = 'last_opened_script';
  static const _fontSizeKey = 'reader_font_size';
  static const _scrollSpeedKey = 'reader_scroll_speed';
  static const _horizontalPaddingKey = 'reader_horizontal_padding';
  static const _mirrorModeKey = 'reader_mirror_mode';

  final SharedPreferences _prefs;

  PersistenceService(this._prefs);

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

  ReaderSettings loadReaderSettings() {
    return ReaderSettings(
      fontSize: _prefs.getDouble(_fontSizeKey) ?? ReaderSettings.minFontSize + 16,
      scrollSpeed: _prefs.getDouble(_scrollSpeedKey) ?? 1.0,
      horizontalPadding:
          _prefs.getDouble(_horizontalPaddingKey) ?? 48.0,
      mirrorMode: _prefs.getBool(_mirrorModeKey) ?? false,
    );
  }

  Future<void> saveReaderSettings(ReaderSettings settings) async {
    await _prefs.setDouble(_fontSizeKey, settings.fontSize);
    await _prefs.setDouble(_scrollSpeedKey, settings.scrollSpeed);
    await _prefs.setDouble(
        _horizontalPaddingKey, settings.horizontalPadding);
    await _prefs.setBool(_mirrorModeKey, settings.mirrorMode);
  }
}
