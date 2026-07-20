/// Platform-agnostic fullscreen API.
///
/// On the web, delegates to `web_fullscreen_web.dart` which calls the browser
/// Fullscreen API. On all other platforms this is a no-op (system UI is handled
/// separately via `SystemChrome`).
export 'web_fullscreen_stub.dart'
    if (dart.library.js_interop) 'web_fullscreen_web.dart';
