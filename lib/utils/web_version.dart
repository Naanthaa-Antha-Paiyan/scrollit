/// Platform-agnostic version.json reader.
///
/// On web, fetches the `version.json` file that Flutter auto-generates
/// from pubspec.yaml during `flutter build web`. On native platforms,
/// returns null (package_info_plus handles it).
export 'web_version_stub.dart'
    if (dart.library.js_interop) 'web_version_web.dart';
