# Scrollit

A lightweight, privacy-first teleprompter app for creators who use physical teleprompters and presentation remotes.

## Features

- **Script Management** — Create, edit, rename, and delete scripts
- **Reader Screen** — Distraction-free text display with black background and white text
- **Auto-Scroll** — Smooth adjustable-speed auto-scrolling
- **Manual Scroll** — Touch, mouse wheel, and trackpad support
- **Mirror Mode** — Horizontal text flip for teleprompter glass
- **Remote Control** — Full keyboard and presentation remote support
- **Fullscreen Mode** — Hide all chrome, show only text
- **Persistent Settings** — Font size, speed, padding, and position remembered per script

## Remote / Keyboard Controls

| Key | Action |
|-----|--------|
| Arrow Up / Down | Scroll up/down |
| Page Up / Down | Large jump up/down |
| Arrow Left / Right | Decrease/increase auto-scroll speed |
| B | Toggle auto-scroll |
| P + Win + Alt + F5 + Shift | Toggle fullscreen (presenter remote) |
| Esc | Exit fullscreen |

## Getting Started

```bash
flutter pub get
flutter run
```

## Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Tech Stack

- Flutter 3.44+
- Riverpod (state management)
- SharedPreferences (local persistence)
- No external APIs, no camera, no internet required

## Privacy

Scrollit requires:
- No internet permission
- No camera permission
- No storage permission
- No analytics
- No tracking
- No user accounts

The app works completely offline.

## License

MIT
