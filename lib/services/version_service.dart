import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Provides version information from a single source (pubspec.yaml).
///
/// Strips trailing `.0` from the semantic version for cleaner user-facing
/// display (e.g. `1.6.0` → `1.6`).
class VersionService {
  final String _version;
  final String _buildNumber;

  VersionService._(this._version, this._buildNumber);

  static Future<VersionService> init() async {
    final info = await PackageInfo.fromPlatform();
    return VersionService._(info.version, info.buildNumber);
  }

  /// Semantic version with trailing `.0` stripped (e.g. `1.6`).
  String get appVersion => _stripTrailingZero(_version);

  /// Build number string (e.g. `25`).
  String get buildNumber => _buildNumber;

  /// User-facing full version string (e.g. `v1.6+25`).
  String get fullVersion => 'v$appVersion+$buildNumber';

  /// Strips a single trailing `.0` from a version string.
  /// `1.6.0` → `1.6`, but `1.0.0` → `1.0`.
  String _stripTrailingZero(String version) {
    if (version.endsWith('.0')) {
      return version.substring(0, version.length - 2);
    }
    return version;
  }
}

/// Async provider for version information.
final versionServiceProvider = FutureProvider<VersionService>((ref) async {
  return VersionService.init();
});
