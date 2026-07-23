import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Whether the current browser supports the standard Fullscreen API.
/// Safari on iOS does NOT support `Element.requestFullscreen()` — this is
/// a deliberate Apple platform limitation, not a bug.
@JS('document.fullscreenEnabled')
external bool? get _fullscreenEnabled;

bool get _supportsFullscreen {
  try {
    return _fullscreenEnabled ?? false;
  } catch (_) {
    return false;
  }
}

/// Requests true browser fullscreen (hides the tab bar, address bar, etc.).
///
/// On iOS Safari this is a no-op because the Fullscreen API is not supported.
/// Users can still get a fullscreen-like experience by adding the app to
/// their home screen (uses the `apple-mobile-web-app-capable` meta tag).
void enterBrowserFullscreen() {
  if (!_supportsFullscreen) return;
  web.document.documentElement?.requestFullscreen().toDart.ignore();
}

/// Exits browser fullscreen mode.
void exitBrowserFullscreen() {
  if (!_supportsFullscreen) return;
  if (web.document.fullscreenElement != null) {
    web.document.exitFullscreen().toDart.ignore();
  }
}
