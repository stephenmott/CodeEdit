# Changelog

All notable changes to CodeEdit are recorded here. The format loosely follows
[Keep a Changelog](https://keepachangelog.com/).

## Unreleased

### Added
- User template layer: `TCodeTemplateProvider.UserTemplates` +
  `UserFileName` with `LoadUserTemplates` / `SaveUserTemplates`, merged into
  the Ctrl+J popup on top of the built-in `Templates` — a user template with
  the same name overrides the built-in one. The template editor dialog's
  `Execute(AProvider)` now edits the user layer (built-ins shown read-only;
  Duplicate creates an editable user copy that keeps the name, i.e. an
  override) and auto-saves to `UserFileName` on OK. JSON persistence moved
  down to `TCodeTemplates` (`LoadFromFile` / `SaveToFile` / streams); the
  provider-level methods still operate on the built-in layer.
- DevExpress skin bridge (`Source\CodeEdit.DevExpressTheme.pas`, not in the
  package): `ApplyDevExpressThemeToEditor` maps the active skin's palette
  onto the editor theme, and `TCodeEditorDevExpressTheme` keeps attached
  editors in sync with runtime skin changes.
- Code templates (Ctrl+J): new `CodeEdit.Templates` unit with a
  `TCodeTemplateProvider` component holding a published `Templates` collection
  (`Name`, `Description`, `Language`, `Code`). Assign it to the editor's new
  `TemplateProvider` property and `Ctrl+J` pops up the templates for the active
  highlighter's language (typing filters the list; Enter/Tab/double-click
  inserts, Esc dismisses). A word typed before `Ctrl+J` is used as a prefix —
  a unique match expands immediately, Delphi-IDE style. Inserted lines inherit
  the current line's indentation; `|` in the template body marks where the
  caret lands (`||` for a literal `|`). Also `TriggerTemplates` /
  `InsertTemplate` methods, an `eccTriggerTemplates` command, and JSON
  persistence via `LoadFromFile` / `SaveToFile` on the provider.
- Template editor dialog (`CodeEdit.TemplateEditorDlg`,
  `TCodeTemplateEditorDialog.Execute`) for end users to create, edit,
  duplicate, and delete templates, with per-language filtering and live
  syntax-highlighted editing of the template body. Wired up at design time as
  the `TCodeTemplateProvider` component editor ("Edit Templates...") — the
  package now requires `designide`.
- `TCustomCodeHighlighter.LanguageName` class function identifying each
  highlighter's language ('Delphi', 'SQL', ...); used to key templates and
  available for host apps.
- Zoom: published `Zoom` percentage property (25–400, default 100) with an
  `OnZoomChanged` event so hosts can adjust surrounding controls. Bound to
  `Ctrl+'+'` / `Ctrl+'-'` (main row and numpad), `Ctrl+0` to reset, and
  `Ctrl+mouse wheel`; `ZoomIn` / `ZoomOut` / `ZoomReset` methods for menus.
  Zoom scales the rendered font; the `Font` property itself is untouched.

## 0.2.0 — 2026-06-10

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
- Multi-line highlighting: new `TokenizeLineState` API with per-line range
  state and an `AddMultiLineRange` registry on `TCustomWordCodeHighlighter`.
  Delphi `{ }` / `(* *)`, JS `/* */` and template literals, SQL/Tungli
  `/* */`, PowerShell `<# #>`, and Python triple-quoted strings now span
  lines correctly. (`IsBlockCommentStart` / `ReadBlockComment` are replaced
  by `BuildMultiLineRanges`.)
- Keyboard: desired-column memory for vertical movement, `Ctrl+Left/Right`
  word navigation, `Ctrl+Home/End`, Tab indents multi-line selections,
  `Shift+Tab` unindents, `Ctrl+D` adds the next occurrence as a caret,
  `Ctrl+Shift+L` selects all occurrences, `F9` toggles breakpoints
  (alongside `F5`), and `Esc` closes the search panel from the editor.
- Public `IndentSelection` / `UnindentSelection` methods.
- Selected text is painted with `Theme.SelectionText` so selections stay
  readable on any palette.
- Component palette icons for all components, and a new ScrEdit sample.
- Console regression test for tokenizer state transitions
  (`Tests/TestHighlighterState.dpr`).
- API documentation under `docs/` (editor, highlighters, completion,
  breakpoints/markers) linked from a restructured README.

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
- Painting now resolves the theme once per paint instead of per line per
  helper, hoists the bracket-match scan and occurrence needle out of the
  per-line loop, and caches per-line tokens (shared with the minimap).
- `MaxLineLength` is cached behind a dirty flag and line changes no longer
  create a measuring bitmap, so large documents type smoothly.
- Search matching uses `PosEx` with a hoisted lowercase haystack; matches
  refresh live while the document is edited, and Replace advances to the
  next match instead of resetting to the first.
- Completion and signature popups hide on focus loss and scrolling, use
  `PopupParent` instead of process-wide `fsStayOnTop`, and the completion
  popup is borderless.
- Angle brackets are no longer treated as matchable brackets (every `<`
  comparison paired with an unrelated `>`).
- `Ctrl+C` / `Ctrl+X` are no-ops without a selection instead of clearing
  the clipboard.
- Tab characters render one cell wide so caret math stays aligned.
- The unimplemented `Options.WordWrap` property was removed.

### Fixed
- Search edit no longer rings the system bell when `Enter` or `Esc` are pressed
  (the `WM_CHAR` is consumed in addition to the `WM_KEYDOWN` handler).
- Double-click selection is no longer wiped by the follow-up `MouseDown([ssDouble])`
  that resets the anchor — selection now happens after the caret has been moved.
- Last visible line is no longer covered by the horizontal scrollbar; line count
  derivation now uses `ClientTextRect.Height`.
- Use-after-free on destroy: the active typing undo group was committed after
  the breakpoint/marker collections were freed.
- The completion popup form was never freed (memory leak).
- Freeing a highlighter or completion provider before the editor left a
  dangling reference (now handled via `FreeNotification`).
- Characters above U+00FF (Cyrillic, CJK, IME input) were silently dropped
  by `KeyPress`.
- Regex search results were off by one column (`TMatch.Index` is 1-based).
- Native scrollbar thumb-tracking was limited to 16-bit positions; now uses
  `SIF_TRACKPOS`.
- Undo restores the `Modified` flag to its pre-edit value.
- Repaired a duplicated, unterminated compiler-options block in
  `CodeEditVcl.dpk` that broke the package build.

## 0.1.0 — initial commit

- `TCodeEditor` custom control with editable line storage, gutter, caret,
  selection, clipboard editing, scrolling, and pluggable highlighter.
- Highlighters for Delphi, JavaScript, and SQL.
- Completion provider model with `Ctrl+Space` / character-trigger popups.
- VCL-style theme integration via `ctmVclStyle` and `OnResolveTheme`.
