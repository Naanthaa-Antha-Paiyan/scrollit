import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Requests true browser fullscreen (hides the tab bar, address bar, etc.).
void enterBrowserFullscreen() {
  web.document.documentElement?.requestFullscreen().toDart.ignore();
}

/// Exits browser fullscreen mode.
void exitBrowserFullscreen() {
  if (web.document.fullscreenElement != null) {
    web.document.exitFullscreen().toDart.ignore();
  }
}
