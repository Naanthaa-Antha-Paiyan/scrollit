# Scrollit - Agent Guide

## Project Overview

Scrollit is a lightweight, privacy-first Flutter teleprompter app for creators using physical teleprompters and presentation remotes. It focuses solely on displaying and controlling text — no video, camera, internet, or accounts.

## Architecture Overview

```
lib/
  main.dart                          # Entry point, ProviderScope setup
  app/
    app.dart                         # MaterialApp with routing
    theme.dart                       # Light/dark theme definitions
  features/
    scripts/
      models/script.dart             # Script data model
      providers/scripts_provider.dart # StateNotifier + CRUD + persistence
      screens/
        script_list_screen.dart       # Home screen - script list
        script_editor_screen.dart     # Create/edit script screen
      widgets/script_tile.dart        # Script list item widget
    reader/
      models/reader_settings.dart     # Reader settings model with defaults
      providers/
        reader_provider.dart          # Auto-scroll, position, fullscreen state
        reader_settings_provider.dart # Font size, speed, padding, mirror
      screens/reader_screen.dart      # Primary teleprompter reader view
      widgets/reader_controls.dart    # Bottom control panel overlay
  services/
    persistence_service.dart          # SharedPreferences wrapper
```

### State Management

Riverpod is used throughout:
- `scriptsProvider` — `StateNotifierProvider<ScriptsNotifier, List<Script>>`
- `readerSettingsProvider` — `StateNotifierProvider<ReaderSettingsNotifier, ReaderSettings>`
- `readerProvider` — `StateNotifierProvider<ReaderNotifier, ReaderState>`

### Persistence

SharedPreferences stores:
- Script metadata (JSON list of id, title, timestamps)
- Script content (keyed by `script_content_{id}`)
- Scroll positions per script (keyed by `script_position_{id}`)
- Reader settings (individual keys for font size, speed, padding, mirror)
- Last opened script ID

## Important Implementation Decisions

1. **No camera/internet permissions** — The app has zero platform permissions beyond what Flutter requires by default. No `InternetPermission`, no `CAMERA`, no `RECORD_AUDIO`.

2. **Scroll position as ratio** — Position is stored as a 0.0–1.0 ratio rather than pixel offset, making it robust across font size and layout changes.

3. **Auto-scroll via Timer + jumpTo** — Uses `Timer.periodic(16ms)` with `ScrollController.jumpTo()` for smooth auto-scrolling. Each tick advances the position ratio by `speed * 0.3 / 100.0`. This is simpler and more controllable than AnimationController.

4. **Keyboard handling via Focus widget** — The reader screen uses `Focus.onKeyEvent` to intercept all keyboard and remote events. The `FocusNode` is always focused while the reader is visible.

5. **Presenter remote sequence detection** — Maintains a `Set<LogicalKeyboardKey>` of currently pressed keys. When all 5 keys (P, Meta, Alt, F5, Shift) are detected simultaneously, toggles fullscreen. Raw keyboard events from presenter remotes arrive as individual key events regardless of being pressed "simultaneously" on the hardware side.

6. **Mirror mode** — Uses `Transform` widget with a `Matrix4` that negates the X axis (`scaleX = -1`), mirroring text horizontally for teleprompter glass.

7. **Controls auto-hide** — After 4 seconds of inactivity, the control panel fades out (via a Timer in the provider). Tapping the screen or pressing any key shows it again.

8. **No pull-to-refresh, no animations** — The app avoids unnecessary visual flourishes. The reader is a black screen with white text.

## Known Limitations

- Script content stored in SharedPreferences (practical limit ~few MB per entry). For scripts exceeding ~100K words, a file-based storage approach would be needed.
- No search/filter for scripts.
- No text formatting (bold, italic, headings) — plain text only.
- Auto-scroll speed is global, not per-script.
- No word count or reading time estimation displayed.
- No undo for script edits or deletions.

## Future Roadmap

- File-based storage for very large scripts
- Script import/export (txt, docx)
- Multiple reading color themes
- Per-script auto-scroll speed
- Word count / estimated reading time
- Text-to-speech playback (offline TTS)
- Landscape-first layout optimization
- iPad multitasking support
- Configurable key bindings UI (currently hardcoded in `_handleKeyEvent`)
