# Scrollit - Agent Guide

## Project Overview

Scrollit is a lightweight, privacy-first Flutter teleprompter app for creators using physical teleprompters and presentation remotes. It focuses solely on displaying and controlling text — no video, camera, internet, or accounts.

## Architecture Overview

```
lib/
  main.dart                                    # Entry point, ProviderScope setup
  app/
    app.dart                                   # MaterialApp with routing
    home_shell.dart                            # Bottom navigation (Scripts / Settings)
    theme.dart                                 # Light/dark theme definitions
  features/
    scripts/
      models/script.dart                       # Script data model
      providers/scripts_provider.dart          # StateNotifier + CRUD + persistence
      screens/
        script_list_screen.dart                # Home tab — script list
        script_editor_screen.dart              # Create/edit script screen
      widgets/script_tile.dart                 # Script list item widget
    reader/
      providers/reader_provider.dart           # Auto-scroll, position, fullscreen state
      screens/reader_screen.dart               # Primary teleprompter reader view
      widgets/reader_controls.dart             # Bottom control panel overlay
    settings/
      models/
        app_settings.dart                      # Unified settings model (all settings)
        reader_enums.dart                      # Enums: FontWeight, TextColor, presets, etc.
      providers/app_settings_provider.dart     # Settings state + persistence
      screens/settings_screen.dart             # Settings UI (Reader, Scrolling, Teleprompter, Remote)
      widgets/
        color_picker_row.dart                  # Text color selection circles
        settings_section.dart                  # Card-based section wrapper
        settings_slider_tile.dart              # Reusable slider row
        settings_toggle_tile.dart              # Reusable switch row
  services/
    auto_scroll_service.dart                   # Timer-based auto-scroll engine
    persistence_service.dart                   # SharedPreferences wrapper
    presenter_remote_service.dart              # Keyboard/remote input handling
  shared/
    widgets/empty_state.dart                   # Empty state placeholder widget
```

### Navigation

The app uses a bottom `NavigationBar` with two tabs:

1. **Scripts** — Script list, create, edit, delete, open (primary tab)
2. **Settings** — Reader preferences, scrolling, teleprompter optimisation, remote control

`HomeShell` wraps both tabs in an `IndexedStack` to preserve state. Navigating to the reader or editor pushes a full-screen route on top of the shell.

### State Management

Riverpod is used throughout:
- `scriptsProvider` — `StateNotifierProvider<ScriptsNotifier, List<Script>>`
- `appSettingsProvider` — `StateNotifierProvider<AppSettingsNotifier, AppSettings>`
- `readerProvider` — `StateNotifierProvider<ReaderNotifier, ReaderState>`

### Settings Architecture

All settings are stored in a single immutable `AppSettings` class covering:

| Section | Fields |
|---------|--------|
| Reader Appearance | fontSize, fontWeight, horizontalPadding, lineHeight, letterSpacing, textColor, mirrorMode, optimizationPreset |
| Scrolling | scrollSpeed, manualScrollStep, pageJumpSize |
| Teleprompter | ghostReductionOverlay |
| Remote Control | showLastKeyReceived, showRemoteDebugInfo |

Enum-based settings use strongly-typed enums (in `reader_enums.dart`) with display labels and serialisation helpers. `AppSettings.resolvedTextStyle()` computes the final `TextStyle` by composing base appearance with optimisation preset overrides.

### Persistence

SharedPreferences stores:
- Script metadata (JSON list of id, title, timestamps)
- Script content (keyed by `script_content_{id}`)
- Scroll positions per script (keyed by `script_position_{id}`)
- Last opened script ID
- All app settings (individual keys, see `PersistenceService` for full list)

Existing keys (`reader_font_size`, `reader_scroll_speed`, `reader_horizontal_padding`, `reader_mirror_mode`) are backward compatible — old values are read seamlessly.

## Important Implementation Decisions

1. **No camera/internet permissions** — The app has zero platform permissions beyond what Flutter requires by default. No `InternetPermission`, no `CAMERA`, no `RECORD_AUDIO`.

2. **Scroll position as ratio** — Position is stored as a 0.0–1.0 ratio rather than pixel offset, making it robust across font size and layout changes.

3. **Auto-scroll via Timer + jumpTo** — Uses `Timer.periodic(16ms)` with `ScrollController.jumpTo()` for smooth auto-scrolling. Each tick advances the position ratio by `speed * 0.05 / 100.0`. This is simpler and more controllable than AnimationController.

4. **Keyboard handling via Focus widget** — The reader screen uses `Focus.onKeyEvent` to intercept all keyboard and remote events. The `FocusNode` is always focused while the reader is visible.

5. **Presenter remote sequence detection** — Maintains a `Set<LogicalKeyboardKey>` of currently pressed keys. When all 5 keys (P, Meta, Alt, F5, Shift) are detected simultaneously, toggles fullscreen. Raw keyboard events from presenter remotes arrive as individual key events regardless of being pressed "simultaneously" on the hardware side.

6. **Mirror mode** — Uses `Transform` widget with a `Matrix4` that negates the X axis (`scaleX = -1`), mirroring text horizontally for teleprompter glass.

7. **Controls auto-hide** — After 4 seconds of inactivity, the control panel fades out (via a Timer in the provider). Tapping the screen or pressing any key shows it again.

8. **No pull-to-refresh, no animations** — The app avoids unnecessary visual flourishes. The reader is a black screen with white text.

9. **Optimisation presets** — Four teleprompter presets (Standard, Bold, High Contrast, Ghost Reduction) modify the resolved text style centrally in `AppSettings.resolvedTextStyle()`, making them easy to tune without touching the UI.

10. **Configurable scroll/page step** — Manual scroll step (Small/Medium/Large) and page jump size (5%/10%/15%/20%) are read from `appSettingsProvider` instead of being hardcoded.

## Known Limitations

- Script content stored in SharedPreferences (practical limit ~few MB per entry). For scripts exceeding ~100K words, a file-based storage approach would be needed.
- No search/filter for scripts.
- No text formatting (bold, italic, headings) — plain text only.
- Auto-scroll speed is global, not per-script.
- No word count or reading time estimation displayed.
- No undo for script edits or deletions.
- Ghost reduction overlay toggle is a placeholder — no rendering changes yet.

## Future Roadmap

- File-based storage for very large scripts
- Script import/export (txt, docx)
- Custom fonts
- Per-script auto-scroll speed
- Word count / estimated reading time
- Text-to-speech playback (offline TTS)
- Landscape-first layout optimization
- iPad multitasking support
- Configurable key bindings UI (currently hardcoded in `_handleKeyEvent`)
- Reading ruler / confidence monitor
- Dual-screen mode
- Remote key mapping
