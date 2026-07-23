import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Native implementation that uses the `url_launcher` plugin
/// with `LaunchMode.externalApplication` to break out of in-app web views.
Future<void> launchWebOrNativeUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('Could not launch native url $url — $e');
  }
}
