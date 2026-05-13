# Changelog

All notable changes to CodeEdit are recorded here. The format loosely follows
[Keep a Changelog](https://keepachangelog.com/).

## Unreleased

### Added
- Find and replace panel (`ShowFind` / `ShowReplace`) with match-case, whole-word,
  and regex toggles, plus next/previous navigation and a result counter.
- Find panel seeds its initial search text from the editor's current selection
  when the selection is on a single line.
- Double-click selects the word at the click position using the same word-character
  rule as whole-word matching (letters, digits, underscore).
- Themed horizontal scrollbar mirroring the vertical one — track and thumb colors
  derive from the active theme, with a corner gap when both bars are visible.

### Changed
- `TCodeEditor` window now sets `WS_CLIPCHILDREN` so child controls (notably the
  search panel) are no longer overpainted by the editor's own `Paint`.
- Styled scrollbar colors now derive from the active theme (`GutterBackground`
  for the track, brightness-shifted for the thumb) instead of being hardcoded.
- `UpdateScrollBars` no longer calls `SetScrollInfo` while in styled mode, and
  explicitly hides the native scrollbars to prevent Windows from drawing an
  unthemed bar alongside the painted one.
- Editor is now `DoubleBuffered`, eliminating the flash between `FillRect` and
  the gutter/text/scrollbar paint passes during resize and scroll.
- Mouse wheel, `WM_VSCROLL`, `WM_HSCROLL`, styled-track clicks, and styled-thumb
  drags all early-exit without repainting when the clamped position is unchanged,
  so scrolling at the limit no longer triggers continuous redraws.

### Fixed
- Search edit no longer rings the system bell when `Enter` or `Esc` are pressed
  (the `WM_CHAR` is consumed in addition to the `WM_KEYDOWN` handler).
- Double-click selection is no longer wiped by the follow-up `MouseDown([ssDouble])`
  that resets the anchor — selection now happens after the caret has been moved.
- Last visible line is no longer covered by the horizontal scrollbar; line count
  derivation now uses `ClientTextRect.Height`.

## Initial commit

- `TCodeEditor` custom control with editable line storage, gutter, caret,
  selection, clipboard editing, scrolling, and pluggable highlighter.
- Highlighters for Delphi, JavaScript, and SQL.
- Completion provider model with `Ctrl+Space` / character-trigger popups.
- VCL-style theme integration via `ctmVclStyle` and `OnResolveTheme`.
