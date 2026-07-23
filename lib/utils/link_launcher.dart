/// Platform-agnostic URL launcher.
///
/// On web, it uses standard JavaScript `window.open` to bypass `url_launcher` 
/// web plugin registration issues and strict popup blockers. 
/// On native platforms, it delegates to `url_launcher`'s `LaunchMode.externalApplication`.
export 'link_launcher_stub.dart'
    if (dart.library.js_interop) 'link_launcher_web.dart';
