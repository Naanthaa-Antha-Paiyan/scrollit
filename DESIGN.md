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

## Typography Choices

- **System font stack.** The app uses the platform default sans-serif font (SF Pro on iOS, Roboto on Android, etc.). No custom fonts are loaded, keeping the bundle size small and ensuring native text rendering quality.
- **Font size range: 16–72+.** Start at 32 (comfortable for most screens). Max of 72+ allows for large displays or distant viewing.
- **Line height: 1.6.** Generous line spacing improves readability during auto-scroll, as the eye needs to track moving text.
- **Color: #FFFFFF on #000000.** Maximum contrast for teleprompter use. The black background also helps the teleprompter glass blend into the camera frame.

## Layout Decisions

### Reader Screen
- **Full-bleed black background.** No borders, no cards, no dividers — just text on black.
- **Horizontal padding slider (16–200px).** Users adjust the reading column width to match their teleprompter glass and lens framing.
- **Controls at bottom.** Sliders and toggles live in an overlay at the bottom of the screen, keeping them accessible but out of the reading area.
- **Fullscreen mode** strips everything — status bar, app bar, controls — leaving only the text.

### Script List
- **Card-based list** with title, word count, and relative time. Clean, scannable, minimal.
- **Popup menu** for rename/delete on each script to avoid permanent action buttons.
- **Empty state** with clear CTA when no scripts exist.

### Script Editor
- **Title at top, content below.** No rich text formatting. A plain text field that accepts paste input.
- **Unobtrusive save.** Save button in the app bar. No auto-save (user controls when to persist).

## Color Palette

| Role | Color | Hex |
|------|-------|-----|
| Reader background | Black | `#000000` |
| Reader text | White | `#FFFFFF` |
| Light background | Off-white | `#F8F9FA` |
| Dark background | Near-black | `#111111` |
| Primary text (light) | Dark navy | `#1A1A2E` |
| Secondary text | Grey | `shade400-500` |

## Future Design Improvements

- **Themed reading presets** — Allow users to save and switch between color/layout configurations (e.g., "Studio", "Outdoor", "Dark Room").
- **Reading progress indicator** — A subtle line or dot showing position in the script without distracting.
- **Landscape-first layout** — Optimize the UI for landscape orientation since teleprompters are typically landscape.
- **iPad multi-window support** — Side-by-side with a camera app or notes.
- **Script word count / estimated time** — Show reading duration at current speed.
- **Swipe gestures on reader** — Swipe left/right to switch between scripts without going back to the list.
