# Changelog

All notable changes to CodeEdit are recorded here. The format loosely follows
[Keep a Changelog](https://keepachangelog.com/).

## Unreleased

### Added
- Highlighters for Tungli script (`TTungliCodeHighlighter`), BAT/CMD
  (`TBatchCodeHighlighter`), PowerShell (`TPowerShellCodeHighlighter`),
  INI (`TIniCodeHighlighter`), YAML (`TYamlCodeHighlighter`), and Python
  (`TPythonCodeHighlighter`). All derive from `TCustomWordCodeHighlighter`
  and are registered on the `CodeEdit` palette page.
- Breakpoint support: click the gutter's breakpoint margin or press `F5` to
  toggle a breakpoint; `ToggleBreakpoint` / `AddBreakpoint` / `RemoveBreakpoint`
  / `ClearBreakpoints` / `HasBreakpoint` / `BreakpointLines` API and an
  `OnBreakpointsChanged` event for the host to interrogate them. Line numbers are
  1-based throughout, matching the gutter.
- Published `Breakpoints` collection (`TCodeBreakpoints` / `TCodeBreakpoint`,
  1-based `Line`) so breakpoints show in the Object Inspector and can be edited
  or pre-seeded at design time; design-time edits repaint the gutter immediately.
- `ExecutionLine` property (1-based; `-1` for none) that draws a current-statement
  arrow in the gutter and a highlight band across the line, and scrolls the line
  into view.
- Breakpoints (and the execution line) shift to follow line insertions and
  deletions; both are cleared when `Lines` is replaced or `Clear` is called.
- Find and replace panel (`ShowFind` / `ShowReplace`) with match-case, whole-word,
  and regex toggles, plus next/previous navigation and a result counter.
- Find panel seeds its initial search text from the editor's current selection
  when the selection is on a single line.
- Double-click selects the word at the click position using the same word-character
  rule as whole-word matching (letters, digits, underscore).
- Themed horizontal scrollbar mirroring the vertical one — track and thumb colors
  derive from the active theme, with a corner gap when both bars are visible.

- Optional minimap (`Options.ShowMinimap`) that paints a compact syntax-colored
  file map on the right, shows the visible viewport, and supports click/drag
  scrolling.
- `Options.MaxPasteBytes`, defaulting to 64 MB, to refuse oversized text pastes
  before `Clipboard.AsText` tries to materialize them.
- Script-editor integration basics: `ReadOnly`, `Modified`, public `Caret`,
  `TopLine`, `LeftColumn`, `ShowLine`, public `InsertText`, plus
  `OnCaretChange` and `OnSelectionChange`.
- Debugger line-marker surface: published `LineMarkers` collection,
  `AddLineMarker`, `RemoveLineMarker`, and `ClearLineMarkers`, with executable,
  error, warning, and info marker kinds that paint gutter glyphs and line
  background bands.
- Signature/parameter help via `TCustomCodeCompletionProvider.OnGetSignatureHelp`,
  `TCodeSignatureItems`, and `TriggerSignatureHelp`; the editor triggers it from
  `(` / `<`, updates the active parameter on comma, and supports
  `Ctrl+Shift+Space`.
- Editing ergonomics: `ToggleLineComment`, `CommentSelection`,
  `UncommentSelection`, `Options.LineCommentPrefix`, and lightweight bracket
  matching via `Options.BracketMatching`.

### Changed
- Minimap rendering now uses fixed-height mini rows and scrolls its content
  instead of stretching the whole file to fill the minimap height.
- Paste line splitting is now single-pass instead of repeatedly copying the
  remaining text while searching for line breaks.
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
