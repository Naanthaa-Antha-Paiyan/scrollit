# Scrollit - Design Guide

## Design Philosophy

Scrollit follows a "less is more" philosophy. The app exists to serve one function — displaying text under a teleprompter — and it does nothing else. Every pixel that isn't script text or an essential control is considered noise.

The aesthetic is inspired by:
- **Notion** — clean typography, generous whitespace, minimal chrome
- **Linear** — purposeful UI, no decorative elements, fast interactions
- **Todoist** — straightforward information hierarchy, excellent readability

## UX Principles

1. **The text is the interface.** In the reader, the script occupies 100% of available space. Controls appear only when summoned and auto-hide.

2. **Zero learning curve.** A creator should open the app, paste a script, tap play, and start reading. There are no onboarding flows, no tutorials, no configuration required to get started.

3. **Privacy first.** No data leaves the device. No accounts. No analytics. No tracking. The app works fully offline.

4. **Physical remote as first-class citizen.** Keyboard/remote input is not an afterthought — it's the primary interaction method while the teleprompter is in use. Touch is secondary for setup.

## Navigation

The app uses a two-tab bottom navigation bar:

| Tab | Icon | Purpose |
|-----|------|---------|
| Scripts | `description` | Script list, create, edit, delete, open scripts |
| Settings | `settings` | Reader preferences, scrolling, teleprompter, remote |

Scripts is the primary/home tab. An `IndexedStack` preserves state when switching between tabs. Navigating to the reader or script editor pushes a full-screen route on top of the navigation shell.

## Typography Choices

- **System font stack.** The app uses the platform default sans-serif font (SF Pro on iOS, Roboto on Android, etc.). No custom fonts are loaded, keeping the bundle size small and ensuring native text rendering quality.
- **Font size range: 16–96.** Start at 32 (comfortable for most screens). Max of 96 allows for large displays or distant viewing.
- **Font weight options:** Normal (w400), Medium (w500), Semi Bold (w600), Bold (w700), Extra Bold (w800). Configurable in settings.
- **Line height: 1.0–3.0, default 1.6.** Generous line spacing improves readability during auto-scroll.
- **Letter spacing: 0–5, default 0.** Adjustable for teleprompter readability.
- **Text color presets:** Pure White (#FFFFFF), Soft White (#F0F0F0), Light Gray (#DADADA), Warm White (#FFF4E8).
- **Background: #000000.** Maximum contrast for teleprompter use. The black background also helps the teleprompter glass blend into the camera frame.

## Layout Decisions

### Reader Screen
- **Full-bleed black background.** No borders, no cards, no dividers — just text on black.
- **Horizontal padding slider (0–100px).** Users adjust the reading column width to match their teleprompter glass and lens framing.
- **Controls at bottom.** Quick-adjust sliders (Size, Speed, Padding) and toggles (Auto, Mirror, Fullscreen) in an overlay at the bottom.
- **Fullscreen mode** strips everything — status bar, app bar, controls — leaving only the text.
- **Remote debug overlays** — Optional chips in the top-right showing last key, auto-scroll state, and speed for troubleshooting presentation remotes.
- **Text styling from settings** — Font size, weight, color, line height, letter spacing, and optimisation presets are all applied via `AppSettings.resolvedTextStyle()`.

### Script List
- **Card-based list** with title, word count, and relative time. Clean, scannable, minimal.
- **Popup menu** for rename/delete on each script to avoid permanent action buttons.
- **Empty state** with clear CTA when no scripts exist.

### Script Editor
- **Title at top, content below.** No rich text formatting. A plain text field that accepts paste input.
- **Unobtrusive save.** Save button in the app bar. No auto-save (user controls when to persist).

### Settings Screen
- **Card-based sections.** Four grouped sections: Reader, Scrolling, Teleprompter Optimisation, Remote Control.
- **Clean, minimal design.** Inspired by Linear/Notion — no cluttered Material settings. Each section is a card with a bold header and consistently spaced controls.
- **Segmented controls** for enum-based options (font weight, scroll step, page jump, preset).
- **Color circles** for text color selection with check indicator.
- **Sliders** for continuous values (font size, padding, line height, letter spacing, speed).
- **Switches** for toggles (mirror, ghost overlay, remote debug).
- **Persistence** — All settings survive app restart automatically.

## Teleprompter Optimisation Presets

| Preset | Behaviour |
|--------|-----------|
| Standard | No changes |
| Bold | Bumps font weight up by one step |
| High Contrast | Forces pure white text |
| Ghost Reduction | Semi-bold weight, soft white color, increased line height (+0.2), slight letter spacing (+0.5) |

Presets are composited centrally in `AppSettings.resolvedTextStyle()`, making them easy to tune without touching the UI.

## Color Palette

| Role | Color | Hex |
|------|-------|-----|
| Reader background | Black | `#000000` |
| Reader text (default) | White | `#FFFFFF` |
| Reader text (soft) | Soft White | `#F0F0F0` |
| Reader text (gray) | Light Gray | `#DADADA` |
| Reader text (warm) | Warm White | `#FFF4E8` |
| Light background | Off-white | `#F8F9FA` |
| Dark background | Near-black | `#111111` |
| Primary text (light) | Dark navy | `#1A1A2E` |
| Secondary text | Grey | `shade400-500` |

## Future Design Improvements

- **Custom fonts** — Allow users to load and select custom font families.
- **Themed reading presets** — Save and switch between color/layout configurations (e.g., "Studio", "Outdoor", "Dark Room").
- **Reading progress indicator** — A subtle line or dot showing position in the script without distracting.
- **Landscape-first layout** — Optimise the UI for landscape orientation since teleprompters are typically landscape.
- **iPad multi-window support** — Side-by-side with a camera app or notes.
- **Script word count / estimated time** — Show reading duration at current speed.
- **Swipe gestures on reader** — Swipe left/right to switch between scripts without going back to the list.
- **Reading ruler** — A horizontal guide line to help track the current reading position.
- **Confidence monitor** — Secondary display mode for the presenter.
- **Dual-screen mode** — Control screen + display screen.
