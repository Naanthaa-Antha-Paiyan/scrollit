import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Reads version info from the `version.json` file that Flutter
/// auto-generates from pubspec.yaml during `flutter build web`.
///
/// Returns `{'version': '1.6.0', 'build_number': '25'}` on success,
/// or `null` if the file can't be read.
Future<Map<String, String>?> readWebVersionJson() async {
  try {
    final response = await web.window.fetch('version.json'.toJS).toDart;
    if (!response.ok) return null;

    final jsString = await response.text().toDart;
    final text = jsString.toDart;
    final data = jsonDecode(text) as Map<String, dynamic>;
    return {
      'version': data['version']?.toString() ?? '',
      'build_number': data['build_number']?.toString() ?? '',
    };
  } catch (_) {
    return null;
  }
}
