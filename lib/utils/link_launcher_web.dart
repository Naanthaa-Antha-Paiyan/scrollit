import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Web implementation that uses standard browser APIs (`window.open`).
///
/// This completely bypasses the `url_launcher` web plugin, which prevents
/// `MissingPluginException` if the web plugin registrant is cached incorrectly
/// by the build system. It also natively handles popup blocker contexts by 
/// running synchronously without async Dart gaps.
Future<void> launchWebOrNativeUrl(String url) async {
  try {
    web.window.open(url, '_blank');
  } catch (e) {
    debugPrint('Could not launch web url $url — $e');
  }
}
